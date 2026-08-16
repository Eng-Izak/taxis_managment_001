import 'package:flutter/material.dart';
import '../../../../core/shared/models/alert_item_model.dart';
import '../../../../core/theming/app_colors.dart';

class AlertsSection extends StatelessWidget {
  final List<AlertItem> alerts;
  final ValueChanged<String>? onDismissAlert;

  const AlertsSection({super.key, required this.alerts, this.onDismissAlert});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Card 1: Rent Due (Red Theme)
        _AlertMockCard(
          title: 'إيجار مستحق',
          subtitle: 'لوحة رقم: 1234',
          badgeText: 'متأخر',
          badgeBgColor: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6),
          badgeTextColor: isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F),
          cardBgColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFFDF7F7),
          borderColor: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFCDAD7),
          icon: Icons.warning_rounded,
          iconBgColor: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6),
          iconColor: isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F),
        ),
        const SizedBox(height: 10),

        // Card 2: Periodic Maintenance (Amber / Neutral Theme)
        _AlertMockCard(
          title: 'صيانة دورية',
          subtitle: 'سيارة رقم: 5678',
          badgeText: 'قادم',
          badgeBgColor: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0),
          badgeTextColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000),
          cardBgColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
          borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAED),
          icon: Icons.build_rounded,
          iconBgColor: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0),
          iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000),
        ),
        const SizedBox(height: 10),

        // Card 3: License Renewal (Blue Theme)
        _AlertMockCard(
          title: 'تجديد رخصة',
          subtitle: 'ينتهي الترخيص خلال 30 يوم',
          badgeText: 'معلومة',
          badgeBgColor: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFD2E3FC),
          badgeTextColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A73E8),
          cardBgColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF4FE),
          borderColor: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFD2E3FC),
          icon: Icons.info_rounded,
          iconBgColor: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFD2E3FC),
          iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A73E8),
        ),
      ],
    );
  }
}

class _AlertMockCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final Color cardBgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _AlertMockCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.cardBgColor,
    required this.borderColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Icon on Right (in RTL)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle on Right (in RTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
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
          const Spacer(),

          // Badge on Left (in RTL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
