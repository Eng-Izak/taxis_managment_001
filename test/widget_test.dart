import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxis_managment_001/core/shared/models/asset_model.dart';
import 'package:taxis_managment_001/core/shared/models/partner_share_model.dart';
import 'package:taxis_managment_001/core/shared/models/shareholder_model.dart';
import 'package:taxis_managment_001/core/shared/models/user_model.dart';
import 'package:taxis_managment_001/core/shared/models/sync_entry_model.dart';
import 'package:taxis_managment_001/core/shared/enums/app_enums.dart';
import 'package:taxis_managment_001/core/utils/financial_calculator.dart';
import 'package:taxis_managment_001/core/utils/formatters.dart';
import 'package:taxis_managment_001/core/services/local_storage_service.dart';
import 'package:taxis_managment_001/core/services/cloud_sync_service.dart';
import 'package:taxis_managment_001/core/sync/sync_cubit.dart';
import 'package:taxis_managment_001/core/theming/theme_cubit.dart';
import 'package:taxis_managment_001/core/localization/locale_cubit.dart';
import 'package:taxis_managment_001/features/auth/logic/auth_cubit.dart';
import 'package:taxis_managment_001/features/auth/logic/auth_state.dart';
import 'package:taxis_managment_001/core/shared/widgets/app_phone_field.dart';
import 'package:taxis_managment_001/core/shared/models/document_meta_model.dart';
import 'package:taxis_managment_001/core/shared/models/archived_item_model.dart';
import 'package:taxis_managment_001/core/security/logic/app_lock_cubit.dart';
import 'package:taxis_managment_001/core/security/services/biometric_service.dart';

class FakeBiometricService extends BiometricService {
  final bool shouldSucceed;
  final bool isSupported;
  FakeBiometricService({this.shouldSucceed = true, this.isSupported = true});

  @override
  Future<bool> canAuthenticate() async => isSupported;

  @override
  Future<bool> authenticate({required String localizedReason, bool biometricOnly = false}) async {
    return shouldSucceed;
  }
}

void main() {
  group('Taxi Asset Management Financial Engine Tests', () {
    test('Calculates net monthly cashflow correctly deducting operational expenses', () {
      const asset = AssetModel(
        id: 'test_1',
        plateNumber: 'س أ د 4821',
        chassisNumber: 'VIN-123456',
        carModelYear: 'BYD F3 2023',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8500.0,
        averageMonthlyExpenses: 1000.0,
        assetValuation: 280000.0,
      );

      final net = FinancialCalculator.calculateAssetNetMonthly(asset);
      expect(net, 7500.0);
    });

    test('Calculates fractional partner dividends according to exact equity percentage', () {
      const asset = AssetModel(
        id: 'test_1',
        plateNumber: 'س أ د 4821',
        chassisNumber: 'VIN-123456',
        carModelYear: 'BYD F3 2023',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8500.0,
        averageMonthlyExpenses: 1000.0,
        partnerShares: [
          PartnerShare(partnerId: 'p1', partnerName: 'أحمد محمود', percentage: 60.0),
          PartnerShare(partnerId: 'p2', partnerName: 'محمد سعيد', percentage: 40.0),
        ],
      );

      final p1Dividend = FinancialCalculator.calculatePartnerDividend(
        asset: asset,
        equityPercentage: 60.0,
      );
      final p2Dividend = FinancialCalculator.calculatePartnerDividend(
        asset: asset,
        equityPercentage: 40.0,
      );

      expect(p1Dividend, 4500.0); // 7500 * 0.60
      expect(p2Dividend, 3000.0); // 7500 * 0.40
      expect(p1Dividend + p2Dividend, 7500.0);
    });

    test('Computes real-time dynamic ShareholderAnalytics across fleet', () {
      const shareholder = ShareholderModel(
        id: 'p1',
        name: 'أحمد محمود سالم',
        phone: '01012345678',
        totalInvestedCapital: 500000.0,
      );

      const assets = [
        AssetModel(
          id: '1',
          plateNumber: 'س أ د 4821',
          chassisNumber: 'VIN1',
          carModelYear: 'BYD F3 2023',
          modelType: AssetType.fullTaxi,
          monthlyRent: 8500.0,
          averageMonthlyExpenses: 1000.0,
          assetValuation: 280000.0,
          partnerShares: [
            PartnerShare(partnerId: 'p1', partnerName: 'أحمد محمود سالم', percentage: 60.0),
          ],
        ),
        AssetModel(
          id: '2',
          plateNumber: 'م ن ف 9182',
          chassisNumber: 'VIN2',
          carModelYear: 'Nissan Sunny 2022',
          modelType: AssetType.fullTaxi,
          monthlyRent: 9000.0,
          averageMonthlyExpenses: 1000.0,
          assetValuation: 320000.0,
          partnerShares: [
            PartnerShare(partnerId: 'p1', partnerName: 'أحمد محمود سالم', percentage: 100.0),
          ],
        ),
      ];

      final analytics = FinancialCalculator.computeShareholderAnalytics(
        shareholder: shareholder,
        allAssets: assets,
      );

      expect(analytics.investedAssets.length, 2);
      expect(analytics.totalMonthlyDividend, 4500.0 + 8000.0); // 7500*0.6 + 8000*1.0 = 12500
      expect(analytics.averageEquityPercentage, 80.0);
      expect(analytics.investorRoleKey, 'mainInvestor');
      expect(analytics.hasActiveInvestments, isTrue);
    });

    test('Validates 100% total equity share requirement', () {
      const validShares = [
        PartnerShare(partnerId: '1', partnerName: 'A', percentage: 70.0),
        PartnerShare(partnerId: '2', partnerName: 'B', percentage: 30.0),
      ];
      const invalidShares = [
        PartnerShare(partnerId: '1', partnerName: 'A', percentage: 50.0),
        PartnerShare(partnerId: '2', partnerName: 'B', percentage: 30.0),
      ];

      expect(FinancialCalculator.isEquitySumValid(validShares), isTrue);
      expect(FinancialCalculator.isEquitySumValid(invalidShares), isFalse);
    });

    test('Calculates portfolio aggregations accurately across multiple ownership models', () {
      const assets = [
        AssetModel(
          id: '1',
          plateNumber: 'أ ب ج 1234',
          chassisNumber: 'VIN1',
          carModelYear: 'Toyota Corolla 2023',
          modelType: AssetType.fullTaxi,
          monthlyRent: 5000.0,
          averageMonthlyExpenses: 500.0,
          assetValuation: 300000.0,
        ),
        AssetModel(
          id: '2',
          plateNumber: '5566',
          chassisNumber: 'VIN2',
          carModelYear: 'لوحة تجارية',
          modelType: AssetType.plateOnly,
          monthlyRent: 2500.0,
          averageMonthlyExpenses: 300.0,
          assetValuation: 120000.0,
        ),
        AssetModel(
          id: '3',
          plateNumber: '9988',
          chassisNumber: 'VIN3',
          carModelYear: 'Hyundai Elantra 2022',
          modelType: AssetType.vehicleOnly,
          monthlyRent: 4000.0,
          averageMonthlyExpenses: 800.0,
          assetValuation: 180000.0,
        ),
      ];

      final summary = FinancialCalculator.computeDashboardSummary(
        assets: assets,
        shareholders: [],
        transactions: [],
      );

      expect(summary.totalPortfolioValue, 600000.0);
      expect(summary.grossRentIncome, 11500.0);
      expect(summary.totalOperationalExpenses, 1600.0);
      expect(summary.netMonthlyRevenue, 9900.0); // 11500 - 1600
      expect(summary.fullTaxisCount, 1);
      expect(summary.plateOnlyCount, 1);
      expect(summary.vehicleOnlyCount, 1);
    });
  });

  group('LocalStorageService Real Data Lifecycle Tests', () {
    test('Archives asset and restores it seamlessly', () {
      final storage = LocalStorageService();
      const sampleAsset = AssetModel(
        id: 'test_archive_asset',
        plateNumber: 'س أ د 1122',
        chassisNumber: 'VIN-999',
        carModelYear: 'BYD F3',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8000.0,
        averageMonthlyExpenses: 1000.0,
        assetValuation: 250000.0,
      );
      storage.addAsset(sampleAsset);
      final initialAssetCount = storage.getAssets().length;
      final initialArchiveCount = storage.getArchivedItems().length;

      storage.archiveAsset(sampleAsset);

      expect(storage.getAssets().length, initialAssetCount - 1);
      expect(storage.getArchivedItems().length, initialArchiveCount + 1);

      final archivedItem = storage.getArchivedItems().first;
      final restored = storage.restoreArchivedAsset(archivedItem.id);

      expect(restored, isTrue);
      expect(storage.getAssets().length, initialAssetCount);
      expect(storage.getArchivedItems().length, initialArchiveCount);
    });

    test('Archives shareholder with documents and transaction history and restores it seamlessly', () {
      final storage = LocalStorageService();
      const doc = DocumentMeta(
        id: 'doc_partner_id',
        title: 'صورة بطاقة الرقم القومي',
        type: DocumentType.nationalId,
        images: ['/storage/id_front.jpg', '/storage/id_back.jpg'],
      );

      const testShareholder = ShareholderModel(
        id: 'sh_archive_test',
        name: 'شريك تجريبي مؤرشف',
        phone: '01099998888',
        nationalId: '29801019999999',
        documents: [doc],
      );

      storage.addShareholder(testShareholder);
      final initialShareholderCount = storage.getShareholders().length;
      final initialArchiveCount = storage.getArchivedItems().length;

      storage.archiveShareholder(testShareholder, reason: 'انسحاب الشريك وتسوية المستحقات');

      expect(storage.getShareholders().length, initialShareholderCount - 1);
      expect(storage.getArchivedItems().length, initialArchiveCount + 1);

      final archivedItem = storage.getArchivedItems().firstWhere((item) => item.category == ArchiveCategory.archivedShareholders);
      expect(archivedItem.originalShareholder, isNotNull);
      expect(archivedItem.originalShareholder!.id, 'sh_archive_test');
      expect(archivedItem.originalShareholder!.documents.length, 1);
      expect(archivedItem.originalShareholder!.documents.first.imageCount, 2);

      final restored = storage.restoreArchivedShareholder(archivedItem.id);
      expect(restored, isTrue);
      expect(storage.getShareholders().length, initialShareholderCount);
      expect(storage.getShareholders().any((s) => s.id == 'sh_archive_test'), isTrue);

      final restoredShareholder = storage.getShareholders().firstWhere((s) => s.id == 'sh_archive_test');
      expect(restoredShareholder.documents.length, 1);
      expect(restoredShareholder.documents.first.allImages.contains('/storage/id_back.jpg'), isTrue);

      storage.deleteShareholder('sh_archive_test');
    });

    test('Generates real dynamic alerts for upcoming license expirations', () {
      final storage = LocalStorageService();
      final sampleAsset = AssetModel(
        id: 'asset_with_expiry',
        plateNumber: 'س أ د 4821',
        chassisNumber: 'VIN-123',
        carModelYear: 'BYD F3',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8000.0,
        averageMonthlyExpenses: 1000.0,
        assetValuation: 250000.0,
        licenseExpiryDate: DateTime.now().add(const Duration(days: 10)),
      );
      storage.addAsset(sampleAsset);
      final alerts = storage.getAlerts();

      expect(alerts.isNotEmpty, isTrue);
      expect(alerts.any((a) => a.type == AlertType.licenseExpiry), isTrue);
    });

    test('Queues mutations for offline sync and clears queue upon sync', () {
      final storage = LocalStorageService();
      storage.clearSyncQueue();
      expect(storage.getSyncQueue().length, 0);

      const newShareholder = ShareholderModel(
        id: 'new_partner_test',
        name: 'كابتن محمود',
        phone: '01000000000',
      );
      storage.addShareholder(newShareholder);

      final queue = storage.getSyncQueue();
      expect(queue.isNotEmpty, isTrue);
      expect(queue.any((q) => q.entityId == 'new_partner_test'), isTrue);

      storage.clearSyncQueue();
      expect(storage.getSyncQueue().length, 0);
    });
  });

  group('UserModel and SyncQueueEntry Tests', () {
    test('Serializes and deserializes UserModel correctly', () {
      final user = UserModel(
        id: 'usr_test',
        email: 'test@sadattaxis.com',
        displayName: 'مستخدم تجريبي',
        phone: '01012345678',
        role: 'مدير المحفظة',
        lastSyncTime: DateTime(2026, 8, 17, 10, 0),
        autoSyncEnabled: true,
      );

      final json = user.toJson();
      final fromJson = UserModel.fromJson(json);

      expect(fromJson.id, user.id);
      expect(fromJson.email, user.email);
      expect(fromJson.displayName, user.displayName);
      expect(fromJson.autoSyncEnabled, isTrue);
    });

    test('Serializes and deserializes SyncQueueEntry correctly', () {
      final entry = SyncQueueEntry(
        id: 'entry_1',
        entityType: SyncEntityType.asset,
        operation: SyncOperationType.create,
        entityId: 'asset_99',
        payload: {'plateNumber': 'س أ د 9999'},
        timestamp: DateTime(2026, 8, 17),
      );

      final json = entry.toJson();
      final fromJson = SyncQueueEntry.fromJson(json);

      expect(fromJson.id, entry.id);
      expect(fromJson.entityType, SyncEntityType.asset);
      expect(fromJson.operation, SyncOperationType.create);
      expect(fromJson.entityId, 'asset_99');
    });
  });

  group('CountryInfo and Phone Validation Tests', () {
    test('Finds country by dial code or defaults to Egypt (+20)', () {
      final egypt = CountryInfo.findByDialCode('+20');
      expect(egypt.dialCode, '+20');
      expect(egypt.flag, '🇪🇬');
      expect(egypt.maxDigits, 11);

      final saudi = CountryInfo.findByDialCode('+966');
      expect(saudi.dialCode, '+966');
      expect(saudi.flag, '🇸🇦');
      expect(saudi.maxDigits, 9);

      final unknown = CountryInfo.findByDialCode('+999');
      expect(unknown.dialCode, '+20');
    });

    test('Contains valid supported countries with correct digit requirements', () {
      expect(CountryInfo.supportedCountries.length, greaterThanOrEqualTo(15));
      for (final country in CountryInfo.supportedCountries) {
        expect(country.dialCode.startsWith('+'), isTrue);
        expect(country.minDigits, greaterThan(6));
        expect(country.maxDigits, greaterThanOrEqualTo(country.minDigits));
      }
    });
  });

  group('DocumentMeta and Multi-Image Support Tests', () {
    test('Serializes and deserializes DocumentMeta with multiple images', () {
      final doc = DocumentMeta(
        id: 'doc_test_1',
        title: 'رخصة التسيير وجهين',
        type: DocumentType.licenseCard,
        images: const [
          '/storage/license_front.jpg',
          '/storage/license_back.jpg',
        ],
        expiryDate: DateTime(2027, 8, 15),
        notes: 'تم استلام الأصل وتوثيقه',
      );

      expect(doc.imageCount, 2);
      expect(doc.allImages.length, 2);
      expect(doc.allImages.first, '/storage/license_front.jpg');

      final json = doc.toJson();
      final fromJson = DocumentMeta.fromJson(json);

      expect(fromJson.id, doc.id);
      expect(fromJson.title, doc.title);
      expect(fromJson.type, DocumentType.licenseCard);
      expect(fromJson.images.length, 2);
      expect(fromJson.allImages.contains('/storage/license_back.jpg'), isTrue);
    });

    test('Falls back seamlessly to fileUrl if images list is empty', () {
      const doc = DocumentMeta(
        id: 'doc_legacy',
        title: 'عقد إيجار قديم',
        type: DocumentType.leaseContract,
        fileUrl: '/legacy/path/contract.pdf',
      );

      expect(doc.imageCount, 1);
      expect(doc.allImages, ['/legacy/path/contract.pdf']);
    });

    test('ShareholderModel handles attached documents list correctly', () {
      const doc1 = DocumentMeta(
        id: 'doc_sh_1',
        title: 'بطاقة الرقم القومي',
        type: DocumentType.nationalId,
        images: ['/sh/id_front.jpg', '/sh/id_back.jpg'],
      );

      const shareholder = ShareholderModel(
        id: 'sh_100',
        name: 'أحمد محمود',
        phone: '01012345678',
        documents: [doc1],
      );

      expect(shareholder.documents.length, 1);
      expect(shareholder.documents.first.imageCount, 2);

      final json = shareholder.toJson();
      final fromJson = ShareholderModel.fromJson(json);

      expect(fromJson.documents.length, 1);
      expect(fromJson.documents.first.title, 'بطاقة الرقم القومي');
      expect(fromJson.documents.first.images.length, 2);
    });
  });

  group('CloudSyncService and SyncCubit Tests', () {
    test('SyncCubit manages synchronization flow and emits updated state', () async {
      final storage = LocalStorageService();
      storage.setCurrentUser(const UserModel(
        id: 'u_sync_test',
        email: 'ahmed.salem@sadattaxis.com',
        displayName: 'أحمد محمود سالم',
      ));
      final syncService = CloudSyncService(storage);
      final cubit = SyncCubit(syncService: syncService, storageService: storage);

      expect(cubit.state.userEmail, isNotNull);

      final result = await cubit.triggerSync(force: true);
      expect(result.isSuccess, isTrue);

      cubit.toggleAutoSync(false);
      expect(storage.getCurrentUser()?.autoSyncEnabled, isFalse);

      cubit.toggleAutoSync(true);
      expect(storage.getCurrentUser()?.autoSyncEnabled, isTrue);

      await cubit.close();
      syncService.dispose();
    });
  });

  group('AuthCubit Email Authentication Tests', () {
    test('Logs in with email, initializes user and emits authenticated state', () async {
      final storage = LocalStorageService();
      final syncService = CloudSyncService(storage);
      final cubit = AuthCubit(storageService: storage, syncService: syncService);

      await cubit.loginWithEmail(
        email: 'investor.sadat@gmail.com',
        passwordOrPin: '1234',
        displayName: 'مستثمر السادات',
      );

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.email, 'investor.sadat@gmail.com');
      expect(cubit.state.user?.displayName, 'مستثمر السادات');
      expect(cubit.state.isAuthenticated, isTrue);

      await cubit.updateProfile(displayName: 'مستثمر السادات المحدث');
      expect(cubit.state.user?.displayName, 'مستثمر السادات المحدث');

      await cubit.logout();
      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);

      syncService.dispose();
    });
  });

  group('ThemeCubit Tests', () {
    test('Initializes with default theme mode and toggles seamlessly', () {
      final storage = LocalStorageService();
      final cubit = ThemeCubit(storage);

      expect(cubit.state, ThemeMode.light);
      expect(cubit.isDarkMode, isFalse);

      cubit.toggleTheme();
      expect(cubit.state, ThemeMode.dark);
      expect(cubit.isDarkMode, isTrue);
      expect(storage.getThemeMode(), ThemeMode.dark);

      cubit.toggleTheme();
      expect(cubit.state, ThemeMode.light);
      expect(cubit.isDarkMode, isFalse);
      expect(storage.getThemeMode(), ThemeMode.light);
    });

    test('Sets theme mode explicitly', () {
      final storage = LocalStorageService();
      final cubit = ThemeCubit(storage);

      cubit.setThemeMode(ThemeMode.system);
      expect(cubit.state, ThemeMode.system);
      expect(storage.getThemeMode(), ThemeMode.system);
    });
  });

  group('LocaleCubit Tests', () {
    test('Initializes with Arabic by default and toggles to English and back', () {
      final storage = LocalStorageService();
      final cubit = LocaleCubit(storage);

      expect(cubit.state.languageCode, 'ar');
      expect(cubit.isArabic, isTrue);

      cubit.toggleLocale();
      expect(cubit.state.languageCode, 'en');
      expect(cubit.isArabic, isFalse);
      expect(storage.getLocale().languageCode, 'en');

      cubit.toggleLocale();
      expect(cubit.state.languageCode, 'ar');
      expect(cubit.isArabic, isTrue);
      expect(storage.getLocale().languageCode, 'ar');
    });

    test('Sets locale explicitly via setArabic and setEnglish', () {
      final storage = LocalStorageService();
      final cubit = LocaleCubit(storage);

      cubit.setEnglish();
      expect(cubit.state.languageCode, 'en');
      expect(cubit.isArabic, isFalse);

      cubit.setArabic();
      expect(cubit.state.languageCode, 'ar');
      expect(cubit.isArabic, isTrue);
    });
  });

  group('AppFormatters Dual Numerals Tests', () {
    test('Formats numbers in Arabic Eastern numerals when isArabic is true', () {
      expect(AppFormatters.formatNumber(1510000, isArabic: true), '١,٥١٠,٠٠٠');
      expect(AppFormatters.formatNumber(34350, isArabic: true), '٣٤,٣٥٠');
      expect(AppFormatters.formatCurrency(1510000, isArabic: true), '١,٥١٠,٠٠٠ ج.م');
      expect(AppFormatters.formatPercentage(14.8, isArabic: true), '١٤.٨%');
      expect(AppFormatters.convertDigits('1234', isArabic: true), '١٢٣٤');
    });

    test('Formats numbers in English Western numerals when isArabic is false', () {
      expect(AppFormatters.formatNumber(1510000, isArabic: false), '1,510,000');
      expect(AppFormatters.formatNumber(34350, isArabic: false), '34,350');
      expect(AppFormatters.formatCurrency(1510000, isArabic: false), '1,510,000 EGP');
      expect(AppFormatters.formatPercentage(14.8, isArabic: false), '14.8%');
      expect(AppFormatters.convertDigits('١٢٣٤', isArabic: false), '1234');
    });
  });

  group('Security and Data Protection Tests', () {
    test('Verifies default PIN code and allows updating securely', () {
      final storage = LocalStorageService();
      expect(storage.getPinCode(), '1234');
      expect(storage.verifyPin('1234'), isTrue);
      expect(storage.verifyPin('0000'), isFalse);

      storage.setPinCode('9876');
      expect(storage.getPinCode(), '9876');
      expect(storage.verifyPin('9876'), isTrue);
      expect(storage.verifyPin('1234'), isFalse);

      // Restore
      storage.setPinCode('1234');
    });

    test('Persists biometric, auto-lock and PIN requirement settings', () {
      final storage = LocalStorageService();
      expect(storage.isBiometricEnabled(), isTrue);
      expect(storage.isAutoLockEnabled(), isTrue);
      expect(storage.isRequirePinForTransactions(), isTrue);

      storage.setBiometricEnabled(false);
      expect(storage.isBiometricEnabled(), isFalse);

      storage.setAutoLockEnabled(false);
      expect(storage.isAutoLockEnabled(), isFalse);

      storage.setRequirePinForTransactions(false);
      expect(storage.isRequirePinForTransactions(), isFalse);

      // Restore
      storage.setBiometricEnabled(true);
      storage.setAutoLockEnabled(true);
      storage.setRequirePinForTransactions(true);
    });

    test('Exports and imports portfolio snapshot data correctly', () {
      final storage = LocalStorageService();
      final exported = storage.exportPortfolioData();

      expect(exported['assets'], isNotNull);
      expect(exported['shareholders'], isNotNull);
      expect(exported['transactions'], isNotNull);
      expect(exported['version'], 2);
    });

    test('Initializes first-run setup and marks completion', () {
      final storage = LocalStorageService();
      storage.setSetupCompleted(false);
      expect(storage.isSetupCompleted(), isFalse);

      const testUser = UserModel(
        id: 'usr_new_test',
        email: 'test.admin@sadattaxis.com',
        displayName: 'كابتن عمر الشامي',
        phone: '01099887766',
        role: 'المدير المالي والتنفيذي',
      );

      storage.completeInitialSetup(
        user: testUser,
        pinCode: '5566',
        biometricEnabled: true,
        autoLockEnabled: true,
        requirePinForTransactions: true,
        lockTimeoutMinutes: 5,
      );

      expect(storage.isSetupCompleted(), isTrue);
      expect(storage.getCurrentUser()?.displayName, 'كابتن عمر الشامي');
      expect(storage.getPinCode(), '5566');
      expect(storage.verifyPin('5566'), isTrue);
      expect(storage.getLockTimeoutMinutes(), 5);

      // Restore
      storage.setPinCode('1234');
      storage.setLockTimeoutMinutes(1);
    });

    test('AppLockCubit manages PIN entry, wrong attempts, and biometrics unlock', () async {
      final storage = LocalStorageService();
      storage.setSetupCompleted(true);
      storage.setAutoLockEnabled(true);
      storage.setPinCode('1234');
      storage.setBiometricEnabled(true);

      final fakeBiometric = FakeBiometricService(shouldSucceed: true);
      final lockCubit = AppLockCubit(storage, fakeBiometric);
      expect(lockCubit.state.isLocked, isTrue);

      // Wrong PIN entry
      lockCubit.inputDigit('9');
      lockCubit.inputDigit('9');
      lockCubit.inputDigit('9');
      lockCubit.inputDigit('9'); // auto verifies on 4th digit
      expect(lockCubit.state.isLocked, isTrue);
      expect(lockCubit.state.errorMessage, isNotNull);
      expect(lockCubit.state.failedAttempts, 1);

      // Delete and correct PIN entry
      lockCubit.inputDigit('1');
      lockCubit.inputDigit('2');
      lockCubit.inputDigit('3');
      lockCubit.inputDigit('4');
      expect(lockCubit.state.isLocked, isFalse);
      expect(lockCubit.state.errorMessage, isNull);

      // Manual lock
      lockCubit.lock();
      expect(lockCubit.state.isLocked, isTrue);

      // Biometrics unlock (success)
      final bioSuccess = await lockCubit.unlockWithBiometrics();
      expect(bioSuccess, isTrue);
      expect(lockCubit.state.isLocked, isFalse);

      // Lock again and test biometric failure
      lockCubit.lock();
      expect(lockCubit.state.isLocked, isTrue);

      final failingBiometric = FakeBiometricService(shouldSucceed: false);
      final failingLockCubit = AppLockCubit(storage, failingBiometric);
      final failSuccess = await failingLockCubit.unlockWithBiometrics();
      expect(failSuccess, isFalse);
      expect(failingLockCubit.state.isLocked, isTrue);
    });

    test('LocalStorageService starts clean and empty on fresh launch', () {
      final storage = LocalStorageService();
      storage.clearAllData();

      expect(storage.getAssets().isEmpty, isTrue);
      expect(storage.getShareholders().isEmpty, isTrue);
      expect(storage.getTransactions().isEmpty, isTrue);
      expect(storage.getArchivedItems().isEmpty, isTrue);
      expect(storage.getAlerts().isEmpty, isTrue);
      expect(storage.getCurrentUser(), isNull);
      expect(storage.isSetupCompleted(), isFalse);

      // Adding user data
      const user = UserModel(
        id: 'u_real',
        email: 'user@test.com',
        displayName: 'المستثمر أحمد',
      );
      storage.setCurrentUser(user);
      expect(storage.getCurrentUser()?.displayName, 'المستثمر أحمد');

      const asset = AssetModel(
        id: 'a_real',
        plateNumber: 'س أ د 1000',
        chassisNumber: 'VIN-1000',
        carModelYear: 'Toyota 2024',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8000.0,
      );
      storage.addAsset(asset);
      expect(storage.getAssets().length, 1);
      expect(storage.getAssets().first.plateNumber, 'س أ د 1000');
    });
  });
}


