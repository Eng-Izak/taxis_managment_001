import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/localization/app_localization_extension.dart';

enum _ArchiveCategoryEnum { all, soldAssets, pastContracts, maintenanceLogs, expiredDocs }

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  _ArchiveCategoryEnum _selectedCategory = _ArchiveCategoryEnum.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_ArchivedItemData> _items = [
    _ArchivedItemData(
      id: 'arch_001',
      categoryType: _ArchiveCategoryEnum.soldAssets,
      title: 'Toyota Corolla 2018 - SAD 1122',
      subtitle: 'Asset sold & capital distributed to partners',
      date: '15 Aug 2025',
      tag: 'Sold',
      tagColor: const Color(0xFF137333),
      tagBgColor: const Color(0xFFE6F4EA),
      icon: Icons.directions_car_filled_rounded,
      metaInfo: 'Exit Value: 420,000 EGP',
    ),
    _ArchivedItemData(
      id: 'arch_002',
      categoryType: _ArchiveCategoryEnum.pastContracts,
      title: 'Driver Lease Contract: Mahmoud Adel',
      subtitle: 'Taxi Plate 5566 - 24-month contract ended',
      date: '01 Jul 2025',
      tag: 'Expired',
      tagColor: const Color(0xFF0F56B3),
      tagBgColor: const Color(0xFFE8F0FE),
      icon: Icons.history_edu_rounded,
      metaInfo: 'Total Collected: 144,000 EGP',
    ),
    _ArchivedItemData(
      id: 'arch_003',
      categoryType: _ArchiveCategoryEnum.maintenanceLogs,
      title: 'Complete Engine Overhaul - Hyundai Elantra (5678)',
      subtitle: 'Completed at authorized service center',
      date: '20 Mar 2025',
      tag: 'Completed',
      tagColor: const Color(0xFFB06000),
      tagBgColor: const Color(0xFFFEF7E0),
      icon: Icons.build_circle_rounded,
      metaInfo: 'Deducted Cost: 18,500 EGP',
    ),
    _ArchivedItemData(
      id: 'arch_004',
      categoryType: _ArchiveCategoryEnum.expiredDocs,
      title: 'Expired License - Taxi Plate 9012',
      subtitle: 'Renewed for 3 years successfully',
      date: '10 Jan 2025',
      tag: 'Renewed',
      tagColor: const Color(0xFF5F6368),
      tagBgColor: const Color(0xFFF1F3F4),
      icon: Icons.description_rounded,
      metaInfo: 'El Sadat Traffic Department',
    ),
    _ArchivedItemData(
      id: 'arch_005',
      categoryType: _ArchiveCategoryEnum.pastContracts,
      title: 'Full Taxi Operating Contract - Driver: Ibrahim Khalil',
      subtitle: 'Nissan Sunny 2020 (1234)',
      date: '15 Dec 2024',
      tag: 'Terminated',
      tagColor: const Color(0xFFC5221F),
      tagBgColor: const Color(0xFFFCE8E6),
      icon: Icons.assignment_turned_in_rounded,
      metaInfo: 'Fully Settled',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ArchivedItemData> get _filteredItems {
    return _items.where((item) {
      if (_selectedCategory != _ArchiveCategoryEnum.all && item.categoryType != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.tag.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  void _restoreItem(_ArchivedItemData item) {
    final l10n = context.l10n;
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
    });
    AppToast.show(
      context,
      message: '${l10n.itemRestored}: "${item.title}"',
      duration: const Duration(seconds: 4),
    );
  }

  void _confirmDeleteItem(_ArchivedItemData item) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmPermanentDelete),
        content: Text('${l10n.confirmPermanentDeleteMsg}\n\n"${item.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5221F)),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _items.removeWhere((i) => i.id == item.id);
              });
              AppToast.show(
                context,
                message: l10n.itemDeleted,
                backgroundColor: const Color(0xFFC5221F),
                icon: Icons.delete_outline_rounded,
                duration: const Duration(seconds: 4),
              );
            },
            child: Text(l10n.permanentDelete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final filtered = _filteredItems;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_rounded, color: primaryColor, size: 22),
            const SizedBox(width: 8),
            Text(
              l10n.archiveTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar & Filter Tabs
          Container(
            color: isDark ? AppColors.darkSurface : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: l10n.searchArchiveHint,
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8),
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 22),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ArchiveFilterPill(
                        label: l10n.filterAll,
                        isSelected: _selectedCategory == _ArchiveCategoryEnum.all,
                        onTap: () => setState(() => _selectedCategory = _ArchiveCategoryEnum.all),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: l10n.catSoldAssets,
                        isSelected: _selectedCategory == _ArchiveCategoryEnum.soldAssets,
                        onTap: () => setState(() => _selectedCategory = _ArchiveCategoryEnum.soldAssets),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: l10n.catPastContracts,
                        isSelected: _selectedCategory == _ArchiveCategoryEnum.pastContracts,
                        onTap: () => setState(() => _selectedCategory = _ArchiveCategoryEnum.pastContracts),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: l10n.catMaintenanceLogs,
                        isSelected: _selectedCategory == _ArchiveCategoryEnum.maintenanceLogs,
                        onTap: () => setState(() => _selectedCategory = _ArchiveCategoryEnum.maintenanceLogs),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: l10n.catExpiredDocs,
                        isSelected: _selectedCategory == _ArchiveCategoryEnum.expiredDocs,
                        onTap: () => setState(() => _selectedCategory = _ArchiveCategoryEnum.expiredDocs),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Archive List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noData,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _ArchivedCard(
                        item: item,
                        onRestore: () => _restoreItem(item),
                        onDelete: () => _confirmDeleteItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ArchivedItemData {
  final String id;
  final _ArchiveCategoryEnum categoryType;
  final String title;
  final String subtitle;
  final String date;
  final String tag;
  final Color tagColor;
  final Color tagBgColor;
  final IconData icon;
  final String metaInfo;

  _ArchivedItemData({
    required this.id,
    required this.categoryType,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.tag,
    required this.tagColor,
    required this.tagBgColor,
    required this.icon,
    required this.metaInfo,
  });
}

class _ArchivedCard extends StatelessWidget {
  final _ArchivedItemData item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchivedCard({
    required this.item,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final l10n = context.l10n;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? item.tagBgColor.withValues(alpha: 0.35) : item.tagBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: item.tagColor.withValues(alpha: 0.3), width: 0.8) : null,
                ),
                child: Text(
                  item.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.tagColor,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    context.digits(item.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Middle: Title & Subtitle with Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: const Color(0xFF334155), width: 1) : null,
                ),
                child: Center(
                  child: Icon(item.icon, color: primaryColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.digits(item.title),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.digits(item.subtitle),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                      ),
                    ),
                    if (item.metaInfo.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        context.digits(item.metaInfo),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Bottom Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Delete Button
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, color: Color(0xFFC5221F), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        l10n.permanentDelete,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC5221F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Restore Button
              InkWell(
                onTap: onRestore,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restore_rounded, color: primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        l10n.restoreFromArchive,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchiveFilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ArchiveFilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: isDark && !isSelected
              ? Border.all(color: AppColors.darkCardBorder, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}
