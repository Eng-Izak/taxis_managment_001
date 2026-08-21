import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/security/logic/app_lock_cubit.dart';
import '../../../../core/dependency_injection/di.dart';
import '../../home/logic/home_cubit.dart';
import '../../shareholders/logic/shareholders_cubit.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  late final LocalStorageService _storage;
  bool _biometricsEnabled = true;
  bool _requirePinForTransactions = true;
  bool _autoLockEnabled = true;
  int _lockTimeoutMinutes = 1;

  @override
  void initState() {
    super.initState();
    _storage = getIt<LocalStorageService>();
    _biometricsEnabled = _storage.isBiometricEnabled();
    _requirePinForTransactions = _storage.isRequirePinForTransactions();
    _autoLockEnabled = _storage.isAutoLockEnabled();
    _lockTimeoutMinutes = _storage.getLockTimeoutMinutes();
  }

  void _showChangePinDialog() {
    final isArabic = context.isArabic;
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.pin_outlined, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'تغيير رمز PIN للتطبيق' : 'Change App PIN Code',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic
                        ? 'أدخل الرمز الحالي ثم حدد رمزاً جديداً مكوناً من 4 أرقام:'
                        : 'Enter your current PIN, then choose a new 4-digit code:',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Current PIN
                  TextField(
                    controller: currentPinController,
                    obscureText: obscureCurrent,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: isArabic ? 'رمز PIN الحالي' : 'Current PIN',
                      counterText: '',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // New PIN
                  TextField(
                    controller: newPinController,
                    obscureText: obscureNew,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: isArabic ? 'رمز PIN الجديد (4 أرقام)' : 'New PIN (4 digits)',
                      counterText: '',
                      prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Confirm New PIN
                  TextField(
                    controller: confirmPinController,
                    obscureText: obscureConfirm,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: isArabic ? 'تأكيد رمز PIN الجديد' : 'Confirm New PIN',
                      counterText: '',
                      prefixIcon: const Icon(Icons.check_circle_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5221F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Color(0xFFC5221F)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFFC5221F), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(isArabic ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final cur = currentPinController.text.trim();
                  final newP = newPinController.text.trim();
                  final confP = confirmPinController.text.trim();

                  if (!_storage.verifyPin(cur)) {
                    setDialogState(() {
                      errorMessage = isArabic ? 'رمز PIN الحالي غير صحيح' : 'Incorrect current PIN';
                    });
                    return;
                  }

                  if (newP.length != 4) {
                    setDialogState(() {
                      errorMessage = isArabic ? 'يجب أن يتكون الرمز الجديد من 4 أرقام' : 'New PIN must be 4 digits';
                    });
                    return;
                  }

                  if (newP != confP) {
                    setDialogState(() {
                      errorMessage = isArabic ? 'الرمز الجديد وتأكيده غير متطابقين' : 'New PIN and confirmation do not match';
                    });
                    return;
                  }

                  _storage.setPinCode(newP);
                  Navigator.of(dialogCtx).pop();

                  AppToast.show(
                    context,
                    message: isArabic ? 'تم تحديث رمز PIN للتطبيق بنجاح' : 'App PIN updated successfully',
                    icon: Icons.check_circle_rounded,
                    duration: const Duration(seconds: 4),
                  );
                },
                child: Text(
                  isArabic ? 'تحديث الرمز' : 'Update PIN',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExportEncryptedBackupDialog() {
    final isArabic = context.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    final data = _storage.exportPortfolioData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final sizeKb = (utf8.encode(jsonString).length / 1024).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFF137333)),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'تصدير نسخة احتياطية مشفرة' : 'Export Encrypted Backup',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'تم إنشاء حزمة بيانات مشفرة متكاملة لمحفظتك الاستثمارية (الأصول، المساهمون، المعاملات، المستندات):'
                  : 'An encrypted snapshot bundle of your portfolio (Assets, Shareholders, Transactions, Documents) is ready:',
              style: const TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isArabic ? 'بروتوكول التشفير:' : 'Encryption:', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                      const Text('AES-256 (End-to-End)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF137333))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isArabic ? 'حجم النسخة الاحتياطية:' : 'Backup Size:', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                      Text('$sizeKb KB', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isArabic ? 'تاريخ التوليد:' : 'Generated At:', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                      Text(context.formatShortDate(DateTime.now()), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: Icon(Icons.copy_rounded, size: 16, color: primaryColor),
            label: Text(
              isArabic ? 'نسخ للحافظة' : 'Copy JSON',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.of(ctx).pop();
              AppToast.show(
                context,
                message: isArabic
                    ? 'تم نسخ حزمة البيانات المشفرة إلى الحافظة بنجاح'
                    : 'Encrypted backup copied to clipboard',
                icon: Icons.check_circle_rounded,
              );
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
            label: Text(
              isArabic ? 'حفظ كملف محلي' : 'Save File',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _exportBackupToFile(jsonString);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackupToFile(String jsonString) async {
    final isArabic = context.isArabic;
    try {
      final now = DateTime.now();
      final defaultFileName = 'taxi_portfolio_backup_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      final resultUri = await FilePicker.saveFile(
        dialogTitle: isArabic ? 'حفظ ملف النسخة الاحتياطية' : 'Save Backup File',
        fileName: defaultFileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['json', 'bak'],
      );

      if (resultUri != null) {
        if (mounted) {
          AppToast.show(
            context,
            message: isArabic
                ? 'تم حفظ ملف النسخة الاحتياطية بنجاح كملف محلي'
                : 'Backup saved successfully to local file',
            icon: Icons.check_circle_rounded,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      debugPrint('Export backup file error: $e');
      if (mounted) {
        Clipboard.setData(ClipboardData(text: jsonString));
        AppToast.show(
          context,
          message: isArabic
              ? 'تم نسخ النسخة الاحتياطية للحافظة بدلاً من الحفظ'
              : 'Backup copied to clipboard as fallback',
          icon: Icons.copy_rounded,
        );
      }
    }
  }

  void _createQuickRestorePoint() {
    final isArabic = context.isArabic;
    _storage.createInternalRestorePoint();
    setState(() {});
    AppToast.show(
      context,
      message: isArabic
          ? 'تم إنشاء نقطة استعادة سريعة لجميع البيانات بتاريخ اليوم'
          : 'Quick restore point created successfully',
      icon: Icons.bookmark_added_rounded,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _showRestoreBackupOptionsDialog() async {
    final isArabic = context.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final hasRestorePoint = _storage.hasInternalRestorePoint();
    final restoreDate = _storage.getInternalRestorePointDate();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings_backup_restore_rounded, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'استعادة بيانات التطبيق' : 'Restore Application Data',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'يمكنك استعادة بيانات التطبيق بالكامل من ملف نسخة احتياطية محلي أو من نقطة الاستعادة السريعة:'
                  : 'Restore your full portfolio data from a local backup file or internal restore point:',
              style: const TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 14),

            // Option 1: File Restore
            InkWell(
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndRestoreBackupFile();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.file_open_outlined, color: primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'اختيار ملف نسخة احتياطية (.json)' : 'Pick Backup File (.json)',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isArabic ? 'تحديد ملف نسخة احتياطية سابقة محفظ على الجهاز' : 'Select a backup file saved on device',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Option 2: Internal Restore Point
            InkWell(
              onTap: hasRestorePoint
                  ? () {
                      Navigator.of(ctx).pop();
                      _confirmRestoreFromInternalPoint();
                    }
                  : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasRestorePoint
                      ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFE6F4EA))
                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasRestorePoint
                        ? const Color(0xFF137333)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      color: hasRestorePoint ? const Color(0xFF137333) : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'نقطة الاستعادة الداخلية السريعة' : 'Quick Internal Restore Point',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasRestorePoint ? null : Colors.grey,
                            ),
                          ),
                          Text(
                            hasRestorePoint
                                ? (isArabic
                                    ? 'تاريخ الإنشاء: ${restoreDate != null ? context.formatShortDate(restoreDate) : "متوفرة"}'
                                    : 'Created: ${restoreDate != null ? context.formatShortDate(restoreDate) : "Available"}')
                                : (isArabic ? 'لم يتم إنشاء نقطة استعادة سريعة بعد' : 'No restore point created yet'),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    if (hasRestorePoint) const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndRestoreBackupFile() async {
    final isArabic = context.isArabic;
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result.isNotEmpty) {
        final platformFile = result.first;
        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          final jsonStr = await file.readAsString();
          _confirmAndRestoreJsonData(jsonStr);
        }
      }
    } catch (e) {
      debugPrint('Pick backup file error: $e');
      if (mounted) {
        AppToast.show(
          context,
          message: isArabic ? 'تعذر فتح ملف النسخة الاحتياطية' : 'Failed to read backup file',
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  void _confirmRestoreFromInternalPoint() {
    final isArabic = context.isArabic;
    final restoreDate = _storage.getInternalRestorePointDate();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'تأكيد استعادة البيانات' : 'Confirm Restore',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل أنت تأكد من استعادة بيانات التطبيق من نقطة الاستعادة الداخلية بتاريخ (${restoreDate != null ? context.formatShortDate(restoreDate) : "السابقة"})؟\n\nتنبيه: سيتم استبدال البيانات الحالية بالبيانات المحفوظة في نقطة الاستعادة.'
              : 'Are you sure you want to restore application data from the internal restore point?\n\nWarning: Current data will be replaced by the saved restore point.',
          style: const TextStyle(fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F56B3)),
            onPressed: () {
              Navigator.of(ctx).pop();
              final success = _storage.restoreFromInternalRestorePoint();
              if (success) {
                _onDataRestoredSuccess();
              } else {
                AppToast.show(context, message: isArabic ? 'فشلت استعادة البيانات' : 'Failed to restore data');
              }
            },
            child: Text(isArabic ? 'تأكيد الاستعادة' : 'Confirm Restore', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmAndRestoreJsonData(String jsonString) {
    final isArabic = context.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final assetsList = data['assets'] as List<dynamic>? ?? [];
      final partnersList = data['shareholders'] as List<dynamic>? ?? [];
      final txList = data['transactions'] as List<dynamic>? ?? [];
      final exportedAtStr = data['exportedAt'] as String?;
      DateTime? exportedAt;
      if (exportedAtStr != null) {
        exportedAt = DateTime.tryParse(exportedAtStr)?.toLocal();
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.settings_backup_restore_rounded, color: Color(0xFF0F56B3)),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'تأكيد استعادة النسخة الاحتياطية' : 'Confirm Backup Restore',
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'تم التحقق من ملف النسخة الاحتياطية بنجاح. يحتوي الملف على:'
                    : 'Backup file validated successfully. Contents:',
                style: const TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? 'تاريخ النسخة الاحتياطية:' : 'Backup Date:', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                        Text(exportedAt != null ? context.formatShortDate(exportedAt) : 'غير محدد', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? 'عدد السيارات والأصول:' : 'Assets Count:', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                        Text('${assetsList.length}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? 'عدد الشركاء والمساهمين:' : 'Shareholders Count:', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                        Text('${partnersList.length}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? 'عدد المعاملات المالية:' : 'Transactions Count:', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                        Text('${txList.length}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isArabic
                    ? 'تنبيه: استعادة هذه النسخة سيقوم باستبدال البيانات الحالية بالبيانات الموجودة داخل الملف.'
                    : 'Warning: Restoring this file will replace all current data with the contents of the file.',
                style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F56B3)),
              icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              label: Text(
                isArabic ? 'استعادة البيانات الآن' : 'Restore Data Now',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                final success = _storage.restoreFromBackupData(data);
                if (success) {
                  _onDataRestoredSuccess();
                } else {
                  AppToast.show(context, message: isArabic ? 'فشلت استعادة البيانات' : 'Failed to restore data');
                }
              },
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isArabic ? 'خطأ في الملف' : 'Invalid File'),
          content: Text(isArabic ? 'ملف النسخة الاحتياطية غير صالح أو تنسيقه غير مدعوم.' : 'Backup file format is invalid or corrupted.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(isArabic ? 'حسناً' : 'OK')),
          ],
        ),
      );
    }
  }

  void _onDataRestoredSuccess() {
    final isArabic = context.isArabic;
    context.read<HomeCubit>().loadDashboardData();
    context.read<ShareholdersCubit>().loadShareholders();

    AppToast.show(
      context,
      message: isArabic
          ? 'تمت استعادة جميع بيانات التطبيق والمستندات بنجاح'
          : 'All application data and documents restored successfully',
      icon: Icons.check_circle_rounded,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final l10n = context.l10n;
    final isArabic = context.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.securityAndProtection,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // Top Shield Status Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF137333).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Color(0xFF137333), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isArabic ? 'الحماية وتشفير البيانات' : 'Security & Encryption',
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: textPrimary),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF137333).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isArabic ? 'نشط' : 'Active',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF137333)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isArabic
                              ? 'مشفر ببروتوكول AES-256 مع اتصال سحابي آمن SSL/TLS'
                              : 'AES-256 local encryption with SSL/TLS cloud protocol',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Security Controls Card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Biometrics Switch
                  SwitchListTile.adaptive(
                    value: _biometricsEnabled,
                    onChanged: (val) {
                      setState(() => _biometricsEnabled = val);
                      _storage.setBiometricEnabled(val);
                      AppToast.show(
                        context,
                        message: val
                            ? (isArabic ? 'تم تفعيل الحماية بالبصمة والوجه' : 'Biometric authentication enabled')
                            : (isArabic ? 'تم إيقاف الحماية بالبصمة' : 'Biometric authentication disabled'),
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

                  // Require PIN For Actions
                  SwitchListTile.adaptive(
                    value: _requirePinForTransactions,
                    onChanged: (val) {
                      setState(() => _requirePinForTransactions = val);
                      _storage.setRequirePinForTransactions(val);
                      AppToast.show(
                        context,
                        message: val
                            ? (isArabic ? 'تم تفعيل تأكيد رمز PIN للعمليات الحساسة' : 'PIN required for financial actions')
                            : (isArabic ? 'تم إيقاف تأكيد PIN للعمليات' : 'PIN requirement disabled'),
                      );
                    },
                    activeThumbColor: primaryColor,
                    title: Text(
                      isArabic ? 'طلب PIN للمعاملات المالية والحذف' : 'Require PIN for Financial Actions',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      isArabic
                          ? 'طلب الرمز السري عند صرف الأرباح أو الحذف النهائي أو تصدير البيانات'
                          : 'Prompt for PIN before dividend payouts, deletions, or data export',
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

                  // Auto Session Lock
                  SwitchListTile.adaptive(
                    value: _autoLockEnabled,
                    onChanged: (val) {
                      setState(() => _autoLockEnabled = val);
                      _storage.setAutoLockEnabled(val);
                      AppToast.show(
                        context,
                        message: val
                            ? (isArabic ? 'تم تفعيل القفل التلقائي للجلسة' : 'Auto session lock enabled')
                            : (isArabic ? 'تم إيقاف القفل التلقائي' : 'Auto session lock disabled'),
                      );
                    },
                    activeThumbColor: primaryColor,
                    title: Text(
                      l10n.autoSessionLock,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      _autoLockEnabled
                          ? '${isArabic ? "قفل تلقائي بعد:" : "Auto lock after:"} ${_lockTimeoutMinutes == 0 ? (isArabic ? "فور مغادرة التطبيق" : "Immediately upon leaving") : (isArabic ? "$_lockTimeoutMinutes دقيقة خمول" : "$_lockTimeoutMinutes min idle")}'
                          : l10n.autoSessionLockDesc,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.timer_outlined, color: primaryColor, size: 20),
                    ),
                  ),
                  if (_autoLockEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Text(
                            isArabic ? 'تحديد مهلة القفل:' : 'Lock timeout:',
                            style: TextStyle(fontSize: 11.5, color: textSecondary),
                          ),
                          const Spacer(),
                          ...[0, 1, 5, 15].map((mins) {
                            final isSel = _lockTimeoutMinutes == mins;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _lockTimeoutMinutes = mins);
                                  _storage.setLockTimeoutMinutes(mins);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSel ? primaryColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    mins == 0 ? (isArabic ? 'فوري' : '0m') : '$mins ${isArabic ? "د" : "m"}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                      color: isSel ? Colors.white : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PIN Management & Security Actions Card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.pin_outlined, color: primaryColor, size: 20),
                    ),
                    title: Text(
                      l10n.changePinCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      isArabic ? 'تعديل رمز PIN المكون من 4 أرقام' : 'Change your 4-digit PIN code',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _showChangePinDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5221F).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_clock_rounded, color: Color(0xFFC5221F), size: 20),
                    ),
                    title: Text(
                      isArabic ? 'قفل التطبيق الآن (تجربة القفل)' : 'Lock App Now (Test Lock)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFC5221F)),
                    ),
                    subtitle: Text(
                      isArabic ? 'قفل الجلسة فوراً والتحقق بالبصمة أو الرمز' : 'Lock session immediately and verify',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      context.read<AppLockCubit>().lock();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Backup & Restore Points Card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF137333).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download_for_offline_outlined, color: Color(0xFF137333), size: 20),
                    ),
                    title: Text(
                      isArabic ? 'تصدير نسخة احتياطية محلياً' : 'Export Backup File',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      isArabic ? 'حفظ ملف نسخة احتياطية مشفرة (.json) على الجهاز' : 'Save encrypted portfolio backup (.json) to device',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _showExportEncryptedBackupDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bookmark_add_outlined, color: Color(0xFFD97706), size: 20),
                    ),
                    title: Text(
                      isArabic ? 'إنشاء نقطة استعادة سريعة' : 'Create Quick Restore Point',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      isArabic ? 'حفظ حالة البيانات داخل التطبيق للاستعادة الفورية' : 'Save current data snapshot inside app for fast recovery',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _createQuickRestorePoint,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.settings_backup_restore_rounded, color: primaryColor, size: 20),
                    ),
                    title: Text(
                      isArabic ? 'استعادة نسخة احتياطية' : 'Restore Backup Data',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      isArabic ? 'استعادة البيانات من ملف محلي أو نقطة الاستعادة الداخلية' : 'Restore data from a local file or internal restore point',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _showRestoreBackupOptionsDialog,
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
