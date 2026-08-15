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

                    // Segmented Partners Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 60,
                            child: Container(
                              height: 5,
                              color: const Color(0xFF0F56B3), // 60% Blue
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 40,
                            child: Container(
                              height: 5,
                              color: const Color(0xFF94A3B8), // 40% Grey
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
