import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/models/asset_model.dart';
import '../../../shared/models/shareholder_model.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/archived_item_model.dart';
import '../../../services/local_storage_service.dart';
import '../enums/sync_enums.dart';
import '../models/sync_payload_model.dart';

class LocalSyncRepository {
  final LocalStorageService _storage;

  // In-memory tombstones registry: recordId -> deletion timestamp (for LWW soft delete protection)
  final Map<String, DateTime> _tombstones = {};

  final _syncEventController = StreamController<SyncPayloadModel>.broadcast();
  Stream<SyncPayloadModel> get syncEvents => _syncEventController.stream;

  LocalSyncRepository(this._storage);

  /// Applies a single incoming mutation payload using Last-Write-Wins (LWW) resolution
  bool applyIncomingPayload(SyncPayloadModel payload) {
    debugPrint('[LocalSyncRepository] Applying payload: ${payload.tableName} - ${payload.uuid} [${payload.action.name}] (time: ${payload.timestamp})');

    try {
      switch (payload.tableName) {
        case 'assets':
          return _applyAssetPayload(payload);

        case 'shareholders':
          return _applyShareholderPayload(payload);

        case 'transactions':
          return _applyTransactionPayload(payload);

        case 'archived':
          return _applyArchivedPayload(payload);

        default:
          debugPrint('[LocalSyncRepository] Unknown table name: ${payload.tableName}');
          return false;
      }
    } catch (e, stack) {
      debugPrint('[LocalSyncRepository] Failed to apply payload: $e\n$stack');
      return false;
    }
  }

  /// Batch sync resolver: atomically applies multiple records and updates storage in one pass
  void applyBatchSync(List<SyncPayloadModel> payloads) {
    if (payloads.isEmpty) return;
    debugPrint('[LocalSyncRepository] Processing atomic batch sync (${payloads.length} items)...');

    final currentAssets = Map<String, AssetModel>.fromEntries(_storage.getAssets().map((a) => MapEntry(a.id, a)));
    final currentShareholders = Map<String, ShareholderModel>.fromEntries(_storage.getShareholders().map((s) => MapEntry(s.id, s)));
    final currentTransactions = Map<String, TransactionRecord>.fromEntries(_storage.getTransactions().map((t) => MapEntry(t.id, t)));
    final currentArchived = Map<String, ArchivedItemModel>.fromEntries(_storage.getArchivedItems().map((a) => MapEntry(a.id, a)));

    bool hasAssetChanges = false;
    bool hasShareholderChanges = false;
    bool hasTransactionChanges = false;
    bool hasArchivedChanges = false;

    // Process each payload in the batch against in-memory maps
    for (final payload in payloads) {
      final id = payload.uuid;
      final isDelete = payload.isDeleted || payload.action == SyncAction.delete;

      // Check tombstone
      final tombstoneTime = _tombstones[id];
      if (tombstoneTime != null && !isDelete && (tombstoneTime.isAfter(payload.timestamp) || tombstoneTime.isAtSameMomentAs(payload.timestamp))) {
        // Drop update because item was deleted at a later or equal time
        continue;
      }

      switch (payload.tableName) {
        case 'assets':
          if (isDelete) {
            _tombstones[id] = payload.timestamp;
            if (currentAssets.containsKey(id)) {
              currentAssets.remove(id);
              hasAssetChanges = true;
            }
          } else {
            try {
              final model = AssetModel.fromJson(payload.data);
              currentAssets[model.id] = model;
              hasAssetChanges = true;
            } catch (e) {
              debugPrint('[LocalSyncRepository] Error parsing batch asset: $e');
            }
          }
          break;

        case 'shareholders':
          if (isDelete) {
            _tombstones[id] = payload.timestamp;
            if (currentShareholders.containsKey(id)) {
              currentShareholders.remove(id);
              hasShareholderChanges = true;
            }
          } else {
            try {
              final model = ShareholderModel.fromJson(payload.data);
              currentShareholders[model.id] = model;
              hasShareholderChanges = true;
            } catch (e) {
              debugPrint('[LocalSyncRepository] Error parsing batch shareholder: $e');
            }
          }
          break;

        case 'transactions':
          if (isDelete) {
            _tombstones[id] = payload.timestamp;
            if (currentTransactions.containsKey(id)) {
              currentTransactions.remove(id);
              hasTransactionChanges = true;
            }
          } else {
            try {
              final model = TransactionRecord.fromJson(payload.data);
              currentTransactions[model.id] = model;
              hasTransactionChanges = true;
            } catch (e) {
              debugPrint('[LocalSyncRepository] Error parsing batch transaction: $e');
            }
          }
          break;

        case 'archived':
          if (isDelete) {
            _tombstones[id] = payload.timestamp;
            if (currentArchived.containsKey(id)) {
              currentArchived.remove(id);
              hasArchivedChanges = true;
            }
          } else {
            try {
              final model = ArchivedItemModel.fromJson(payload.data);
              currentArchived[model.id] = model;
              hasArchivedChanges = true;
            } catch (e) {
              debugPrint('[LocalSyncRepository] Error parsing batch archived: $e');
            }
          }
          break;
      }
    }

    // Atomic persistence
    _storage.applyBatchSnapshot(
      assets: hasAssetChanges ? currentAssets.values.toList() : null,
      shareholders: hasShareholderChanges ? currentShareholders.values.toList() : null,
      transactions: hasTransactionChanges ? currentTransactions.values.toList() : null,
      archivedItems: hasArchivedChanges ? currentArchived.values.toList() : null,
    );

    debugPrint('[LocalSyncRepository] Batch sync applied successfully (Assets: ${currentAssets.length}, Shareholders: ${currentShareholders.length}, Transactions: ${currentTransactions.length})');
  }

  bool _applyAssetPayload(SyncPayloadModel payload) {
    final id = payload.uuid;
    final isDelete = payload.isDeleted || payload.action == SyncAction.delete;

    if (isDelete) {
      _tombstones[id] = payload.timestamp;
      _storage.deleteAsset(id);
      _syncEventController.add(payload);
      return true;
    }

    // Check tombstone
    final tombstoneTime = _tombstones[id];
    if (tombstoneTime != null && (tombstoneTime.isAfter(payload.timestamp) || tombstoneTime.isAtSameMomentAs(payload.timestamp))) {
      debugPrint('[LocalSyncRepository] Dropping asset update $id because tombstone is newer');
      return false;
    }

    final newAsset = AssetModel.fromJson(payload.data);
    final existingList = _storage.getAssets();
    final existingIndex = existingList.indexWhere((a) => a.id == newAsset.id);

    if (existingIndex != -1) {
      _storage.updateAsset(newAsset);
    } else {
      _storage.addAsset(newAsset);
    }

    _syncEventController.add(payload);
    return true;
  }

  bool _applyShareholderPayload(SyncPayloadModel payload) {
    final id = payload.uuid;
    final isDelete = payload.isDeleted || payload.action == SyncAction.delete;

    if (isDelete) {
      _tombstones[id] = payload.timestamp;
      _storage.deleteShareholder(id);
      _syncEventController.add(payload);
      return true;
    }

    final tombstoneTime = _tombstones[id];
    if (tombstoneTime != null && (tombstoneTime.isAfter(payload.timestamp) || tombstoneTime.isAtSameMomentAs(payload.timestamp))) {
      debugPrint('[LocalSyncRepository] Dropping shareholder update $id because tombstone is newer');
      return false;
    }

    final newPartner = ShareholderModel.fromJson(payload.data);
    final existingList = _storage.getShareholders();
    final existingIndex = existingList.indexWhere((s) => s.id == newPartner.id);

    if (existingIndex != -1) {
      _storage.updateShareholder(newPartner);
    } else {
      _storage.addShareholder(newPartner);
    }

    _syncEventController.add(payload);
    return true;
  }

  bool _applyTransactionPayload(SyncPayloadModel payload) {
    final id = payload.uuid;
    final isDelete = payload.isDeleted || payload.action == SyncAction.delete;

    if (isDelete) {
      _tombstones[id] = payload.timestamp;
      _storage.deleteTransaction(id);
      _syncEventController.add(payload);
      return true;
    }

    final tombstoneTime = _tombstones[id];
    if (tombstoneTime != null && (tombstoneTime.isAfter(payload.timestamp) || tombstoneTime.isAtSameMomentAs(payload.timestamp))) {
      debugPrint('[LocalSyncRepository] Dropping transaction update $id because tombstone is newer');
      return false;
    }

    final newTx = TransactionRecord.fromJson(payload.data);
    final existingList = _storage.getTransactions();
    final existingIndex = existingList.indexWhere((t) => t.id == newTx.id);

    if (existingIndex != -1) {
      _storage.updateTransaction(newTx);
    } else {
      _storage.addTransaction(newTx);
    }

    _syncEventController.add(payload);
    return true;
  }

  bool _applyArchivedPayload(SyncPayloadModel payload) {
    final id = payload.uuid;
    final isDelete = payload.isDeleted || payload.action == SyncAction.delete;

    if (isDelete) {
      _tombstones[id] = payload.timestamp;
      _storage.deleteArchivedItem(id);
      _syncEventController.add(payload);
      return true;
    }

    final tombstoneTime = _tombstones[id];
    if (tombstoneTime != null && (tombstoneTime.isAfter(payload.timestamp) || tombstoneTime.isAtSameMomentAs(payload.timestamp))) {
      return false;
    }

    final newArch = ArchivedItemModel.fromJson(payload.data);
    _storage.addArchivedItem(newArch);
    _syncEventController.add(payload);
    return true;
  }

  /// Generates a full snapshot payload list of the entire database
  List<SyncPayloadModel> generateFullSnapshot() {
    final list = <SyncPayloadModel>[];
    final now = DateTime.now().toUtc();

    for (final a in _storage.getAssets()) {
      list.add(SyncPayloadModel(
        uuid: a.id,
        tableName: 'assets',
        action: SyncAction.update,
        data: a.toJson(),
        timestamp: now,
      ));
    }

    for (final s in _storage.getShareholders()) {
      list.add(SyncPayloadModel(
        uuid: s.id,
        tableName: 'shareholders',
        action: SyncAction.update,
        data: s.toJson(),
        timestamp: now,
      ));
    }

    for (final t in _storage.getTransactions()) {
      list.add(SyncPayloadModel(
        uuid: t.id,
        tableName: 'transactions',
        action: SyncAction.update,
        data: t.toJson(),
        timestamp: now,
      ));
    }

    for (final arch in _storage.getArchivedItems()) {
      list.add(SyncPayloadModel(
        uuid: arch.id,
        tableName: 'archived',
        action: SyncAction.update,
        data: arch.toJson(),
        timestamp: now,
      ));
    }

    return list;
  }

  /// Disposes repository streams
  Future<void> dispose() async {
    await _syncEventController.close();
  }
}
