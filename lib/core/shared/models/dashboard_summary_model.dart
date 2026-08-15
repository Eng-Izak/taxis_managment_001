class DashboardSummary {
  final double totalPortfolioValue;
  final double netMonthlyRevenue;
  final double monthlyRevenueGrowthPercentage;
  final int fullTaxisCount;
  final int plateOnlyCount;
  final int vehicleOnlyCount;
  final int totalPartnersCount;
  final int totalAssetsCount;
  final double grossRentIncome;
  final double totalOperationalExpenses;
  final double totalMilestoneRenewalFees;
  final double averageRoiPercentage;

  const DashboardSummary({
    required this.totalPortfolioValue,
    required this.netMonthlyRevenue,
    this.monthlyRevenueGrowthPercentage = 5.0,
    required this.fullTaxisCount,
    required this.plateOnlyCount,
    required this.vehicleOnlyCount,
    required this.totalPartnersCount,
    required this.totalAssetsCount,
    required this.grossRentIncome,
    required this.totalOperationalExpenses,
    this.totalMilestoneRenewalFees = 0.0,
    this.averageRoiPercentage = 18.4,
  });
}
