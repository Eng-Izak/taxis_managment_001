import 'package:flutter/material.dart';
import '../shared/models/asset_model.dart';
import '../shared/models/partner_share_model.dart';
import '../shared/models/shareholder_model.dart';
import '../shared/models/transaction_model.dart';
import '../shared/models/alert_item_model.dart';
import '../shared/models/document_meta_model.dart';
import '../shared/enums/app_enums.dart';

class LocalStorageService {
  List<AssetModel> _assets = [];
  List<ShareholderModel> _shareholders = [];
  List<TransactionRecord> _transactions = [];
  List<AlertItem> _alerts = [];

  LocalStorageService() {
    _initSeedData();
  }

  void _initSeedData() {
    // Initial Shareholders
    _shareholders = [
      const ShareholderModel(
        id: 'partner_1',
        name: 'أحمد محمود سالم',
        phone: '01012345678',
        nationalId: '29001011234567',
        payoutMethod: PayoutMethod.instapay,
        accountDetails: 'ahmed.salem@instapay',
        totalInvestedCapital: 280000.0,
        notes: 'مستثمر رئيسي في تاكسيات السادات',
      ),
      const ShareholderModel(
        id: 'partner_2',
        name: 'محمد سعيد الشافعي',
        phone: '01198765432',
        nationalId: '28805051234568',
        payoutMethod: PayoutMethod.vodafoneCash,
        accountDetails: '01198765432',
        totalInvestedCapital: 140000.0,
        notes: 'شريك بنسبة 40% في لوحة س أ د 4821',
      ),
      const ShareholderModel(
        id: 'partner_3',
        name: 'فاطمة علي إبراهيم',
        phone: '01234567890',
        nationalId: '29510101234569',
        payoutMethod: PayoutMethod.bankTransfer,
        accountDetails: 'NBE - EG5000020001234567890123',
        totalInvestedCapital: 100000.0,
        notes: 'شريكة في سيارة الأجرة تويوتا كورولا',
      ),
    ];

    // Initial Assets across 3 ownership models
    _assets = [
      AssetModel(
        id: 'asset_1',
        plateNumber: 'س أ د 4821',
        chassisNumber: 'VIN-EGY-982341-BYD',
        carModelYear: 'BYD F3 2023 - غاز طبيعي',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8500.0,
        averageMonthlyExpenses: 1000.0,
        assetValuation: 280000.0,
        driverOrRenterName: 'كابتن محمود عبد العال',
        driverPhone: '01099887766',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 30)),
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 15)),
        status: AssetStatus.active,
        partnerShares: const [
          PartnerShare(
            partnerId: 'partner_1',
            partnerName: 'أحمد محمود سالم',
            percentage: 60.0,
            payoutMethod: PayoutMethod.instapay,
            accountDetails: 'ahmed.salem@instapay',
          ),
          PartnerShare(
            partnerId: 'partner_2',
            partnerName: 'محمد سعيد الشافعي',
            percentage: 40.0,
            payoutMethod: PayoutMethod.vodafoneCash,
            accountDetails: '01198765432',
          ),
        ],
        documents: [
          DocumentMeta(
            id: 'doc_1',
            title: 'رخصة تسيير تاكسي السادات',
            type: DocumentType.licenseCard,
            expiryDate: DateTime.now().add(const Duration(days: 30)),
            issueDate: DateTime.now().subtract(const Duration(days: 335)),
          ),
          DocumentMeta(
            id: 'doc_2',
            title: 'عقد تشغيل سائق أجرة',
            type: DocumentType.leaseContract,
            expiryDate: DateTime.now().add(const Duration(days: 180)),
          ),
        ],
        notes: 'السيارة تعمل ورديتين في مدينة السادات والمنطقة الصناعية',
      ),
      AssetModel(
        id: 'asset_2',
        plateNumber: 'م ن ف 9182',
        chassisNumber: 'VIN-EGY-112233-NISSAN',
        carModelYear: 'Nissan Sunny 2022',
        modelType: AssetType.fullTaxi,
        monthlyRent: 9000.0,
        averageMonthlyExpenses: 1200.0,
        assetValuation: 320000.0,
        driverOrRenterName: 'كابتن حسن التوني',
        driverPhone: '01511223344',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 120)),
        status: AssetStatus.active,
        partnerShares: const [
          PartnerShare(
            partnerId: 'partner_1',
            partnerName: 'أحمد محمود سالم',
            percentage: 100.0,
            payoutMethod: PayoutMethod.instapay,
            accountDetails: 'ahmed.salem@instapay',
          ),
        ],
        documents: [
          DocumentMeta(
            id: 'doc_3',
            title: 'رخصة القيادة والتسيير',
            type: DocumentType.licenseCard,
            expiryDate: DateTime.now().add(const Duration(days: 120)),
          ),
        ],
      ),
      const AssetModel(
        id: 'asset_3',
        plateNumber: 'س أ د 1234',
        chassisNumber: 'VIN-EGY-556677-OPTRA',
        carModelYear: 'Chevrolet Optra 2021',
        modelType: AssetType.fullTaxi,
        monthlyRent: 7500.0,
        averageMonthlyExpenses: 800.0,
        assetValuation: 240000.0,
        driverOrRenterName: 'كابتن سمير رضوان',
        driverPhone: '01222334455',
        status: AssetStatus.active,
        partnerShares: [
          PartnerShare(
            partnerId: 'partner_2',
            partnerName: 'محمد سعيد الشافعي',
            percentage: 50.0,
            payoutMethod: PayoutMethod.vodafoneCash,
          ),
          PartnerShare(
            partnerId: 'partner_3',
            partnerName: 'فاطمة علي إبراهيم',
            percentage: 50.0,
            payoutMethod: PayoutMethod.bankTransfer,
          ),
        ],
      ),
      const AssetModel(
        id: 'asset_4',
        plateNumber: 'س أ د 7731',
        chassisNumber: 'بدون مركبة (لوحة فقط)',
        carModelYear: 'لوحة تجارية أجرة سارية',
        modelType: AssetType.plateOnly,
        monthlyRent: 4000.0,
        averageMonthlyExpenses: 200.0,
        assetValuation: 160000.0,
        driverOrRenterName: 'كابتن طارق الديب (مالك السيارة)',
        driverPhone: '01066778899',
        status: AssetStatus.active,
        partnerShares: [
          PartnerShare(
            partnerId: 'partner_1',
            partnerName: 'أحمد محمود سالم',
            percentage: 70.0,
            payoutMethod: PayoutMethod.instapay,
          ),
          PartnerShare(
            partnerId: 'partner_3',
            partnerName: 'فاطمة علي إبراهيم',
            percentage: 30.0,
            payoutMethod: PayoutMethod.bankTransfer,
          ),
        ],
      ),
      const AssetModel(
        id: 'asset_5',
        plateNumber: 'م ن ف 3320',
        chassisNumber: 'بدون مركبة (لوحة فقط)',
        carModelYear: 'لوحة أجرة مدينة السادات',
        modelType: AssetType.plateOnly,
        monthlyRent: 4200.0,
        averageMonthlyExpenses: 150.0,
        assetValuation: 160000.0,
        driverOrRenterName: 'كابتن مصطفى الغندور',
        driverPhone: '01122337788',
        status: AssetStatus.active,
        partnerShares: [
          PartnerShare(
            partnerId: 'partner_2',
            partnerName: 'محمد سعيد الشافعي',
            percentage: 100.0,
          ),
        ],
      ),
      const AssetModel(
        id: 'asset_6',
        plateNumber: 'مستأجرة من طرف ثالث (س أ د 9090)',
        chassisNumber: 'VIN-EGY-990011-COROLLA',
        carModelYear: 'Toyota Corolla 2020 (مركبة فقط)',
        modelType: AssetType.vehicleOnly,
        monthlyRent:
            6000.0, // Net collection after paying plate rent to third party
        averageMonthlyExpenses: 1500.0,
        assetValuation: 350000.0,
        driverOrRenterName: 'كابتن علاء يوسف',
        driverPhone: '01033445566',
        status: AssetStatus.active,
        partnerShares: [
          PartnerShare(
            partnerId: 'partner_3',
            partnerName: 'فاطمة علي إبراهيم',
            percentage: 100.0,
          ),
        ],
      ),
    ];

    // Seed Transactions
    _transactions = [
      TransactionRecord(
        id: 'tx_1',
        assetId: 'asset_1',
        assetPlateNumber: 'س أ د 4821',
        amount: 8500.0,
        type: TransactionType.rentIncome,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'تحصيل إيجار شهري',
        notes: 'إيجار شهر أغسطس 2026',
        referenceNumber: 'REC-2026-081',
      ),
      TransactionRecord(
        id: 'tx_2',
        assetId: 'asset_2',
        assetPlateNumber: 'م ن ف 9182',
        amount: 9000.0,
        type: TransactionType.rentIncome,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'تحصيل إيجار شهري',
        notes: 'تحصيل نقدي عن طريق الكابتن حسن',
      ),
      TransactionRecord(
        id: 'tx_3',
        assetId: 'asset_1',
        assetPlateNumber: 'س أ د 4821',
        amount: 650.0,
        type: TransactionType.operationalExpense,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'صيانة دورية وتغيير زيت وفلتر',
        notes: 'مركز صيانة السادات المعتمد',
      ),
      TransactionRecord(
        id: 'tx_4',
        assetId: 'asset_1',
        assetPlateNumber: 'س أ د 4821',
        amount: 1800.0,
        type: TransactionType.renewalFee,
        date: DateTime.now().subtract(const Duration(days: 10)),
        category: 'رسوم تجديد ترخيص سنوي للمرور',
        notes: 'فحص فني وتأمين إجباري وضرائب مرور السادات (معاملة مرحلية)',
      ),
      TransactionRecord(
        id: 'tx_5',
        assetId: 'asset_4',
        assetPlateNumber: 'س أ د 7731',
        amount: 4000.0,
        type: TransactionType.rentIncome,
        date: DateTime.now().subtract(const Duration(days: 6)),
        category: 'إيجار لوحة تجارية',
      ),
    ];

    // Seed Alerts matching design prototype
    _alerts = [
      AlertItem(
        id: 'alert_1',
        title: 'إيجار مستحق',
        subtitle: 'لوحة رقم: س أ د ١٢٣٤ - متأخر يومين',
        type: AlertType.rentDue,
        priority: AlertPriority.high,
        date: DateTime.now(),
        assetId: 'asset_3',
        plateNumber: 'س أ د 1234',
      ),
      AlertItem(
        id: 'alert_2',
        title: 'صيانة دورية',
        subtitle: 'سيارة رقم: م ن ف ٥٦٧٨ (تغيير فحمات الفرامل)',
        type: AlertType.maintenance,
        priority: AlertPriority.low,
        date: DateTime.now().add(const Duration(days: 3)),
        assetId: 'asset_2',
        plateNumber: 'م ن ف 9182',
      ),
      AlertItem(
        id: 'alert_3',
        title: 'تجديد رخصة',
        subtitle: 'ينتهي الترخيص لسيارة س أ د ٤٨٢١ خلال ٣٠ يوم',
        type: AlertType.licenseExpiry,
        priority: AlertPriority.info,
        date: DateTime.now().add(const Duration(days: 30)),
        assetId: 'asset_1',
        plateNumber: 'س أ د 4821',
      ),
    ];
  }

  // Assets Operations
  List<AssetModel> getAssets() => List.unmodifiable(_assets);

  void addAsset(AssetModel asset) {
    _assets.insert(0, asset);
  }

  void updateAsset(AssetModel asset) {
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
    }
  }

  void deleteAsset(String assetId) {
    _assets.removeWhere((a) => a.id == assetId);
  }

  // Shareholders Operations
  List<ShareholderModel> getShareholders() => List.unmodifiable(_shareholders);

  void addShareholder(ShareholderModel shareholder) {
    _shareholders.insert(0, shareholder);
  }

  void updateShareholder(ShareholderModel shareholder) {
    final index = _shareholders.indexWhere((s) => s.id == shareholder.id);
    if (index != -1) {
      _shareholders[index] = shareholder;
    }
  }

  void deleteShareholder(String shareholderId) {
    _shareholders.removeWhere((s) => s.id == shareholderId);
  }

  // Transactions Operations
  List<TransactionRecord> getTransactions() => List.unmodifiable(_transactions);

  void addTransaction(TransactionRecord transaction) {
    _transactions.insert(0, transaction);
  }

  // Alerts Operations
  List<AlertItem> getAlerts() => List.unmodifiable(_alerts);

  void dismissAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
  }

  // Theme Mode Operations
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode getThemeMode() => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
  }

  // Locale Operations
  Locale _locale = const Locale('ar', 'EG');

  Locale getLocale() => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
  }
}


