import '../shared/models/asset_model.dart';
import '../shared/models/partner_share_model.dart';
import '../shared/models/shareholder_model.dart';
import '../shared/models/transaction_model.dart';
import '../shared/models/dashboard_summary_model.dart';
import '../shared/enums/app_enums.dart';

class FinancialCalculator {
  FinancialCalculator._();

  /// Calculates net monthly cash flow for a single asset after routine operational deductions
  static double calculateAssetNetMonthly(AssetModel asset) {
    final net = asset.monthlyRent - asset.averageMonthlyExpenses;
    return net < 0 ? 0.0 : net;
  }

  /// Calculates a partner's monthly dividend for a specific asset based on equity share
  static double calculatePartnerDividend({
    required AssetModel asset,
    required double equityPercentage,
  }) {
    final netMonthly = calculateAssetNetMonthly(asset);
    return (netMonthly * (equityPercentage / 100.0));
  }

  /// Calculates total monthly dividends across all assets for a specific shareholder
  static double calculateTotalMonthlyDividendsForShareholder({
    required ShareholderModel shareholder,
    required List<AssetModel> allAssets,
  }) {
    double total = 0.0;
    for (final asset in allAssets) {
      for (final share in asset.partnerShares) {
        if (share.partnerId == shareholder.id || share.partnerName.trim() == shareholder.name.trim()) {
          total += calculatePartnerDividend(
            asset: asset,
            equityPercentage: share.percentage,
          );
        }
      }
    }
    return total;
  }

  /// Returns list of assets in which a shareholder owns shares with their specific equity
  static List<Map<String, dynamic>> getShareholderInvestments({
    required ShareholderModel shareholder,
    required List<AssetModel> allAssets,
  }) {
    final List<Map<String, dynamic>> results = [];
    for (final asset in allAssets) {
      for (final share in asset.partnerShares) {
        if (share.partnerId == shareholder.id || share.partnerName.trim() == shareholder.name.trim()) {
          final monthlyPayout = calculatePartnerDividend(
            asset: asset,
            equityPercentage: share.percentage,
          );
          results.add({
            'asset': asset,
            'share': share,
            'percentage': share.percentage,
            'monthlyPayout': monthlyPayout,
          });
        }
      }
    }
    return results;
  }

  /// Validates whether a list of partner shares sums up to exactly 100% (within floating tolerance)
  static bool isEquitySumValid(List<PartnerShare> shares) {
    if (shares.isEmpty) return false;
    final total = shares.fold(0.0, (sum, share) => sum + share.percentage);
    return (total - 100.0).abs() < 0.01;
  }

  /// Calculates annual ROI percentage for an asset: (Net Monthly * 12 / Asset Valuation) * 100
  static double calculateAssetAnnualRoi(AssetModel asset) {
    if (asset.assetValuation <= 0) return 0.0;
    final annualNet = calculateAssetNetMonthly(asset) * 12;
    return (annualNet / asset.assetValuation) * 100.0;
  }

  /// Computes overall portfolio summary and metrics
  static DashboardSummary computeDashboardSummary({
    required List<AssetModel> assets,
    required List<ShareholderModel> shareholders,
    required List<TransactionRecord> transactions,
  }) {
    double totalValuation = 0.0;
    double totalGrossRent = 0.0;
    double totalRoutineExpenses = 0.0;
    int fullTaxis = 0;
    int plateOnly = 0;
    int vehicleOnly = 0;

    for (final asset in assets) {
      totalValuation += asset.assetValuation;
      totalGrossRent += asset.monthlyRent;
      totalRoutineExpenses += asset.averageMonthlyExpenses;

      switch (asset.modelType) {
        case AssetType.fullTaxi:
          fullTaxis++;
          break;
        case AssetType.plateOnly:
          plateOnly++;
          break;
        case AssetType.vehicleOnly:
          vehicleOnly++;
          break;
      }
    }

    final netMonthly = (totalGrossRent - totalRoutineExpenses).clamp(0.0, double.infinity);

    // Calculate milestone renewals separately
    final milestoneRenewals = transactions
        .where((t) => t.type == TransactionType.renewalFee)
        .fold(0.0, (sum, t) => sum + t.amount);

    final avgRoi = totalValuation > 0 ? ((netMonthly * 12) / totalValuation) * 100.0 : 18.0;

    return DashboardSummary(
      totalPortfolioValue: totalValuation,
      netMonthlyRevenue: netMonthly,
      monthlyRevenueGrowthPercentage: 5.2,
      fullTaxisCount: fullTaxis,
      plateOnlyCount: plateOnly,
      vehicleOnlyCount: vehicleOnly,
      totalPartnersCount: shareholders.length,
      totalAssetsCount: assets.length,
      grossRentIncome: totalGrossRent,
      totalOperationalExpenses: totalRoutineExpenses,
      totalMilestoneRenewalFees: milestoneRenewals,
      averageRoiPercentage: avgRoi,
    );
  }
}
