import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../../core/shared/widgets/sync_status_badge.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/sync/sync_cubit.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../security/ui/security_screen.dart';
import '../../settings/ui/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final authUser = context.watch<AuthCubit>().state.user;
    final syncState = context.watch<SyncCubit>().state;

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: SyncStatusBadge(),
          ),
        ),
        leadingWidth: 115,
        title: Text(
          context.isArabic ? 'الملف الشخصي والحساب' : 'Profile & Account',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // Profile Header Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authUser?.displayName ?? (context.isArabic ? 'مدير المحفظة والأسطول' : 'Fleet Manager'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authUser?.email ?? 'ahmed.salem@sadattaxis.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF137333).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.isArabic ? 'حساب سحابي موثق' : 'Verified Cloud Account',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF137333),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.isArabic ? 'أندرويد + ويندوز' : 'Android & Windows',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cloud Sync Status Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cloud_done_outlined, size: 20, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            context.isArabic ? 'حالة المزامنة السحابية' : 'Cloud Sync Status',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                          ),
                        ],
                      ),
                      const SyncStatusBadge(showLabel: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.isArabic ? 'آخر مزامنة ناجحة:' : 'Last Synced:',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      Text(
                        syncState.lastSyncTime != null
                            ? context.formatShortDate(syncState.lastSyncTime)
                            : (context.isArabic ? 'الآن' : 'Just now'),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.sync_rounded, size: 16),
                      label: Text(
                        context.isArabic ? 'مزامنة فورية الآن' : 'Sync Now',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final res = await context.read<SyncCubit>().triggerSync(force: true);
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            message: res.isOnline
                                ? (context.isArabic ? 'تمت المزامنة بنجاح' : 'Synced successfully')
                                : (context.isArabic ? 'تم الحفظ محلياً' : 'Saved locally'),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings & Security Options
            SectionHeader(
              title: context.isArabic ? 'إدارة النظام والتفضيلات' : 'System & Preferences',
              leadingIcon: Icons.tune_rounded,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileOptionTile(
                    icon: Icons.security_rounded,
                    title: context.isArabic ? 'الأمان والتحقق البيومتري' : 'Security & Biometrics',
                    subtitle: context.isArabic ? 'بصمة الإصبع ورمز المرور السري' : 'Fingerprint & Passcode',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.settings_outlined,
                    title: context.isArabic ? 'إعدادات المظهر واللغة' : 'Appearance & Language',
                    subtitle: context.isArabic ? 'الوضع الداكن واللغة العربية/الإنجليزية' : 'Dark mode & Arabic/English',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // About App Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.isArabic ? 'عن نظام إدارة تاكسيات السادات' : 'About Sadat Taxis System',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.isArabic
                        ? 'منظومة متكاملة لإدارة أصول التاكسيات وحصص الشركاء والمصروفات، متوافقة للعمل بكفاءة عالية على نسختي الأندرويد والويندوز مع مزامنة سحابية تلقائية ودعم كامل للعمل بدون إنترنت (Offline-First).'
                        : 'Integrated system for managing taxi fleet assets, partner shares, and expenses across Android & Windows with auto-sync and offline-first support.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.isArabic ? 'الإصدار 1.0.0 (Android & Windows Edition 2026)' : 'Version 1.0.0 (Android & Windows Edition 2026)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: textSecondary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }
}
