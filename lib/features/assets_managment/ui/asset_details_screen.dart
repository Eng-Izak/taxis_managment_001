import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/utils/formatters.dart';
import 'add_asset_screen.dart';

class AssetDetailsScreen extends StatelessWidget {
  final AssetModel asset;

  const AssetDetailsScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final textTertiary = isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8);
    final innerBoxBg = isDark ? const Color(0xFF131D31) : const Color(0xFFF8F9FA);
    final innerBoxBorder = isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل الأصل',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: primaryColor),
            tooltip: 'تعديل بيانات الأصل',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddAssetScreen(assetToEdit: asset),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // 1. Vehicle Main Details Card
            AppCard(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge on Left & Car Title on Right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3), width: 0.8) : null,
                        ),
                        child: Text(
                          'نشط (تحت التشغيل)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000),
                          ),
                        ),
                      ),
                      Text(
                        asset.carModelYear,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Box: Plate Number & Model Code
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: innerBoxBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: innerBoxBorder, width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          asset.plateNumber,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'رقم اللوحة',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Chassis Number Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: innerBoxBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: innerBoxBorder, width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          asset.chassisNumber.isNotEmpty ? asset.chassisNumber : 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'رقم الشاسيه',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Model Type Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: innerBoxBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: innerBoxBorder, width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          asset.modelType.arabicLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'نوع الأصل',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Current Valuation Card
            AppCard(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'القيمة السوقية التقديرية',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(8),
                          border: isDark ? Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3), width: 0.8) : null,
                        ),
                        child: Text(
                          '+12.5% منذ الشراء',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                          ),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(asset.assetValuation > 0 ? asset.assetValuation : 450000),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Partner Shares & Equity Card
            AppCard(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pie_chart_outline_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'نسب الملكية والتوزيع',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Segmented Progress Bar with Tooltips
                  _buildDetailsSharesBar(asset),

                  const SizedBox(height: 14),

                  if (asset.partnerShares.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'لا توجد حصص مساهمين مسجلة لهذا الأصل.',
                        style: TextStyle(color: textSecondary, fontSize: 12.5),
                      ),
                    )
                  else
                    ...asset.partnerShares.asMap().entries.map((entry) {
                      final i = entry.key;
                      final share = entry.value;
                      const colors = [
                        Color(0xFF0F56B3),
                        Color(0xFF0D9488),
                        Color(0xFF7C3AED),
                        Color(0xFFD97706),
                        Color(0xFF059669),
                        Color(0xFFE11D48),
                        Color(0xFF2563EB),
                        Color(0xFF475569),
                      ];
                      final color = colors[i % colors.length];
                      final initial = share.partnerName.trim().isNotEmpty
                          ? share.partnerName.trim().substring(0, 1)
                          : 'ش';
                      final shareValue = asset.assetValuation > 0
                          ? asset.assetValuation * (share.percentage / 100.0)
                          : 0.0;

                      return Column(
                        children: [
                          if (i > 0) const Divider(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    share.partnerName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    share.payoutMethod.name == 'instapay'
                                        ? 'إنستاباي'
                                        : share.payoutMethod.name == 'vodafoneCash'
                                            ? 'فودافون كاش'
                                            : 'تحويل بنكي',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${share.percentage % 1 == 0 ? share.percentage.toInt() : share.percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  if (shareValue > 0)
                                    Text(
                                      AppFormatters.formatCurrency(shareValue),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Documents Registry Card
            AppCard(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            color: primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'سجل المستندات والرخص',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: isDark ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 0.8) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 14, color: primaryColor),
                            const SizedBox(width: 2),
                            Text(
                              'إضافة مستند',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const _DocumentRowItem(
                    title: 'رخصة المركبة',
                    subtitle: 'صالحة حتى 2025/12',
                    icon: Icons.description_outlined,
                  ),
                  const Divider(height: 16),

                  const _DocumentRowItem(
                    title: 'بوليصة التأمين',
                    subtitle: 'تأمين شامل',
                    icon: Icons.shield_outlined,
                  ),
                  const Divider(height: 16),

                  const _DocumentRowItem(
                    title: 'عقد الشراء',
                    subtitle: 'نسخة أصلية',
                    icon: Icons.handshake_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Archive Asset Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkCardBorder : const Color(0xFFD1D5DB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 18,
                        color: textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'أرشفة الأصل',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'نقل الأصل إلى السجل غير النشط',
                    style: TextStyle(
                      fontSize: 10,
                      color: textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSharesBar(AssetModel asset) {
    final validShares = asset.partnerShares.where((s) => s.percentage > 0).toList();

    const colors = [
      Color(0xFF0F56B3),
      Color(0xFF0D9488),
      Color(0xFF7C3AED),
      Color(0xFFD97706),
      Color(0xFF059669),
      Color(0xFFE11D48),
      Color(0xFF2563EB),
      Color(0xFF475569),
    ];

    if (validShares.isEmpty) {
      return Tooltip(
        message: 'لا يوجد مساهمين محددين (100% غير مخصص)',
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 50),
        verticalOffset: 10,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 7,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      );
    }

    final totalPercentage = validShares.fold<double>(0.0, (sum, s) => sum + s.percentage);
    final hasRemainder = totalPercentage < 99.9;
    final remainder = (100.0 - totalPercentage).clamp(0.0, 100.0);

    final List<Widget> segments = [];

    for (int i = 0; i < validShares.length; i++) {
      final share = validShares[i];
      final color = colors[i % colors.length];
      final percentStr = share.percentage % 1 == 0
          ? '${share.percentage.toInt()}%'
          : '${share.percentage.toStringAsFixed(1)}%';
      final flex = (share.percentage * 100).round().clamp(1, 10000);

      if (i > 0) {
        segments.add(const SizedBox(width: 3));
      }

      segments.add(
        Expanded(
          flex: flex,
          child: Tooltip(
            message: '${share.partnerName} ($percentStr)',
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 50),
            showDuration: const Duration(seconds: 3),
            verticalOffset: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(i == 0 ? 4 : 0),
                    left: Radius.circular(i == validShares.length - 1 && !hasRemainder ? 4 : 0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (hasRemainder && remainder > 0.1) {
      final percentStr = remainder % 1 == 0
          ? '${remainder.toInt()}%'
          : '${remainder.toStringAsFixed(1)}%';
      final flex = (remainder * 100).round().clamp(1, 10000);

      if (segments.isNotEmpty) {
        segments.add(const SizedBox(width: 3));
      }

      segments.add(
        Expanded(
          flex: flex,
          child: Tooltip(
            message: 'حصة غير مخصصة ($percentStr)',
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 50),
            showDuration: const Duration(seconds: 3),
            verticalOffset: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: segments,
      ),
    );
  }
}

class _DocumentRowItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DocumentRowItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: isDark ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 0.8) : null,
          ),
          child: Icon(icon, color: primaryColor, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
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
        Icon(
          Icons.file_download_outlined,
          color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
          size: 20,
        ),
      ],
    );
  }
}
