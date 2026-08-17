import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/shared/widgets/documents_section_widget.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/utils/financial_calculator.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../home/logic/home_cubit.dart';
import '../logic/shareholders_cubit.dart';
import '../../assets_managment/ui/asset_details_screen.dart';
import 'add_shareholder_screen.dart';

class ShareholderDetailsScreen extends StatelessWidget {
  final ShareholderModel shareholder;

  const ShareholderDetailsScreen({super.key, required this.shareholder});

  void _confirmArchiveShareholder(BuildContext context, ShareholderModel currentShareholder) {
    final isArabic = context.isArabic;
    final docsCount = currentShareholder.documents.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isArabic ? 'تأكيد أرشفة المساهم' : 'Confirm Shareholder Archiving',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'هل أنت متأكد من رغبتك في نقل المساهم "${currentShareholder.name}" إلى الأرشيف؟'
                  : 'Are you sure you want to move shareholder "${currentShareholder.name}" to the archive?',
              style: const TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F56B3).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0F56B3).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF0F56B3)),
                      const SizedBox(width: 6),
                      Text(
                        isArabic ? 'الحفاظ التام على السجلات:' : 'Complete Data Preservation:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F56B3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic
                        ? '• سيتم الاحتفاظ بجميع بيانات الهوية والتواصل\n• حفظ كافة المستندات والوثائق المرفقة ($docsCount مستند)\n• الاحتفاظ بكامل سجل المعاملات وتوزيع الأرباح السابقة\n• إمكانية استعادة المساهم بنقرة واحدة من شاشة الأرشيف'
                        : '• Identity & contact data preserved\n• All attached documents ($docsCount docs) saved\n• Complete dividend & transaction history kept\n• Instant one-click restoration from Archive',
                    style: const TextStyle(fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.archive_outlined, size: 16, color: Colors.white),
            label: Text(
              isArabic ? 'نقل للأرشيف' : 'Move to Archive',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F56B3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<ShareholdersCubit>().archiveShareholder(currentShareholder);
              if (context.mounted) {
                Navigator.of(context).pop();
                AppToast.show(
                  context,
                  message: isArabic
                      ? 'تم نقل المساهم "${currentShareholder.name}" ومستنداته إلى الأرشيف بنجاح'
                      : 'Shareholder "${currentShareholder.name}" & documents moved to archive',
                  icon: Icons.archive_rounded,
                  duration: const Duration(seconds: 4),
                );
              }
            },
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
    final textTertiary = isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8);
    final l10n = context.l10n;

    final allAssets = context.watch<HomeCubit>().state.assets;
    final shareholdersState = context.watch<ShareholdersCubit>().state;
    final currentShareholder = shareholdersState.shareholders.firstWhere(
      (s) => s.id == shareholder.id,
      orElse: () => shareholder,
    );

    final analytics = FinancialCalculator.computeShareholderAnalytics(
      shareholder: currentShareholder,
      allAssets: allAssets,
    );

    final role = analytics.investorRoleKey == 'mainInvestor'
        ? l10n.mainInvestor
        : analytics.investorRoleKey == 'partnerInvestor'
            ? l10n.partnerInvestor
            : l10n.founderPartner;

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
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: primaryColor),
            tooltip: l10n.edit,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddShareholderScreen(shareholderToEdit: currentShareholder),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.archive_outlined, color: textSecondary),
            tooltip: context.isArabic ? 'أرشفة المساهم' : 'Archive Shareholder',
            onPressed: () => _confirmArchiveShareholder(context, currentShareholder),
          ),
        ],
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
                  // Left Side: Total Investment, Account Details, Phone
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
                          context.formatCurrency(analytics.totalInvestedCapital),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (shareholder.accountDetails.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                shareholder.payoutMethod == PayoutMethod.instapay
                                    ? Icons.flash_on_rounded
                                    : shareholder.payoutMethod == PayoutMethod.vodafoneCash
                                        ? Icons.phone_android_rounded
                                        : Icons.account_balance_rounded,
                                size: 14,
                                color: textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  shareholder.accountDetails,
                                  style: TextStyle(fontSize: 11, color: textTertiary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              context.digits(shareholder.phone),
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
                      // Avatar Box
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
                        role,
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
                          context.digits('+5.2%'),
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
                        context.formatCurrency(analytics.totalMonthlyDividend),
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
                  '${l10n.investedAssetsList} (${context.digits(analytics.investedAssets.length)})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Real Invested Assets List
            if (analytics.investmentEntries.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_car_outlined, size: 48, color: textTertiary),
                      const SizedBox(height: 10),
                      Text(
                        l10n.noPartnersAssigned,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...analytics.investmentEntries.map((entry) {
                final AssetModel asset = entry['asset'] as AssetModel;
                final double percentage = entry['percentage'] as double;
                final double payout = entry['monthlyPayout'] as double;

                return _InvestedAssetCard(
                  asset: asset,
                  plateNumber: asset.plateNumber,
                  carName: asset.carModelYear,
                  equityPercent: context.formatPercentage(percentage),
                  equityFlex: percentage.round().clamp(1, 100),
                  monthlyReturn: context.formatCurrency(payout),
                  icon: asset.modelType == AssetType.fullTaxi
                      ? Icons.local_taxi_rounded
                      : asset.modelType == AssetType.plateOnly
                          ? Icons.confirmation_number_rounded
                          : Icons.directions_car_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AssetDetailsScreen(asset: asset),
                      ),
                    );
                  },
                );
              }),

            const SizedBox(height: 16),

            // Shareholder Documents & Multi-Image Section
            DocumentsSectionWidget(
              title: context.isArabic ? 'مستندات وهوية المساهم (صور البطاقة / العقود)' : 'Shareholder Documents & ID (Cards/Contracts)',
              documents: currentShareholder.documents,
              onDocumentsChanged: (updatedDocs) {
                final updated = currentShareholder.copyWith(documents: updatedDocs);
                context.read<ShareholdersCubit>().addOrUpdateShareholder(updated);
              },
            ),

            const SizedBox(height: 16),

            // Archive Shareholder Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F56B3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.archive_outlined, color: Color(0xFF0F56B3), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.isArabic ? 'نقل المساهم إلى الأرشيف' : 'Archive Shareholder',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.isArabic
                              ? 'حفظ كامل البيانات والمستندات وسجل المعاملات في الأرشيف'
                              : 'Keep all data, documents, and transaction logs in archive',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmArchiveShareholder(context, currentShareholder),
                    icon: const Icon(Icons.archive_rounded, size: 16),
                    label: Text(
                      context.isArabic ? 'أرشفة' : 'Archive',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F56B3),
                      side: const BorderSide(color: Color(0xFF0F56B3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
}

class _InvestedAssetCard extends StatelessWidget {
  final AssetModel asset;
  final String plateNumber;
  final String carName;
  final String equityPercent;
  final int equityFlex;
  final String monthlyReturn;
  final IconData icon;
  final VoidCallback onTap;

  const _InvestedAssetCard({
    required this.asset,
    required this.plateNumber,
    required this.carName,
    required this.equityPercent,
    required this.equityFlex,
    required this.monthlyReturn,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final l10n = context.l10n;

    return AppCard(
      onTap: onTap,
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
