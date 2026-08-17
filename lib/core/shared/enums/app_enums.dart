enum AssetType {
  fullTaxi,
  plateOnly,
  vehicleOnly;

  String get arabicLabel {
    switch (this) {
      case AssetType.fullTaxi:
        return 'تاكسي كامل (سيارة + لوحة)';
      case AssetType.plateOnly:
        return 'لوحة فقط (تأجير للخارج)';
      case AssetType.vehicleOnly:
        return 'مركبة فقط (استئجار لوحة)';
    }
  }

  String get englishLabel {
    switch (this) {
      case AssetType.fullTaxi:
        return 'Full Taxi (Vehicle + Plate)';
      case AssetType.plateOnly:
        return 'Plate Only (Rented Out)';
      case AssetType.vehicleOnly:
        return 'Vehicle Only (Plate Leased In)';
    }
  }

  String get shortArabicLabel {
    switch (this) {
      case AssetType.fullTaxi:
        return 'تاكسي كامل';
      case AssetType.plateOnly:
        return 'لوحة مؤجرة';
      case AssetType.vehicleOnly:
        return 'مركبة بدون لوحة';
    }
  }
}

enum AssetStatus {
  active,
  maintenance,
  inactive;

  String get arabicLabel {
    switch (this) {
      case AssetStatus.active:
        return 'نشط وعامل';
      case AssetStatus.maintenance:
        return 'في الصيانة';
      case AssetStatus.inactive:
        return 'متوقف';
    }
  }

  String get englishLabel {
    switch (this) {
      case AssetStatus.active:
        return 'Active';
      case AssetStatus.maintenance:
        return 'Maintenance';
      case AssetStatus.inactive:
        return 'Inactive';
    }
  }
}

enum TransactionType {
  rentIncome,
  operationalExpense,
  renewalFee,
  trafficFine,
  dividendPayout;

  String get arabicLabel {
    switch (this) {
      case TransactionType.rentIncome:
        return 'تحصيل إيجار شهري';
      case TransactionType.operationalExpense:
        return 'مصروف تشغيلي / صيانة';
      case TransactionType.renewalFee:
        return 'رسوم تجديد ترخيص / عقد';
      case TransactionType.trafficFine:
        return 'مخالفة مرورية';
      case TransactionType.dividendPayout:
        return 'توزيع أرباح للشركاء';
    }
  }

  bool get isIncome => this == TransactionType.rentIncome;
  bool get isMilestoneRenewal => this == TransactionType.renewalFee;
}

enum PayoutMethod {
  instapay,
  vodafoneCash,
  bankTransfer,
  cash;

  String get arabicLabel {
    switch (this) {
      case PayoutMethod.instapay:
        return 'إنستاباي (InstaPay)';
      case PayoutMethod.vodafoneCash:
        return 'فودافون كاش / محافظ إلكترونية';
      case PayoutMethod.bankTransfer:
        return 'تحويل حساب بنكي';
      case PayoutMethod.cash:
        return 'تسليم نقدي';
    }
  }
}

enum AlertType {
  rentDue,
  maintenance,
  licenseExpiry,
  contractRenewal,
  trafficFine;

  String get arabicTitle {
    switch (this) {
      case AlertType.rentDue:
        return 'إيجار مستحق';
      case AlertType.maintenance:
        return 'صيانة دورية';
      case AlertType.licenseExpiry:
        return 'تجديد رخصة';
      case AlertType.contractRenewal:
        return 'تجديد عقد الإيجار';
      case AlertType.trafficFine:
        return 'مخالفة مرورية';
    }
  }
}

enum AlertPriority {
  high,
  medium,
  low,
  info;

  String get arabicBadge {
    switch (this) {
      case AlertPriority.high:
        return 'متأخر';
      case AlertPriority.medium:
        return 'عاجل';
      case AlertPriority.low:
        return 'قادم';
      case AlertPriority.info:
        return 'معلومة';
    }
  }
}

enum DocumentType {
  licenseCard,
  leaseContract,
  taxCard,
  insurance,
  nationalId,
  partnershipAgreement,
  technicalInspection,
  paymentReceipt,
  other;

  String get arabicLabel {
    switch (this) {
      case DocumentType.licenseCard:
        return 'رخصة التسيير / القيادة';
      case DocumentType.leaseContract:
        return 'عقد الإيجار والتشغيل';
      case DocumentType.taxCard:
        return 'البطاقة الضريبية';
      case DocumentType.insurance:
        return 'وثيقة التأمين الشامل';
      case DocumentType.nationalId:
        return 'بطاقة الرقم القومي';
      case DocumentType.partnershipAgreement:
        return 'عقد الشراكة والملكية';
      case DocumentType.technicalInspection:
        return 'الفحص الفني وشهادة الصلاحية';
      case DocumentType.paymentReceipt:
        return 'إيصال سداد / مخالصة مالية';
      case DocumentType.other:
        return 'مستند إضافي';
    }
  }

  String get englishLabel {
    switch (this) {
      case DocumentType.licenseCard:
        return 'Vehicle / Driver License';
      case DocumentType.leaseContract:
        return 'Lease / Operation Contract';
      case DocumentType.taxCard:
        return 'Tax Card';
      case DocumentType.insurance:
        return 'Insurance Policy';
      case DocumentType.nationalId:
        return 'National ID Card';
      case DocumentType.partnershipAgreement:
        return 'Partnership Agreement';
      case DocumentType.technicalInspection:
        return 'Technical Inspection';
      case DocumentType.paymentReceipt:
        return 'Payment Receipt';
      case DocumentType.other:
        return 'Other Document';
    }
  }
}
