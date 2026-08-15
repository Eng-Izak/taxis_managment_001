import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/utils/formatters.dart';
import '../../home/logic/home_cubit.dart';
import '../../home/logic/home_state.dart';
import '../../notifications/ui/notifications_screen.dart';

class FinancialAnalysisScreen extends StatefulWidget {
  const FinancialAnalysisScreen({super.key});

  @override
  State<FinancialAnalysisScreen> createState() => _FinancialAnalysisScreenState();
}

class _FinancialAnalysisScreenState extends State<FinancialAnalysisScreen> {
  String _selectedPeriod = 'هذا الشهر';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SadatTaxiLogo(),
            SizedBox(width: 8),
            Text(
              'التحليل المالي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          const ArchiveIconButton(),
          NotificationBellButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final summary = state.summary;
          final grossIncome = (summary?.grossRentIncome ?? 0) > 0
              ? summary!.grossRentIncome
              : 45200.0;
          final expenses = (summary?.totalOperationalExpenses ?? 0) > 0
              ? summary!.totalOperationalExpenses
              : 12450.0;
          final netCashFlow = (summary?.netMonthlyRevenue ?? 0) > 0
              ? summary!.netMonthlyRevenue
              : (grossIncome - expenses);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Period Selector Filter Pills
                Row(
                  children: [
                    _PeriodFilterPill(
                      label: 'هذا الشهر',
                      isSelected: _selectedPeriod == 'هذا الشهر',
                      onTap: () => setState(() => _selectedPeriod = 'هذا الشهر'),
                    ),
                    const SizedBox(width: 8),
                    _PeriodFilterPill(
                      label: 'الربع الحالي',
                      isSelected: _selectedPeriod == 'الربع الحالي',
                      onTap: () => setState(() => _selectedPeriod = 'الربع الحالي'),
                    ),
                    const SizedBox(width: 8),
                    _PeriodFilterPill(
                      label: 'السنة المالية 2026',
                      isSelected: _selectedPeriod == 'السنة المالية 2026',
                      onTap: () => setState(() => _selectedPeriod = 'السنة المالية 2026'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Net Cash Flow Hero Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F56B3), Color(0xFF1E3A8A)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F56B3).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.trending_up_rounded, color: Color(0xFFFDE047), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  '+14.8% نمو نقدي',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFDE047),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'صافي التدفق النقدي المحقق',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE2E8F0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppFormatters.formatCurrency(netCashFlow),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'عائد تشغيلي صافي بعد استقطاع مصاريف الصيانة ورسوم الرخص',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFBFDBFE),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Top 2 KPI Cards (Revenue & Expenses)
                Row(
                  children: [
                    // Expenses Card
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي المصروفات',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  AppFormatters.formatNumber(expenses),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFC5221F),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ج.م',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '↑ 5% عن الشهر الماضي',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC5221F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Income Card
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي الإيرادات',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  AppFormatters.formatNumber(grossIncome),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F56B3),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ج.م',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '↑ 12% عن الشهر الماضي',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF137333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Section Header 1: سجل التحصيلات (الإيجارات)
                const Text(
                  'سجل التحصيلات (الإيجارات)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F56B3),
                  ),
                ),
                const SizedBox(height: 12),

                // Collections Card Container
                const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _CollectionItem(
                        plateNumber: 'أ ب ج 1234',
                        subtitle: 'أحمد محمود - أسبوع 1 أكتوبر',
                        amount: '1,500 ج.م',
                        amountColor: Color(0xFF0F56B3),
                        statusText: 'تم الدفع',
                        statusBgColor: Color(0xFFE6F4EA),
                        statusTextColor: Color(0xFF137333),
                        icon: Icons.directions_car_rounded,
                        iconBgColor: Color(0xFFE8F0FE),
                        iconColor: Color(0xFF0F56B3),
                      ),
                      Divider(height: 1),
                      _CollectionItem(
                        plateNumber: 'س ص ع 5678',
                        subtitle: 'محمد علي - أسبوع 1 أكتوبر',
                        amount: '1,500 ج.م',
                        amountColor: Color(0xFF0F56B3),
                        statusText: 'قيد الانتظار',
                        statusBgColor: Color(0xFFE8F0FE),
                        statusTextColor: Color(0xFF1A73E8),
                        icon: Icons.directions_car_rounded,
                        iconBgColor: Color(0xFFE8F0FE),
                        iconColor: Color(0xFF0F56B3),
                      ),
                      Divider(height: 1),
                      _CollectionItem(
                        plateNumber: 'ل م ن 9012',
                        subtitle: 'محمود خالد - أسبوع 4 سبتمبر',
                        amount: '1,500 ج.م',
                        amountColor: Color(0xFFC5221F),
                        statusText: 'متأخر',
                        statusBgColor: Color(0xFFFCE8E6),
                        statusTextColor: Color(0xFFC5221F),
                        icon: Icons.warning_rounded,
                        iconBgColor: Color(0xFFFCE8E6),
                        iconColor: Color(0xFFC5221F),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Section Header 2: سجل المصروفات
                const Text(
                  'سجل المصروفات',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F56B3),
                  ),
                ),
                const SizedBox(height: 12),

                // Expenses Card Container
                const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Red Expense Amount on Left
                      Text(
                        '- 850 ج.م',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC5221F),
                        ),
                      ),
                      Spacer(),
                      // Title & Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'صيانة دورية - أ ب ج 1234',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F56B3),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '05 أكتوبر 2023',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF64748B)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      // Wrench Icon on Right
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Center(
                            child: Icon(Icons.build_rounded, color: Color(0xFF5F6368), size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PeriodFilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodFilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F56B3) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _CollectionItem extends StatelessWidget {
  final String plateNumber;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _CollectionItem({
    required this.plateNumber,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Left: Amount & Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Middle: Plate & Driver
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
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Right: Icon Box
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
