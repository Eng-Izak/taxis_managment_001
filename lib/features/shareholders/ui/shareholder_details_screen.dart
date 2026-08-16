import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/shareholder_model.dart';

class ShareholderDetailsScreen extends StatelessWidget {
  final ShareholderModel shareholder;

  const ShareholderDetailsScreen({super.key, required this.shareholder});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final textTertiary = isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل المساهم',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // Top Card: Shareholder Profile Overview
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Left Side: Total Investment, Email, Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي الاستثمار',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '1,250,000 ج.م',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              'ahmed@example.com',
                              style: TextStyle(fontSize: 11, color: textTertiary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              '+20 100 123 4567',
                              style: TextStyle(fontSize: 11, color: textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right Side: Avatar, Name, and Role
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131D31) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(14),
                          border: isDark ? Border.all(color: AppColors.darkCardBorder, width: 1) : null,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: isDark ? textSecondary : const Color(0xFF5F6368),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shareholder.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'مستثمر رئيسي',
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Middle Card: Current Month Return Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E3A8A), const Color(0xFF1E293B)]
                      : [const Color(0xFF0F56B3), const Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: AppColors.darkCardBorder, width: 1) : null,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF1E3A8A) : const Color(0xFF0F56B3)).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Trend Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.north_east_rounded, color: Color(0xFFFDE047), size: 12),
                        SizedBox(width: 2),
                        Text(
                          '+3.2%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFDE047),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Return Title & Amount
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'عائد الشهر الحالي (أكتوبر)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFBFDBFE),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '12,450 ج.م',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFDE047),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section Header: الأصول المستثمر بها (4)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأصول المستثمر بها (4)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Invested Assets Mock List
            const _InvestedAssetMockCard(
              plateNumber: 'أ ب ج 1234',
              carName: 'تويوتا كورولا 2022',
              equityPercent: '60%',
              equityFlex: 60,
              monthlyReturn: '4,500 ج.م',
              icon: Icons.directions_car_rounded,
            ),
            const _InvestedAssetMockCard(
              plateNumber: 'س ص ع 5678',
              carName: 'هيونداي إلنترا 2021',
              equityPercent: '40%',
              equityFlex: 40,
              monthlyReturn: '3,200 ج.م',
              icon: Icons.directions_car_rounded,
            ),
            const _InvestedAssetMockCard(
              plateNumber: 'لوحة 3344',
              carName: 'تأجير لوحة فقط',
              equityPercent: '100%',
              equityFlex: 100,
              monthlyReturn: '2,500 ج.م',
              icon: Icons.credit_card_rounded,
            ),
            const _InvestedAssetMockCard(
              plateNumber: 'د ر ز 7890',
              carName: 'نيسان صني 2023',
              equityPercent: '30%',
              equityFlex: 30,
              monthlyReturn: '2,250 ج.م',
              icon: Icons.directions_car_rounded,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InvestedAssetMockCard extends StatelessWidget {
  final String plateNumber;
  final String carName;
  final String equityPercent;
  final int equityFlex;
  final String monthlyReturn;
  final IconData icon;

  const _InvestedAssetMockCard({
    required this.plateNumber,
    required this.carName,
    required this.equityPercent,
    required this.equityFlex,
    required this.monthlyReturn,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              // Monthly Return on Left
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العائد الشهري',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monthlyReturn,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Plate & Car on Right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plateNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    carName,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(8),
                  border: isDark ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 0.8) : null,
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Share Progress Bar & Percentage
          Row(
            children: [
              Text(
                'نسبة الملكية: $equityPercent',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 6,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: equityFlex,
                          child: Container(color: primaryColor),
                        ),
                        Expanded(
                          flex: (100 - equityFlex).clamp(0, 100),
                          child: const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
