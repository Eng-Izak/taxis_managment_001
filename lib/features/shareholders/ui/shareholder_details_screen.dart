import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/localization/app_localization_extension.dart';

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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.shareholderDetails,
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
                          l10n.totalInvestment,
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.formatCurrency(1250000),
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
                              context.digits('+20 100 123 4567'),
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
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.mainInvestor,
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
                  // Trend Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.north_east_rounded, color: Color(0xFFFDE047), size: 12),
                        const SizedBox(width: 2),
                        Text(
                          context.digits('+3.2%'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFDE047),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Return Title & Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.currentMonthReturn,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFBFDBFE),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.formatCurrency(12450),
                        style: const TextStyle(
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

            // Section Header: Invested Assets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.investedAssetsList} (${context.digits(4)})',
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
            _InvestedAssetMockCard(
              plateNumber: 'أ ب ج 1234',
              carName: 'Toyota Corolla 2022',
              equityPercent: context.formatPercentage(60),
              equityFlex: 60,
              monthlyReturn: context.formatCurrency(4500),
              icon: Icons.directions_car_rounded,
            ),
            _InvestedAssetMockCard(
              plateNumber: 'س ص ع 5678',
              carName: 'Hyundai Elantra 2021',
              equityPercent: context.formatPercentage(40),
              equityFlex: 40,
              monthlyReturn: context.formatCurrency(3200),
              icon: Icons.directions_car_rounded,
            ),
            _InvestedAssetMockCard(
              plateNumber: 'لوحة 3344',
              carName: l10n.rentedPlatesOnly,
              equityPercent: context.formatPercentage(100),
              equityFlex: 100,
              monthlyReturn: context.formatCurrency(2500),
              icon: Icons.credit_card_rounded,
            ),
            _InvestedAssetMockCard(
              plateNumber: 'د ر ز 7890',
              carName: 'Nissan Sunny 2023',
              equityPercent: context.formatPercentage(30),
              equityFlex: 30,
              monthlyReturn: context.formatCurrency(2250),
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
    final l10n = context.l10n;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              // Monthly Return
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.monthlyReturnYield,
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
              // Plate & Car
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
                '${l10n.ownershipRatio}: $equityPercent',
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
