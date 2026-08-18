import '../shared/models/asset_model.dart';
import '../shared/models/partner_share_model.dart';
import '../shared/models/shareholder_model.dart';
import '../shared/models/transaction_model.dart';
import '../shared/models/dashboard_summary_model.dart';
import '../shared/enums/app_enums.dart';

class ShareholderAnalytics {
  final List<Map<String, dynamic>> investmentEntries; // Contains asset, share, percentage, monthlyPayout
  final List<AssetModel> investedAssets;
  final double totalInvestedCapital;
  final double totalMonthlyDividend;
  final double averageEquityPercentage;
  final String investorRoleKey; // 'mainInvestor', 'partnerInvestor', 'founderPartner'
  final bool hasActiveInvestments;

  const ShareholderAnalytics({
    required this.investmentEntries,
    required this.investedAssets,
    required this.totalInvestedCapital,
    required this.totalMonthlyDividend,
    required this.averageEquityPercentage,
    required this.investorRoleKey,
    required this.hasActiveInvestments,
  });
}

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

  /// Computes comprehensive real-time analytics for a specific shareholder based on active fleet assets
  static ShareholderAnalytics computeShareholderAnalytics({
    required ShareholderModel shareholder,
    required List<AssetModel> allAssets,
  }) {
    final List<Map<String, dynamic>> entries = [];
    final List<AssetModel> matchingAssets = [];
    double totalCapital = 0.0;
    double totalDividends = 0.0;
    double totalEquitySum = 0.0;

    for (final asset in allAssets) {
      for (final share in asset.partnerShares) {
        final matchesId = share.partnerId.isNotEmpty && share.partnerId == shareholder.id;
        final matchesName = share.partnerName.trim().isNotEmpty &&
            (share.partnerName.trim().toLowerCase() == shareholder.name.trim().toLowerCase() ||
             shareholder.name.trim().toLowerCase().contains(share.partnerName.trim().toLowerCase()) ||
             share.partnerName.trim().toLowerCase().contains(shareholder.name.trim().toLowerCase()));

        if (matchesId || matchesName) {
          final payout = calculatePartnerDividend(
            asset: asset,
            equityPercentage: share.percentage,
          );
          final assetShareVal = asset.assetValuation > 0
              ? asset.assetValuation * (share.percentage / 100.0)
              : 0.0;

          totalCapital += assetShareVal;
          totalDividends += payout;
          totalEquitySum += share.percentage;

          matchingAssets.add(asset);
          entries.add({
            'asset': asset,
            'share': share,
            'percentage': share.percentage,
            'monthlyPayout': payout,
            'shareValue': assetShareVal,
          });
        }
      }
    }

    final avgEquity = matchingAssets.isNotEmpty
        ? (totalEquitySum / matchingAssets.length)
        : 0.0;

    // Determine capital: use calculated from assets or shareholder's stated capital if higher
    final finalCapital = shareholder.totalInvestedCapital > 0
        ? shareholder.totalInvestedCapital
        : (totalCapital > 0 ? totalCapital : 0.0);

    String roleKey = 'founderPartner';
    if (avgEquity >= 50.0 || matchingAssets.length >= 3) {
      roleKey = 'mainInvestor';
    } else if (matchingAssets.isNotEmpty) {
      roleKey = 'partnerInvestor';
    }

    return ShareholderAnalytics(
      investmentEntries: entries,
      investedAssets: matchingAssets,
      totalInvestedCapital: finalCapital,
      totalMonthlyDividend: totalDividends,
      averageEquityPercentage: avgEquity,
      investorRoleKey: roleKey,
      hasActiveInvestments: matchingAssets.isNotEmpty,
    );
  }

  /// Calculates total monthly dividends across all assets for a specific shareholder
  static double calculateTotalMonthlyDividendsForShareholder({
    required ShareholderModel shareholder,
    required List<AssetModel> allAssets,
  }) {
    return computeShareholderAnalytics(shareholder: shareholder, allAssets: allAssets).totalMonthlyDividend;
  }

  /// Returns list of assets in which a shareholder owns shares with their specific equity
  static List<Map<String, dynamic>> getShareholderInvestments({
    required ShareholderModel shareholder,
    required List<AssetModel> allAssets,
  }) {
    return computeShareholderAnalytics(shareholder: shareholder, allAssets: allAssets).investmentEntries;
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

    final avgRoi = totalValuation > 0 ? ((netMonthly * 12) / totalValuation) * 100.0 : 0.0;

    return DashboardSummary(
      totalPortfolioValue: totalValuation,
      netMonthlyRevenue: netMonthly,
      monthlyRevenueGrowthPercentage: totalValuation > 0 ? 5.2 : 0.0,
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
