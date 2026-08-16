import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/theme_cubit.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../notifications/ui/notifications_screen.dart';
import '../../security/ui/security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rentDueAlerts = true;
  bool _maintenanceAlerts = true;
  bool _licenseRenewalAlerts = true;
  bool _biometricEnabled = true;
  bool _autoLockEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = context.watch<ThemeCubit>().state;
    final currentLocale = context.watch<LocaleCubit>().state;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SadatTaxiLogo(),
            const SizedBox(width: 8),
            Text(
              l10n.settings,
              style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    activeThumbColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    title: Text(
                      l10n.rentDueAlerts,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.rentDueAlertsDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
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
                    activeThumbColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    title: Text(
                      l10n.maintenanceAlerts,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.maintenanceAlertsDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
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
                    activeThumbColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    title: Text(
                      l10n.licenseRenewalAlerts,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.licenseRenewalAlertsDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
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

            // Section 4: الأمان والتحقق
            SectionHeader(
              title: l10n.securityAndProtection,
              leadingIcon: Icons.security_rounded,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _biometricEnabled,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                    activeThumbColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    title: Text(
                      l10n.biometricAuth,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.biometricAuthDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fingerprint_rounded,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _autoLockEnabled,
                    onChanged: (val) => setState(() => _autoLockEnabled = val),
                    activeThumbColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    title: Text(
                      l10n.autoSessionLock,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.autoSessionLockDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lock_clock_outlined,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.pin_outlined,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(l10n.passcodeSettings, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      l10n.passcodeSettingsDesc,
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B)),
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

            // Section 5: النسخ الاحتياطي وتصدير البيانات
            SectionHeader(
              title: l10n.backupAndReports,
              leadingIcon: Icons.cloud_sync_outlined,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.file_download_outlined,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3),
                        size: 20,
                      ),
                    ),
                    title: Text(l10n.exportReport, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      l10n.exportReportDesc,
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B)),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.reportExportSuccess)),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.sync_rounded,
                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                        size: 20,
                      ),
                    ),
                    title: Text(l10n.cloudSync, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      l10n.cloudSyncDesc,
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B)),
                    ),
                    trailing: Text(
                      l10n.connected,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.systemVersion,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
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
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

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
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
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
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

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
