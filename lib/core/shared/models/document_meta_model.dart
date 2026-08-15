import '../enums/app_enums.dart';

class DocumentMeta {
  final String id;
  final String title;
  final DocumentType type;
  final DateTime? expiryDate;
  final DateTime? issueDate;
  final String fileUrl;
  final String notes;

  const DocumentMeta({
    required this.id,
    required this.title,
    required this.type,
    this.expiryDate,
    this.issueDate,
    this.fileUrl = '',
    this.notes = '',
  });

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'expiryDate': expiryDate?.toIso8601String(),
      'issueDate': issueDate?.toIso8601String(),
      'fileUrl': fileUrl,
      'notes': notes,
    };
  }

  factory DocumentMeta.fromJson(Map<String, dynamic> json) {
    return DocumentMeta(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.licenseCard,
      ),
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate']) : null,
      issueDate: json['issueDate'] != null ? DateTime.tryParse(json['issueDate']) : null,
      fileUrl: json['fileUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}
