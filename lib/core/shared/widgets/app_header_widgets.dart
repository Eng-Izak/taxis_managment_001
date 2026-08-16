import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theming/app_colors.dart';
import '../../theming/theme_cubit.dart';
import '../../../features/archive/ui/archive_screen.dart';

class SadatTaxiLogo extends StatelessWidget {
  final double size;

  const SadatTaxiLogo({
    super.key,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF22C55E) : const Color(0xFF137333),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_taxi_rounded,
          size: size * 0.65,
          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
        ),
      ),
    );
  }
}

class ThemeToggleIconButton extends StatelessWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: isDark ? 'التبديل إلى الوضع الفاتح' : 'التبديل إلى الوضع الداكن',
      child: InkWell(
        onTap: () {
          context.read<ThemeCubit>().toggleTheme();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : const Color(0xFFF1F3F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                size: 20,
                color: isDark ? const Color(0xFFFBBF24) : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationBellButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasUnread;

  const NotificationBellButton({
    super.key,
    required this.onTap,
    this.hasUnread = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 21,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF3C4043),
            ),
            if (hasUnread)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ArchiveIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ArchiveIconButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ArchiveScreen()),
            );
          },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: 20,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF3C4043),
          ),
        ),
      ),
    );
  }
}
