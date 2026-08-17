import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxis_managment_001/core/shared/models/asset_model.dart';
import 'package:taxis_managment_001/core/shared/models/partner_share_model.dart';
import 'package:taxis_managment_001/core/shared/models/shareholder_model.dart';
import 'package:taxis_managment_001/core/shared/enums/app_enums.dart';
import 'package:taxis_managment_001/core/utils/financial_calculator.dart';
import 'package:taxis_managment_001/core/utils/formatters.dart';
import 'package:taxis_managment_001/core/services/local_storage_service.dart';
import 'package:taxis_managment_001/core/theming/theme_cubit.dart';
import 'package:taxis_managment_001/core/localization/locale_cubit.dart';

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
      final initialAssetCount = storage.getAssets().length;
      final initialArchiveCount = storage.getArchivedItems().length;

      final assetToArchive = storage.getAssets().first;
      storage.archiveAsset(assetToArchive);

      expect(storage.getAssets().length, initialAssetCount - 1);
      expect(storage.getArchivedItems().length, initialArchiveCount + 1);

      final archivedItem = storage.getArchivedItems().first;
      final restored = storage.restoreArchivedAsset(archivedItem.id);

      expect(restored, isTrue);
      expect(storage.getAssets().length, initialAssetCount);
      expect(storage.getArchivedItems().length, initialArchiveCount);
    });

    test('Generates real dynamic alerts for upcoming license expirations', () {
      final storage = LocalStorageService();
      final alerts = storage.getAlerts();

      expect(alerts.isNotEmpty, isTrue);
      expect(alerts.any((a) => a.type == AlertType.licenseExpiry), isTrue);
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
}
