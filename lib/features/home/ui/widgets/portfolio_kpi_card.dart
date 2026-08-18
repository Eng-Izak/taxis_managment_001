import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/dashboard_summary_model.dart';
import '../../../../core/localization/app_localization_extension.dart';

class PortfolioKpiCard extends StatelessWidget {
  final DashboardSummary summary;

  const PortfolioKpiCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Stack(
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: إجمالي قيمة المحفظة
              Text(
                l10n.totalPortfolioValue,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),

              // Big Value: إجمالي قيمة المحفظة
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    context.formatNumber(summary.totalPortfolioValue),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.egp,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Inner Container: صافي الإيرادات الشهري
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.netMonthlyRevenue,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Amount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              context.formatNumber(summary.netMonthlyRevenue),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.egp,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),

                        // Growth Badge
                        if (summary.monthlyRevenueGrowthPercentage > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '+${context.formatPercentage(summary.monthlyRevenueGrowthPercentage)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 14,
                                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Indicator Bar on Start Edge
        Positioned.directional(
          textDirection: Directionality.of(context),
          start: 0,
          top: 14,
          bottom: 14,
          child: Container(
            width: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFF0F56B3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }
}
