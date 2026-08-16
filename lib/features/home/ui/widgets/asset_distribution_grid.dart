import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/localization/app_localization_extension.dart';

class AssetDistributionGrid extends StatelessWidget {
  final int fullTaxisCount;
  final int plateOnlyCount;
  final int vehicleOnlyCount;
  final AssetType? selectedFilter;
  final ValueChanged<AssetType?> onFilterSelected;

  const AssetDistributionGrid({
    super.key,
    required this.fullTaxisCount,
    required this.plateOnlyCount,
    required this.vehicleOnlyCount,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        // Top Row: Full Taxi & Plate Only
        Row(
          children: [
            // Full Taxi
            Expanded(
              child: _GridItemCard(
                count: fullTaxisCount,
                label: l10n.fullTaxis,
                icon: Icons.local_taxi_rounded,
                iconBgColor: const Color(0xFFE8F0FE),
                iconColor: const Color(0xFF0F56B3),
                isSelected: selectedFilter == AssetType.fullTaxi,
                onTap: () => onFilterSelected(AssetType.fullTaxi),
              ),
            ),
            const SizedBox(width: 12),
            // Plate Only
            Expanded(
              child: _GridItemCard(
                count: plateOnlyCount,
                label: l10n.rentedPlatesOnly,
                icon: Icons.confirmation_number_rounded,
                iconBgColor: const Color(0xFFF1F3F4),
                iconColor: const Color(0xFF5F6368),
                isSelected: selectedFilter == AssetType.plateOnly,
                onTap: () => onFilterSelected(AssetType.plateOnly),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Bottom Card: Vehicles Only
        _GridItemCard(
          count: vehicleOnlyCount,
          label: l10n.vehiclesOnly,
          icon: Icons.directions_car_rounded,
          iconBgColor: const Color(0xFFF1F3F4),
          iconColor: const Color(0xFF5F6368),
          isSelected: selectedFilter == AssetType.vehicleOnly,
          onTap: () => onFilterSelected(AssetType.vehicleOnly),
          isFullWidth: true,
        ),
      ],
    );
  }
}

class _GridItemCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _GridItemCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      borderColor: isSelected ? primaryColor : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon in rounded box
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162032) : iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: const Color(0xFF334155), width: 1) : null,
                ),
                child: Center(
                  child: Icon(icon, color: isDark ? primaryColor : iconColor, size: 20),
                ),
              ),
              // Count
              Text(
                context.digits(count),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
