import '../enums/app_enums.dart';

class PartnerShare {
  final String partnerId;
  final String partnerName;
  final double percentage; // e.g. 50.0 for 50%
  final PayoutMethod payoutMethod;
  final String accountDetails;

  const PartnerShare({
    required this.partnerId,
    required this.partnerName,
    required this.percentage,
    this.payoutMethod = PayoutMethod.instapay,
    this.accountDetails = '',
  });

  PartnerShare copyWith({
    String? partnerId,
    String? partnerName,
    double? percentage,
    PayoutMethod? payoutMethod,
    String? accountDetails,
  }) {
    return PartnerShare(
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      percentage: percentage ?? this.percentage,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      accountDetails: accountDetails ?? this.accountDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'percentage': percentage,
      'payoutMethod': payoutMethod.name,
      'accountDetails': accountDetails,
    };
  }

  factory PartnerShare.fromJson(Map<String, dynamic> json) {
    return PartnerShare(
      partnerId: json['partnerId'] as String? ?? '',
      partnerName: json['partnerName'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      payoutMethod: PayoutMethod.values.firstWhere(
        (e) => e.name == json['payoutMethod'],
        orElse: () => PayoutMethod.instapay,
      ),
      accountDetails: json['accountDetails'] as String? ?? '',
    );
  }
}
