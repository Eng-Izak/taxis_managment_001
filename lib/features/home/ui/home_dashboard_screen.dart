import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/shared/widgets/sync_status_badge.dart';
import '../../../../core/sync/sync_cubit.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';
import 'widgets/portfolio_kpi_card.dart';
import 'widgets/asset_distribution_grid.dart';
import 'widgets/alerts_section.dart';
import '../../notifications/ui/notifications_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToAssets;
  final VoidCallback? onNavigateToFinancials;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateToAssets,
    this.onNavigateToFinancials,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: SyncStatusBadge(),
          ),
        ),
        leadingWidth: 115,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SadatTaxiLogo(),
            const SizedBox(width: 8),
            Text(
              l10n.dashboard,
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

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<HomeCubit>().loadDashboardData();
              if (context.mounted) {
                await context.read<SyncCubit>().triggerSync();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    l10n.welcomeBack,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.portfolioOverview,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Portfolio KPI Card
                  if (summary != null)
                    PortfolioKpiCard(summary: summary),

                  const SizedBox(height: 24),

                  // Section Title: توزيع الأصول
                  Text(
                    l10n.assetDistribution,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Asset Distribution Grid (3 models)
                  if (summary != null)
                    AssetDistributionGrid(
                      fullTaxisCount: summary.fullTaxisCount,
                      plateOnlyCount: summary.plateOnlyCount,
                      vehicleOnlyCount: summary.vehicleOnlyCount,
                      selectedFilter: state.selectedFilter,
                      onFilterSelected: (type) {
                        context.read<HomeCubit>().filterByAssetType(type);
                        if (onNavigateToAssets != null) onNavigateToAssets!();
                      },
                    ),

                  const SizedBox(height: 24),

                  // Section Title: التنبيهات والمواعيد with "عرض الكل"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.alertsAndSchedules,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                        child: Text(
                          l10n.viewAll,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F56B3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Alerts Cards (Rent Due, Periodic Maintenance, License Renewal)
                  AlertsSection(
                    alerts: state.alerts,
                    onDismissAlert: (id) => context.read<HomeCubit>().dismissAlert(id),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
