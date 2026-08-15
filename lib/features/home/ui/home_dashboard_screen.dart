import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SadatTaxiLogo(),
            SizedBox(width: 8),
            Text(
              'لوحة التحكم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          const ArchiveIconButton(),
          NotificationBellButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final summary = state.summary;

          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().loadDashboardData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting (starts on right in RTL)
                  const Text(
                    'مرحباً بعودتك، مدير الأسطول',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'نظرة عامة على أداء محفظتك اليوم',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Portfolio KPI Card
                  if (summary != null)
                    PortfolioKpiCard(summary: summary),

                  const SizedBox(height: 24),

                  // Section Title: توزيع الأصول
                  const Text(
                    'توزيع الأصول',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
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
                      const Text(
                        'التنبيهات والمواعيد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontSize: 13,
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
