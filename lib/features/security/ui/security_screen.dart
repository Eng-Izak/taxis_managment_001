import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_button.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricsEnabled = true;
  bool _requirePinForTransactions = true;
  bool _autoLockEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الأمان والتحقق البيومتري',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _biometricsEnabled,
                    onChanged: (val) => setState(() => _biometricsEnabled = val),
                    activeThumbColor: primaryColor,
                    title: const Text(
                      'تفعيل بصمة الإصبع / Face ID',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'تسجيل الدخول السريع عبر المصادقة البيومترية',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Icon(Icons.fingerprint_rounded, color: primaryColor),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _requirePinForTransactions,
                    onChanged: (val) => setState(() => _requirePinForTransactions = val),
                    activeThumbColor: primaryColor,
                    title: const Text(
                      'طلب رمز PIN عند تسجيل المعاملات',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'تأكيد إضافي قبل صرف الأرباح أو إضافة المصروفات',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Icon(Icons.lock_outline_rounded, color: primaryColor),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: _autoLockEnabled,
                    onChanged: (val) => setState(() => _autoLockEnabled = val),
                    activeThumbColor: primaryColor,
                    title: const Text(
                      'القفل التلقائي للتطبيق',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'قفل الشاشة عند مغادرة التطبيق لمدة 3 دقائق',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    secondary: Icon(Icons.timer_outlined, color: primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'تغيير رمز المرور (PIN Code)',
              variant: AppButtonVariant.outline,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم فتح نافذة تحديث رمز المرور')),
                );
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
