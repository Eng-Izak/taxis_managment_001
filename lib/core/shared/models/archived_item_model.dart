import 'asset_model.dart';
import 'shareholder_model.dart';
import 'transaction_model.dart';

enum ArchiveCategory {
  soldAssets,
  pastContracts,
  maintenanceLogs,
  expiredDocs,
  archivedShareholders,
}

class ArchivedItemModel {
  final String id;
  final ArchiveCategory category;
  final String title;
  final String subtitle;
  final DateTime date;
  final String tag;
  final String metaInfo;
  final AssetModel? originalAsset;
  final ShareholderModel? originalShareholder;
  final List<TransactionRecord>? shareholderTransactions;

  const ArchivedItemModel({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.tag,
    required this.metaInfo,
    this.originalAsset,
    this.originalShareholder,
    this.shareholderTransactions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'subtitle': subtitle,
      'date': date.toIso8601String(),
      'tag': tag,
      'metaInfo': metaInfo,
      'originalAsset': originalAsset?.toJson(),
      'originalShareholder': originalShareholder?.toJson(),
      'shareholderTransactions': shareholderTransactions?.map((t) => t.toJson()).toList(),
    };
  }

  factory ArchivedItemModel.fromJson(Map<String, dynamic> json) {
    return ArchivedItemModel(
      id: json['id'] as String? ?? '',
      category: ArchiveCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ArchiveCategory.soldAssets,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      tag: json['tag'] as String? ?? '',
      metaInfo: json['metaInfo'] as String? ?? '',
      originalAsset: json['originalAsset'] != null
          ? AssetModel.fromJson(json['originalAsset'] as Map<String, dynamic>)
          : null,
      originalShareholder: json['originalShareholder'] != null
          ? ShareholderModel.fromJson(json['originalShareholder'] as Map<String, dynamic>)
          : null,
      shareholderTransactions: json['shareholderTransactions'] != null
          ? (json['shareholderTransactions'] as List<dynamic>)
              .map((t) => TransactionRecord.fromJson(t as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
