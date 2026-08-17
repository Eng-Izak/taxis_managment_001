import '../enums/app_enums.dart';

class DocumentMeta {
  final String id;
  final String title;
  final DocumentType type;
  final DateTime? expiryDate;
  final DateTime? issueDate;
  final String fileUrl;
  final List<String> images; // List of image paths or URLs (المستند صورة أو عدة صور)
  final String notes;
  final DateTime? createdAt;

  const DocumentMeta({
    required this.id,
    required this.title,
    required this.type,
    this.expiryDate,
    this.issueDate,
    this.fileUrl = '',
    this.images = const [],
    this.notes = '',
    this.createdAt,
  });

  /// Returns all available images (from images list or fileUrl)
  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (fileUrl.isNotEmpty) return [fileUrl];
    return const [];
  }

  int get imageCount => allImages.length;

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  DocumentMeta copyWith({
    String? id,
    String? title,
    DocumentType? type,
    DateTime? expiryDate,
    DateTime? issueDate,
    String? fileUrl,
    List<String>? images,
    String? notes,
    DateTime? createdAt,
  }) {
    return DocumentMeta(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      issueDate: issueDate ?? this.issueDate,
      fileUrl: fileUrl ?? this.fileUrl,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'expiryDate': expiryDate?.toIso8601String(),
      'issueDate': issueDate?.toIso8601String(),
      'fileUrl': fileUrl,
      'images': images,
      'notes': notes,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory DocumentMeta.fromJson(Map<String, dynamic> json) {
    final imgsList = (json['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final legacyUrl = json['fileUrl'] as String? ?? '';

    return DocumentMeta(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.licenseCard,
      ),
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate']) : null,
      issueDate: json['issueDate'] != null ? DateTime.tryParse(json['issueDate']) : null,
      fileUrl: legacyUrl,
      images: imgsList.isNotEmpty ? imgsList : (legacyUrl.isNotEmpty ? [legacyUrl] : []),
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
