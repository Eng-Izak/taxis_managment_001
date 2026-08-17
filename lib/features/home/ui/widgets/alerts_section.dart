import 'package:flutter/material.dart';
import '../../../../core/shared/models/alert_item_model.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/localization/app_localization_extension.dart';

class AlertsSection extends StatelessWidget {
  final List<AlertItem> alerts;
  final ValueChanged<String>? onDismissAlert;

  const AlertsSection({super.key, required this.alerts, this.onDismissAlert});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    if (alerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF137333), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.isArabic ? 'جميع الأصول والتراخيص سارية' : 'All assets and licenses are up to date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.isArabic ? 'لا توجد تنبيهات متأخرة أو متطلبات صيانة حالياً' : 'No overdue rents or urgent maintenance required',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: alerts.map((alert) {
        // Color themes based on priority and type
        Color badgeBgColor;
        Color badgeTextColor;
        Color cardBgColor;
        Color borderColor;
        Color iconBgColor;
        Color iconColor;
        IconData icon;
        String badgeText;

        switch (alert.type) {
          case AlertType.rentDue:
            badgeText = l10n.overdue;
            badgeBgColor = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6);
            badgeTextColor = isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F);
            cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFFDF7F7);
            borderColor = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFCDAD7);
            icon = Icons.warning_rounded;
            iconBgColor = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6);
            iconColor = isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F);
            break;
          case AlertType.maintenance:
            badgeText = l10n.upcoming;
            badgeBgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0);
            badgeTextColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000);
            cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA);
            borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE8EAED);
            icon = Icons.build_rounded;
            iconBgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0);
            iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000);
            break;
          case AlertType.licenseExpiry:
          default:
            badgeText = l10n.info;
            badgeBgColor = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFD2E3FC);
            badgeTextColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A73E8);
            cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF4FE);
            borderColor = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFD2E3FC);
            icon = Icons.info_rounded;
            iconBgColor = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFD2E3FC);
            iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A73E8);
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _AlertCard(
            title: alert.title,
            subtitle: context.digits(alert.subtitle),
            badgeText: badgeText,
            badgeBgColor: badgeBgColor,
            badgeTextColor: badgeTextColor,
            cardBgColor: cardBgColor,
            borderColor: borderColor,
            icon: icon,
            iconBgColor: iconBgColor,
            iconColor: iconColor,
            onDismiss: onDismissAlert != null ? () => onDismissAlert!(alert.id) : null,
          ),
        );
      }).toList(),
    );
  }
}

class _AlertCard extends StatelessWidget {
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
  final VoidCallback? onDismiss;

  const _AlertCard({
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
    this.onDismiss,
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
          // Icon on Start Edge
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

          // Title & Subtitle
          Expanded(
            child: Column(
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
          ),

          // Badge on End Edge
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

          if (onDismiss != null) ...[
            const SizedBox(width: 6),
            IconButton(
              icon: Icon(Icons.close, size: 16, color: isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8)),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
