import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/shared/models/asset_model.dart';

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
    String name = shareholder.name;
    String role = 'مستثمر رئيسي';
    String statusText = 'نشط';
    IconData statusIcon = Icons.check_circle_outline_rounded;
    String totalShare = '25%';
    String assetsCount = '12 أصل';
    bool hasInitialsAvatar = false;
    String initials = 'م.س';

    if (name.contains('محمد سعيد')) {
      role = 'مستثمر مشارك';
      statusText = 'قيد المراجعة';
      statusIcon = Icons.pending_outlined;
      totalShare = '15%';
      assetsCount = '8 أصول';
      hasInitialsAvatar = true;
      initials = 'م.س';
    } else if (name.contains('فاطمة')) {
      role = 'مؤسس شريك';
      statusText = 'نشط';
      statusIcon = Icons.check_circle_outline_rounded;
      totalShare = '45%';
      assetsCount = '24 أصل';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row: Status badge (Left) & Avatar + Name (Right)
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

          // Inner Grey Box: إجمالي الحصص & عدد الأصول
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
                // إجمالي الحصص (Left)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي الحصص',
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
                // عدد الأصول (Right)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'عدد الأصول',
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

          // Bottom Row: Icons on Left & "عرض التفاصيل >" on Right
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
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
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
