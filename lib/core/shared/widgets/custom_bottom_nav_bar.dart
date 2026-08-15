import 'package:flutter/material.dart';
import '../../theming/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 0: الأصول (Assets)
              _NavBarItem(
                icon: Icons.directions_car_rounded,
                label: 'الأصول',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              // Tab 1: المساهمين (Shareholders)
              _NavBarItem(
                icon: Icons.people_alt_rounded,
                label: 'المساهمين',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              // Tab 2: الرئيسية (Home Dashboard - CENTER)
              _CenterHomeNavBarItem(
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),

              // Tab 3: المالية (Financials)
              _NavBarItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'المالية',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),

              // Tab 4: الإعدادات (Settings)
              _NavBarItem(
                icon: Icons.settings_rounded,
                label: 'الإعدادات',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterHomeNavBarItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterHomeNavBarItem({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF0F56B3), Color(0xFF1E3A8A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: isSelected ? null : const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F56B3).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_rounded,
                  size: 22,
                  color: isSelected ? Colors.white : const Color(0xFF0F56B3),
                ),
                const SizedBox(height: 2),
                Text(
                  'الرئيسية',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF0F56B3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFE8F0FE))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: isSelected
                      ? const Color(0xFF0F56B3)
                      : (isDark ? AppColors.darkTextTertiary : const Color(0xFF5F6368)),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0F56B3)
                        : (isDark ? AppColors.darkTextTertiary : const Color(0xFF5F6368)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
