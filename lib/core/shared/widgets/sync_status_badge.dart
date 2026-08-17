import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theming/app_colors.dart';
import '../../services/cloud_sync_service.dart';
import '../../sync/sync_cubit.dart';
import '../../sync/sync_state.dart';
import '../../localization/app_localization_extension.dart';
import 'app_card.dart';
import 'app_toast.dart';

class SyncStatusBadge extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const SyncStatusBadge({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  void _showSyncDetailsModal(BuildContext context, SyncState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D31) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.cloud_sync_rounded, color: primaryColor, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.isArabic ? 'المزامنة السحابية والحساب' : 'Cloud Sync & Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Connected Email Card
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryColor.withValues(alpha: 0.15),
                      child: Icon(Icons.email_outlined, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.isArabic ? 'البريد الإلكتروني المرتبط' : 'Connected Email',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.userEmail ?? (context.isArabic ? 'غير متصل بحساب' : 'No account linked'),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: state.isOnline
                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA))
                            : (isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.isOnline
                            ? (context.isArabic ? 'متصل بالسحابة' : 'Online')
                            : (context.isArabic ? 'وضع عدم الاتصال' : 'Offline'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: state.isOnline ? const Color(0xFF137333) : const Color(0xFFB06000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Sync Stats Row
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.isArabic ? 'آخر مزامنة' : 'Last Synced',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.lastSyncTime != null
                                ? context.formatShortDate(state.lastSyncTime)
                                : (context.isArabic ? 'الآن' : 'Just now'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.isArabic ? 'تعديلات معلقة' : 'Pending Sync',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${context.digits(state.pendingChangesCount)} ${context.isArabic ? "عنصر" : "items"}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: state.pendingChangesCount > 0 ? const Color(0xFFD97706) : const Color(0xFF137333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Sync Now Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: state.status == CloudSyncStatus.syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync_rounded, color: Colors.white),
                  label: Text(
                    state.status == CloudSyncStatus.syncing
                        ? (context.isArabic ? 'جاري المزامنة السحابية...' : 'Syncing in progress...')
                        : (context.isArabic ? 'مزامنة سحابية الآن' : 'Sync Cloud Now'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: state.status == CloudSyncStatus.syncing
                      ? null
                      : () async {
                          final result = await context.read<SyncCubit>().triggerSync(force: true);
                          if (context.mounted) {
                            Navigator.of(ctx).pop();
                            AppToast.show(
                              context,
                              message: result.isOnline
                                  ? (context.isArabic ? 'تمت المزامنة بنجاح مع السحابة' : 'Successfully synced with cloud')
                                  : (context.isArabic ? 'تم الحفظ محلياً (لا يتوفر اتصال بالإنترنت)' : 'Saved locally (No internet connection)'),
                            );
                          }
                        },
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        Color badgeBgColor;
        Color badgeBorderColor;
        Color iconColor;
        IconData icon;
        String statusLabel;

        switch (state.status) {
          case CloudSyncStatus.syncing:
            icon = Icons.sync_rounded;
            iconColor = primaryColor;
            badgeBgColor = primaryColor.withValues(alpha: isDark ? 0.2 : 0.1);
            badgeBorderColor = primaryColor.withValues(alpha: 0.3);
            statusLabel = context.isArabic ? 'جاري المزامنة...' : 'Syncing...';
            break;
          case CloudSyncStatus.offline:
            icon = Icons.cloud_off_rounded;
            iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
            badgeBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
            badgeBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
            statusLabel = context.isArabic ? 'وضع محلي' : 'Offline';
            break;
          case CloudSyncStatus.pendingChanges:
            icon = Icons.cloud_upload_outlined;
            iconColor = const Color(0xFFD97706);
            badgeBgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF7E0);
            badgeBorderColor = const Color(0xFFFBBF24).withValues(alpha: 0.4);
            statusLabel = context.isArabic ? 'تعديلات معلقة' : 'Pending';
            break;
          case CloudSyncStatus.error:
            icon = Icons.cloud_off_rounded;
            iconColor = const Color(0xFFC5221F);
            badgeBgColor = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFCE8E6);
            badgeBorderColor = const Color(0xFFF87171).withValues(alpha: 0.4);
            statusLabel = context.isArabic ? 'خطأ مزامنة' : 'Sync error';
            break;
          case CloudSyncStatus.synced:
            icon = Icons.cloud_done_rounded;
            iconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333);
            badgeBgColor = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFE6F4EA);
            badgeBorderColor = isDark ? const Color(0xFF22C55E).withValues(alpha: 0.3) : const Color(0xFFA7F3D0);
            statusLabel = context.isArabic ? 'مُزامن' : 'Synced';
            break;
        }

        if (compact) {
          return InkWell(
            onTap: () => _showSyncDetailsModal(context, state),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeBgColor,
                shape: BoxShape.circle,
                border: Border.all(color: badgeBorderColor, width: 0.8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
          );
        }

        return InkWell(
          onTap: () => _showSyncDetailsModal(context, state),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badgeBorderColor, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: iconColor),
                if (showLabel) ...[
                  const SizedBox(width: 5),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
