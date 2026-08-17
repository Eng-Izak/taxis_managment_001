import 'asset_model.dart';

enum ArchiveCategory {
  soldAssets,
  pastContracts,
  maintenanceLogs,
  expiredDocs,
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

  const ArchivedItemModel({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.tag,
    required this.metaInfo,
    this.originalAsset,
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
    );
  }
}
