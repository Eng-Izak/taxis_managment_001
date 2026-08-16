import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/localization/app_localization_extension.dart';

class ShareholderCard extends StatelessWidget {
  final ShareholderModel shareholder;
  final List<AssetModel> allAssets;
  final VoidCallback onTap;

  const ShareholderCard({
    super.key,
    required this.shareholder,
    required this.allAssets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String name = shareholder.name;
    String role = l10n.mainInvestor;
    String statusText = l10n.statusActive;
    IconData statusIcon = Icons.check_circle_outline_rounded;
    String totalShare = context.formatPercentage(25);
    String assetsCount = '${context.digits(12)} ${l10n.navAssets}';
    bool hasInitialsAvatar = false;
    String initials = 'م.س';

    if (name.contains('محمد سعيد')) {
      role = l10n.partnerInvestor;
      statusText = l10n.underReview;
      statusIcon = Icons.pending_outlined;
      totalShare = context.formatPercentage(15);
      assetsCount = '${context.digits(8)} ${l10n.navAssets}';
      hasInitialsAvatar = true;
      initials = 'م.س';
    } else if (name.contains('فاطمة')) {
      role = l10n.founderPartner;
      statusText = l10n.statusActive;
      statusIcon = Icons.check_circle_outline_rounded;
      totalShare = context.formatPercentage(45);
      assetsCount = '${context.digits(24)} ${l10n.navAssets}';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row: Status badge & Avatar + Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8EAED),
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: const Color(0xFF334155), width: 0.8) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368)),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ),

              // Name, Role & Avatar
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Avatar Box
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131D31) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                      border: isDark ? Border.all(color: const Color(0xFF334155), width: 1) : null,
                    ),
                    child: Center(
                      child: hasInitialsAvatar
                          ? Text(
                              initials,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368),
                              size: 26,
                            ),
                    ),
                  ),
                ],
              ),
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

          const SizedBox(height: 12),

          // Bottom Row
          Row(
            children: [
              // Icons
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162032) : const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_shipping_outlined,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Link
              Row(
                children: [
                  Text(
                    l10n.viewShareholderDetails,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
