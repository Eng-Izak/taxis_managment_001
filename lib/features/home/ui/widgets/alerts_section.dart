import 'package:flutter/material.dart';
import '../../../../core/shared/models/alert_item_model.dart';

class AlertsSection extends StatelessWidget {
  final List<AlertItem> alerts;
  final ValueChanged<String>? onDismissAlert;

  const AlertsSection({super.key, required this.alerts, this.onDismissAlert});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Card 1: Rent Due (Red Theme)
        _AlertMockCard(
          title: 'إيجار مستحق',
          subtitle: 'لوحة رقم: 1234',
          badgeText: 'متأخر',
          badgeBgColor: Color(0xFFFCE8E6),
          badgeTextColor: Color(0xFFC5221F),
          cardBgColor: Color(0xFFFDF7F7),
          borderColor: Color(0xFFFCDAD7),
          icon: Icons.warning_rounded,
          iconBgColor: Color(0xFFFCE8E6),
          iconColor: Color(0xFFC5221F),
        ),
        SizedBox(height: 10),

        // Card 2: Periodic Maintenance (Grey Theme)
        _AlertMockCard(
          title: 'صيانة دورية',
          subtitle: 'سيارة رقم: 5678',
          badgeText: 'قادم',
          badgeBgColor: Color(0xFFE8EAED),
          badgeTextColor: Color(0xFF5F6368),
          cardBgColor: Color(0xFFF8F9FA),
          borderColor: Color(0xFFE8EAED),
          icon: Icons.build_rounded,
          iconBgColor: Color(0xFFE8EAED),
          iconColor: Color(0xFF5F6368),
        ),
        SizedBox(height: 10),

        // Card 3: License Renewal (Blue Theme)
        _AlertMockCard(
          title: 'تجديد رخصة',
          subtitle: 'ينتهي الترخيص خلال 30 يوم',
          badgeText: 'معلومة',
          badgeBgColor: Color(0xFFD2E3FC),
          badgeTextColor: Color(0xFF1A73E8),
          cardBgColor: Color(0xFFEEF4FE),
          borderColor: Color(0xFFD2E3FC),
          icon: Icons.info_rounded,
          iconBgColor: Color(0xFFD2E3FC),
          iconColor: Color(0xFF1A73E8),
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
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
