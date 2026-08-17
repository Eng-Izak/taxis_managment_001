import '../enums/app_enums.dart';
import 'document_meta_model.dart';

class ShareholderModel {
  final String id;
  final String name;
  final String phone;
  final String nationalId;
  final PayoutMethod payoutMethod;
  final String accountDetails; // e.g. InstaPay handle / Vodafone cash number / IBAN
  final double totalInvestedCapital; // Capital in EGP
  final String notes;
  final List<DocumentMeta> documents;

  const ShareholderModel({
    required this.id,
    required this.name,
    required this.phone,
    this.nationalId = '',
    this.payoutMethod = PayoutMethod.instapay,
    this.accountDetails = '',
    this.totalInvestedCapital = 0.0,
    this.notes = '',
    this.documents = const [],
  });

  ShareholderModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? nationalId,
    PayoutMethod? payoutMethod,
    String? accountDetails,
    double? totalInvestedCapital,
    String? notes,
    List<DocumentMeta>? documents,
  }) {
    return ShareholderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      accountDetails: accountDetails ?? this.accountDetails,
      totalInvestedCapital: totalInvestedCapital ?? this.totalInvestedCapital,
      notes: notes ?? this.notes,
      documents: documents ?? this.documents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'nationalId': nationalId,
      'payoutMethod': payoutMethod.name,
      'accountDetails': accountDetails,
      'totalInvestedCapital': totalInvestedCapital,
      'notes': notes,
      'documents': documents.map((d) => d.toJson()).toList(),
    };
  }

  factory ShareholderModel.fromJson(Map<String, dynamic> json) {
    return ShareholderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      payoutMethod: PayoutMethod.values.firstWhere(
        (e) => e.name == json['payoutMethod'],
        orElse: () => PayoutMethod.instapay,
      ),
      accountDetails: json['accountDetails'] as String? ?? '',
      totalInvestedCapital: (json['totalInvestedCapital'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => DocumentMeta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
