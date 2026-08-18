import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theming/app_colors.dart';
import '../../localization/app_localization_extension.dart';
import '../logic/app_lock_cubit.dart';
import '../logic/app_lock_state.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final cubit = context.read<AppLockCubit>();

    if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
      cubit.inputDigit('0');
    } else if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
      cubit.inputDigit('1');
    } else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
      cubit.inputDigit('2');
    } else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) {
      cubit.inputDigit('3');
    } else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) {
      cubit.inputDigit('4');
    } else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) {
      cubit.inputDigit('5');
    } else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) {
      cubit.inputDigit('6');
    } else if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) {
      cubit.inputDigit('7');
    } else if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) {
      cubit.inputDigit('8');
    } else if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) {
      cubit.inputDigit('9');
    } else if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      cubit.deleteDigit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final isArabic = context.isArabic;

    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        final cubit = context.read<AppLockCubit>();
        final name = cubit.userName ?? (isArabic ? 'مدير المحفظة' : 'Fleet Manager');
        final role = cubit.userRole ?? (isArabic ? 'مدير الأسطول والمحفظة' : 'Portfolio Admin');
        final digitsCount = state.enteredDigits.length;

        return KeyboardListener(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sadat Taxis Brand Logo & Shield
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        isArabic ? 'تاكسيات مدينة السادات' : 'Sadat City Taxis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // User Profile Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_rounded, size: 16, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      Text(
                        isArabic ? 'أدخل رمز PIN لإلغاء القفل' : 'Enter PIN Code to Unlock',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 4 PIN Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < digitsCount;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: isFilled ? 18 : 14,
                            height: isFilled ? 18 : 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled
                                  ? primaryColor
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                              boxShadow: isFilled
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),

                      // Error Banner
                      if (state.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5221F).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFC5221F).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFC5221F)),
                              const SizedBox(width: 8),
                              Text(
                                state.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFC5221F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        const SizedBox(height: 38),
                      ],

                      // Numeric Keypad
                      ConstrainedBox(
                        constraints: const ConstrainedBoxSort(maxWidth: 290),
                        child: Column(
                          children: [
                            _buildKeypadRow(['1', '2', '3'], isDark, primaryColor),
                            const SizedBox(height: 14),
                            _buildKeypadRow(['4', '5', '6'], isDark, primaryColor),
                            const SizedBox(height: 14),
                            _buildKeypadRow(['7', '8', '9'], isDark, primaryColor),
                            const SizedBox(height: 14),
                            _buildBottomKeypadRow(isDark, primaryColor, cubit),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeypadRow(List<String> digits, bool isDark, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKeypadButton(d, isDark, primaryColor)).toList(),
    );
  }

  Widget _buildBottomKeypadRow(bool isDark, Color primaryColor, AppLockCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometrics Button (if enabled) or Empty
        if (cubit.isBiometricEnabled)
          _buildActionKeypadButton(
            icon: Icons.fingerprint_rounded,
            color: const Color(0xFF137333),
            isDark: isDark,
            onTap: () => cubit.unlockWithBiometrics(),
          )
        else
          const SizedBox(width: 68, height: 68),

        // Digit 0
        _buildKeypadButton('0', isDark, primaryColor),

        // Backspace Button
        _buildActionKeypadButton(
          icon: Icons.backspace_outlined,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
          isDark: isDark,
          onTap: () => cubit.deleteDigit(),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit, bool isDark, Color primaryColor) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<AppLockCubit>().inputDigit(digit);
      },
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKeypadButton({
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}

class ConstrainedBoxSort extends BoxConstraints {
  const ConstrainedBoxSort({super.maxWidth = 290});
}
