import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_button.dart';
import '../../../../core/shared/widgets/app_text_field.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../logic/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'ahmed.salem@sadattaxis.com');
  final _pinController = TextEditingController(text: '1234');
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    await context.read<AuthCubit>().loginWithEmail(
      email: email,
      passwordOrPin: _pinController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(Routes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Taxi & Sadat City Icon
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_taxi_rounded,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    context.isArabic ? 'إدارة تاكسيات مدينة السادات' : 'Sadat City Taxis Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.isArabic
                        ? 'منظومة إدارة المحفظة الاستثمارية والمزامنة السحابية المشتركة'
                        : 'Fleet Investment Management & Cloud Synchronization',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Cross-platform sync banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.devices_rounded, size: 22, color: primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.isArabic
                                ? 'متوافق بالكامل بين هاتفك الأندرويد وجهاز الويندوز مع مزامنة سحابية فورية'
                                : 'Synchronized seamlessly across Android mobile & Windows desktop',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login Form Card
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: context.isArabic ? 'البريد الإلكتروني للحساب' : 'Email Address',
                          hint: 'user@sadattaxis.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.email_outlined, size: 20, color: primaryColor),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: context.isArabic ? 'رمز المرور السري (PIN / Password)' : 'Security PIN / Password',
                          hint: '****',
                          controller: _pinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: primaryColor),
                        ),
                        const SizedBox(height: 22),
                        AppButton(
                          text: context.isArabic ? 'تسجيل الدخول ومزامنة المحفظة' : 'Sign In & Sync Portfolio',
                          onPressed: _login,
                          isLoading: _isLoading,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Offline notice
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.offline_pin_rounded, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        context.isArabic
                            ? 'يعمل التطبيق بدون إنترنت ويحفظ البيانات محلياً تلقائياً'
                            : 'Works offline & persists all data locally automatically',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
