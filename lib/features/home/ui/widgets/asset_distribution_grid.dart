import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/enums/app_enums.dart';

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
    return Column(
      children: [
        // Top Row: Full Taxi (Right) & Plate Only (Left)
        Row(
          children: [
            // Right Card: سيارات أجرة كاملة (3)
            Expanded(
              child: _GridItemCard(
                count: fullTaxisCount,
                label: 'سيارات أجرة كاملة',
                icon: Icons.local_taxi_rounded,
                iconBgColor: const Color(0xFFE8F0FE),
                iconColor: const Color(0xFF0F56B3),
                isSelected: selectedFilter == AssetType.fullTaxi,
                onTap: () => onFilterSelected(AssetType.fullTaxi),
              ),
            ),
            const SizedBox(width: 12),
            // Left Card: لوحات مؤجرة (2)
            Expanded(
              child: _GridItemCard(
                count: plateOnlyCount,
                label: 'لوحات مؤجرة',
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

        // Bottom Card: مركبات بدون لوحات (1)
        _GridItemCard(
          count: vehicleOnlyCount,
          label: 'مركبات بدون لوحات',
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
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      borderColor: isSelected ? const Color(0xFF0F56B3) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon in rounded box on Right (in RTL)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ),
              // Count on Left (in RTL)
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F56B3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Label on Bottom Right (in RTL)
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
