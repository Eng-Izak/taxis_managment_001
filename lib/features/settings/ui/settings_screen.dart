import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/theme_cubit.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/shared/widgets/sync_status_badge.dart';
import '../../../../core/sync/sync_cubit.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../core/routing/routes.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../notifications/ui/notifications_screen.dart';
import '../../security/ui/security_screen.dart';
import '../../../../core/dependency_injection/di.dart';
import '../../../../core/services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final LocalStorageService _storageService;
  bool _rentDueAlerts = true;
  bool _maintenanceAlerts = true;
  bool _licenseRenewalAlerts = true;
  bool _biometricEnabled = true;
  bool _autoLockEnabled = true;
  bool _requirePinForTransactions = true;

  @override
  void initState() {
    super.initState();
    _storageService = getIt<LocalStorageService>();
    _biometricEnabled = _storageService.isBiometricEnabled();
    _autoLockEnabled = _storageService.isAutoLockEnabled();
    _requirePinForTransactions = _storageService.isRequirePinForTransactions();
  }

  void _showSwitchAccountDialog(BuildContext context) {
    final emailController = TextEditingController(text: context.read<AuthCubit>().state.user?.email ?? '');
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.switch_account_rounded, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                context.isArabic ? 'ربط بريد إلكتروني آخر' : 'Switch Email Account',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.isArabic
                    ? 'أدخل البريد الإلكتروني لمزامنة محفظتك الاستثمارية عليه بين الأندرويد والويندوز:'
                    : 'Enter email to synchronize your fleet portfolio across Android & Windows:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.isArabic ? 'البريد الإلكتروني' : 'Email Address',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  Navigator.of(ctx).pop();
                  await context.read<AuthCubit>().loginWithEmail(
                    email: email,
                    passwordOrPin: '1234',
                  );
                  if (context.mounted) {
                    AppToast.show(
                      context,
                      message: context.isArabic
                          ? 'تم ربط الحساب بالبريد: $email وجاري المزامنة السحابية'
                          : 'Linked to $email & sync initiated',
                    );
                  }
                }
              },
              child: Text(
                context.isArabic ? 'حفظ ومزامنة' : 'Save & Sync',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.isArabic ? 'تسجيل الخروج' : 'Sign Out'),
        content: Text(
          context.isArabic
              ? 'هل ترغب في تسجيل الخروج؟ ستبقى بياناتك محفوظة ومزامنة في السحابة على بريدك الإلكتروني.'
              : 'Are you sure you want to sign out? Your portfolio remains saved & synced in the cloud.',
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
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                context.go(Routes.login);
              }
            },
            child: Text(
              context.isArabic ? 'تسجيل الخروج' : 'Sign Out',
              style: const TextStyle(color: Colors.white),
            ),
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
    final currentThemeMode = context.watch<ThemeCubit>().state;
    final currentLocale = context.watch<LocaleCubit>().state;
    final authUser = context.watch<AuthCubit>().state.user;
    final syncState = context.watch<SyncCubit>().state;
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
              l10n.settings,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: primaryColor,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 0: الحساب والمزامنة السحابية (Cloud Sync & Email Account)
            SectionHeader(
              title: context.isArabic ? 'الحساب والمزامنة السحابية (Android & Windows)' : 'Account & Cloud Sync (Android & Windows)',
              leadingIcon: Icons.cloud_sync_rounded,
            ),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile & Email Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        child: Icon(Icons.person_rounded, size: 28, color: primaryColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  authUser?.displayName ?? (context.isArabic ? 'مدير المحفظة والأسطول' : 'Fleet Manager'),
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF137333).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.isArabic ? 'موثق' : 'Verified',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF137333),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authUser?.email ?? 'ahmed.salem@sadattaxis.com',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                        tooltip: context.isArabic ? 'تغيير الحساب' : 'Switch account',
                        onPressed: () => _showSwitchAccountDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Sync Status Info Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: syncState.isOnline ? const Color(0xFF137333) : const Color(0xFFD97706),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  syncState.isOnline
                                      ? (context.isArabic ? 'متصل بالسحابة (مزامنة تلقائية)' : 'Connected to Cloud (Auto-Sync)')
                                      : (context.isArabic ? 'وضع محلي (البيانات محفوظة)' : 'Offline Mode (Data Saved Locally)'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              syncState.lastSyncTime != null
                                  ? '${context.isArabic ? "آخر مزامنة:" : "Last sync:"} ${context.formatShortDate(syncState.lastSyncTime)}'
                                  : (context.isArabic ? 'آخر مزامنة: الآن' : 'Last sync: Just now'),
                              style: TextStyle(fontSize: 11, color: textSecondary),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: syncState.status == CloudSyncStatus.syncing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.sync_rounded, size: 16, color: Colors.white),
                          label: Text(
                            syncState.status == CloudSyncStatus.syncing
                                ? (context.isArabic ? 'جاري المزامنة...' : 'Syncing...')
                                : (context.isArabic ? 'مزامنة الآن' : 'Sync Now'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: syncState.status == CloudSyncStatus.syncing
                              ? null
                              : () async {
                                  final res = await context.read<SyncCubit>().triggerSync(force: true);
                                  if (context.mounted) {
                                    context.read<AuthCubit>().refreshUser();
                                    AppToast.show(
                                      context,
                                      message: res.isOnline
                                          ? (context.isArabic ? 'تمت مزامنة المحفظة مع السحابة بنجاح' : 'Portfolio synced with cloud')
                                          : (context.isArabic ? 'تم حفظ التعديلات محلياً بنجاح' : 'Saved locally (Offline)'),
                                      icon: Icons.cloud_done_rounded,
                                      duration: const Duration(seconds: 4),
                                    );
                                  }
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Auto Sync Switch
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: syncState.autoSyncEnabled,
                    activeThumbColor: primaryColor,
                    title: Text(
                      context.isArabic ? 'المزامنة السحابية اللحظية في الخلفية' : 'Real-time Background Sync',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      context.isArabic
                          ? 'مزامنة التعديلات تلقائياً بين نسخة الأندرويد والويندوز فور توفر الإنترنت'
                          : 'Auto-sync updates between Android & Windows devices when online',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    onChanged: (val) {
                      context.read<SyncCubit>().toggleAutoSync(val);
                      context.read<AuthCubit>().toggleAutoSync(val);
                      AppToast.show(
                        context,
                        message: val
                            ? (context.isArabic ? 'تم تفعيل المزامنة التلقائية اللحظية' : 'Real-time auto-sync enabled')
                            : (context.isArabic ? 'تم إيقاف المزامنة التلقائية' : 'Auto-sync disabled'),
                        duration: const Duration(seconds: 3),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: المظهر والسمة
            SectionHeader(
              title: l10n.appearanceAndTheme,
              leadingIcon: Icons.palette_outlined,
            ),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _ThemeSelectionTile(
                    label: l10n.lightMode,
                    subtitle: l10n.lightModeDesc,
                    icon: Icons.light_mode_rounded,
                    isSelected: currentThemeMode == ThemeMode.light,
                    iconColor: const Color(0xFFD97706),
                    onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(height: 8),
                  _ThemeSelectionTile(
                    label: l10n.darkMode,
                    subtitle: l10n.darkModeDesc,
                    icon: Icons.dark_mode_rounded,
                    isSelected: currentThemeMode == ThemeMode.dark,
                    iconColor: const Color(0xFF3B82F6),
                    onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(height: 8),
                  _ThemeSelectionTile(
                    label: l10n.systemTheme,
                    subtitle: l10n.systemThemeDesc,
                    icon: Icons.brightness_auto_rounded,
                    isSelected: currentThemeMode == ThemeMode.system,
                    iconColor: const Color(0xFF10B981),
                    onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: لغة واجهة التطبيق
            SectionHeader(
              title: l10n.languageSettings,
              leadingIcon: Icons.language_rounded,
            ),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _LanguageSelectionTile(
                    label: l10n.arabicLanguage,
                    isSelected: currentLocale.languageCode == 'ar',
                    onTap: () => context.read<LocaleCubit>().setArabic(),
                  ),
                  const SizedBox(height: 8),
                  _LanguageSelectionTile(
                    label: l10n.englishLanguage,
                    isSelected: currentLocale.languageCode == 'en',
                    onTap: () => context.read<LocaleCubit>().setEnglish(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: إعدادات الإشعارات والتنبيهات
            SectionHeader(
              title: l10n.notificationSettings,
              leadingIcon: Icons.notifications_active_outlined,
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _rentDueAlerts,
                    onChanged: (val) => setState(() => _rentDueAlerts = val),
                    activeThumbColor: primaryColor,
                    title: Text(
                      l10n.rentDueAlerts,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.rentDueAlertsDesc,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.monetization_on_outlined,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000),
                        size: 20,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _maintenanceAlerts,
                    onChanged: (val) => setState(() => _maintenanceAlerts = val),
                    activeThumbColor: primaryColor,
                    title: Text(
                      l10n.maintenanceAlerts,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.maintenanceAlertsDesc,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.build_outlined,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3),
                        size: 20,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _licenseRenewalAlerts,
                    onChanged: (val) => setState(() => _licenseRenewalAlerts = val),
                    activeThumbColor: primaryColor,
                    title: Text(
                      l10n.licenseRenewalAlerts,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.licenseRenewalAlertsDesc,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 4: الأمان والتحقق وحماية البيانات
            SectionHeader(
              title: context.isArabic ? 'الأمان والتحقق وحماية البيانات' : 'Security, Auth & Data Protection',
              leadingIcon: Icons.security_rounded,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Biometric Switch
                  SwitchListTile.adaptive(
                    value: _biometricEnabled,
                    onChanged: (val) {
                      setState(() => _biometricEnabled = val);
                      _storageService.setBiometricEnabled(val);
                      AppToast.show(
                        context,
                        message: val
                            ? (context.isArabic ? 'تم تفعيل الحماية بالبصمة والوجه' : 'Biometric authentication enabled')
                            : (context.isArabic ? 'تم إيقاف الحماية بالبصمة' : 'Biometric authentication disabled'),
                      );
                    },
                    activeThumbColor: primaryColor,
                    title: Text(
                      l10n.biometricAuth,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.biometricAuthDesc,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fingerprint_rounded, color: primaryColor, size: 20),
                    ),
                  ),
                  const Divider(height: 1),

                  // Require PIN for Financial Actions Switch
                  SwitchListTile.adaptive(
                    value: _requirePinForTransactions,
                    onChanged: (val) {
                      setState(() => _requirePinForTransactions = val);
                      _storageService.setRequirePinForTransactions(val);
                      AppToast.show(
                        context,
                        message: val
                            ? (context.isArabic ? 'تم تفعيل تأكيد رمز PIN للعمليات الحساسة' : 'PIN required for financial operations')
                            : (context.isArabic ? 'تم إيقاف تأكيد PIN للعمليات' : 'PIN requirement disabled'),
                      );
                    },
                    activeThumbColor: primaryColor,
                    title: Text(
                      context.isArabic ? 'طلب رمز PIN للعمليات المالية والحذف' : 'Require PIN for Financial Actions',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      context.isArabic
                          ? 'طلب الرمز السري عند صرف الأرباح أو الحذف النهائي من الأرشيف'
                          : 'Prompt for PIN before dividend payouts or permanent deletions',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lock_outline_rounded, color: primaryColor, size: 20),
                    ),
                  ),
                  const Divider(height: 1),

                  // Auto Session Lock Switch
                  SwitchListTile.adaptive(
                    value: _autoLockEnabled,
                    onChanged: (val) {
                      setState(() => _autoLockEnabled = val);
                      _storageService.setAutoLockEnabled(val);
                      AppToast.show(
                        context,
                        message: val
                            ? (context.isArabic ? 'تم تفعيل القفل التلقائي للجلسة' : 'Auto session lock enabled')
                            : (context.isArabic ? 'تم إيقاف القفل التلقائي' : 'Auto session lock disabled'),
                      );
                    },
                    activeThumbColor: primaryColor,
                    title: Text(
                      l10n.autoSessionLock,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.autoSessionLockDesc,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lock_clock_outlined, color: primaryColor, size: 20),
                    ),
                  ),
                  const Divider(height: 1),

                  // PIN Settings Tile
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.pin_outlined, color: primaryColor, size: 20),
                    ),
                    title: Text(l10n.passcodeSettings, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      context.isArabic ? 'تعديل رمز PIN المكون من 4 أرقام وإدارة الأمان المتقدم' : 'Change 4-digit PIN & advanced security controls',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SecurityScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // Backup & Restore Points Tile
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF137333).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.settings_backup_restore_rounded, color: Color(0xFF137333), size: 20),
                    ),
                    title: Text(
                      context.isArabic ? 'النسخ الاحتياطي ونقاط الاستعادة' : 'Backup & Restore Points',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      context.isArabic
                          ? 'تصدير ملف نسخة احتياطية (.json)، نقطة استعادة سريعة، أو استعادة البيانات'
                          : 'Export local backup file (.json), quick restore point, or restore portfolio',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SecurityScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 5: Sign Out & Account Action
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5221F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFC5221F), size: 20),
                ),
                title: Text(
                  context.isArabic ? 'تسجيل الخروج من الحساب' : 'Sign Out Account',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFC5221F)),
                ),
                subtitle: Text(
                  context.isArabic ? 'الاحتفاظ بآخر نسخة في السحابة وتسجيل الخروج' : 'Keep cloud backup and sign out',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
                onTap: () => _confirmSignOut(context),
              ),
            ),

            const SizedBox(height: 20),

            // Section 6: عن النظام والدعم
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SadatTaxiLogo(size: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.systemName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.systemDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.systemVersion} - Android & Windows Edition',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8),
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

class _ThemeSelectionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color iconColor;
  final VoidCallback onTap;

  const _ThemeSelectionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.35) : const Color(0xFFE8F0FE))
              : (isDark ? const Color(0xFF162032) : const Color(0xFFF8F9FA)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937)),
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
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 20)
            else
              Icon(
                Icons.circle_outlined,
                color: isDark ? AppColors.darkCardBorder : const Color(0xFF94A3B8),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelectionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageSelectionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.35) : const Color(0xFFE8F0FE))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : (isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937)),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 18)
            else
              Icon(Icons.circle_outlined, color: isDark ? AppColors.darkCardBorder : const Color(0xFF94A3B8), size: 18),
          ],
        ),
      ),
    );
  }
}
