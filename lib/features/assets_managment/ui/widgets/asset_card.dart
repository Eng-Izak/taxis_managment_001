import 'package:flutter/material.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../asset_details_screen.dart';

class AssetCard extends StatelessWidget {
  final AssetModel asset;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.asset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color stripeColor;
    String statusText;
    Color statusBgColor;
    Color statusTextColor;

    switch (asset.status) {
      case AssetStatus.active:
        stripeColor = const Color(0xFF137333); // Green
        statusText = 'نشط';
        statusBgColor = const Color(0xFFE6F4EA);
        statusTextColor = const Color(0xFF137333);
        break;
      case AssetStatus.maintenance:
        stripeColor = const Color(0xFFE37400); // Orange
        statusText = 'صيانة';
        statusBgColor = const Color(0xFFFEF7E0);
        statusTextColor = const Color(0xFFB06000);
        break;
      case AssetStatus.inactive:
        stripeColor = const Color(0xFF0F56B3); // Blue
        statusText = asset.modelType == AssetType.plateOnly ? 'لوحة مؤجرة' : 'غير نشط';
        statusBgColor = const Color(0xFFE8F0FE);
        statusTextColor = const Color(0xFF0F56B3);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AssetDetailsScreen(asset: asset),
                ),
              );
            },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Right Edge Colored Stripe (Start in RTL)
            Container(
              width: 5,
              height: 120,
              color: stripeColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Plate & Car Model on Right (Expanded to prevent overflow), Status Badge on Left
                    Row(
                      children: [
                        // Right: Plate Number & Car Model
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                asset.plateNumber,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F56B3),
                                ),
                              ),
                              if (asset.carModelYear.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    asset.carModelYear,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Left: Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Metrics Row: Monthly Income on Right, Return Rate on Left
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Right: Monthly Gross Income (الدخل الشهري)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الدخل الشهري',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.formatCurrency(asset.monthlyRent),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),

                        // Left: Monthly Return Yield (العائد الشهري)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                              '${((asset.netMonthlyProfit / (asset.assetValuation > 0 ? asset.assetValuation : 500000)) * 100 * 12).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF137333),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Dynamic Segmented Partners Equity Progress Bar with Mouse Hover Tooltips
                    _buildPartnerSharesBar(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerSharesBar(BuildContext context) {
    final validShares = asset.partnerShares.where((s) => s.percentage > 0).toList();

    const colors = [
      Color(0xFF0F56B3), // Brand Blue
      Color(0xFF0D9488), // Teal
      Color(0xFF7C3AED), // Purple
      Color(0xFFD97706), // Amber
      Color(0xFF059669), // Emerald
      Color(0xFFE11D48), // Rose
      Color(0xFF2563EB), // Indigo
      Color(0xFF475569), // Slate
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
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
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
        segments.add(const SizedBox(width: 2));
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
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 6,
                color: color,
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
        segments.add(const SizedBox(width: 2));
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
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 6,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Row(
        children: segments,
      ),
    );
  }
}

