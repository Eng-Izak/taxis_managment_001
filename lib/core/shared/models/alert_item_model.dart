import '../enums/app_enums.dart';

class AlertItem {
  final String id;
  final String title;
  final String subtitle;
  final AlertType type;
  final AlertPriority priority;
  final DateTime date;
  final String? assetId;
  final String? plateNumber;

  const AlertItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.priority,
    required this.date,
    this.assetId,
    this.plateNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'priority': priority.name,
      'date': date.toIso8601String(),
      'assetId': assetId,
      'plateNumber': plateNumber,
    };
  }

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.rentDue,
      ),
      priority: AlertPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AlertPriority.low,
      ),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      assetId: json['assetId'] as String?,
      plateNumber: json['plateNumber'] as String?,
    );
  }
}
