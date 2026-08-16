import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxis_managment_001/core/shared/models/asset_model.dart';
import 'package:taxis_managment_001/core/shared/models/partner_share_model.dart';
import 'package:taxis_managment_001/core/shared/enums/app_enums.dart';
import 'package:taxis_managment_001/core/utils/financial_calculator.dart';
import 'package:taxis_managment_001/core/services/local_storage_service.dart';
import 'package:taxis_managment_001/core/theming/theme_cubit.dart';

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
}

