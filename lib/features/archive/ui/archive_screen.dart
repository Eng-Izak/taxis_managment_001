import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_toast.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_ArchivedItemData> _items = [
    _ArchivedItemData(
      id: 'arch_001',
      category: 'أصول مباعة ومتقاعدة',
      title: 'تويوتا كورولا 2018 - س أ د 1122',
      subtitle: 'تم بيع الأصل وتوزيع رأس المال على المساهمين',
      date: '15 أغسطس 2025',
      tag: 'تم البيع',
      tagColor: const Color(0xFF137333),
      tagBgColor: const Color(0xFFE6F4EA),
      icon: Icons.directions_car_filled_rounded,
      metaInfo: 'قيمة التخارج: 420,000 ج.م',
    ),
    _ArchivedItemData(
      id: 'arch_002',
      category: 'عقود إيجار سابقة',
      title: 'عقد إيجار السائق: محمود عادل عبد الله',
      subtitle: 'لوحة أجرة رقم 5566 - انتهاء فترة التعاقد 24 شهراً',
      date: '01 يوليو 2025',
      tag: 'عقد منتهي',
      tagColor: const Color(0xFF0F56B3),
      tagBgColor: const Color(0xFFE8F0FE),
      icon: Icons.history_edu_rounded,
      metaInfo: 'إجمالي الإيجارات المحصلة: 144,000 ج.م',
    ),
    _ArchivedItemData(
      id: 'arch_003',
      category: 'سجلات الصيانة المؤرشفة',
      title: 'عمرة محرك كاملة - هيونداي إلنترا (س ص ع 5678)',
      subtitle: 'تمت الصيانة في مركز خدمة السادات المعتمد',
      date: '20 مارس 2025',
      tag: 'صيانة مكتملة',
      tagColor: const Color(0xFFB06000),
      tagBgColor: const Color(0xFFFEF7E0),
      icon: Icons.build_circle_rounded,
      metaInfo: 'التكلفة المستقطعة: 18,500 ج.م',
    ),
    _ArchivedItemData(
      id: 'arch_004',
      category: 'وثائق وتراخيص منتهية',
      title: 'رخصة تسيير منتهية - لوحة أجرة رقم 9012',
      subtitle: 'تم استخراج رخصة التسيير الجديدة لمدة 3 سنوات',
      date: '10 يناير 2025',
      tag: 'مستند مجدد',
      tagColor: const Color(0xFF5F6368),
      tagBgColor: const Color(0xFFF1F3F4),
      icon: Icons.description_rounded,
      metaInfo: 'مرور مدينة السادات - المنوفية',
    ),
    _ArchivedItemData(
      id: 'arch_005',
      category: 'عقود إيجار سابقة',
      title: 'عقد تشغيل تاكسي كامل - السائق: إبراهيم خليل',
      subtitle: 'سيارة نيسان صني 2020 (أ ب ج 1234)',
      date: '15 ديسمبر 2024',
      tag: 'فسخ بالتراضي',
      tagColor: const Color(0xFFC5221F),
      tagBgColor: const Color(0xFFFCE8E6),
      icon: Icons.assignment_turned_in_rounded,
      metaInfo: 'تسوية المستحقات بالكامل',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ArchivedItemData> get _filteredItems {
    return _items.where((item) {
      if (_selectedCategory != 'الكل' && item.category != _selectedCategory) {
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
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
    });
    AppToast.show(
      context,
      message: 'تمت استعادة "${item.title}" من الأرشيف بنجاح',
      duration: const Duration(seconds: 5),
    );
  }

  void _confirmDeleteItem(_ArchivedItemData item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف النهائي'),
        content: Text('هل أنت متأكد من حذف "${item.title}" نهائياً من الأرشيف؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
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
                message: 'تم حذف السجل من الأرشيف نهائياً',
                backgroundColor: const Color(0xFFC5221F),
                icon: Icons.delete_outline_rounded,
                duration: const Duration(seconds: 5),
              );
            },
            child: const Text('حذف نهائي', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_rounded, color: Color(0xFF0F56B3), size: 22),
            SizedBox(width: 8),
            Text(
              'أرشيف الملفات والسجلات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar & Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'بحث في الأرشيف بالعنوان، رقم اللوحة، أو السائق...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F56B3), size: 22),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0F56B3), width: 1.5),
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
                        label: 'الكل (${_items.length})',
                        isSelected: _selectedCategory == 'الكل',
                        onTap: () => setState(() => _selectedCategory = 'الكل'),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: 'أصول مباعة ومتقاعدة',
                        isSelected: _selectedCategory == 'أصول مباعة ومتقاعدة',
                        onTap: () => setState(() => _selectedCategory = 'أصول مباعة ومتقاعدة'),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: 'عقود إيجار سابقة',
                        isSelected: _selectedCategory == 'عقود إيجار سابقة',
                        onTap: () => setState(() => _selectedCategory = 'عقود إيجار سابقة'),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: 'سجلات الصيانة',
                        isSelected: _selectedCategory == 'سجلات الصيانة المؤرشفة',
                        onTap: () => setState(() => _selectedCategory = 'سجلات الصيانة المؤرشفة'),
                      ),
                      const SizedBox(width: 8),
                      _ArchiveFilterPill(
                        label: 'وثائق وتراخيص',
                        isSelected: _selectedCategory == 'وثائق وتراخيص منتهية',
                        onTap: () => setState(() => _selectedCategory = 'وثائق وتراخيص منتهية'),
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
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 12),
                        Text(
                          'لا توجد سجلات مؤرشفة مطابقة',
                          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
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
  final String category;
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
    required this.category,
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
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag on Left, Date on Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: item.tagBgColor,
                  borderRadius: BorderRadius.circular(10),
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
                  const Icon(Icons.archive_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    item.date,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Middle: Icon + Title + Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(item.icon, color: const Color(0xFF0F56B3), size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        item.metaInfo,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F56B3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Bottom Action Row: Restore & Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Restore Button
              InkWell(
                onTap: onRestore,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.unarchive_rounded, color: Color(0xFF0F56B3), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'استعادة من الأرشيف',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F56B3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC5221F), size: 20),
                onPressed: onDelete,
                tooltip: 'حذف نهائي',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F56B3) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
