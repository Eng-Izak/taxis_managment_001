import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
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
                    label: 'الكل',
                    count: 4,
                    isSelected: _selectedFilter == NotificationFilter.all,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _NotificationFilterChip(
                    label: 'مالي',
                    count: 1,
                    isSelected: _selectedFilter == NotificationFilter.financial,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.financial),
                  ),
                  const SizedBox(width: 8),
                  _NotificationFilterChip(
                    label: 'صيانة',
                    count: 1,
                    isSelected: _selectedFilter == NotificationFilter.maintenance,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.maintenance),
                  ),
                  const SizedBox(width: 8),
                  _NotificationFilterChip(
                    label: 'مستندات',
                    count: null,
                    isSelected: _selectedFilter == NotificationFilter.documents,
                    onTap: () => setState(() => _selectedFilter = NotificationFilter.documents),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: اليوم (Today)
            const Text(
              'اليوم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),

            // Item 1: Payment Received
            const _NotificationItemCard(
              title: 'تم استلام مبلغ 1,500 ج.م من لوحة 1234',
              timeText: 'منذ 10 دقائق',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: Color(0xFF137333),
              iconBgColor: Color(0xFFE6F4EA),
              hasUnreadDot: true,
            ),
            const SizedBox(height: 10),

            // Item 2: Overdue Rent
            const _NotificationItemCard(
              title: 'تأخير في سداد إيجار لوحة 5678 -\nمحمود خالد',
              timeText: 'منذ 2 ساعة',
              icon: Icons.warning_rounded,
              iconColor: Color(0xFFC5221F),
              iconBgColor: Color(0xFFFCE8E6),
              hasUnreadDot: true,
            ),
            const SizedBox(height: 10),

            // Item 3: Maintenance Notice
            const _NotificationItemCard(
              title: 'موعد صيانة دورية لسيارة 1234 غداً',
              timeText: '09:30 صباحاً',
              icon: Icons.build_rounded,
              iconColor: Color(0xFF5F6368),
              iconBgColor: Color(0xFFF1F3F4),
              hasUnreadDot: false,
            ),

            const SizedBox(height: 24),

            // Section: أمس (Yesterday)
            const Text(
              'أمس',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),

            // Item 4: License Expiring
            const _NotificationItemCard(
              title: 'رخصة السيارة 9012 تنتهي خلال 30 يوم',
              timeText: 'أمس، 14:15',
              icon: Icons.description_rounded,
              iconColor: Color(0xFF1A73E8),
              iconBgColor: Color(0xFFE8F0FE),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F56B3) : const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF3C4043),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF0F56B3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF0F56B3) : Colors.white,
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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread Blue Dot
          if (hasUnreadDot)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 14, left: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF0F56B3),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
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
