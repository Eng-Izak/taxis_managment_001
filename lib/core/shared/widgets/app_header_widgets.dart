import 'package:flutter/material.dart';
import '../../theming/app_colors.dart';
import '../../../features/archive/ui/archive_screen.dart';

class SadatTaxiLogo extends StatelessWidget {
  final double size;

  const SadatTaxiLogo({
    super.key,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF137333), width: 1.2),
      ),
      child: Center(
        child: Icon(
          Icons.local_taxi_rounded,
          size: size * 0.65,
          color: const Color(0xFF137333),
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
