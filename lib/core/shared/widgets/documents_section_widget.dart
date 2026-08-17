import 'dart:io';
import 'package:flutter/material.dart';
import '../../theming/app_colors.dart';
import '../../localization/app_localization_extension.dart';
import '../models/document_meta_model.dart';
import '../enums/app_enums.dart';
import 'app_card.dart';
import 'document_upload_dialog.dart';
import 'document_viewer_dialog.dart';

class DocumentsSectionWidget extends StatelessWidget {
  final List<DocumentMeta> documents;
  final ValueChanged<List<DocumentMeta>> onDocumentsChanged;
  final String? title;
  final bool readOnly;

  const DocumentsSectionWidget({
    super.key,
    required this.documents,
    required this.onDocumentsChanged,
    this.title,
    this.readOnly = false,
  });

  void _onAddDocument(BuildContext context) async {
    final newDoc = await DocumentUploadDialog.show(context);
    if (newDoc != null) {
      final updated = List<DocumentMeta>.from(documents)..add(newDoc);
      onDocumentsChanged(updated);
    }
  }

  void _onDeleteDocument(BuildContext context, int index) {
    final isArabic = context.isArabic;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'حذف المستند' : 'Delete Document'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف مستند "${documents[index].title}" وجميع الصور المرفقة به؟'
              : 'Are you sure you want to delete "${documents[index].title}" and all its attached images?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final updated = List<DocumentMeta>.from(documents)..removeAt(index);
              onDocumentsChanged(updated);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: Text(isArabic ? 'حذف' : 'Delete', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocIcon(DocumentType type, Color primaryColor) {
    IconData icon;
    switch (type) {
      case DocumentType.licenseCard:
        icon = Icons.credit_card_rounded;
        break;
      case DocumentType.leaseContract:
        icon = Icons.assignment_outlined;
        break;
      case DocumentType.nationalId:
        icon = Icons.badge_outlined;
        break;
      case DocumentType.partnershipAgreement:
        icon = Icons.handshake_outlined;
        break;
      case DocumentType.insurance:
        icon = Icons.security_rounded;
        break;
      case DocumentType.technicalInspection:
        icon = Icons.fact_check_outlined;
        break;
      case DocumentType.paymentReceipt:
        icon = Icons.receipt_long_rounded;
        break;
      default:
        icon = Icons.description_outlined;
    }
    return Icon(icon, color: primaryColor, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final textTertiary = isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8);
    final isArabic = context.isArabic;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.folder_copy_rounded, color: primaryColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title ?? (isArabic ? 'المستندات والوثائق المرفقة' : 'Documents & Attachments'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: documents.isNotEmpty
                      ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA))
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isArabic ? '${documents.length} مستند' : '${documents.length} Docs',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: documents.isNotEmpty
                        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333))
                        : textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Document List or Empty State
          if (documents.isEmpty)
            InkWell(
              onTap: readOnly ? null : () => _onAddDocument(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 36,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'لا توجد مستندات أو صور مرفقة حتى الآن' : 'No documents or images attached yet',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic ? 'اضغط هنا لتحميل رخصة، عقد، بطاقة هوية، أو فحص فني' : 'Tap to upload license, contract, ID card, or certificate',
                      style: TextStyle(fontSize: 11, color: textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final doc = documents[index];
                final images = doc.allImages;

                return InkWell(
                  onTap: () => DocumentViewerDialog.show(
                    context,
                    doc,
                    onDelete: readOnly ? null : () {
                      final updated = List<DocumentMeta>.from(documents)..removeAt(index);
                      onDocumentsChanged(updated);
                    },
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left Thumbnail or Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: images.isNotEmpty && File(images.first).existsSync()
                              ? Image.file(File(images.first), fit: BoxFit.cover)
                              : Center(child: _buildDocIcon(doc.type, primaryColor)),
                        ),
                        const SizedBox(width: 10),

                        // Title, Type / Expiry (compact with ellipsis)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      doc.title,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (images.length > 1) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.photo_library_rounded, size: 10, color: primaryColor),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${images.length}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                doc.expiryDate != null
                                    ? (doc.isExpired
                                        ? (isArabic ? 'منتهي الصلاحية' : 'Expired')
                                        : '${isArabic ? "ينتهي:" : "Exp:"} ${doc.expiryDate!.year}/${doc.expiryDate!.month.toString().padLeft(2, '0')}/${doc.expiryDate!.day.toString().padLeft(2, '0')}')
                                    : (isArabic ? doc.type.arabicLabel : doc.type.englishLabel),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: doc.expiryDate != null ? FontWeight.w600 : FontWeight.normal,
                                  color: doc.isExpired
                                      ? const Color(0xFFEF4444)
                                      : (doc.daysUntilExpiry != null && doc.daysUntilExpiry! <= 30
                                          ? const Color(0xFFF59E0B)
                                          : textSecondary),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Action Buttons (Compact)
                        IconButton(
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.visibility_outlined, color: primaryColor, size: 19),
                          tooltip: isArabic ? 'عرض المستند والصور' : 'View Document',
                          onPressed: () => DocumentViewerDialog.show(
                            context,
                            doc,
                            onDelete: readOnly ? null : () {
                              final updated = List<DocumentMeta>.from(documents)..removeAt(index);
                              onDocumentsChanged(updated);
                            },
                          ),
                        ),
                        if (!readOnly) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 19),
                            tooltip: isArabic ? 'حذف' : 'Delete',
                            onPressed: () => _onDeleteDocument(context, index),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

          if (!readOnly) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _onAddDocument(context),
              icon: Icon(Icons.add_photo_alternate_outlined, size: 18, color: primaryColor),
              label: Text(
                isArabic ? 'إضافة مستند جديد (صورة أو عدة صور)' : 'Add Document (Single or Multi-Image)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                minimumSize: const Size(double.infinity, 42),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
