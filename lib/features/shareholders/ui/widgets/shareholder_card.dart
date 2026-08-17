import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/utils/financial_calculator.dart';
import '../../../../core/localization/app_localization_extension.dart';

class ShareholderCard extends StatelessWidget {
  final ShareholderModel shareholder;
  final List<AssetModel> allAssets;
  final VoidCallback onTap;
  final VoidCallback? onArchive;

  const ShareholderCard({
    super.key,
    required this.shareholder,
    required this.allAssets,
    required this.onTap,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    // Compute real analytics dynamically from active assets
    final analytics = FinancialCalculator.computeShareholderAnalytics(
      shareholder: shareholder,
      allAssets: allAssets,
    );

    final String name = shareholder.name;
    final String role = analytics.investorRoleKey == 'mainInvestor'
        ? l10n.mainInvestor
        : analytics.investorRoleKey == 'partnerInvestor'
            ? l10n.partnerInvestor
            : l10n.founderPartner;

    final String statusText = l10n.statusActive;
    const IconData statusIcon = Icons.check_circle_outline_rounded;
    final String totalShare = context.formatPercentage(analytics.averageEquityPercentage);
    final String assetsCount = '${context.digits(analytics.investedAssets.length)} ${l10n.navAssets}';

    // Generate dynamic initials from name
    final nameParts = name.trim().split(RegExp(r'\s+'));
    final String initials = nameParts.length >= 2
        ? '${nameParts[0][0]}.${nameParts[1][0]}'
        : (name.isNotEmpty ? name[0] : 'P');

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row: Avatar + Name (Expanded) + Status Badge + Archive Button
          Row(
            children: [
              // Avatar Box with initials
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D31) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: const Color(0xFF334155), width: 1) : null,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Name & Role (Expanded to prevent any RenderFlex overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3), width: 0.8) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333)),
                    const SizedBox(width: 3),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                      ),
                    ),
                  ],
                ),
              ),

              // Archive Button
              if (onArchive != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.archive_outlined,
                    size: 18,
                    color: textSecondary,
                  ),
                  tooltip: context.isArabic ? 'أرشفة المساهم' : 'Archive Shareholder',
                  onPressed: onArchive,
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Inner Box: إجمالي الحصص & عدد الأصول
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
              border: isDark ? Border.all(color: const Color(0xFF334155), width: 0.8) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total shares
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalInvestedEquity,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalShare,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                // Owned assets count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.ownedAssetsCount,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assetsCount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
