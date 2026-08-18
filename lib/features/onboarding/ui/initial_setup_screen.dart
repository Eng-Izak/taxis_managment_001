import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/models/user_model.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_phone_field.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../core/sync/sync_cubit.dart';
import '../../../../core/dependency_injection/di.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/security/logic/app_lock_cubit.dart';
import '../../auth/logic/auth_cubit.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  int _currentStep = 0; // 0: Manager Profile, 1: Security & Protection

  // Form Controllers - Step 1: User Profile
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  CountryInfo _selectedCountry = CountryInfo.defaultCountry;

  // Form Controllers - Step 2: Security & Protection
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _biometricEnabled = true;
  bool _requirePinForTransactions = true;
  bool _autoLockEnabled = true;
  bool _autoSyncEnabled = true;
  int _lockTimeoutMinutes = 1;

  String? _step1Error;
  String? _step2Error;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _validateAndProceedToSecurity() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _step1Error = context.isArabic ? 'يرجى إدخال اسم المستخدم بالكامل' : 'Please enter full name');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _step1Error = context.isArabic ? 'يرجى إدخال بريد إلكتروني صحيح' : 'Please enter a valid email');
      return;
    }

    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty || digitsOnly.length < _selectedCountry.minDigits) {
      setState(() => _step1Error = context.isArabic
          ? 'يرجى إدخال رقم هاتف صحيح لـ ${_selectedCountry.nameAr}'
          : 'Please enter a valid phone number for ${_selectedCountry.nameEn}');
      return;
    }

    setState(() {
      _step1Error = null;
      _currentStep = 1;
    });
  }

  Future<void> _completeSetupAndLaunch() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.length != 4) {
      setState(() => _step2Error = context.isArabic ? 'يجب أن يتكون رمز PIN من 4 أرقام' : 'PIN must be exactly 4 digits');
      return;
    }

    if (pin != confirmPin) {
      setState(() => _step2Error = context.isArabic ? 'رمز PIN وتأكيده غير متطابقين' : 'PIN and confirmation do not match');
      return;
    }

    setState(() {
      _step2Error = null;
      _isLoading = true;
    });

    final storage = getIt<LocalStorageService>();
    final syncService = getIt<CloudSyncService>();

    final user = UserModel(
      id: 'usr_${_emailController.text.trim().hashCode.abs()}',
      email: _emailController.text.trim().toLowerCase(),
      displayName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _roleController.text.trim().isNotEmpty ? _roleController.text.trim() : 'مدير الأسطول والمحفظة',
      autoSyncEnabled: _autoSyncEnabled,
      lastSyncTime: DateTime.now(),
    );

    // Persist all profile & security configurations
    storage.completeInitialSetup(
      user: user,
      pinCode: pin,
      biometricEnabled: _biometricEnabled,
      autoLockEnabled: _autoLockEnabled,
      requirePinForTransactions: _requirePinForTransactions,
      lockTimeoutMinutes: _lockTimeoutMinutes,
    );

    // Initialize AuthCubit & AppLockCubit with new user
    if (mounted) {
      context.read<AuthCubit>().refreshUser();
      context.read<SyncCubit>().toggleAutoSync(_autoSyncEnabled);
      context.read<AppLockCubit>().verifyPin(pin);
    }

    // Trigger cloud sync snapshot
    if (_autoSyncEnabled) {
      await syncService.syncNow(force: true);
    }

    if (mounted) {
      setState(() => _isLoading = false);

      AppToast.show(
        context,
        message: context.isArabic
            ? 'مرحباً بك! تم إعداد الحساب وتفعيل منظومة الأمان بنجاح'
            : 'Welcome! Account & security initialized successfully',
        icon: Icons.verified_user_rounded,
        duration: const Duration(seconds: 4),
      );

      context.go(Routes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_taxi_rounded, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'تاكسيات مدينة السادات' : 'Sadat City Taxis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFE8F0FE), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFD0E2FF),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _currentStep == 0 ? Icons.person_pin_rounded : Icons.shield_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'تهيئة الحساب لأول مرة' : 'First-Time App Setup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isArabic
                                    ? 'يرجى تسجيل بياناتك وتعيين متطلبات الأمان لحماية بيانات المحفظة'
                                    : 'Please register your info and configure security protection',
                                style: TextStyle(fontSize: 11.5, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Step Indicator Bar
                    Row(
                      children: [
                        Expanded(
                          child: _buildStepTab(
                            stepIndex: 0,
                            title: isArabic ? '١. بيانات المدير' : '1. Profile',
                            isActive: _currentStep == 0,
                            isCompleted: _currentStep > 0,
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStepTab(
                            stepIndex: 1,
                            title: isArabic ? '٢. الأمان والحماية' : '2. Security',
                            isActive: _currentStep == 1,
                            isCompleted: false,
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Step 1 Content: User Profile Form
              if (_currentStep == 0) ...[
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'بيانات مدير المنظومة والمحفظة' : 'Manager & Account Information',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'تستخدم هذه البيانات لمزامنة التعديلات سحابياً بين نسختي الأندرويد والويندوز'
                            : 'This data is used to sync updates across Android & Windows',
                        style: TextStyle(fontSize: 11.5, color: textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الاسم بالكامل *' : 'Full Name *',
                          hintText: isArabic ? 'أحمد محمود سالم' : 'Ahmed Mahmoud Salem',
                          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Email Address
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'البريد الإلكتروني للمزامنة السحابية *' : 'Cloud Sync Email *',
                          hintText: 'ahmed.salem@sadattaxis.com',
                          prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                          helperText: isArabic
                              ? 'البريد المعتمد لمزامنة المحفظة بين الهواتف والأجهزة'
                              : 'Anchor email for cross-device synchronization',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Phone Field
                      AppPhoneField(
                        controller: _phoneController,
                        label: isArabic ? 'رقم الهاتف المحمول *' : 'Mobile Phone Number *',
                        isRequired: true,
                        initialDialCode: '+20',
                        onCountryChanged: (country) {
                          setState(() => _selectedCountry = country);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Role / Title
                      TextField(
                        controller: _roleController,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'المسمى الوظيفي / الدور' : 'Role / Position',
                          hintText: isArabic ? 'مدير الأسطول والمحفظة' : 'Fleet & Portfolio Manager',
                          prefixIcon: const Icon(Icons.work_outline_rounded, size: 20),
                        ),
                      ),

                      if (_step1Error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5221F).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC5221F).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 16, color: Color(0xFFC5221F)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _step1Error!,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFC5221F), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          label: Text(
                            isArabic ? 'المتابعة لتعيين ميزات الأمان' : 'Continue to Security Setup',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: _validateAndProceedToSecurity,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Step 2 Content: Security & Protection Setup
              if (_currentStep == 1) ...[
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF137333).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.lock_person_rounded, color: Color(0xFF137333), size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'تعيين رمز PIN السري ومنظومة الحماية' : 'Set Master PIN & Protection',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  isArabic ? 'حماية بيانات المحفظة والمستندات ببروتوكول AES-256' : 'AES-256 End-to-End Protection',
                                  style: TextStyle(fontSize: 11, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Master PIN Setup
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pinController,
                              obscureText: _obscurePin,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: isArabic ? 'رمز PIN (4 أرقام)' : 'PIN (4 digits)',
                                hintText: '••••',
                                counterText: '',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, size: 18),
                                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _confirmPinController,
                              obscureText: _obscureConfirmPin,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: isArabic ? 'تأكيد رمز PIN' : 'Confirm PIN',
                                hintText: '••••',
                                counterText: '',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirmPin ? Icons.visibility_off : Icons.visibility, size: 18),
                                  onPressed: () => setState(() => _obscureConfirmPin = !_obscureConfirmPin),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // Biometrics Switch
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _biometricEnabled,
                        onChanged: (val) => setState(() => _biometricEnabled = val),
                        activeThumbColor: primaryColor,
                        title: Text(
                          isArabic ? 'الحماية بالبصمة والوجه (Biometrics)' : 'Biometric Authentication',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'استخدام البصمة لفتح التطبيق وتأكيد العمليات الحساسة بسرعة'
                              : 'Fast and secure login using fingerprint or Face ID',
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
                        contentPadding: EdgeInsets.zero,
                        value: _requirePinForTransactions,
                        onChanged: (val) => setState(() => _requirePinForTransactions = val),
                        activeThumbColor: primaryColor,
                        title: Text(
                          isArabic ? 'طلب PIN للمعاملات المالية والحذف' : 'Require PIN for Financial Actions',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'طلب الرمز السري عند صرف الأرباح أو التعديل أو الحذف النهائي'
                              : 'Prompt for PIN before payouts or permanent deletions',
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
                        contentPadding: EdgeInsets.zero,
                        value: _autoLockEnabled,
                        onChanged: (val) => setState(() => _autoLockEnabled = val),
                        activeThumbColor: primaryColor,
                        title: Text(
                          isArabic ? 'القفل التلقائي للجلسة' : 'Auto Session Lock',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'قفل التطبيق تلقائياً بعد فترة من الخمول ومغادرة الشاشة'
                              : 'Automatically locks the app upon leaving or idle',
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                isArabic ? 'مهلة القفل:' : 'Lock timeout:',
                                style: TextStyle(fontSize: 11.5, color: textSecondary),
                              ),
                              const Spacer(),
                              ...[0, 1, 5, 15].map((mins) {
                                final isSel = _lockTimeoutMinutes == mins;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: InkWell(
                                    onTap: () => setState(() => _lockTimeoutMinutes = mins),
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

                      const Divider(height: 1),

                      // Auto Cloud Sync Switch
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _autoSyncEnabled,
                        onChanged: (val) => setState(() => _autoSyncEnabled = val),
                        activeThumbColor: primaryColor,
                        title: Text(
                          isArabic ? 'المزامنة السحابية اللحظية' : 'Real-Time Cloud Sync',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'مزامنة التعديلات والبيانات بين نسخة الهاتف والكمبيوتر فورياً'
                              : 'Sync portfolio changes automatically across devices',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.cloud_sync_rounded, color: primaryColor, size: 20),
                        ),
                      ),

                      if (_step2Error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5221F).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC5221F).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 16, color: Color(0xFFC5221F)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _step2Error!,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFC5221F), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Action Buttons (Back + Complete)
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => setState(() => _currentStep = 0),
                            child: Text(isArabic ? 'السابق' : 'Back'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF137333),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              label: Text(
                                _isLoading
                                    ? (isArabic ? 'جاري التهيئة...' : 'Setting up...')
                                    : (isArabic ? 'حفظ وبدء استخدام التطبيق' : 'Save & Launch App'),
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              onPressed: _isLoading ? null : _completeSetupAndLaunch,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTab({
    required int stepIndex,
    required String title,
    required bool isActive,
    required bool isCompleted,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: isActive
            ? primaryColor
            : isCompleted
                ? const Color(0xFF137333)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : isActive
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: (isActive || isCompleted) ? Colors.white : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: (isActive || isCompleted) ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
