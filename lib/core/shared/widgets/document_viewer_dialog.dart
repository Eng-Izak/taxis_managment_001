import 'dart:io';
import 'package:flutter/material.dart';
import '../../localization/app_localization_extension.dart';
import '../models/document_meta_model.dart';

class DocumentViewerDialog extends StatefulWidget {
  final DocumentMeta document;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const DocumentViewerDialog({
    super.key,
    required this.document,
    this.onDelete,
    this.onEdit,
  });

  static void show(BuildContext context, DocumentMeta document, {VoidCallback? onDelete, VoidCallback? onEdit}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => DocumentViewerDialog(
        document: document,
        onDelete: onDelete,
        onEdit: onEdit,
      ),
    );
  }

  @override
  State<DocumentViewerDialog> createState() => _DocumentViewerDialogState();
}

class _DocumentViewerDialogState extends State<DocumentViewerDialog> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(String path) {
    if (path.isEmpty) {
      return _buildPlaceholder();
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F56B3).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 64,
                color: Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.document.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.document.type.arabicLabel,
                style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12),
              ),
            ),
            if (widget.document.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.document.notes,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.document.allImages;
    final totalImages = images.isNotEmpty ? images.length : 1;
    final isArabic = context.isArabic;
    final doc = widget.document;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF334155), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F56B3).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_shared_rounded,
                      color: Color(0xFF60A5FA),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              isArabic ? doc.type.arabicLabel : doc.type.englishLabel,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11.5,
                              ),
                            ),
                            if (totalImages > 1) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F56B3).withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isArabic ? 'صورة ${_currentIndex + 1} من $totalImages' : 'Image ${_currentIndex + 1} of $totalImages',
                                  style: const TextStyle(
                                    color: Color(0xFF93C5FD),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Edit Action (if provided)
                  if (widget.onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF60A5FA), size: 24),
                      tooltip: isArabic ? 'تعديل المستند' : 'Edit document',
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onEdit?.call();
                      },
                    ),

                  // Delete Action (if provided)
                  if (widget.onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 22),
                      tooltip: isArabic ? 'حذف المستند' : 'Delete document',
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDelete?.call();
                      },
                    ),

                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Image Viewer Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (images.isEmpty)
                    _buildPlaceholder()
                  else
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (idx) {
                        setState(() => _currentIndex = idx);
                        _transformController.value = Matrix4.identity();
                      },
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          transformationController: _transformController,
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Center(
                            child: _buildImageWidget(images[index]),
                          ),
                        );
                      },
                    ),

                  // Navigation Arrows (if multi-image)
                  if (totalImages > 1) ...[
                    if (_currentIndex > 0)
                      Positioned(
                        left: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    if (_currentIndex < totalImages - 1)
                      Positioned(
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),

            // Bottom Thumbnail Strip (if multi-image)
            if (images.length > 1)
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF131D31),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, idx) {
                    final isSelected = idx == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          idx,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildImageWidget(images[idx]),
                      ),
                    );
                  },
                ),
              ),

            // Metadata Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  // Expiry Status
                  if (doc.expiryDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: doc.isExpired
                            ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                            : (doc.daysUntilExpiry != null && doc.daysUntilExpiry! <= 30
                                ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                : const Color(0xFF10B981).withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            doc.isExpired ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                            size: 14,
                            color: doc.isExpired
                                ? const Color(0xFFF87171)
                                : (doc.daysUntilExpiry != null && doc.daysUntilExpiry! <= 30
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFF34D399)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doc.isExpired
                                ? (isArabic ? 'منتهي الصلاحية' : 'Expired')
                                : '${isArabic ? "ساري حتى:" : "Valid until:"} ${doc.expiryDate!.year}/${doc.expiryDate!.month.toString().padLeft(2, '0')}/${doc.expiryDate!.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: doc.isExpired
                                  ? const Color(0xFFF87171)
                                  : (doc.daysUntilExpiry != null && doc.daysUntilExpiry! <= 30
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFF34D399)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      isArabic ? 'مستند دائم (بدون انتهاء)' : 'Permanent Document',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    ),
                  ],

                  const Spacer(),

                  // Image count badge
                  Text(
                    isArabic ? '$totalImages صور مرفقة' : '$totalImages Images',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
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
