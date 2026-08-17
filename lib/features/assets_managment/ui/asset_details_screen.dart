import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/shared/widgets/documents_section_widget.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../home/logic/home_cubit.dart';
import '../../home/logic/home_state.dart';
import 'add_asset_screen.dart';

class AssetDetailsScreen extends StatelessWidget {
  final AssetModel asset;

  const AssetDetailsScreen({super.key, required this.asset});

  void _confirmArchiveAsset(BuildContext context, AssetModel currentAsset) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.archiveAssetConfirmTitle),
        content: Text(
          '${l10n.archiveAssetConfirmMessage}\n\n"${currentAsset.plateNumber}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5221F)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<HomeCubit>().archiveAsset(currentAsset);
              if (context.mounted) {
                Navigator.of(context).pop();
                AppToast.show(
                  context,
                  message: '${l10n.itemRestored}: "${currentAsset.plateNumber}"',
                );
              }
            },
            child: Text(l10n.swipeToArchive, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final l10n = context.l10n;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // Find active updated instance or fallback to original
        final currentAsset = state.assets.firstWhere(
          (a) => a.id == asset.id,
          orElse: () => asset,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.assetDetails,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.archive_outlined, color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B)),
                tooltip: l10n.swipeToArchive,
                onPressed: () => _confirmArchiveAsset(context, currentAsset),
              ),
              IconButton(
                icon: Icon(Icons.edit_rounded, color: primaryColor),
                tooltip: l10n.editAsset,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddAssetScreen(assetToEdit: currentAsset),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Card: Plate, Model, Valuation
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Valuation
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.assetValuation,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.formatCurrency(currentAsset.assetValuation),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          // Right: Plate Badge & Model
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFE8F0FE),
                                  borderRadius: BorderRadius.circular(8),
                                  border: isDark ? Border.all(color: primaryColor.withValues(alpha: 0.4), width: 0.8) : null,
                                ),
                                child: Text(
                                  currentAsset.plateNumber,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentAsset.carModelYear,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Driver info
                      Row(
                        children: [
                          Icon(Icons.person_pin_rounded, size: 18, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            currentAsset.driverOrRenterName.isNotEmpty
                                ? currentAsset.driverOrRenterName
                                : (context.isArabic ? 'لم يتم تعيين سائق بعد' : 'No driver assigned'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (currentAsset.driverPhone.isNotEmpty)
                            Text(
                              context.digits(currentAsset.driverPhone),
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Financial Metrics: Monthly Rent & Net Profit
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.monthlyIncome,
                              style: TextStyle(fontSize: 11, color: textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.formatCurrency(currentAsset.monthlyRent),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.monthlyReturnYield,
                              style: TextStyle(fontSize: 11, color: textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.formatCurrency(currentAsset.netMonthlyProfit),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF137333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Partner Equity Distribution Section
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.equityDistribution,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            '${context.digits(currentAsset.partnerShares.length)} ${l10n.shareholders}',
                            style: TextStyle(fontSize: 11.5, color: textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Interactive Equity Segment Bar
                      _buildDetailsSharesBar(context, currentAsset),
                      const SizedBox(height: 14),

                      // List of partners
                      if (currentAsset.partnerShares.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            l10n.noPartnersAssigned,
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        )
                      else
                        ...currentAsset.partnerShares.map((share) {
                          final dividend = currentAsset.netMonthlyProfit * (share.percentage / 100.0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      share.partnerName.isNotEmpty ? share.partnerName[0] : 'P',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        share.partnerName,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                                      ),
                                      Text(
                                        '${context.formatPercentage(share.percentage)} ${l10n.ownershipRatio}',
                                        style: TextStyle(fontSize: 11, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  context.formatCurrency(dividend),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF137333),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Real Documents Registry (Single & Multi-Image)
                DocumentsSectionWidget(
                  documents: currentAsset.documents,
                  onDocumentsChanged: (updatedDocs) {
                    final updatedAsset = currentAsset.copyWith(documents: updatedDocs);
                    context.read<HomeCubit>().addOrUpdateAsset(updatedAsset);
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsSharesBar(BuildContext context, AssetModel asset) {
    final validShares = asset.partnerShares.where((s) => s.percentage > 0).toList();
    final l10n = context.l10n;

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
        message: '${l10n.noPartnersAssigned} (${context.formatPercentage(100)} ${l10n.unassignedShare})',
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
      final percentStr = context.formatPercentage(share.percentage);
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
      final percentStr = context.formatPercentage(remainder);
      final flex = (remainder * 100).round().clamp(1, 10000);

      if (segments.isNotEmpty) {
        segments.add(const SizedBox(width: 3));
      }

      segments.add(
        Expanded(
          flex: flex,
          child: Tooltip(
            message: '${l10n.unassignedShare} ($percentStr)',
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
                  color: Color(0xFFE2E8F0),
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
      child: Row(children: segments),
    );
  }
}
