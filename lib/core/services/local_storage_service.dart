import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/asset_model.dart';
import '../shared/models/shareholder_model.dart';
import '../shared/models/transaction_model.dart';
import '../shared/models/alert_item_model.dart';
import '../shared/models/document_meta_model.dart';
import '../shared/models/archived_item_model.dart';
import '../shared/models/user_model.dart';
import '../shared/models/sync_entry_model.dart';
import '../shared/enums/app_enums.dart';

class LocalStorageService {
  static const String _keyAssets = 'taxi_app_assets_v2';
  static const String _keyShareholders = 'taxi_app_shareholders_v2';
  static const String _keyTransactions = 'taxi_app_transactions_v2';
  static const String _keyArchived = 'taxi_app_archived_v2';
  static const String _keyUser = 'taxi_app_user_v2';
  static const String _keySyncQueue = 'taxi_app_sync_queue_v2';
  static const String _keyLastSync = 'taxi_app_last_sync_v2';
  static const String _keyThemeMode = 'taxi_app_theme_mode_v2';
  static const String _keyLocale = 'taxi_app_locale_v2';
  static const String _keyBiometric = 'taxi_app_biometric_v2';
  static const String _keyAutoLock = 'taxi_app_auto_lock_v2';
  static const String _keyRequirePin = 'taxi_app_require_pin_v2';
  static const String _keyPinCode = 'taxi_app_pin_code_v2';
  static const String _keyLockTimeout = 'taxi_app_lock_timeout_v2';
  static const String _keySetupCompleted = 'taxi_app_setup_completed_v2';

  SharedPreferences? _prefs;

  List<AssetModel> _assets = [];
  List<ShareholderModel> _shareholders = [];
  List<TransactionRecord> _transactions = [];
  List<AlertItem> _alerts = [];
  List<ArchivedItemModel> _archivedItems = [];
  List<SyncQueueEntry> _syncQueue = [];
  UserModel? _currentUser;
  DateTime? _lastSyncTime;

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('ar', 'EG');

  bool _biometricEnabled = true;
  bool _autoLockEnabled = true;
  bool _requirePinForTransactions = true;
  String _pinCode = '1234';
  int _lockTimeoutMinutes = 1;
  bool _isSetupCompleted = false;

  final StreamController<void> _dataChangesController = StreamController<void>.broadcast();
  Stream<void> get dataChanges => _dataChangesController.stream;

  final StreamController<SyncQueueEntry> _mutationEventsController = StreamController<SyncQueueEntry>.broadcast();
  Stream<SyncQueueEntry> get mutationEvents => _mutationEventsController.stream;

  void _notifyDataChanged() {
    if (!_dataChangesController.isClosed) {
      _dataChangesController.add(null);
    }
  }

  LocalStorageService() {
    _assets = [];
    _shareholders = [];
    _transactions = [];
    _archivedItems = [];
    _alerts = [];
    _syncQueue = [];
  }

  /// Initializes asynchronous local storage from disk (SharedPreferences)
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadFromDisk();
    } catch (e) {
      debugPrint('LocalStorageService init warning: $e');
    }
  }

  void _loadFromDisk() {
    if (_prefs == null) return;

    // 1. User
    final userStr = _prefs!.getString(_keyUser);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userStr) as Map<String, dynamic>);
      } catch (_) {
        _currentUser = null;
      }
    } else {
      _currentUser = null;
    }

    // 2. Assets
    final assetsStr = _prefs!.getString(_keyAssets);
    if (assetsStr != null && assetsStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(assetsStr) as List<dynamic>;
        _assets = list.map((e) => AssetModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _assets = [];
      }
    } else {
      _assets = [];
    }

    // 3. Shareholders
    final partnersStr = _prefs!.getString(_keyShareholders);
    if (partnersStr != null && partnersStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(partnersStr) as List<dynamic>;
        _shareholders = list.map((e) => ShareholderModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _shareholders = [];
      }
    } else {
      _shareholders = [];
    }

    // 4. Transactions
    final txStr = _prefs!.getString(_keyTransactions);
    if (txStr != null && txStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(txStr) as List<dynamic>;
        _transactions = list.map((e) => TransactionRecord.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _transactions = [];
      }
    } else {
      _transactions = [];
    }

    // 5. Archived Items
    final archStr = _prefs!.getString(_keyArchived);
    if (archStr != null && archStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(archStr) as List<dynamic>;
        _archivedItems = list.map((e) => ArchivedItemModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _archivedItems = [];
      }
    } else {
      _archivedItems = [];
    }

    // 6. Sync Queue
    final queueStr = _prefs!.getString(_keySyncQueue);
    if (queueStr != null && queueStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(queueStr) as List<dynamic>;
        _syncQueue = list.map((e) => SyncQueueEntry.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _syncQueue = [];
      }
    } else {
      _syncQueue = [];
    }

    // 7. Last Sync Time
    final lastSyncStr = _prefs!.getString(_keyLastSync);
    if (lastSyncStr != null && lastSyncStr.isNotEmpty) {
      _lastSyncTime = DateTime.tryParse(lastSyncStr);
    }

    // 8. Theme & Locale
    final themeStr = _prefs!.getString(_keyThemeMode);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere((m) => m.name == themeStr, orElse: () => ThemeMode.light);
    }
    final localeStr = _prefs!.getString(_keyLocale);
    if (localeStr != null) {
      _locale = Locale(localeStr);
    }

    // 9. Security Settings
    _biometricEnabled = _prefs!.getBool(_keyBiometric) ?? true;
    _autoLockEnabled = _prefs!.getBool(_keyAutoLock) ?? true;
    _requirePinForTransactions = _prefs!.getBool(_keyRequirePin) ?? true;
    _pinCode = _prefs!.getString(_keyPinCode) ?? '1234';
    _lockTimeoutMinutes = _prefs!.getInt(_keyLockTimeout) ?? 1;
    _isSetupCompleted = _prefs!.getBool(_keySetupCompleted) ?? false;
  }

  // ================= ASSETS OPERATIONS =================
  List<AssetModel> getAssets() => List.unmodifiable(_assets);

  void addAsset(AssetModel asset) {
    _assets.insert(0, asset);
    _persistAssets();
    _queueMutation(SyncEntityType.asset, SyncOperationType.create, asset.id, asset.toJson());
  }

  void updateAsset(AssetModel asset) {
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
      _persistAssets();
      _queueMutation(SyncEntityType.asset, SyncOperationType.update, asset.id, asset.toJson());
    }
  }

  void deleteAsset(String assetId) {
    _assets.removeWhere((a) => a.id == assetId);
    _persistAssets();
    _queueMutation(SyncEntityType.asset, SyncOperationType.delete, assetId, null);
  }

  void addDocumentToAsset(String assetId, DocumentMeta document) {
    final index = _assets.indexWhere((a) => a.id == assetId);
    if (index != -1) {
      final currentAsset = _assets[index];
      final updatedDocs = List<DocumentMeta>.from(currentAsset.documents)..add(document);
      _assets[index] = currentAsset.copyWith(documents: updatedDocs);
      _persistAssets();
      _queueMutation(SyncEntityType.asset, SyncOperationType.update, assetId, _assets[index].toJson());
    }
  }

  // ================= ARCHIVE OPERATIONS =================
  List<ArchivedItemModel> getArchivedItems() => List.unmodifiable(_archivedItems);

  void archiveAsset(AssetModel asset, {String? reason}) {
    // 1. Remove from active assets
    _assets.removeWhere((a) => a.id == asset.id);
    _persistAssets();
    _queueMutation(SyncEntityType.asset, SyncOperationType.delete, asset.id, null);

    // 2. Create and add to archive
    final archivedItem = ArchivedItemModel(
      id: 'arch_${DateTime.now().millisecondsSinceEpoch}',
      category: ArchiveCategory.soldAssets,
      title: '${asset.carModelYear} (${asset.plateNumber})',
      subtitle: reason ?? (asset.driverOrRenterName.isNotEmpty
          ? 'السائق: ${asset.driverOrRenterName}'
          : 'تم نقل الأصل إلى الأرشيف'),
      date: DateTime.now(),
      tag: 'مؤرشف',
      metaInfo: 'القيمة التقديرية: ${asset.assetValuation > 0 ? asset.assetValuation.toInt() : (asset.monthlyRent * 12).toInt()} ج.م',
      originalAsset: asset,
    );

    _archivedItems.insert(0, archivedItem);
    _persistArchivedItems();
    _queueMutation(SyncEntityType.archivedItem, SyncOperationType.create, archivedItem.id, archivedItem.toJson());
  }

  void archiveShareholder(ShareholderModel shareholder, {String? reason}) {
    // 1. Fetch matching transactions history for this shareholder
    final matchingTx = _transactions.where(
      (t) => t.partnerId == shareholder.id || (t.partnerName != null && t.partnerName == shareholder.name),
    ).toList();

    // 2. Remove from active shareholders
    _shareholders.removeWhere((s) => s.id == shareholder.id);
    _persistShareholders();
    _queueMutation(SyncEntityType.shareholder, SyncOperationType.delete, shareholder.id, null);

    // 3. Create and add to archive with all data, documents, and transaction history
    final archivedItem = ArchivedItemModel(
      id: 'arch_sh_${DateTime.now().millisecondsSinceEpoch}',
      category: ArchiveCategory.archivedShareholders,
      title: 'المساهم: ${shareholder.name}',
      subtitle: reason ?? 'الهاتف: ${shareholder.phone} • ${shareholder.documents.length} مستندات • ${matchingTx.length} معاملات مسجلة',
      date: DateTime.now(),
      tag: 'مساهم مؤرشف',
      metaInfo: '${shareholder.documents.length} مستندات مرفقة | ${matchingTx.length} معاملة مالية مسجلة',
      originalShareholder: shareholder,
      shareholderTransactions: matchingTx,
    );

    _archivedItems.insert(0, archivedItem);
    _persistArchivedItems();
    _queueMutation(SyncEntityType.archivedItem, SyncOperationType.create, archivedItem.id, archivedItem.toJson());
  }

  bool restoreArchivedAsset(String archiveId) {
    final index = _archivedItems.indexWhere((item) => item.id == archiveId);
    if (index != -1) {
      final archivedItem = _archivedItems[index];
      if (archivedItem.originalAsset != null) {
        _assets.insert(0, archivedItem.originalAsset!);
        _persistAssets();
        _queueMutation(SyncEntityType.asset, SyncOperationType.create, archivedItem.originalAsset!.id, archivedItem.originalAsset!.toJson());
      }
      _archivedItems.removeAt(index);
      _persistArchivedItems();
      _queueMutation(SyncEntityType.archivedItem, SyncOperationType.delete, archiveId, null);
      return true;
    }
    return false;
  }

  bool restoreArchivedShareholder(String archiveId) {
    final index = _archivedItems.indexWhere((item) => item.id == archiveId);
    if (index != -1) {
      final archivedItem = _archivedItems[index];
      if (archivedItem.originalShareholder != null) {
        _shareholders.insert(0, archivedItem.originalShareholder!);
        _persistShareholders();
        _queueMutation(SyncEntityType.shareholder, SyncOperationType.create, archivedItem.originalShareholder!.id, archivedItem.originalShareholder!.toJson());
      }
      _archivedItems.removeAt(index);
      _persistArchivedItems();
      _queueMutation(SyncEntityType.archivedItem, SyncOperationType.delete, archiveId, null);
      return true;
    }
    return false;
  }

  bool restoreArchivedItem(String archiveId) {
    final index = _archivedItems.indexWhere((item) => item.id == archiveId);
    if (index != -1) {
      final archivedItem = _archivedItems[index];
      if (archivedItem.category == ArchiveCategory.archivedShareholders || archivedItem.originalShareholder != null) {
        return restoreArchivedShareholder(archiveId);
      } else {
        return restoreArchivedAsset(archiveId);
      }
    }
    return false;
  }

  void deleteArchivedPermanently(String archiveId) {
    _archivedItems.removeWhere((item) => item.id == archiveId);
    _persistArchivedItems();
    _queueMutation(SyncEntityType.archivedItem, SyncOperationType.delete, archiveId, null);
  }

  void addArchivedItem(ArchivedItemModel item) {
    _archivedItems.insert(0, item);
    _persistArchivedItems();
    _queueMutation(SyncEntityType.archivedItem, SyncOperationType.create, item.id, item.toJson());
  }

  void deleteArchivedItem(String archiveId) {
    deleteArchivedPermanently(archiveId);
  }

  // ================= SHAREHOLDERS OPERATIONS =================
  List<ShareholderModel> getShareholders() => List.unmodifiable(_shareholders);

  void addShareholder(ShareholderModel shareholder) {
    _shareholders.insert(0, shareholder);
    _persistShareholders();
    _queueMutation(SyncEntityType.shareholder, SyncOperationType.create, shareholder.id, shareholder.toJson());
  }

  void updateShareholder(ShareholderModel shareholder) {
    final index = _shareholders.indexWhere((s) => s.id == shareholder.id);
    if (index != -1) {
      _shareholders[index] = shareholder;
      _persistShareholders();
      _queueMutation(SyncEntityType.shareholder, SyncOperationType.update, shareholder.id, shareholder.toJson());
    }
  }

  void deleteShareholder(String shareholderId) {
    _shareholders.removeWhere((s) => s.id == shareholderId);
    _persistShareholders();
    _queueMutation(SyncEntityType.shareholder, SyncOperationType.delete, shareholderId, null);
  }

  // ================= TRANSACTIONS OPERATIONS =================
  List<TransactionRecord> getTransactions() => List.unmodifiable(_transactions);

  void addTransaction(TransactionRecord transaction) {
    _transactions.insert(0, transaction);
    _persistTransactions();
    _queueMutation(SyncEntityType.transaction, SyncOperationType.create, transaction.id, transaction.toJson());
  }

  void updateTransaction(TransactionRecord transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _persistTransactions();
      _queueMutation(SyncEntityType.transaction, SyncOperationType.update, transaction.id, transaction.toJson());
    }
  }

  void deleteTransaction(String transactionId) {
    _transactions.removeWhere((t) => t.id == transactionId);
    _persistTransactions();
    _queueMutation(SyncEntityType.transaction, SyncOperationType.delete, transactionId, null);
  }

  // ================= ALERTS OPERATIONS =================
  List<AlertItem> getAlerts() {
    final dynamicAlerts = <AlertItem>[];

    for (final asset in _assets) {
      // 1. License expiring alert (if <= 30 days)
      if (asset.licenseExpiryDate != null) {
        final daysLeft = asset.licenseExpiryDate!.difference(DateTime.now()).inDays;
        if (daysLeft >= 0 && daysLeft <= 30) {
          dynamicAlerts.add(
            AlertItem(
              id: 'dyn_lic_${asset.id}',
              title: 'تجديد رخصة تسيير',
              subtitle: 'ينتهي ترخيص ${asset.carModelYear} (${asset.plateNumber}) خلال $daysLeft يوم',
              type: AlertType.licenseExpiry,
              priority: daysLeft <= 7 ? AlertPriority.high : AlertPriority.info,
              date: asset.licenseExpiryDate!,
              assetId: asset.id,
              plateNumber: asset.plateNumber,
            ),
          );
        }
      }

      // 2. Contract expiring alert (if <= 15 days)
      if (asset.contractExpiryDate != null) {
        final daysLeft = asset.contractExpiryDate!.difference(DateTime.now()).inDays;
        if (daysLeft >= 0 && daysLeft <= 15) {
          dynamicAlerts.add(
            AlertItem(
              id: 'dyn_cont_${asset.id}',
              title: 'تجديد عقد الإيجار',
              subtitle: 'ينتهي عقد السائق ${asset.driverOrRenterName} لسيارة (${asset.plateNumber}) خلال $daysLeft يوم',
              type: AlertType.rentDue,
              priority: AlertPriority.high,
              date: asset.contractExpiryDate!,
              assetId: asset.id,
              plateNumber: asset.plateNumber,
            ),
          );
        }
      }
    }

    final all = List<AlertItem>.from(_alerts);
    for (final dyn in dynamicAlerts) {
      if (!all.any((a) => a.id == dyn.id || (a.assetId == dyn.assetId && a.type == dyn.type))) {
        all.add(dyn);
      }
    }

    return List.unmodifiable(all);
  }

  void dismissAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
  }

  // ================= USER & AUTH OPERATIONS =================
  UserModel? getCurrentUser() => _currentUser;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    _persistUser();
  }

  // ================= SYNC QUEUE & METADATA =================
  List<SyncQueueEntry> getSyncQueue() => List.unmodifiable(_syncQueue);

  void removeSyncQueueEntry(String id) {
    _syncQueue.removeWhere((e) => e.id == id);
    _persistSyncQueue();
  }

  void clearSyncQueue() {
    _syncQueue.clear();
    _persistSyncQueue();
  }

  DateTime? getLastSyncTime() => _lastSyncTime;

  void setLastSyncTime(DateTime time) {
    _lastSyncTime = time;
    _currentUser = _currentUser?.copyWith(lastSyncTime: time);
    if (_prefs != null) {
      _prefs!.setString(_keyLastSync, time.toIso8601String());
    }
    _persistUser();
  }

  void _queueMutation(SyncEntityType type, SyncOperationType op, String entityId, Map<String, dynamic>? payload) {
    final entry = SyncQueueEntry(
      id: 'mut_${DateTime.now().millisecondsSinceEpoch}_${entityId.hashCode}',
      entityType: type,
      operation: op,
      entityId: entityId,
      payload: payload,
      timestamp: DateTime.now().toUtc(),
    );
    _syncQueue.add(entry);
    _persistSyncQueue();
    if (!_mutationEventsController.isClosed) {
      _mutationEventsController.add(entry);
    }
  }

  // ================= DIRECT SYNC APPLICATION (NO OUTGOING QUEUE) =================
  void applySyncAsset(AssetModel asset) {
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
    } else {
      _assets.insert(0, asset);
    }
    _persistAssets();
  }

  void applySyncDeleteAsset(String assetId) {
    _assets.removeWhere((a) => a.id == assetId);
    _persistAssets();
  }

  void applySyncShareholder(ShareholderModel shareholder) {
    final index = _shareholders.indexWhere((s) => s.id == shareholder.id);
    if (index != -1) {
      _shareholders[index] = shareholder;
    } else {
      _shareholders.insert(0, shareholder);
    }
    _persistShareholders();
  }

  void applySyncDeleteShareholder(String shareholderId) {
    _shareholders.removeWhere((s) => s.id == shareholderId);
    _persistShareholders();
  }

  void applySyncTransaction(TransactionRecord transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    } else {
      _transactions.insert(0, transaction);
    }
    _persistTransactions();
  }

  void applySyncDeleteTransaction(String transactionId) {
    _transactions.removeWhere((t) => t.id == transactionId);
    _persistTransactions();
  }

  void applySyncArchivedItem(ArchivedItemModel item) {
    final index = _archivedItems.indexWhere((a) => a.id == item.id);
    if (index != -1) {
      _archivedItems[index] = item;
    } else {
      _archivedItems.insert(0, item);
    }
    _persistArchivedItems();
  }

  void applySyncDeleteArchivedItem(String archiveId) {
    _archivedItems.removeWhere((a) => a.id == archiveId);
    _persistArchivedItems();
  }

  // ================= BULK IMPORT & EXPORT (CLOUD SYNC) =================
  Map<String, dynamic> exportPortfolioData() {
    return {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'user': _currentUser?.toJson(),
      'assets': _assets.map((a) => a.toJson()).toList(),
      'shareholders': _shareholders.map((s) => s.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'archivedItems': _archivedItems.map((a) => a.toJson()).toList(),
    };
  }

  void importPortfolioData(Map<String, dynamic> data) {
    if (data['assets'] != null) {
      final List<dynamic> list = data['assets'] as List<dynamic>;
      _assets = list.map((e) => AssetModel.fromJson(e as Map<String, dynamic>)).toList();
      _persistAssets();
    }
    if (data['shareholders'] != null) {
      final List<dynamic> list = data['shareholders'] as List<dynamic>;
      _shareholders = list.map((e) => ShareholderModel.fromJson(e as Map<String, dynamic>)).toList();
      _persistShareholders();
    }
    if (data['transactions'] != null) {
      final List<dynamic> list = data['transactions'] as List<dynamic>;
      _transactions = list.map((e) => TransactionRecord.fromJson(e as Map<String, dynamic>)).toList();
      _persistTransactions();
    }
    if (data['archivedItems'] != null) {
      final List<dynamic> list = data['archivedItems'] as List<dynamic>;
      _archivedItems = list.map((e) => ArchivedItemModel.fromJson(e as Map<String, dynamic>)).toList();
      _persistArchivedItems();
    }
    setLastSyncTime(DateTime.now().toUtc());
  }

  // ================= DISK PERSISTENCE HELPERS =================
  void _persistAssets() {
    if (_prefs != null) {
      final jsonStr = jsonEncode(_assets.map((a) => a.toJson()).toList());
      _prefs!.setString(_keyAssets, jsonStr);
    }
    _notifyDataChanged();
  }

  void _persistShareholders() {
    if (_prefs != null) {
      final jsonStr = jsonEncode(_shareholders.map((s) => s.toJson()).toList());
      _prefs!.setString(_keyShareholders, jsonStr);
    }
    _notifyDataChanged();
  }

  void _persistTransactions() {
    if (_prefs != null) {
      final jsonStr = jsonEncode(_transactions.map((t) => t.toJson()).toList());
      _prefs!.setString(_keyTransactions, jsonStr);
    }
    _notifyDataChanged();
  }

  void _persistArchivedItems() {
    if (_prefs != null) {
      final jsonStr = jsonEncode(_archivedItems.map((a) => a.toJson()).toList());
      _prefs!.setString(_keyArchived, jsonStr);
    }
    _notifyDataChanged();
  }

  void _persistUser() {
    if (_prefs == null || _currentUser == null) return;
    final jsonStr = jsonEncode(_currentUser!.toJson());
    _prefs!.setString(_keyUser, jsonStr);
  }

  void _persistSyncQueue() {
    if (_prefs == null) return;
    final jsonStr = jsonEncode(_syncQueue.map((e) => e.toJson()).toList());
    _prefs!.setString(_keySyncQueue, jsonStr);
  }

  // ================= THEME & LOCALE OPERATIONS =================
  ThemeMode getThemeMode() => _themeMode;
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs?.setString(_keyThemeMode, mode.name);
  }

  Locale getLocale() => _locale;
  void setLocale(Locale locale) {
    _locale = locale;
    _prefs?.setString(_keyLocale, locale.languageCode);
  }

  // ================= SECURITY & DATA PROTECTION =================
  bool isBiometricEnabled() => _biometricEnabled;
  void setBiometricEnabled(bool val) {
    _biometricEnabled = val;
    _prefs?.setBool(_keyBiometric, val);
  }

  bool isAutoLockEnabled() => _autoLockEnabled;
  void setAutoLockEnabled(bool val) {
    _autoLockEnabled = val;
    _prefs?.setBool(_keyAutoLock, val);
  }

  bool isRequirePinForTransactions() => _requirePinForTransactions;
  void setRequirePinForTransactions(bool val) {
    _requirePinForTransactions = val;
    _prefs?.setBool(_keyRequirePin, val);
  }

  String getPinCode() => _pinCode;
  void setPinCode(String pin) {
    _pinCode = pin;
    _prefs?.setString(_keyPinCode, pin);
  }

  bool verifyPin(String enteredPin) {
    return enteredPin == _pinCode;
  }

  int getLockTimeoutMinutes() => _lockTimeoutMinutes;
  void setLockTimeoutMinutes(int mins) {
    _lockTimeoutMinutes = mins;
    _prefs?.setInt(_keyLockTimeout, mins);
  }

  // ================= FIRST-RUN & ONBOARDING =================
  bool isSetupCompleted() => _isSetupCompleted;
  void setSetupCompleted(bool val) {
    _isSetupCompleted = val;
    _prefs?.setBool(_keySetupCompleted, val);
  }

  void completeInitialSetup({
    required UserModel user,
    required String pinCode,
    required bool biometricEnabled,
    required bool autoLockEnabled,
    required bool requirePinForTransactions,
    required int lockTimeoutMinutes,
  }) {
    setCurrentUser(user);
    setPinCode(pinCode);
    setBiometricEnabled(biometricEnabled);
    setAutoLockEnabled(autoLockEnabled);
    setRequirePinForTransactions(requirePinForTransactions);
    setLockTimeoutMinutes(lockTimeoutMinutes);
    setSetupCompleted(true);
  }

  /// Applies a full atomic batch of assets, shareholders, and transactions from local sync
  void applyBatchSnapshot({
    List<AssetModel>? assets,
    List<ShareholderModel>? shareholders,
    List<TransactionRecord>? transactions,
    List<ArchivedItemModel>? archivedItems,
  }) {
    if (assets != null) {
      _assets = List.from(assets);
      if (_prefs != null) {
        final jsonStr = jsonEncode(_assets.map((a) => a.toJson()).toList());
        _prefs!.setString(_keyAssets, jsonStr);
      }
    }
    if (shareholders != null) {
      _shareholders = List.from(shareholders);
      if (_prefs != null) {
        final jsonStr = jsonEncode(_shareholders.map((s) => s.toJson()).toList());
        _prefs!.setString(_keyShareholders, jsonStr);
      }
    }
    if (transactions != null) {
      _transactions = List.from(transactions);
      if (_prefs != null) {
        final jsonStr = jsonEncode(_transactions.map((t) => t.toJson()).toList());
        _prefs!.setString(_keyTransactions, jsonStr);
      }
    }
    if (archivedItems != null) {
      _archivedItems = List.from(archivedItems);
      if (_prefs != null) {
        final jsonStr = jsonEncode(_archivedItems.map((a) => a.toJson()).toList());
        _prefs!.setString(_keyArchived, jsonStr);
      }
    }
    _lastSyncTime = DateTime.now().toUtc();
    _prefs?.setString(_keyLastSync, _lastSyncTime!.toIso8601String());
    _notifyDataChanged();
  }

  /// Clears all local application data and resets to clean initial state
  void clearAllData() {
    _assets = [];
    _shareholders = [];
    _transactions = [];
    _archivedItems = [];
    _alerts = [];
    _syncQueue = [];
    _currentUser = null;
    _isSetupCompleted = false;
    _prefs?.remove(_keyAssets);
    _prefs?.remove(_keyShareholders);
    _prefs?.remove(_keyTransactions);
    _prefs?.remove(_keyArchived);
    _prefs?.remove(_keyUser);
    _prefs?.remove(_keySyncQueue);
    _prefs?.remove(_keyLastSync);
    _prefs?.remove(_keySetupCompleted);
    _notifyDataChanged();
  }

  void dispose() {
    _dataChangesController.close();
    _mutationEventsController.close();
  }
}
