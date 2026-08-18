import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/shared/widgets/sync_status_badge.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../home/logic/home_cubit.dart';
import '../../home/logic/home_state.dart';
import '../../notifications/ui/notifications_screen.dart';
import '../../assets_managment/ui/asset_details_screen.dart';

class FinancialAnalysisScreen extends StatefulWidget {
  const FinancialAnalysisScreen({super.key});

  @override
  State<FinancialAnalysisScreen> createState() => _FinancialAnalysisScreenState();
}

class _FinancialAnalysisScreenState extends State<FinancialAnalysisScreen> {
  int _selectedPeriodIndex = 0; // 0: thisMonth, 1: currentQuarter, 2: fiscalYear2026

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 12),
            child: SyncStatusBadge(),
          ),
        ),
        leadingWidth: 105,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SadatTaxiLogo(),
            const SizedBox(width: 8),
            Text(
              l10n.financialAnalysis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          const ArchiveIconButton(),
          NotificationBellButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final summary = state.summary;
          final double periodMultiplier = _selectedPeriodIndex == 0
              ? 1.0
              : _selectedPeriodIndex == 1
                  ? 3.0
                  : 12.0;

          final double baseGross = summary?.grossRentIncome ?? 0.0;
          final double baseExpenses = summary?.totalOperationalExpenses ?? 0.0;
          final double grossIncome = baseGross * periodMultiplier;
          final double expenses = baseExpenses * periodMultiplier;
          final double netCashFlow = (grossIncome - expenses).clamp(0.0, double.infinity);
          final assets = state.assets;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Period Selector Filter Pills
                Row(
                  children: [
                    _PeriodFilterPill(
                      label: l10n.thisMonth,
                      isSelected: _selectedPeriodIndex == 0,
                      onTap: () => setState(() => _selectedPeriodIndex = 0),
                    ),
                    const SizedBox(width: 8),
                    _PeriodFilterPill(
                      label: l10n.currentQuarter,
                      isSelected: _selectedPeriodIndex == 1,
                      onTap: () => setState(() => _selectedPeriodIndex = 1),
                    ),
                    const SizedBox(width: 8),
                    _PeriodFilterPill(
                      label: l10n.fiscalYear2026,
                      isSelected: _selectedPeriodIndex == 2,
                      onTap: () => setState(() => _selectedPeriodIndex = 2),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Net Cash Flow Hero Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F56B3), Color(0xFF1E3A8A)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F56B3).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.trending_up_rounded, color: Color(0xFFFDE047), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  context.digits('+14.8%'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFDE047),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l10n.netDistributableCashflow,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE2E8F0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.formatCurrency(netCashFlow),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.roiCalculationNote,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFBFDBFE),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Top 2 KPI Cards (Revenue & Expenses)
                Row(
                  children: [
                    // Expenses Card
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.totalOperationalExpenses,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  context.formatNumber(expenses),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFC5221F),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.egp,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.digits('↓ 4.2%'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF137333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Income Card
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.grossRentIncome,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  context.formatNumber(grossIncome),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.egp,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.digits('↑ 8.5%'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF137333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Section Header 1: سجل التحصيلات (الإيجارات)
                Text(
                  '${l10n.monthlyRentCollections} (${context.digits(assets.length)})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Real Collections List
                if (assets.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        l10n.noData,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: List.generate(assets.length, (index) {
                        final asset = assets[index];
                        final isLast = index == assets.length - 1;
                        final double rentAmount = asset.monthlyRent * periodMultiplier;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AssetDetailsScreen(asset: asset),
                                  ),
                                );
                              },
                              child: _CollectionItem(
                                plateNumber: asset.plateNumber,
                                subtitle: asset.driverOrRenterName.isNotEmpty
                                    ? asset.driverOrRenterName
                                    : asset.carModelYear,
                                amount: context.formatCurrency(rentAmount),
                                amountColor: primaryColor,
                                statusText: l10n.receivedStatus,
                                statusBgColor: const Color(0xFFE6F4EA),
                                statusTextColor: const Color(0xFF137333),
                                icon: asset.modelType == AssetType.fullTaxi
                                    ? Icons.local_taxi_rounded
                                    : asset.modelType == AssetType.plateOnly
                                        ? Icons.credit_card_rounded
                                        : Icons.directions_car_rounded,
                                iconBgColor: const Color(0xFFE8F0FE),
                                iconColor: primaryColor,
                              ),
                            ),
                            if (!isLast) const Divider(height: 1),
                          ],
                        );
                      }),
                    ),
                  ),

                const SizedBox(height: 24),

                // 5. Section Header 2: سجل المصروفات
                Text(
                  l10n.totalOperationalExpenses,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Real Expenses List (from assets with operational expenses)
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ...assets.where((a) => a.averageMonthlyExpenses > 0).map((asset) {
                        final double exp = asset.averageMonthlyExpenses * periodMultiplier;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // Expense Amount
                              Text(
                                '- ${context.formatCurrency(exp)}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC5221F),
                                ),
                              ),
                              const Spacer(),
                              // Title & Car
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${l10n.periodicMaintenance} - ${asset.plateNumber}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    asset.carModelYear,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Wrench Icon
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F4),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: Center(
                                    child: Icon(Icons.build_rounded, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF5F6368), size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PeriodFilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodFilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: isDark && !isSelected
              ? Border.all(color: const Color(0xFF334155), width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

class _CollectionItem extends StatelessWidget {
  final String plateNumber;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _CollectionItem({
    required this.plateNumber,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Left: Amount & Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? statusBgColor.withValues(alpha: 0.2) : statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Center: Plate Number & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plateNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Right: Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
