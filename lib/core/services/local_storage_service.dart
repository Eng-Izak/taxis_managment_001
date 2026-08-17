import 'package:flutter/material.dart';
import '../shared/models/asset_model.dart';
import '../shared/models/partner_share_model.dart';
import '../shared/models/shareholder_model.dart';
import '../shared/models/transaction_model.dart';
import '../shared/models/alert_item_model.dart';
import '../shared/models/document_meta_model.dart';
import '../shared/models/archived_item_model.dart';
import '../shared/enums/app_enums.dart';

class LocalStorageService {
  List<AssetModel> _assets = [];
  List<ShareholderModel> _shareholders = [];
  List<TransactionRecord> _transactions = [];
  List<AlertItem> _alerts = [];
  List<ArchivedItemModel> _archivedItems = [];

  LocalStorageService() {
    _initSeedData();
  }

  void _initSeedData() {
    // 1. Initial Shareholders
    _shareholders = [
      const ShareholderModel(
        id: 'partner_1',
        name: 'أحمد محمود سالم',
        phone: '01012345678',
        nationalId: '29001011234567',
        payoutMethod: PayoutMethod.instapay,
        accountDetails: 'ahmed.salem@instapay',
        totalInvestedCapital: 420000.0,
        notes: 'مستثمر رئيسي في تاكسيات مدينة السادات',
      ),
      const ShareholderModel(
        id: 'partner_2',
        name: 'محمد سعيد الشافعي',
        phone: '01198765432',
        nationalId: '28805051234568',
        payoutMethod: PayoutMethod.vodafoneCash,
        accountDetails: '01198765432',
        totalInvestedCapital: 232000.0,
        notes: 'شريك في تاكسي BYD F3 ولوحة م ن ف 3320',
      ),
      const ShareholderModel(
        id: 'partner_3',
        name: 'فاطمة علي إبراهيم',
        phone: '01234567890',
        nationalId: '29510101234569',
        payoutMethod: PayoutMethod.bankTransfer,
        accountDetails: 'NBE - EG5000020001234567890123',
        totalInvestedCapital: 470000.0,
        notes: 'شريكة مؤسسة في سيارات الأجرة تويوتا وشيفروليه',
      ),
    ];

    // 2. Initial Assets
    _assets = [
      AssetModel(
        id: 'asset_1',
        plateNumber: 'س أ د 4821',
        chassisNumber: 'VIN-EGY-982341-BYD',
        engineNumber: 'ENG-887712',
        carModelYear: 'BYD F3 2023 - غاز طبيعي',
        modelType: AssetType.fullTaxi,
        monthlyRent: 8500.0,
        averageMonthlyExpenses: 1000.0,
        assetValuation: 280000.0,
        driverOrRenterName: 'كابتن محمود عبد العال',
        driverPhone: '01099887766',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 28)),
        contractExpiryDate: DateTime.now().add(const Duration(days: 180)),
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
            expiryDate: DateTime.now().add(const Duration(days: 28)),
            issueDate: DateTime.now().subtract(const Duration(days: 337)),
          ),
          DocumentMeta(
            id: 'doc_2',
            title: 'عقد تشغيل سائق أجرة (كابتن محمود)',
            type: DocumentType.leaseContract,
            expiryDate: DateTime.now().add(const Duration(days: 180)),
            issueDate: DateTime.now().subtract(const Duration(days: 185)),
          ),
          DocumentMeta(
            id: 'doc_3',
            title: 'وثيقة التأمين الشامل ضد الحوادث',
            type: DocumentType.insurance,
            expiryDate: DateTime.now().add(const Duration(days: 150)),
          ),
        ],
        notes: 'السيارة تعمل ورديتين في مدينة السادات والمنطقة الصناعية',
      ),
      AssetModel(
        id: 'asset_2',
        plateNumber: 'م ن ف 9182',
        chassisNumber: 'VIN-EGY-112233-NISSAN',
        engineNumber: 'ENG-554421',
        carModelYear: 'Nissan Sunny 2022',
        modelType: AssetType.fullTaxi,
        monthlyRent: 9000.0,
        averageMonthlyExpenses: 1200.0,
        assetValuation: 320000.0,
        driverOrRenterName: 'كابتن حسن التوني',
        driverPhone: '01511223344',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 120)),
        contractExpiryDate: DateTime.now().add(const Duration(days: 240)),
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 20)),
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
            id: 'doc_4',
            title: 'رخصة تسيير المركبة',
            type: DocumentType.licenseCard,
            expiryDate: DateTime.now().add(const Duration(days: 120)),
          ),
          DocumentMeta(
            id: 'doc_5',
            title: 'عقد استئجار وتشغيل السائق',
            type: DocumentType.leaseContract,
            expiryDate: DateTime.now().add(const Duration(days: 240)),
          ),
        ],
      ),
      AssetModel(
        id: 'asset_3',
        plateNumber: 'س أ د 1234',
        chassisNumber: 'VIN-EGY-556677-OPTRA',
        engineNumber: 'ENG-332211',
        carModelYear: 'Chevrolet Optra 2021',
        modelType: AssetType.fullTaxi,
        monthlyRent: 7500.0,
        averageMonthlyExpenses: 800.0,
        assetValuation: 240000.0,
        driverOrRenterName: 'كابتن سمير رضوان',
        driverPhone: '01222334455',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 200)),
        contractExpiryDate: DateTime.now().add(const Duration(days: 90)),
        status: AssetStatus.active,
        partnerShares: const [
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
        documents: [
          DocumentMeta(
            id: 'doc_6',
            title: 'رخصة القيادة والتسيير',
            type: DocumentType.licenseCard,
            expiryDate: DateTime.now().add(const Duration(days: 200)),
          ),
        ],
      ),
      AssetModel(
        id: 'asset_4',
        plateNumber: 'س أ د 7731',
        chassisNumber: 'بدون مركبة (لوحة تجارية فقط)',
        carModelYear: 'لوحة تجارية أجرة سارية',
        modelType: AssetType.plateOnly,
        monthlyRent: 4000.0,
        averageMonthlyExpenses: 200.0,
        assetValuation: 160000.0,
        driverOrRenterName: 'كابتن طارق الديب (مالك السيارة)',
        driverPhone: '01066778899',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 310)),
        contractExpiryDate: DateTime.now().add(const Duration(days: 150)),
        status: AssetStatus.active,
        partnerShares: const [
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
      AssetModel(
        id: 'asset_5',
        plateNumber: 'م ن ف 3320',
        chassisNumber: 'بدون مركبة (لوحة تجارية فقط)',
        carModelYear: 'لوحة أجرة مدينة السادات',
        modelType: AssetType.plateOnly,
        monthlyRent: 4200.0,
        averageMonthlyExpenses: 150.0,
        assetValuation: 160000.0,
        driverOrRenterName: 'كابتن مصطفى الغندور',
        driverPhone: '01122337788',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 85)),
        status: AssetStatus.active,
        partnerShares: const [
          PartnerShare(
            partnerId: 'partner_2',
            partnerName: 'محمد سعيد الشافعي',
            percentage: 100.0,
            payoutMethod: PayoutMethod.vodafoneCash,
          ),
        ],
      ),
      AssetModel(
        id: 'asset_6',
        plateNumber: 'مستأجرة (س أ د 9090)',
        chassisNumber: 'VIN-EGY-990011-COROLLA',
        carModelYear: 'Toyota Corolla 2020 (مركبة فقط)',
        modelType: AssetType.vehicleOnly,
        monthlyRent: 6000.0,
        averageMonthlyExpenses: 1500.0,
        assetValuation: 350000.0,
        driverOrRenterName: 'كابتن علاء يوسف',
        driverPhone: '01033445566',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 60)),
        status: AssetStatus.active,
        partnerShares: const [
          PartnerShare(
            partnerId: 'partner_3',
            partnerName: 'فاطمة علي إبراهيم',
            percentage: 100.0,
            payoutMethod: PayoutMethod.bankTransfer,
          ),
        ],
      ),
    ];

    // 3. Seed Transactions (Real Financial Logs)
    _transactions = [
      TransactionRecord(
        id: 'tx_1',
        assetId: 'asset_1',
        assetPlateNumber: 'س أ د 4821',
        amount: 8500.0,
        type: TransactionType.rentIncome,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'تحصيل إيجار شهري',
        notes: 'إيجار شهر أغسطس 2026 - كابتن محمود',
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
        notes: 'تحصيل إيجار Nissan Sunny - كابتن حسن',
        referenceNumber: 'REC-2026-082',
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
        referenceNumber: 'EXP-2026-041',
      ),
      TransactionRecord(
        id: 'tx_4',
        assetId: 'asset_6',
        assetPlateNumber: 'س أ د 9090',
        amount: 850.0,
        type: TransactionType.operationalExpense,
        date: DateTime.now().subtract(const Duration(days: 8)),
        category: 'صيانة وتغيير فحمات فرامل',
        notes: 'صيانة وقائية Toyota Corolla',
        referenceNumber: 'EXP-2026-042',
      ),
      TransactionRecord(
        id: 'tx_5',
        assetId: 'asset_4',
        assetPlateNumber: 'س أ د 7731',
        amount: 4000.0,
        type: TransactionType.rentIncome,
        date: DateTime.now().subtract(const Duration(days: 6)),
        category: 'إيجار لوحة تجارية',
        referenceNumber: 'REC-2026-083',
      ),
    ];

    // 4. Seed Archived Items (Real Archive System)
    _archivedItems = [
      ArchivedItemModel(
        id: 'arch_001',
        category: ArchiveCategory.soldAssets,
        title: 'Toyota Corolla 2018 (س أ د 1122)',
        subtitle: 'تم بيع الأصل وتوزيع رأس المال على الشركاء بنجاح',
        date: DateTime(2025, 8, 15),
        tag: 'تم البيع',
        metaInfo: 'قيمة التخارج: 420,000 ج.م',
      ),
      ArchivedItemModel(
        id: 'arch_002',
        category: ArchiveCategory.pastContracts,
        title: 'عقد إيجار السائق: محمود عادل',
        subtitle: 'لوحة تاكسي 5566 - انتهاء عقد الإيجار بعد 24 شهراً',
        date: DateTime(2025, 7, 1),
        tag: 'منتهي',
        metaInfo: 'إجمالي التحصيلات: 144,000 ج.م',
      ),
      ArchivedItemModel(
        id: 'arch_003',
        category: ArchiveCategory.maintenanceLogs,
        title: 'عمرة محرك كاملة - هيونداي إلنترا (5678)',
        subtitle: 'تمت الصيانة بالكامل بمركز الخدمة المعتمد وتجربة المحرك',
        date: DateTime(2025, 3, 20),
        tag: 'مكتمل',
        metaInfo: 'التكلفة المخصومة: 18,500 ج.م',
      ),
    ];

    // 5. Seed Initial Alerts
    _alerts = [
      AlertItem(
        id: 'alert_1',
        title: 'تجديد رخصة تسيير',
        subtitle: 'ينتهي ترخيص سيارة س أ د ٤٨٢١ خلال ٢٨ يوماً',
        type: AlertType.licenseExpiry,
        priority: AlertPriority.high,
        date: DateTime.now().add(const Duration(days: 28)),
        assetId: 'asset_1',
        plateNumber: 'س أ د 4821',
      ),
      AlertItem(
        id: 'alert_2',
        title: 'موعد صيانة دورية',
        subtitle: 'سيارة م ن ف ٩١٨٢ (تغيير زيت المحرك وفحص الفرامل)',
        type: AlertType.maintenance,
        priority: AlertPriority.info,
        date: DateTime.now().add(const Duration(days: 5)),
        assetId: 'asset_2',
        plateNumber: 'م ن ف 9182',
      ),
    ];
  }

  // ================= ASSETS OPERATIONS =================
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

  void addDocumentToAsset(String assetId, DocumentMeta document) {
    final index = _assets.indexWhere((a) => a.id == assetId);
    if (index != -1) {
      final currentAsset = _assets[index];
      final updatedDocs = List<DocumentMeta>.from(currentAsset.documents)..add(document);
      _assets[index] = currentAsset.copyWith(documents: updatedDocs);
    }
  }

  // ================= ARCHIVE OPERATIONS =================
  List<ArchivedItemModel> getArchivedItems() => List.unmodifiable(_archivedItems);

  void archiveAsset(AssetModel asset, {String? reason}) {
    // 1. Remove from active assets
    _assets.removeWhere((a) => a.id == asset.id);

    // 2. Create and add to archive
    final archivedItem = ArchivedItemModel(
      id: 'arch_${DateTime.now().millisecondsSinceEpoch}',
      category: ArchiveCategory.soldAssets,
      title: '${asset.carModelYear} (${asset.plateNumber})',
      subtitle: reason ?? (asset.driverOrRenterName.isNotEmpty
          ? 'السائق: ${asset.driverOrRenterName}'
          : 'تم نقل الأصل إلى الأرشيف'),
      date: DateTime.now(),
      tag: 'مؤرشف',
      metaInfo: 'القيمة التقديرية: ${asset.assetValuation > 0 ? asset.assetValuation.toInt() : (asset.monthlyRent * 12).toInt()} ج.م',
      originalAsset: asset,
    );

    _archivedItems.insert(0, archivedItem);
  }

  bool restoreArchivedAsset(String archiveId) {
    final index = _archivedItems.indexWhere((item) => item.id == archiveId);
    if (index != -1) {
      final archivedItem = _archivedItems[index];
      if (archivedItem.originalAsset != null) {
        _assets.insert(0, archivedItem.originalAsset!);
      }
      _archivedItems.removeAt(index);
      return true;
    }
    return false;
  }

  void deleteArchivedPermanently(String archiveId) {
    _archivedItems.removeWhere((item) => item.id == archiveId);
  }

  // ================= SHAREHOLDERS OPERATIONS =================
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

  // ================= TRANSACTIONS OPERATIONS =================
  List<TransactionRecord> getTransactions() => List.unmodifiable(_transactions);

  void addTransaction(TransactionRecord transaction) {
    _transactions.insert(0, transaction);
  }

  // ================= ALERTS OPERATIONS =================
  List<AlertItem> getAlerts() {
    // Dynamic alerts generated from real assets
    final dynamicAlerts = <AlertItem>[];

    for (final asset in _assets) {
      // 1. License expiring alert (if <= 30 days)
      if (asset.licenseExpiryDate != null) {
        final daysLeft = asset.licenseExpiryDate!.difference(DateTime.now()).inDays;
        if (daysLeft >= 0 && daysLeft <= 30) {
          dynamicAlerts.add(
            AlertItem(
              id: 'dyn_lic_${asset.id}',
              title: 'تجديد رخصة تسيير',
              subtitle: 'ينتهي ترخيص ${asset.carModelYear} (${asset.plateNumber}) خلال $daysLeft يوم',
              type: AlertType.licenseExpiry,
              priority: daysLeft <= 7 ? AlertPriority.high : AlertPriority.info,
              date: asset.licenseExpiryDate!,
              assetId: asset.id,
              plateNumber: asset.plateNumber,
            ),
          );
        }
      }

      // 2. Contract expiring alert (if <= 15 days)
      if (asset.contractExpiryDate != null) {
        final daysLeft = asset.contractExpiryDate!.difference(DateTime.now()).inDays;
        if (daysLeft >= 0 && daysLeft <= 15) {
          dynamicAlerts.add(
            AlertItem(
              id: 'dyn_cont_${asset.id}',
              title: 'تجديد عقد الإيجار',
              subtitle: 'ينتهي عقد السائق ${asset.driverOrRenterName} لسيارة (${asset.plateNumber}) خلال $daysLeft يوم',
              type: AlertType.rentDue,
              priority: AlertPriority.high,
              date: asset.contractExpiryDate!,
              assetId: asset.id,
              plateNumber: asset.plateNumber,
            ),
          );
        }
      }
    }

    // Combine manual alerts with dynamic alerts (avoid duplicate IDs)
    final all = List<AlertItem>.from(_alerts);
    for (final dyn in dynamicAlerts) {
      if (!all.any((a) => a.id == dyn.id || (a.assetId == dyn.assetId && a.type == dyn.type))) {
        all.add(dyn);
      }
    }

    return List.unmodifiable(all);
  }

  void dismissAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
  }

  // ================= THEME & LOCALE OPERATIONS =================
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode getThemeMode() => _themeMode;
  void setThemeMode(ThemeMode mode) => _themeMode = mode;

  Locale _locale = const Locale('ar', 'EG');
  Locale getLocale() => _locale;
  void setLocale(Locale locale) => _locale = locale;
}
