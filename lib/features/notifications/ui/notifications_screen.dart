import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/alert_item_model.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../home/logic/home_cubit.dart';
import '../../home/logic/home_state.dart';

enum NotificationFilter { all, financial, maintenance, documents }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _selectedFilter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textHeaderColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF374151);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.notifications,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
          ),
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final alerts = state.alerts;

          // Categorize notifications
          final financialAlerts = alerts.where((a) => a.type == AlertType.rentDue).toList();
          final maintenanceAlerts = alerts.where((a) => a.type == AlertType.maintenance).toList();
          final docAlerts = alerts.where((a) => a.type == AlertType.licenseExpiry || a.type == AlertType.contractRenewal).toList();

          final List<AlertItem> currentList;
          switch (_selectedFilter) {
            case NotificationFilter.financial:
              currentList = financialAlerts;
              break;
            case NotificationFilter.maintenance:
              currentList = maintenanceAlerts;
              break;
            case NotificationFilter.documents:
              currentList = docAlerts;
              break;
            case NotificationFilter.all:
              currentList = alerts;
              break;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Pills Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _NotificationFilterChip(
                        label: l10n.filterAll,
                        count: alerts.length,
                        isSelected: _selectedFilter == NotificationFilter.all,
                        onTap: () => setState(() => _selectedFilter = NotificationFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _NotificationFilterChip(
                        label: l10n.filterFinancial,
                        count: financialAlerts.length,
                        isSelected: _selectedFilter == NotificationFilter.financial,
                        onTap: () => setState(() => _selectedFilter = NotificationFilter.financial),
                      ),
                      const SizedBox(width: 8),
                      _NotificationFilterChip(
                        label: l10n.filterMaintenance,
                        count: maintenanceAlerts.length,
                        isSelected: _selectedFilter == NotificationFilter.maintenance,
                        onTap: () => setState(() => _selectedFilter = NotificationFilter.maintenance),
                      ),
                      const SizedBox(width: 8),
                      _NotificationFilterChip(
                        label: l10n.filterDocuments,
                        count: docAlerts.length,
                        isSelected: _selectedFilter == NotificationFilter.documents,
                        onTap: () => setState(() => _selectedFilter = NotificationFilter.documents),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Notifications Section Header
                Text(
                  l10n.today,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textHeaderColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (currentList.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 48,
                            color: isDark ? AppColors.darkTextTertiary : const Color(0xFFCBD5E1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.isArabic ? 'لا توجد إشعارات جديدة في هذا التصنيف' : 'No new notifications in this category',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...currentList.map((alert) {
                    Color iconBgColor;
                    Color iconColor;
                    IconData icon;

                    switch (alert.type) {
                      case AlertType.rentDue:
                        icon = Icons.warning_rounded;
                        iconColor = isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F);
                        iconBgColor = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6);
                        break;
                      case AlertType.maintenance:
                        icon = Icons.build_rounded;
                        iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000);
                        iconBgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0);
                        break;
                      case AlertType.contractRenewal:
                      case AlertType.licenseExpiry:
                      default:
                        icon = alert.priority == AlertPriority.high ? Icons.error_outline_rounded : Icons.description_rounded;
                        iconColor = alert.priority == AlertPriority.high
                            ? (isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F))
                            : primaryColor;
                        iconBgColor = alert.priority == AlertPriority.high
                            ? (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6))
                            : (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFE8F0FE));
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _NotificationItemCard(
                        title: '${alert.title} - ${context.digits(alert.subtitle)}',
                        timeText: context.digits(l10n.hoursAgo(1)),
                        icon: icon,
                        iconColor: iconColor,
                        iconBgColor: iconBgColor,
                        hasUnreadDot: alert.priority == AlertPriority.high,
                      ),
                    );
                  }),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationFilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotificationFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: isDark && !isSelected
              ? Border.all(color: const Color(0xFF334155), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    context.digits(count),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationItemCard extends StatelessWidget {
  final String title;
  final String timeText;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool hasUnreadDot;

  const _NotificationItemCard({
    required this.title,
    required this.timeText,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.hasUnreadDot,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Icon on Start Edge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Unread Indicator Dot
          if (hasUnreadDot)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFC5221F),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
