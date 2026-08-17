import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/shared/widgets/documents_section_widget.dart';
import '../../../../core/shared/models/archived_item_model.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../home/logic/home_cubit.dart';
import '../../shareholders/logic/shareholders_cubit.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  ArchiveCategory? _selectedCategory; // null = all
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ArchivedItemModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedItems();
  }

  Future<void> _loadArchivedItems() async {
    setState(() => _isLoading = true);
    final items = await context.read<HomeCubit>().getArchivedItems();
    setState(() {
      _items = List.from(items);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArchivedItemModel> get _filteredItems {
    return _items.where((item) {
      if (_selectedCategory != null && item.category != _selectedCategory) {
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

  Future<void> _restoreItem(ArchivedItemModel item) async {
    final l10n = context.l10n;
    final success = await context.read<HomeCubit>().restoreArchivedItem(item.id);
    if (success) {
      setState(() {
        _items.removeWhere((i) => i.id == item.id);
      });
      if (mounted) {
        context.read<ShareholdersCubit>().loadShareholders();
        AppToast.show(
          context,
          message: '${l10n.itemRestored}: "${item.title}"',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _confirmDeleteItem(ArchivedItemModel item) {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5221F),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<HomeCubit>().deleteArchivedPermanently(item.id);
              setState(() {
                _items.removeWhere((i) => i.id == item.id);
              });
              if (mounted) {
                AppToast.show(
                  context,
                  message: l10n.itemDeleted,
                  backgroundColor: const Color(0xFFC5221F),
                  icon: Icons.delete_outline_rounded,
                  duration: const Duration(seconds: 4),
                );
              }
            },
            child: Text(
              l10n.permanentDelete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showArchivedDetails(BuildContext context, ArchivedItemModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.isArabic;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Material(
          color: isDark ? const Color(0xFF131D31) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.archive_outlined, color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isArabic ? 'تفاصيل السجل المؤرشف' : 'Archived Record Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(modalCtx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Subtitle Card
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                            const SizedBox(height: 4),
                            Text(item.subtitle, style: TextStyle(fontSize: 12.5, color: textSecondary)),
                            if (item.metaInfo.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(item.metaInfo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF137333))),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // If Archived Shareholder: Show Documents & Transaction history
                      if (item.originalShareholder != null) ...[
                        // Shareholder Documents
                        DocumentsSectionWidget(
                          title: isArabic ? 'المستندات والصور المؤرشفة' : 'Archived Documents & Photos',
                          documents: item.originalShareholder!.documents,
                          readOnly: true,
                          onDocumentsChanged: (_) {},
                        ),
                        const SizedBox(height: 16),

                        // Transaction History
                        if (item.shareholderTransactions != null && item.shareholderTransactions!.isNotEmpty) ...[
                          AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'سجل المعاملات وتوزيع الأرباح المؤرشفة' : 'Archived Transaction History',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                                const SizedBox(height: 10),
                                ...item.shareholderTransactions!.map((tx) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(tx.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary)),
                                              Text(
                                                context.formatShortDate(tx.date),
                                                style: TextStyle(fontSize: 10.5, color: textSecondary),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            context.formatCurrency(tx.amount),
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF137333)),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],

                      // If Archived Asset: Show Documents
                      if (item.originalAsset != null && item.originalAsset!.documents.isNotEmpty) ...[
                        DocumentsSectionWidget(
                          title: isArabic ? 'مستندات الأصل المؤرشفة' : 'Archived Asset Documents',
                          documents: item.originalAsset!.documents,
                          readOnly: true,
                          onDocumentsChanged: (_) {},
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
                  border: Border(top: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.restore_rounded, size: 18),
                        label: Text(isArabic ? 'استعادة من الأرشيف' : 'Restore from Archive'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(modalCtx).pop();
                          _restoreItem(item);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC5221F)),
                      tooltip: isArabic ? 'حذف نهائي' : 'Delete Permanently',
                      onPressed: () {
                        Navigator.of(modalCtx).pop();
                        _confirmDeleteItem(item);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final filtered = _filteredItems;
    final l10n = context.l10n;
    final isArabic = context.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.archiveTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F56B3),
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Search & Filter Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  color: isDark ? AppColors.darkBackground : Colors.white,
                  child: Column(
                    children: [
                      // Search TextField
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: l10n.searchArchiveHint,
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category Filter Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _ArchiveFilterPill(
                              label: l10n.filterAll,
                              isSelected: _selectedCategory == null,
                              onTap: () => setState(() => _selectedCategory = null),
                            ),
                            const SizedBox(width: 8),
                            _ArchiveFilterPill(
                              label: isArabic ? 'مساهمون مؤرشفون' : 'Archived Shareholders',
                              isSelected: _selectedCategory == ArchiveCategory.archivedShareholders,
                              onTap: () => setState(() => _selectedCategory = ArchiveCategory.archivedShareholders),
                            ),
                            const SizedBox(width: 8),
                            _ArchiveFilterPill(
                              label: l10n.catSoldAssets,
                              isSelected: _selectedCategory == ArchiveCategory.soldAssets,
                              onTap: () => setState(() => _selectedCategory = ArchiveCategory.soldAssets),
                            ),
                            const SizedBox(width: 8),
                            _ArchiveFilterPill(
                              label: l10n.catPastContracts,
                              isSelected: _selectedCategory == ArchiveCategory.pastContracts,
                              onTap: () => setState(() => _selectedCategory = ArchiveCategory.pastContracts),
                            ),
                            const SizedBox(width: 8),
                            _ArchiveFilterPill(
                              label: l10n.catMaintenanceLogs,
                              isSelected: _selectedCategory == ArchiveCategory.maintenanceLogs,
                              onTap: () => setState(() => _selectedCategory = ArchiveCategory.maintenanceLogs),
                            ),
                            const SizedBox(width: 8),
                            _ArchiveFilterPill(
                              label: l10n.catExpiredDocs,
                              isSelected: _selectedCategory == ArchiveCategory.expiredDocs,
                              onTap: () => setState(() => _selectedCategory = ArchiveCategory.expiredDocs),
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
                              const Icon(
                                Icons.folder_open_rounded,
                                size: 64,
                                color: Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noData,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, idx) {
                            final item = filtered[idx];
                            return _ArchiveCard(
                              item: item,
                              onTap: () => _showArchivedDetails(context, item),
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

class _ArchiveCard extends StatelessWidget {
  final ArchivedItemModel item;
  final VoidCallback onTap;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchiveCard({
    required this.item,
    required this.onTap,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final l10n = context.l10n;

    IconData getCategoryIcon() {
      switch (item.category) {
        case ArchiveCategory.archivedShareholders:
          return Icons.person_outline_rounded;
        case ArchiveCategory.soldAssets:
          return Icons.directions_car_filled_rounded;
        case ArchiveCategory.pastContracts:
          return Icons.history_edu_rounded;
        case ArchiveCategory.maintenanceLogs:
          return Icons.build_circle_rounded;
        case ArchiveCategory.expiredDocs:
          return Icons.description_rounded;
      }
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Tag & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3), width: 0.8) : null,
                ),
                child: Text(
                  item.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.formatShortDate(item.date),
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
                  child: Icon(getCategoryIcon(), color: primaryColor, size: 20),
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
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFC5221F),
                        size: 16,
                      ),
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
                      Icon(
                        Icons.restore_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
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
              ? Border.all(color: const Color(0xFF334155), width: 1)
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
