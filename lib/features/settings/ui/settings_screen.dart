import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
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
  bool _isDarkMode = false;
  String _selectedLanguage = 'العربية (Arabic)';
  bool _rentDueAlerts = true;
  bool _maintenanceAlerts = true;
  bool _licenseRenewalAlerts = true;
  bool _biometricEnabled = true;
  bool _autoLockEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SadatTaxiLogo(),
            SizedBox(width: 8),
            Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          NotificationBellButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
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
            // Section 1: المظهر والسمة
            const SectionHeader(
              title: 'المظهر والسمة العامة',
              leadingIcon: Icons.palette_outlined,
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SwitchListTile.adaptive(
                value: _isDarkMode,
                onChanged: (val) => setState(() => _isDarkMode = val),
                activeThumbColor: AppColors.primary,
                title: const Text(
                  'الوضع الداكن (Dark Theme)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  'تفعيل المظهر الداكن لتقليل إجهاد العين وتوفير الطاقة',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: لغة واجهة التطبيق
            const SectionHeader(
              title: 'لغة واجهة التطبيق (Language)',
              leadingIcon: Icons.language_rounded,
            ),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _LanguageSelectionTile(
                    label: 'العربية (RTL - اللغة الأساسية)',
                    isSelected: _selectedLanguage == 'العربية (Arabic)',
                    onTap: () => setState(() => _selectedLanguage = 'العربية (Arabic)'),
                  ),
                  const SizedBox(height: 8),
                  _LanguageSelectionTile(
                    label: 'English (LTR)',
                    isSelected: _selectedLanguage == 'English',
                    onTap: () => setState(() => _selectedLanguage = 'English'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: إعدادات الإشعارات والتنبيهات
            const SectionHeader(
              title: 'إعدادات الإشعارات والتنبيهات',
              leadingIcon: Icons.notifications_active_outlined,
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _rentDueAlerts,
                    onChanged: (val) => setState(() => _rentDueAlerts = val),
                    activeThumbColor: AppColors.primary,
                    title: const Text(
                      'تنبيهات استحقاق الإيجارات',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'إشعارات فورية عند استحقاق أو تأخر إيجار السائقين',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF7E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.monetization_on_outlined, color: Color(0xFFB06000), size: 20),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _maintenanceAlerts,
                    onChanged: (val) => setState(() => _maintenanceAlerts = val),
                    activeThumbColor: AppColors.primary,
                    title: const Text(
                      'مواعيد الصيانة الدورية',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'تذكير بمواعيد تغيير الزيت والفحص الدوري للسيارات',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.build_outlined, color: Color(0xFF0F56B3), size: 20),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _licenseRenewalAlerts,
                    onChanged: (val) => setState(() => _licenseRenewalAlerts = val),
                    activeThumbColor: AppColors.primary,
                    title: const Text(
                      'تجديد رخص التسيير والتأمين',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'إشعار مسبق قبل انتهاء التراخيص بـ 30 يوماً',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description_outlined, color: Color(0xFF137333), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 4: الأمان والتحقق
            const SectionHeader(
              title: 'الأمان وحماية البيانات',
              leadingIcon: Icons.security_rounded,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _biometricEnabled,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                    activeThumbColor: AppColors.primary,
                    title: const Text(
                      'التحقق ببصمة الإصبع / الوجه',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'طلب المصادقة البيومترية عند فتح التطبيق',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 20),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _autoLockEnabled,
                    onChanged: (val) => setState(() => _autoLockEnabled = val),
                    activeThumbColor: AppColors.primary,
                    title: const Text(
                      'القفل التلقائي للجلسة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'قفل الشاشة عند الخروج من التطبيق للحماية',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_clock_outlined, color: AppColors.primary, size: 20),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pin_outlined, color: AppColors.primary, size: 20),
                    ),
                    title: const Text('إعدادات رمز المرور المتقدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('تغيير كود PIN السري للمحفظة', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
            const SectionHeader(
              title: 'النسخ الاحتياطي وتصدير التقارير',
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
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.file_download_outlined, color: Color(0xFF0F56B3), size: 20),
                    ),
                    title: const Text('تصدير تقرير المحفظة والأرباح (Excel/PDF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('تنزيل كشف حساب شامل وتوزيعات الشركاء', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تصدير كشف الحساب بنجاح!')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sync_rounded, color: Color(0xFF137333), size: 20),
                    ),
                    title: const Text('المزامنة السحابية الفورية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('آخر مزامنة ناجحة: اليوم 09:30 ص', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    trailing: const Text('متصل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF137333))),
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
                  const Row(
                    children: [
                      SadatTaxiLogo(size: 24),
                      SizedBox(width: 8),
                      Text(
                        'نظام إدارة أصول تاكسيات مدينة السادات',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'منصة استثمارية متخصصة لإدارة حصص الشركاء، عقود الإيجار، وتوزيعات الأرباح الشهرية للأسطول التجاري.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الإصدار 1.0.0 (Build 2026) - El Sadat City Fleet Manager',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
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
                color: isSelected ? AppColors.primary : const Color(0xFF1F2937),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18)
            else
              const Icon(Icons.circle_outlined, color: Color(0xFF94A3B8), size: 18),
          ],
        ),
      ),
    );
  }
}
