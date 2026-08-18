import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/shared/widgets/sync_status_badge.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../logic/shareholders_cubit.dart';
import '../logic/shareholders_state.dart';
import '../../home/logic/home_cubit.dart';
import 'widgets/shareholder_card.dart';
import 'shareholder_details_screen.dart';
import 'add_shareholder_screen.dart';
import '../../notifications/ui/notifications_screen.dart';

class ShareholdersScreen extends StatelessWidget {
  const ShareholdersScreen({super.key});

  void _confirmArchiveShareholder(BuildContext context, ShareholderModel shareholder) {
    final isArabic = context.isArabic;
    final docsCount = shareholder.documents.length;

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
                  ? 'هل أنت متأكد من رغبتك في نقل المساهم "${shareholder.name}" إلى الأرشيف؟'
                  : 'Are you sure you want to move shareholder "${shareholder.name}" to the archive?',
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
              await context.read<ShareholdersCubit>().archiveShareholder(shareholder);
              if (context.mounted) {
                AppToast.show(
                  context,
                  message: isArabic
                      ? 'تم نقل المساهم "${shareholder.name}" ومستنداته إلى الأرشيف بنجاح'
                      : 'Shareholder "${shareholder.name}" & documents moved to archive',
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
    final allAssets = context.watch<HomeCubit>().state.assets;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: SyncStatusBadge(),
          ),
        ),
        leadingWidth: 115,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SadatTaxiLogo(),
            const SizedBox(width: 8),
            Text(
              l10n.shareholders,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          const ArchiveIconButton(),
          NotificationBellButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocBuilder<ShareholdersCubit, ShareholdersState>(
        builder: (context, state) {
          return Column(
            children: [
              // Top Action Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      l10n.shareholdersList,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    // Add Shareholder Button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddShareholderScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              l10n.addShareholder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Shareholders List
              Expanded(
                child: state.status == ShareholdersStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.shareholders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline_rounded, size: 48, color: Color(0xFFCBD5E1)),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.noShareholders,
                                  style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: state.shareholders.length,
                            itemBuilder: (context, index) {
                              final partner = state.shareholders[index];
                              return ShareholderCard(
                                shareholder: partner,
                                allAssets: allAssets,
                                onArchive: () => _confirmArchiveShareholder(context, partner),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ShareholderDetailsScreen(shareholder: partner),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
