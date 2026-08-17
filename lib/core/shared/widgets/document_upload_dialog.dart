import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theming/app_colors.dart';
import '../../localization/app_localization_extension.dart';
import '../models/document_meta_model.dart';
import '../enums/app_enums.dart';
import 'app_button.dart';

class DocumentUploadDialog extends StatefulWidget {
  final DocumentMeta? initialDocument;
  final String? defaultTitle;
  final DocumentType? defaultType;

  const DocumentUploadDialog({
    super.key,
    this.initialDocument,
    this.defaultTitle,
    this.defaultType,
  });

  static Future<DocumentMeta?> show(
    BuildContext context, {
    DocumentMeta? initialDocument,
    String? defaultTitle,
    DocumentType? defaultType,
  }) {
    return showDialog<DocumentMeta>(
      context: context,
      builder: (ctx) => DocumentUploadDialog(
        initialDocument: initialDocument,
        defaultTitle: defaultTitle,
        defaultType: defaultType,
      ),
    );
  }

  @override
  State<DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<DocumentUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late DocumentType _selectedType;
  DateTime? _expiryDate;
  DateTime? _issueDate;
  final List<String> _imagePaths = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final d = widget.initialDocument;
    _titleController = TextEditingController(text: d?.title ?? widget.defaultTitle ?? '');
    _notesController = TextEditingController(text: d?.notes ?? '');
    _selectedType = d?.type ?? widget.defaultType ?? DocumentType.licenseCard;
    _expiryDate = d?.expiryDate;
    _issueDate = d?.issueDate;

    if (d != null) {
      _imagePaths.addAll(d.allImages);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final xf in pickedFiles) {
            if (!_imagePaths.contains(xf.path)) {
              _imagePaths.add(xf.path);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('pickMultiImage error: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          if (!_imagePaths.contains(photo.path)) {
            _imagePaths.add(photo.path);
          }
        });
      }
    } catch (e) {
      debugPrint('camera pick error: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final doc = DocumentMeta(
      id: widget.initialDocument?.id ?? 'doc_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isNotEmpty ? title : _selectedType.arabicLabel,
      type: _selectedType,
      expiryDate: _expiryDate,
      issueDate: _issueDate,
      images: List.unmodifiable(_imagePaths),
      fileUrl: _imagePaths.isNotEmpty ? _imagePaths.first : '',
      notes: _notesController.text.trim(),
      createdAt: widget.initialDocument?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(doc);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final isArabic = context.isArabic;
    final l10n = context.l10n;

    final quickTemplates = [
      {'title': isArabic ? 'رخصة التسيير' : 'Vehicle License', 'type': DocumentType.licenseCard},
      {'title': isArabic ? 'عقد الشراكة' : 'Partnership Agreement', 'type': DocumentType.partnershipAgreement},
      {'title': isArabic ? 'بطاقة الرقم القومي' : 'National ID Card', 'type': DocumentType.nationalId},
      {'title': isArabic ? 'عقد الإيجار والتشغيل' : 'Lease Contract', 'type': DocumentType.leaseContract},
      {'title': isArabic ? 'وثيقة التأمين الشامل' : 'Insurance Policy', 'type': DocumentType.insurance},
      {'title': isArabic ? 'الفحص الفني وشهادة الصلاحية' : 'Inspection Certificate', 'type': DocumentType.technicalInspection},
      {'title': isArabic ? 'إيصال سداد / مخالصة' : 'Payment Receipt', 'type': DocumentType.paymentReceipt},
    ];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D31) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add_photo_alternate_rounded, color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.initialDocument == null
                          ? (isArabic ? 'إضافة مستند جديد (صورة أو عدة صور)' : 'Add New Document (Single or Multi-Image)')
                          : (isArabic ? 'تعديل بيانات المستند' : 'Edit Document Details'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Dialog Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Template Chips
                      Text(
                        isArabic ? 'نماذج مستندات سريعة:' : 'Quick Document Templates:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: quickTemplates.map((t) {
                          final title = t['title'] as String;
                          final type = t['type'] as DocumentType;
                          final isSelected = _titleController.text == title;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _titleController.text = title;
                                _selectedType = type;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: 0.15)
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? primaryColor : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? primaryColor : (isDark ? AppColors.darkTextSecondary : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Document Title
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'اسم المستند *' : 'Document Title *',
                          hintText: isArabic ? 'مثال: رخصة التسيير وجهين' : 'e.g. Vehicle Registration (2 sides)',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isArabic ? 'يرجى إدخال اسم المستند' : 'Document title is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Document Type Dropdown
                      DropdownButtonFormField<DocumentType>(
                        initialValue: _selectedType,
                        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'تصنيف المستند' : 'Document Category',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                        ),
                        items: DocumentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(isArabic ? type.arabicLabel : type.englishLabel),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),

                      const SizedBox(height: 18),

                      // Image Upload Section (Single or Multi-Image)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.collections_rounded, size: 18, color: primaryColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      isArabic ? 'صور المستند المرفقة' : 'Attached Document Images',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _imagePaths.isNotEmpty
                                        ? primaryColor.withValues(alpha: 0.15)
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isArabic ? '${_imagePaths.length} صور' : '${_imagePaths.length} Images',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _imagePaths.isNotEmpty ? primaryColor : (isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Pick Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickImagesFromGallery,
                                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                                    label: Text(
                                      isArabic ? 'معرض الصور (عدة صور)' : 'Gallery (Multiple)',
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: _pickImageFromCamera,
                                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                  label: Text(
                                    isArabic ? 'كاميرا' : 'Camera',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),

                            // Image Thumbnails Grid
                            if (_imagePaths.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: _imagePaths.length,
                                itemBuilder: (context, idx) {
                                  final p = _imagePaths[idx];
                                  final file = File(p);
                                  final exists = file.existsSync();

                                  return Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Center(
                                          child: exists
                                              ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                              : Icon(Icons.image_rounded, color: primaryColor, size: 30),
                                        ),
                                      ),

                                      // Index badge
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${idx + 1}',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),

                                      // Remove button
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(idx),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dates (Expiry & Issue Date)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  setState(() => _expiryDate = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic ? 'تاريخ الانتهاء (اختياري)' : 'Expiry Date (Optional)',
                                      style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _expiryDate != null
                                              ? '${_expiryDate!.year}/${_expiryDate!.month.toString().padLeft(2, '0')}/${_expiryDate!.day.toString().padLeft(2, '0')}'
                                              : (isArabic ? 'حدد التاريخ' : 'Select Date'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _expiryDate != null ? primaryColor : (isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8)),
                                          ),
                                        ),
                                        Icon(Icons.calendar_today_rounded, size: 14, color: primaryColor),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_expiryDate != null) ...[
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => setState(() => _expiryDate = null),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Notes TextField
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'ملاحظات إضافية' : 'Additional Notes',
                          hintText: isArabic ? 'أي تفاصيل خاصة برقم الوثيقة أو جهة الإصدار...' : 'Notes or document reference number...',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Dialog Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: isArabic ? 'حفظ المستند' : 'Save Document',
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
