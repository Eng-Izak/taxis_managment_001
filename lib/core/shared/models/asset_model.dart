import '../enums/app_enums.dart';
import 'partner_share_model.dart';
import 'document_meta_model.dart';

class AssetModel {
  final String id;
  final String plateNumber; // e.g. "س أ د 4821" / "م ن ف 1234"
  final String chassisNumber; // chassis or car VIN
  final String engineNumber; // engine/motor number (رقم الماتور)
  final String carModelYear; // e.g. "Toyota Corolla 2022" / "BYD F3 2023" / "Nissan Sunny 2021"
  final AssetType modelType;
  final double monthlyRent; // Gross rent revenue collected per month in EGP
  final bool hasAnnualTenPercentIncrease; // 10% annual escalation
  final double contractRenewalFee; // Renewal fee at end of contract period
  final List<PartnerShare> partnerShares;
  final List<DocumentMeta> documents;
  final AssetStatus status;
  final String driverOrRenterName;
  final String driverPhone;
  final double assetValuation; // Market value in EGP (e.g. 500,000 ج.م)
  final DateTime? licenseExpiryDate;
  final DateTime? contractExpiryDate;
  final DateTime? lastMaintenanceDate;
  final double averageMonthlyExpenses; // Routine maintenance/fines
  final String notes;

  const AssetModel({
    required this.id,
    required this.plateNumber,
    required this.chassisNumber,
    this.engineNumber = '',
    required this.carModelYear,
    required this.modelType,
    required this.monthlyRent,
    this.hasAnnualTenPercentIncrease = false,
    this.contractRenewalFee = 0.0,
    this.partnerShares = const [],
    this.documents = const [],
    this.status = AssetStatus.active,
    this.driverOrRenterName = '',
    this.driverPhone = '',
    this.assetValuation = 0.0,
    this.licenseExpiryDate,
    this.contractExpiryDate,
    this.lastMaintenanceDate,
    this.averageMonthlyExpenses = 0.0,
    this.notes = '',
  });

  /// Calculates net monthly distributable profit after routine operational expenses
  double get netMonthlyProfit => (monthlyRent - averageMonthlyExpenses).clamp(0.0, double.infinity);

  /// Total equity percentage allocated across partners (should sum to 100%)
  double get totalEquityPercentage =>
      partnerShares.fold(0.0, (sum, share) => sum + share.percentage);

  bool get isEquityFullyAllocated => (totalEquityPercentage - 100.0).abs() < 0.01;

  AssetModel copyWith({
    String? id,
    String? plateNumber,
    String? chassisNumber,
    String? engineNumber,
    String? carModelYear,
    AssetType? modelType,
    double? monthlyRent,
    bool? hasAnnualTenPercentIncrease,
    double? contractRenewalFee,
    List<PartnerShare>? partnerShares,
    List<DocumentMeta>? documents,
    AssetStatus? status,
    String? driverOrRenterName,
    String? driverPhone,
    double? assetValuation,
    DateTime? licenseExpiryDate,
    DateTime? contractExpiryDate,
    DateTime? lastMaintenanceDate,
    double? averageMonthlyExpenses,
    String? notes,
  }) {
    return AssetModel(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      carModelYear: carModelYear ?? this.carModelYear,
      modelType: modelType ?? this.modelType,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      hasAnnualTenPercentIncrease: hasAnnualTenPercentIncrease ?? this.hasAnnualTenPercentIncrease,
      contractRenewalFee: contractRenewalFee ?? this.contractRenewalFee,
      partnerShares: partnerShares ?? this.partnerShares,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      driverOrRenterName: driverOrRenterName ?? this.driverOrRenterName,
      driverPhone: driverPhone ?? this.driverPhone,
      assetValuation: assetValuation ?? this.assetValuation,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      contractExpiryDate: contractExpiryDate ?? this.contractExpiryDate,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      averageMonthlyExpenses: averageMonthlyExpenses ?? this.averageMonthlyExpenses,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'chassisNumber': chassisNumber,
      'engineNumber': engineNumber,
      'carModelYear': carModelYear,
      'modelType': modelType.name,
      'monthlyRent': monthlyRent,
      'hasAnnualTenPercentIncrease': hasAnnualTenPercentIncrease,
      'contractRenewalFee': contractRenewalFee,
      'partnerShares': partnerShares.map((s) => s.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'status': status.name,
      'driverOrRenterName': driverOrRenterName,
      'driverPhone': driverPhone,
      'assetValuation': assetValuation,
      'licenseExpiryDate': licenseExpiryDate?.toIso8601String(),
      'contractExpiryDate': contractExpiryDate?.toIso8601String(),
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'averageMonthlyExpenses': averageMonthlyExpenses,
      'notes': notes,
    };
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      chassisNumber: json['chassisNumber'] as String? ?? '',
      engineNumber: json['engineNumber'] as String? ?? '',
      carModelYear: json['carModelYear'] as String? ?? '',
      modelType: AssetType.values.firstWhere(
        (e) => e.name == json['modelType'],
        orElse: () => AssetType.fullTaxi,
      ),
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0.0,
      hasAnnualTenPercentIncrease: json['hasAnnualTenPercentIncrease'] as bool? ?? false,
      contractRenewalFee: (json['contractRenewalFee'] as num?)?.toDouble() ?? 0.0,
      partnerShares: (json['partnerShares'] as List<dynamic>?)
              ?.map((e) => PartnerShare.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => DocumentMeta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: AssetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssetStatus.active,
      ),
      driverOrRenterName: json['driverOrRenterName'] as String? ?? '',
      driverPhone: json['driverPhone'] as String? ?? '',
      assetValuation: (json['assetValuation'] as num?)?.toDouble() ?? 0.0,
      licenseExpiryDate: json['licenseExpiryDate'] != null
          ? DateTime.tryParse(json['licenseExpiryDate'])
          : null,
      contractExpiryDate: json['contractExpiryDate'] != null
          ? DateTime.tryParse(json['contractExpiryDate'])
          : null,
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.tryParse(json['lastMaintenanceDate'])
          : null,
      averageMonthlyExpenses: (json['averageMonthlyExpenses'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
    );
  }
}
