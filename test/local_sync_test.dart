import 'package:flutter_test/flutter_test.dart';
import 'package:taxis_managment_001/core/network/sync/enums/sync_enums.dart';
import 'package:taxis_managment_001/core/network/sync/models/sync_payload_model.dart';
import 'package:taxis_managment_001/core/network/sync/models/sync_message_model.dart';
import 'package:taxis_managment_001/core/network/sync/repository/local_sync_repository.dart';
import 'package:taxis_managment_001/core/services/local_storage_service.dart';
import 'package:taxis_managment_001/core/shared/models/asset_model.dart';
import 'package:taxis_managment_001/core/shared/models/shareholder_model.dart';
import 'package:taxis_managment_001/core/shared/models/transaction_model.dart';
import 'package:taxis_managment_001/core/shared/models/sync_entry_model.dart';
import 'package:taxis_managment_001/core/shared/enums/app_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncPayloadModel & SyncMessageModel Tests', () {
    test('Serializes and deserializes SyncPayloadModel correctly', () {
      final payload = SyncPayloadModel.create(
        tableName: 'assets',
        action: SyncAction.insert,
        data: {
          'id': 'asset_100',
          'plateNumber': 'س أ د 9988',
          'monthlyRent': 7500.0,
        },
        recordId: 'asset_100',
      );

      final json = payload.toJson();
      final fromJson = SyncPayloadModel.fromJson(json);

      expect(fromJson.uuid, 'asset_100');
      expect(fromJson.tableName, 'assets');
      expect(fromJson.action, SyncAction.insert);
      expect(fromJson.data['plateNumber'], 'س أ د 9988');
      expect(fromJson.isDeleted, isFalse);
    });

    test('SyncMessageModel handles handshake and mutation envelopes', () {
      final handshake = SyncMessageModel.handshake(
        senderId: 'android_client_01',
        platform: 'android',
        clientVersion: '1.0.0',
      );

      final raw = handshake.toRawJson();
      final decoded = SyncMessageModel.fromRawJson(raw);

      expect(decoded.type, SyncMessageType.handshake);
      expect(decoded.senderId, 'android_client_01');
      expect(decoded.senderPlatform, 'android');

      final mutationMsg = SyncMessageModel.mutation(
        senderId: 'server_win',
        platform: 'windows',
        payload: SyncPayloadModel.create(
          tableName: 'shareholders',
          action: SyncAction.update,
          data: {'id': 'partner_5', 'name': 'علي حسن'},
        ),
      );

      final decodedMutation = SyncMessageModel.fromRawJson(
        mutationMsg.toRawJson(),
      );
      expect(decodedMutation.type, SyncMessageType.mutation);
      expect(decodedMutation.payload?.tableName, 'shareholders');
      expect(decodedMutation.payload?.data['name'], 'علي حسن');
    });

    test('SyncMessageModel handles batch full sync snapshot envelopes', () {
      final p1 = SyncPayloadModel.create(
        tableName: 'assets',
        action: SyncAction.update,
        data: {'id': 'a1'},
      );
      final p2 = SyncPayloadModel.create(
        tableName: 'shareholders',
        action: SyncAction.update,
        data: {'id': 's1'},
      );

      final batchMsg = SyncMessageModel.batchSync(
        senderId: 'server',
        platform: 'windows',
        payloads: [p1, p2],
        isFullSyncResponse: true,
      );

      final decoded = SyncMessageModel.fromRawJson(batchMsg.toRawJson());
      expect(decoded.type, SyncMessageType.fullSyncResponse);
      expect(decoded.batchPayloads?.length, 2);
      expect(decoded.batchPayloads?.first.tableName, 'assets');
      expect(decoded.batchPayloads?.last.tableName, 'shareholders');
    });
  });

  group('Last-Write-Wins (LWW) and Soft-Delete Tests', () {
    test('Newer timestamp wins over older timestamp', () {
      final olderTime = DateTime.utc(2026, 8, 18, 10, 0);
      final newerTime = DateTime.utc(2026, 8, 18, 12, 0);

      final newerPayload = SyncPayloadModel(
        uuid: 'rec_1',
        tableName: 'assets',
        action: SyncAction.update,
        data: {'name': 'Newer'},
        timestamp: newerTime,
      );

      expect(newerPayload.winsAgainst(olderTime), isTrue);

      final olderPayload = SyncPayloadModel(
        uuid: 'rec_1',
        tableName: 'assets',
        action: SyncAction.update,
        data: {'name': 'Older'},
        timestamp: olderTime,
      );

      expect(olderPayload.winsAgainst(newerTime), isFalse);
    });

    test('Soft-delete wins over equal or older update', () {
      final timeT1 = DateTime.utc(2026, 8, 18, 15, 0);

      final deletePayload = SyncPayloadModel(
        uuid: 'rec_del',
        tableName: 'assets',
        action: SyncAction.delete,
        data: {'id': 'rec_del'},
        timestamp: timeT1,
        isDeleted: true,
      );

      expect(deletePayload.winsAgainst(timeT1), isTrue);
    });
  });

  group('LocalSyncRepository Real Data Operations', () {
    test('Applies incoming single mutation to LocalStorageService', () {
      final storage = LocalStorageService();
      storage.clearAllData();
      final repo = LocalSyncRepository(storage);

      const newAsset = AssetModel(
        id: 'sync_test_asset',
        plateNumber: 'س أ د 7711',
        chassisNumber: 'VIN-SYNC-7711',
        carModelYear: 'BYD F3 2024',
        modelType: AssetType.fullTaxi,
        monthlyRent: 9500.0,
      );

      final payload = SyncPayloadModel.create(
        tableName: 'assets',
        action: SyncAction.insert,
        data: newAsset.toJson(),
        recordId: 'sync_test_asset',
      );

      final applied = repo.applyIncomingPayload(payload);
      expect(applied, isTrue);
      expect(storage.getAssets().length, 1);
      expect(storage.getAssets().first.plateNumber, 'س أ د 7711');
      expect(storage.getAssets().first.monthlyRent, 9500.0);
    });

    test('Applies atomic batch snapshot across all tables', () {
      final storage = LocalStorageService();
      storage.clearAllData();
      final repo = LocalSyncRepository(storage);

      const asset = AssetModel(
        id: 'batch_asset_1',
        plateNumber: 'ط ر ق 1122',
        chassisNumber: 'VIN-BATCH-1',
        carModelYear: 'Toyota Corolla 2023',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8000.0,
      );

      const partner = ShareholderModel(
        id: 'batch_partner_1',
        name: 'كابتن طارق الديب',
        phone: '01011112222',
      );

      final tx = TransactionRecord(
        id: 'batch_tx_1',
        assetId: 'batch_asset_1',
        assetPlateNumber: 'ط ر ق 1122',
        amount: 8000.0,
        type: TransactionType.rentIncome,
        category: 'تحصيل إيجار شهري',
        date: DateTime.now().toUtc(),
      );

      final batch = [
        SyncPayloadModel.create(
          tableName: 'assets',
          action: SyncAction.insert,
          data: asset.toJson(),
          recordId: asset.id,
        ),
        SyncPayloadModel.create(
          tableName: 'shareholders',
          action: SyncAction.insert,
          data: partner.toJson(),
          recordId: partner.id,
        ),
        SyncPayloadModel.create(
          tableName: 'transactions',
          action: SyncAction.insert,
          data: tx.toJson(),
          recordId: tx.id,
        ),
      ];

      repo.applyBatchSync(batch);

      expect(storage.getAssets().length, 1);
      expect(storage.getAssets().first.id, 'batch_asset_1');
      expect(storage.getShareholders().length, 1);
      expect(storage.getShareholders().first.name, 'كابتن طارق الديب');
      expect(storage.getTransactions().length, 1);
      expect(storage.getTransactions().first.amount, 8000.0);

      // Verify generateFullSnapshot
      final snapshot = repo.generateFullSnapshot();
      expect(snapshot.length, 3);
      expect(snapshot.any((s) => s.tableName == 'assets'), isTrue);
      expect(snapshot.any((s) => s.tableName == 'shareholders'), isTrue);
      expect(snapshot.any((s) => s.tableName == 'transactions'), isTrue);
    });

    test('Soft-delete in repository purges record and retains tombstone', () {
      final storage = LocalStorageService();
      storage.clearAllData();
      final repo = LocalSyncRepository(storage);

      const asset = AssetModel(
        id: 'asset_to_delete',
        plateNumber: 'س أ د 3344',
        chassisNumber: 'VIN-DEL',
        carModelYear: 'Nissan Sunny 2022',
        modelType: AssetType.fullTaxi,
        monthlyRent: 7000.0,
      );

      storage.addAsset(asset);
      expect(storage.getAssets().length, 1);

      final deletePayload = SyncPayloadModel(
        uuid: 'asset_to_delete',
        tableName: 'assets',
        action: SyncAction.delete,
        data: {'id': 'asset_to_delete'},
        timestamp: DateTime.now().toUtc(),
        isDeleted: true,
      );

      final deleted = repo.applyIncomingPayload(deletePayload);
      expect(deleted, isTrue);
      expect(storage.getAssets().isEmpty, isTrue);

      // Attempt an older update - must be dropped by tombstone
      final olderUpdate = SyncPayloadModel(
        uuid: 'asset_to_delete',
        tableName: 'assets',
        action: SyncAction.update,
        data: asset.toJson(),
        timestamp: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
      );

      final rejected = repo.applyIncomingPayload(olderUpdate);
      expect(rejected, isFalse);
      expect(storage.getAssets().isEmpty, isTrue); // Still deleted
    });
  });

  group('Reactive UI Auto-Update and Mutation Events Tests', () {
    test(
      'LocalStorageService emits dataChanges when assets/shareholders/batch are modified',
      () async {
        final storage = LocalStorageService();
        storage.clearAllData();

        int changeCount = 0;
        final sub = storage.dataChanges.listen((_) {
          changeCount++;
        });

        const asset = AssetModel(
          id: 'reactive_asset_1',
          plateNumber: 'س أ د 1234',
          chassisNumber: 'VIN-REACTIVE-1',
          carModelYear: 'BYD F3 2023',
          modelType: AssetType.fullTaxi,
          monthlyRent: 8500.0,
        );

        storage.addAsset(asset);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(changeCount, 1);

        storage.applySyncDeleteAsset('reactive_asset_1');
        await Future.delayed(const Duration(milliseconds: 10));
        expect(changeCount, 2);

        storage.applyBatchSnapshot(assets: [asset]);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(changeCount, 3);

        await sub.cancel();
      },
    );

    test(
      'LocalStorageService emits mutationEvents for local operations and not for applySync',
      () async {
        final storage = LocalStorageService();
        storage.clearAllData();

        final capturedMutations = <SyncQueueEntry>[];
        final sub = storage.mutationEvents.listen((entry) {
          capturedMutations.add(entry);
        });

        const asset = AssetModel(
          id: 'mutation_asset_1',
          plateNumber: 'س أ د 9999',
          chassisNumber: 'VIN-MUT-1',
          carModelYear: 'Chery Arrizo 5 2024',
          modelType: AssetType.fullTaxi,
          monthlyRent: 9000.0,
        );

        // Local addition -> should emit mutation
        storage.addAsset(asset);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(capturedMutations.length, 1);
        expect(capturedMutations.first.entityId, 'mutation_asset_1');
        expect(capturedMutations.first.operation, SyncOperationType.create);

        // Remote sync application -> must NOT emit outgoing mutation
        storage.applySyncAsset(asset.copyWith(monthlyRent: 9500.0));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(capturedMutations.length, 1); // Still 1

        await sub.cancel();
      },
    );
  });
}
