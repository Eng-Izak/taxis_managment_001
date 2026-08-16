import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/localization/app_localization_extension.dart';

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
      body: SingleChildScrollView(
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
                    count: 4,
                    isSelected: _selectedFilter == NotificationFilter.all,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _NotificationFilterChip(
                    label: l10n.filterFinancial,
                    count: 1,
                    isSelected: _selectedFilter == NotificationFilter.financial,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.financial),
                  ),
                  const SizedBox(width: 8),
                  _NotificationFilterChip(
                    label: l10n.filterMaintenance,
                    count: 1,
                    isSelected: _selectedFilter == NotificationFilter.maintenance,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.maintenance),
                  ),
                  const SizedBox(width: 8),
                  _NotificationFilterChip(
                    label: l10n.filterDocuments,
                    count: null,
                    isSelected: _selectedFilter == NotificationFilter.documents,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.documents),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: اليوم (Today)
            Text(
              l10n.today,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textHeaderColor,
              ),
            ),
            const SizedBox(height: 12),

            // Item 1: Payment Received
            _NotificationItemCard(
              title: '${l10n.receivedStatus}: ${context.formatCurrency(1500)} (${l10n.rentedPlatesOnly} ${context.digits("1234")})',
              timeText: context.digits(l10n.minutesAgo(10)),
              icon: Icons.account_balance_wallet_rounded,
              iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
              iconBgColor: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA),
              hasUnreadDot: true,
            ),
            const SizedBox(height: 10),

            // Item 2: Overdue Rent
            _NotificationItemCard(
              title: '${l10n.overdueStatus}: ${l10n.rentDue} ${context.digits("5678")} - Mahmoud',
              timeText: context.digits(l10n.hoursAgo(2)),
              icon: Icons.warning_rounded,
              iconColor: isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F),
              iconBgColor: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6),
              hasUnreadDot: true,
            ),
            const SizedBox(height: 10),

            // Item 3: Maintenance Notice
            _NotificationItemCard(
              title: '${l10n.periodicMaintenance} - Toyota Corolla (${context.digits("1234")})',
              timeText: context.digits(l10n.hoursAgo(5)),
              icon: Icons.build_rounded,
              iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000),
              iconBgColor: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0),
              hasUnreadDot: false,
            ),

            const SizedBox(height: 24),

            // Section: أمس (Yesterday)
            Text(
              l10n.yesterday,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textHeaderColor,
              ),
            ),
            const SizedBox(height: 12),

            // Item 4: License Renewal Alert
            _NotificationItemCard(
              title: '${l10n.licenseRenewalAlerts}: ${context.digits("9012")} (${context.digits("30 days")})',
              timeText: context.digits('${l10n.yesterday} 04:30 PM'),
              icon: Icons.description_rounded,
              iconColor: primaryColor,
              iconBgColor: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFE8F0FE),
              hasUnreadDot: false,
            ),

            const SizedBox(height: 24),

            // Section: هذا الأسبوع (This Week)
            Text(
              l10n.thisWeek,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textHeaderColor,
              ),
            ),
            const SizedBox(height: 12),

            // Item 5: Monthly Report Exported
            _NotificationItemCard(
              title: l10n.reportExportSuccess,
              timeText: context.digits('Sunday 09:00 AM'),
              icon: Icons.file_download_done_rounded,
              iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
              iconBgColor: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA),
              hasUnreadDot: false,
            ),

            const SizedBox(height: 32),
          ],
        ),
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
    this.count,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: isDark && !isSelected
              ? Border.all(color: AppColors.darkCardBorder, width: 1)
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
                    : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
              ),
            ),
            if (count != null) ...[
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
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread Dot
          if (hasUnreadDot)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 14, left: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 8),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
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

          const SizedBox(width: 12),

          // Right Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: iconColor.withValues(alpha: 0.3), width: 0.8) : null,
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
