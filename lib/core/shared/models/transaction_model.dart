import '../enums/app_enums.dart';

class TransactionRecord {
  final String id;
  final String assetId;
  final String assetPlateNumber;
  final double amount; // EGP
  final TransactionType type;
  final DateTime date;
  final String category; // e.g. "إيجار شهري", "تغيير زيت وفلاتر", "تجديد رخصة سنوي", "توزيع أرباح"
  final String? partnerId;
  final String? partnerName;
  final String notes;
  final String referenceNumber;

  const TransactionRecord({
    required this.id,
    required this.assetId,
    required this.assetPlateNumber,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.partnerId,
    this.partnerName,
    this.notes = '',
    this.referenceNumber = '',
  });

  bool get isIncome => type == TransactionType.rentIncome;
  bool get isMilestoneRenewal => type == TransactionType.renewalFee;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetPlateNumber': assetPlateNumber,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
      'category': category,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'notes': notes,
      'referenceNumber': referenceNumber,
    };
  }

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      assetPlateNumber: json['assetPlateNumber'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.rentIncome,
      ),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      category: json['category'] as String? ?? '',
      partnerId: json['partnerId'] as String?,
      partnerName: json['partnerName'] as String?,
      notes: json['notes'] as String? ?? '',
      referenceNumber: json['referenceNumber'] as String? ?? '',
    );
  }
}
