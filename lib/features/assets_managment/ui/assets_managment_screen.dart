import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../home/logic/home_cubit.dart';
import '../../home/logic/home_state.dart';
import '../../notifications/ui/notifications_screen.dart';
import 'widgets/asset_card.dart';
import 'add_asset_screen.dart';

class AssetsManagmentScreen extends StatefulWidget {
  const AssetsManagmentScreen({super.key});

  @override
  State<AssetsManagmentScreen> createState() => _AssetsManagmentScreenState();
}

class _AssetsManagmentScreenState extends State<AssetsManagmentScreen> {
  String _selectedFilter = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AssetModel> _filterAssets(List<AssetModel> assets) {
    return assets.where((asset) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesPlate = asset.plateNumber.toLowerCase().contains(query);
        final matchesCar = asset.carModelYear.toLowerCase().contains(query);
        if (!matchesPlate && !matchesCar) return false;
      }

      // 2. Filter Pills
      if (_selectedFilter == 'الكل') return true;
      if (_selectedFilter == 'تاكسي كامل') return asset.modelType == AssetType.fullTaxi;
      if (_selectedFilter == 'لوحة فقط') return asset.modelType == AssetType.plateOnly;
      if (_selectedFilter == 'مركبة فقط') return asset.modelType == AssetType.vehicleOnly;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SadatTaxiLogo(),
            SizedBox(width: 8),
            Text(
              'إدارة الأصول',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          const ThemeToggleIconButton(),
          const ArchiveIconButton(),
          NotificationBellButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final filteredAssets = _filterAssets(state.assets);

          return Column(
            children: [
              // Top Action Row: Search Bar & "+ إضافة أصل" Button
              Container(
                color: isDark ? AppColors.darkSurface : Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Search Bar & Add Button Row
                    Row(
                      children: [
                        // Search Bar
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'بحث برقم اللوحة، الموديل...',
                              hintStyle: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark ? AppColors.primaryLight : const Color(0xFF0F56B3),
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
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.primaryLight : const Color(0xFF0F56B3),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Add Asset Top Quick Button
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddAssetScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.primaryLight : const Color(0xFF0F56B3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'إضافة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Filter Pills Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterPill(
                            label: 'الكل',
                            isSelected: _selectedFilter == 'الكل',
                            onTap: () => setState(() => _selectedFilter = 'الكل'),
                          ),
                          const SizedBox(width: 8),
                          _FilterPill(
                            label: 'تاكسي كامل',
                            isSelected: _selectedFilter == 'تاكسي كامل',
                            onTap: () => setState(() => _selectedFilter = 'تاكسي كامل'),
                          ),
                          const SizedBox(width: 8),
                          _FilterPill(
                            label: 'لوحة فقط',
                            isSelected: _selectedFilter == 'لوحة فقط',
                            onTap: () => setState(() => _selectedFilter = 'لوحة فقط'),
                          ),
                          const SizedBox(width: 8),
                          _FilterPill(
                            label: 'مركبة فقط',
                            isSelected: _selectedFilter == 'مركبة فقط',
                            onTap: () => setState(() => _selectedFilter = 'مركبة فقط'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),

              // Assets List
              Expanded(
                child: filteredAssets.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد أصول مطابقة للبحث',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredAssets.length,
                        itemBuilder: (context, index) {
                          final asset = filteredAssets[index];
                          return Dismissible(
                            key: ValueKey('asset_dismiss_${asset.id}'),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F56B3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_rounded, color: Colors.white, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'تعديل بيانات الأصل',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC5221F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerLeft,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'نقل إلى الأرشيف',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.archive_rounded, color: Colors.white, size: 24),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Navigate to edit asset screen without removing item from list
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddAssetScreen(assetToEdit: asset),
                                  ),
                                );
                                return false;
                              }

                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.inventory_2_rounded, color: Color(0xFF0F56B3)),
                                      SizedBox(width: 8),
                                      Text(
                                        'نقل إلى الأرشيف',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'هل أنت متأكد من نقل الأصل "${asset.plateNumber} (${asset.carModelYear})" إلى الأرشيف؟',
                                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('إلغاء'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F56B3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('تأكيد النقل', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                context.read<HomeCubit>().deleteAsset(asset.id);
                                AppToast.show(
                                  context,
                                  message: 'تم نقل الأصل "${asset.plateNumber}" إلى الأرشيف بنجاح',
                                  actionLabel: 'تراجع',
                                  duration: const Duration(seconds: 5),
                                  onAction: () {
                                    context.read<HomeCubit>().addOrUpdateAsset(asset);
                                  },
                                );
                              }
                            },
                            child: AssetCard(asset: asset),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
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

