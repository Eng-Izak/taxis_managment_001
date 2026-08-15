import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/shareholder_model.dart';

class ShareholderDetailsScreen extends StatelessWidget {
  final ShareholderModel shareholder;

  const ShareholderDetailsScreen({super.key, required this.shareholder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المساهم'), centerTitle: false),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي الاستثمار',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '1,250,000 ج.م',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F56B3),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748B)),
                            SizedBox(width: 4),
                            Text(
                              'ahmed@example.com',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                            SizedBox(width: 4),
                            Text(
                              '+20 100 123 4567',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shareholder.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F56B3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'مستثمر رئيسي',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
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
                color: const Color(0xFF0F56B3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Trend Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأصول المستثمر بها (4)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F56B3),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Monthly Return on Left
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'العائد الشهري',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monthlyReturn,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF137333),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F56B3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    carName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF0F56B3), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Share Progress Bar & Percentage
          Row(
            children: [
              Text(
                'نسبة الملكية: $equityPercent',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F56B3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 6,
                    color: const Color(0xFFE2E8F0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: equityFlex,
                          child: Container(color: const Color(0xFF0F56B3)),
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
