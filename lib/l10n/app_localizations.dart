import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة أصول تاكسيات مدينة السادات'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'منصة استثمارية متخصصة لإدارة أسطول التاكسي وحصص الشركاء'**
  String get appSubtitle;

  /// No description provided for @fleetManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير الأسطول'**
  String get fleetManager;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك، مدير الأسطول'**
  String get welcomeBack;

  /// No description provided for @portfolioOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على أداء محفظتك اليوم'**
  String get portfolioOverview;

  /// No description provided for @totalPortfolioValue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي قيمة المحفظة'**
  String get totalPortfolioValue;

  /// No description provided for @netMonthlyRevenue.
  ///
  /// In ar, this message translates to:
  /// **'صافي الإيرادات الشهري'**
  String get netMonthlyRevenue;

  /// No description provided for @grossRentIncome.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي عوائد الإيجار'**
  String get grossRentIncome;

  /// No description provided for @totalOperationalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات التشغيلية'**
  String get totalOperationalExpenses;

  /// No description provided for @totalPartners.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المساهمين'**
  String get totalPartners;

  /// No description provided for @totalAssets.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأصول'**
  String get totalAssets;

  /// No description provided for @activeAssets.
  ///
  /// In ar, this message translates to:
  /// **'أصول نشطة'**
  String get activeAssets;

  /// No description provided for @egp.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get egp;

  /// No description provided for @growthThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'+5% هذا الشهر'**
  String get growthThisMonth;

  /// No description provided for @assetDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الأصول'**
  String get assetDistribution;

  /// No description provided for @fullTaxis.
  ///
  /// In ar, this message translates to:
  /// **'تاكسي كامل'**
  String get fullTaxis;

  /// No description provided for @fullTaxisDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيارة + لوحة تجارية'**
  String get fullTaxisDesc;

  /// No description provided for @rentedPlatesOnly.
  ///
  /// In ar, this message translates to:
  /// **'لوحة فقط'**
  String get rentedPlatesOnly;

  /// No description provided for @rentedPlatesOnlyDesc.
  ///
  /// In ar, this message translates to:
  /// **'تأجير لوحة تجارية'**
  String get rentedPlatesOnlyDesc;

  /// No description provided for @vehiclesOnly.
  ///
  /// In ar, this message translates to:
  /// **'مركبة فقط'**
  String get vehiclesOnly;

  /// No description provided for @vehiclesOnlyDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيارة بدون لوحة'**
  String get vehiclesOnlyDesc;

  /// No description provided for @ownershipModels.
  ///
  /// In ar, this message translates to:
  /// **'نماذج الملكية'**
  String get ownershipModels;

  /// No description provided for @modelFullTaxi.
  ///
  /// In ar, this message translates to:
  /// **'تاكسي كامل (سيارة + لوحة)'**
  String get modelFullTaxi;

  /// No description provided for @modelPlateOnly.
  ///
  /// In ar, this message translates to:
  /// **'لوحة فقط (تأجير للخارج)'**
  String get modelPlateOnly;

  /// No description provided for @modelVehicleOnly.
  ///
  /// In ar, this message translates to:
  /// **'سيارة فقط (استئجار لوحة)'**
  String get modelVehicleOnly;

  /// No description provided for @alertsAndSchedules.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات والمواعيد'**
  String get alertsAndSchedules;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @rentDue.
  ///
  /// In ar, this message translates to:
  /// **'إيجار مستحق'**
  String get rentDue;

  /// No description provided for @periodicMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة دورية'**
  String get periodicMaintenance;

  /// No description provided for @licenseRenewal.
  ///
  /// In ar, this message translates to:
  /// **'تجديد رخصة'**
  String get licenseRenewal;

  /// No description provided for @contractRenewal.
  ///
  /// In ar, this message translates to:
  /// **'تجديد عقد'**
  String get contractRenewal;

  /// No description provided for @trafficFine.
  ///
  /// In ar, this message translates to:
  /// **'مخالفة مرورية'**
  String get trafficFine;

  /// No description provided for @overdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get overdue;

  /// No description provided for @upcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادم'**
  String get upcoming;

  /// No description provided for @info.
  ///
  /// In ar, this message translates to:
  /// **'معلومة'**
  String get info;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navAssets.
  ///
  /// In ar, this message translates to:
  /// **'الأصول'**
  String get navAssets;

  /// No description provided for @navPartners.
  ///
  /// In ar, this message translates to:
  /// **'المساهمين'**
  String get navPartners;

  /// No description provided for @navFinancials.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get navFinancials;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @assetsManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأصول'**
  String get assetsManagement;

  /// No description provided for @assetsList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الأصول'**
  String get assetsList;

  /// No description provided for @addNewAsset.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أصل'**
  String get addNewAsset;

  /// No description provided for @addNewAssetFull.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أصل جديد للمحفظة'**
  String get addNewAssetFull;

  /// No description provided for @editAsset.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الأصل'**
  String get editAsset;

  /// No description provided for @assetDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الأصل'**
  String get assetDetails;

  /// No description provided for @searchAssetsHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث برقم اللوحة، الموديل...'**
  String get searchAssetsHint;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterFullTaxi.
  ///
  /// In ar, this message translates to:
  /// **'تاكسي كامل'**
  String get filterFullTaxi;

  /// No description provided for @filterPlateOnly.
  ///
  /// In ar, this message translates to:
  /// **'لوحة فقط'**
  String get filterPlateOnly;

  /// No description provided for @filterVehicleOnly.
  ///
  /// In ar, this message translates to:
  /// **'مركبة فقط'**
  String get filterVehicleOnly;

  /// No description provided for @monthlyIncome.
  ///
  /// In ar, this message translates to:
  /// **'الدخل الشهري'**
  String get monthlyIncome;

  /// No description provided for @monthlyReturnYield.
  ///
  /// In ar, this message translates to:
  /// **'العائد الشهري'**
  String get monthlyReturnYield;

  /// No description provided for @swipeToEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الأصل'**
  String get swipeToEdit;

  /// No description provided for @swipeToArchive.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة الأصل'**
  String get swipeToArchive;

  /// No description provided for @archiveAssetConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد أرشفة الأصل'**
  String get archiveAssetConfirmTitle;

  /// No description provided for @archiveAssetConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في نقل الأصل إلى الأرشيف السجل غير النشط؟'**
  String get archiveAssetConfirmMessage;

  /// No description provided for @plateNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get plateNumber;

  /// No description provided for @chassisNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الشاسيه'**
  String get chassisNumber;

  /// No description provided for @engineNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الماتور'**
  String get engineNumber;

  /// No description provided for @carModelYear.
  ///
  /// In ar, this message translates to:
  /// **'طراز وسنة الصنع'**
  String get carModelYear;

  /// No description provided for @assetValuation.
  ///
  /// In ar, this message translates to:
  /// **'القيمة السوقية التقديرية للأصل'**
  String get assetValuation;

  /// No description provided for @assetValuationShort.
  ///
  /// In ar, this message translates to:
  /// **'القيمة السوقية'**
  String get assetValuationShort;

  /// No description provided for @assetType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الأصل'**
  String get assetType;

  /// No description provided for @assetStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة تشغيل الأصل'**
  String get assetStatus;

  /// No description provided for @statusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط (تحت التشغيل)'**
  String get statusActive;

  /// No description provided for @statusMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة'**
  String get statusMaintenance;

  /// No description provided for @statusInactive.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get statusInactive;

  /// No description provided for @statusPlateRented.
  ///
  /// In ar, this message translates to:
  /// **'لوحة مؤجرة'**
  String get statusPlateRented;

  /// No description provided for @sincePurchase.
  ///
  /// In ar, this message translates to:
  /// **'منذ الشراء'**
  String get sincePurchase;

  /// No description provided for @equityShares.
  ///
  /// In ar, this message translates to:
  /// **'المساهمين في الأصل وتوزيع الحصص'**
  String get equityShares;

  /// No description provided for @equityDistribution.
  ///
  /// In ar, this message translates to:
  /// **'نسب الملكية والتوزيع'**
  String get equityDistribution;

  /// No description provided for @totalEquity.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalEquity;

  /// No description provided for @unassignedShare.
  ///
  /// In ar, this message translates to:
  /// **'حصة غير مخصصة'**
  String get unassignedShare;

  /// No description provided for @noPartnersAssigned.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم إضافة مساهمين بعد. اضغط على الزر أدناه لإضافة مساهم.'**
  String get noPartnersAssigned;

  /// No description provided for @addPartnerShare.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مساهم / شريك في الأصل'**
  String get addPartnerShare;

  /// No description provided for @selectShareholder.
  ///
  /// In ar, this message translates to:
  /// **'اختر المساهم'**
  String get selectShareholder;

  /// No description provided for @sharePercentage.
  ///
  /// In ar, this message translates to:
  /// **'النسبة'**
  String get sharePercentage;

  /// No description provided for @payoutMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التحويل'**
  String get payoutMethod;

  /// No description provided for @payoutInstapay.
  ///
  /// In ar, this message translates to:
  /// **'إنستاباي'**
  String get payoutInstapay;

  /// No description provided for @payoutVodafoneCash.
  ///
  /// In ar, this message translates to:
  /// **'فودافون كاش'**
  String get payoutVodafoneCash;

  /// No description provided for @payoutBankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get payoutBankTransfer;

  /// No description provided for @rentalAndContractData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الإيجار والتشغيل والتعاقد'**
  String get rentalAndContractData;

  /// No description provided for @collectedMonthlyRent.
  ///
  /// In ar, this message translates to:
  /// **'الإيجار الشهري المحصل (ج.م)'**
  String get collectedMonthlyRent;

  /// No description provided for @contractRenewalFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم تجديد العقد السنوية (ج.م)'**
  String get contractRenewalFee;

  /// No description provided for @hasAnnualIncrease.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق زيادة سنوية بنسبة 10% على الإيجار'**
  String get hasAnnualIncrease;

  /// No description provided for @annualIncreaseNotice.
  ///
  /// In ar, this message translates to:
  /// **'سيتم زيادة الإيجار تلقائياً بنسبة 10% سنوياً في تاريخ تجديد العقد'**
  String get annualIncreaseNotice;

  /// No description provided for @averageMonthlyExpenses.
  ///
  /// In ar, this message translates to:
  /// **'متوسط المصروفات والصيانة الشهرية (ج.م)'**
  String get averageMonthlyExpenses;

  /// No description provided for @contractExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ انتهاء عقد الإيجار الحالي'**
  String get contractExpiryDate;

  /// No description provided for @licenseExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ انتهاء رخصة التسيير'**
  String get licenseExpiryDate;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @driverData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات السائق الحالي (المستأجر)'**
  String get driverData;

  /// No description provided for @driverName.
  ///
  /// In ar, this message translates to:
  /// **'اسم السائق بالكامل'**
  String get driverName;

  /// No description provided for @driverPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف السائق'**
  String get driverPhone;

  /// No description provided for @documentsAndNotes.
  ///
  /// In ar, this message translates to:
  /// **'المستندات والملاحظات الإضافية'**
  String get documentsAndNotes;

  /// No description provided for @notesHint.
  ///
  /// In ar, this message translates to:
  /// **'سجل أي ملاحظات خاصة بالسيارة، السائق، أو فترات الصيانة...'**
  String get notesHint;

  /// No description provided for @saveAsset.
  ///
  /// In ar, this message translates to:
  /// **'حفظ بيانات الأصل'**
  String get saveAsset;

  /// No description provided for @updateAsset.
  ///
  /// In ar, this message translates to:
  /// **'تحديث بيانات الأصل'**
  String get updateAsset;

  /// No description provided for @saveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الأصل بنجاح!'**
  String get saveSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات الأصل بنجاح!'**
  String get updateSuccess;

  /// No description provided for @documentsRegistry.
  ///
  /// In ar, this message translates to:
  /// **'سجل المستندات والرخص'**
  String get documentsRegistry;

  /// No description provided for @addDocument.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستند'**
  String get addDocument;

  /// No description provided for @vehicleLicense.
  ///
  /// In ar, this message translates to:
  /// **'رخصة المركبة'**
  String get vehicleLicense;

  /// No description provided for @insurancePolicy.
  ///
  /// In ar, this message translates to:
  /// **'بوليصة التأمين'**
  String get insurancePolicy;

  /// No description provided for @purchaseContract.
  ///
  /// In ar, this message translates to:
  /// **'عقد الشراء'**
  String get purchaseContract;

  /// No description provided for @validUntil.
  ///
  /// In ar, this message translates to:
  /// **'صالحة حتى'**
  String get validUntil;

  /// No description provided for @comprehensiveInsurance.
  ///
  /// In ar, this message translates to:
  /// **'تأمين شامل'**
  String get comprehensiveInsurance;

  /// No description provided for @originalCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخة أصلية'**
  String get originalCopy;

  /// No description provided for @archiveAssetButton.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة الأصل'**
  String get archiveAssetButton;

  /// No description provided for @archiveAssetSubtext.
  ///
  /// In ar, this message translates to:
  /// **'نقل الأصل إلى السجل غير النشط'**
  String get archiveAssetSubtext;

  /// No description provided for @shareholders.
  ///
  /// In ar, this message translates to:
  /// **'المساهمين'**
  String get shareholders;

  /// No description provided for @shareholdersList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المساهمين والشركاء'**
  String get shareholdersList;

  /// No description provided for @addShareholder.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مساهم'**
  String get addShareholder;

  /// No description provided for @addShareholderTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مساهم جديد'**
  String get addShareholderTitle;

  /// No description provided for @editShareholderTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات المساهم'**
  String get editShareholderTitle;

  /// No description provided for @shareholderDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المساهم'**
  String get shareholderDetails;

  /// No description provided for @shareholderName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المساهم / الشريك'**
  String get shareholderName;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @nationalId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي (14 رقم)'**
  String get nationalId;

  /// No description provided for @accountDetails.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التحويل (إنستاباي / محفظة / بنك)'**
  String get accountDetails;

  /// No description provided for @totalInvestedEquity.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الحصص'**
  String get totalInvestedEquity;

  /// No description provided for @ownedAssetsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأصول'**
  String get ownedAssetsCount;

  /// No description provided for @totalInvestment.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الاستثمار'**
  String get totalInvestment;

  /// No description provided for @currentMonthReturn.
  ///
  /// In ar, this message translates to:
  /// **'عائد الشهر الحالي'**
  String get currentMonthReturn;

  /// No description provided for @investedAssetsList.
  ///
  /// In ar, this message translates to:
  /// **'الأصول المستثمر بها'**
  String get investedAssetsList;

  /// No description provided for @ownershipRatio.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الملكية'**
  String get ownershipRatio;

  /// No description provided for @mainInvestor.
  ///
  /// In ar, this message translates to:
  /// **'مستثمر رئيسي'**
  String get mainInvestor;

  /// No description provided for @partnerInvestor.
  ///
  /// In ar, this message translates to:
  /// **'مستثمر مشارك'**
  String get partnerInvestor;

  /// No description provided for @founderPartner.
  ///
  /// In ar, this message translates to:
  /// **'مؤسس شريك'**
  String get founderPartner;

  /// No description provided for @underReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get underReview;

  /// No description provided for @noShareholders.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مساهمين مسجلين'**
  String get noShareholders;

  /// No description provided for @viewShareholderDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewShareholderDetails;

  /// No description provided for @financialAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'التحليل المالي'**
  String get financialAnalysis;

  /// No description provided for @thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// No description provided for @currentQuarter.
  ///
  /// In ar, this message translates to:
  /// **'الربع الحالي'**
  String get currentQuarter;

  /// No description provided for @fiscalYear2026.
  ///
  /// In ar, this message translates to:
  /// **'السنة المالية 2026'**
  String get fiscalYear2026;

  /// No description provided for @financialPerformanceBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'بيان الأداء والتدفق النقدي'**
  String get financialPerformanceBreakdown;

  /// No description provided for @monthlyGrossIncome.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get monthlyGrossIncome;

  /// No description provided for @maintenanceAndOps.
  ///
  /// In ar, this message translates to:
  /// **'الصيانة والمصروفات'**
  String get maintenanceAndOps;

  /// No description provided for @netDistributableCashflow.
  ///
  /// In ar, this message translates to:
  /// **'صافي التدفق القابل للتوزيع'**
  String get netDistributableCashflow;

  /// No description provided for @estimatedAnnualROI.
  ///
  /// In ar, this message translates to:
  /// **'العائد السنوي المتوقع على الاستثمار (ROI)'**
  String get estimatedAnnualROI;

  /// No description provided for @roiCalculationNote.
  ///
  /// In ar, this message translates to:
  /// **'محسوب على أساس القيمة السوقية الإجمالية للأصول'**
  String get roiCalculationNote;

  /// No description provided for @monthlyRentCollections.
  ///
  /// In ar, this message translates to:
  /// **'تحصيلات الإيجار الشهرية'**
  String get monthlyRentCollections;

  /// No description provided for @receivedStatus.
  ///
  /// In ar, this message translates to:
  /// **'تم التحصيل'**
  String get receivedStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In ar, this message translates to:
  /// **'قيد التحصيل'**
  String get pendingStatus;

  /// No description provided for @overdueStatus.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get overdueStatus;

  /// No description provided for @maintenanceCost.
  ///
  /// In ar, this message translates to:
  /// **'صيانة دورية'**
  String get maintenanceCost;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @filterFinancial.
  ///
  /// In ar, this message translates to:
  /// **'مالي'**
  String get filterFinancial;

  /// No description provided for @filterMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة'**
  String get filterMaintenance;

  /// No description provided for @filterDocuments.
  ///
  /// In ar, this message translates to:
  /// **'مستندات'**
  String get filterDocuments;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get thisWeek;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقائق'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعات'**
  String hoursAgo(Object count);

  /// No description provided for @archive.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف'**
  String get archive;

  /// No description provided for @archiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرشيف الملفات والسجلات'**
  String get archiveTitle;

  /// No description provided for @searchArchiveHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في الأرشيف (أصول، عقود، صيانة...)...'**
  String get searchArchiveHint;

  /// No description provided for @catSoldAssets.
  ///
  /// In ar, this message translates to:
  /// **'أصول مباعة ومتقاعدة'**
  String get catSoldAssets;

  /// No description provided for @catPastContracts.
  ///
  /// In ar, this message translates to:
  /// **'عقود إيجار سابقة'**
  String get catPastContracts;

  /// No description provided for @catMaintenanceLogs.
  ///
  /// In ar, this message translates to:
  /// **'سجلات الصيانة المؤرشفة'**
  String get catMaintenanceLogs;

  /// No description provided for @catExpiredDocs.
  ///
  /// In ar, this message translates to:
  /// **'وثائق وتراخيص منتهية'**
  String get catExpiredDocs;

  /// No description provided for @restoreFromArchive.
  ///
  /// In ar, this message translates to:
  /// **'استعادة من الأرشيف'**
  String get restoreFromArchive;

  /// No description provided for @permanentDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائي'**
  String get permanentDelete;

  /// No description provided for @confirmPermanentDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف النهائي'**
  String get confirmPermanentDelete;

  /// No description provided for @confirmPermanentDeleteMsg.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا السجل نهائياً من الأرشيف؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get confirmPermanentDeleteMsg;

  /// No description provided for @itemRestored.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة السجل من الأرشيف بنجاح'**
  String get itemRestored;

  /// No description provided for @itemDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف السجل من الأرشيف نهائياً'**
  String get itemDeleted;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @appearanceAndTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر والسمة العامة'**
  String get appearanceAndTheme;

  /// No description provided for @lightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح (Light Mode)'**
  String get lightMode;

  /// No description provided for @lightModeDesc.
  ///
  /// In ar, this message translates to:
  /// **'واجهة نهارية مشرقة وعالية التباين'**
  String get lightModeDesc;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن (Dark Mode)'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In ar, this message translates to:
  /// **'مظهر مسائي مريح للعين وموفر للطاقة'**
  String get darkModeDesc;

  /// No description provided for @systemTheme.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي حسب النظام (System Default)'**
  String get systemTheme;

  /// No description provided for @systemThemeDesc.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة السمة تلقائياً مع إعدادات جهازك'**
  String get systemThemeDesc;

  /// No description provided for @switchThemeToLight.
  ///
  /// In ar, this message translates to:
  /// **'التبديل إلى الوضع الفاتح'**
  String get switchThemeToLight;

  /// No description provided for @switchThemeToDark.
  ///
  /// In ar, this message translates to:
  /// **'التبديل إلى الوضع الداكن'**
  String get switchThemeToDark;

  /// No description provided for @languageSettings.
  ///
  /// In ar, this message translates to:
  /// **'لغة واجهة التطبيق (Language)'**
  String get languageSettings;

  /// No description provided for @arabicLanguage.
  ///
  /// In ar, this message translates to:
  /// **'العربية (RTL - اللغة الأساسية)'**
  String get arabicLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In ar, this message translates to:
  /// **'English (LTR)'**
  String get englishLanguage;

  /// No description provided for @notificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات والتنبيهات'**
  String get notificationSettings;

  /// No description provided for @rentDueAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات استحقاق الإيجارات'**
  String get rentDueAlerts;

  /// No description provided for @rentDueAlertsDesc.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات فورية عند استحقاق أو تأخر إيجار السائقين'**
  String get rentDueAlertsDesc;

  /// No description provided for @maintenanceAlerts.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد الصيانة الدورية'**
  String get maintenanceAlerts;

  /// No description provided for @maintenanceAlertsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بمواعيد تغيير الزيت والفحص الدوري للسيارات'**
  String get maintenanceAlertsDesc;

  /// No description provided for @licenseRenewalAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تجديد رخص التسيير والتأمين'**
  String get licenseRenewalAlerts;

  /// No description provided for @licenseRenewalAlertsDesc.
  ///
  /// In ar, this message translates to:
  /// **'إشعار مسبق قبل انتهاء التراخيص بـ 30 يوماً'**
  String get licenseRenewalAlertsDesc;

  /// No description provided for @securityAndProtection.
  ///
  /// In ar, this message translates to:
  /// **'الأمان وحماية البيانات'**
  String get securityAndProtection;

  /// No description provided for @biometricAuth.
  ///
  /// In ar, this message translates to:
  /// **'التحقق ببصمة الإصبع / الوجه'**
  String get biometricAuth;

  /// No description provided for @biometricAuthDesc.
  ///
  /// In ar, this message translates to:
  /// **'طلب المصادقة البيومترية عند فتح التطبيق'**
  String get biometricAuthDesc;

  /// No description provided for @autoSessionLock.
  ///
  /// In ar, this message translates to:
  /// **'القفل التلقائي للجلسة'**
  String get autoSessionLock;

  /// No description provided for @autoSessionLockDesc.
  ///
  /// In ar, this message translates to:
  /// **'قفل الشاشة عند الخروج من التطبيق للحماية'**
  String get autoSessionLockDesc;

  /// No description provided for @passcodeSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات رمز المرور المتقدمة'**
  String get passcodeSettings;

  /// No description provided for @passcodeSettingsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كود PIN السري للمحفظة'**
  String get passcodeSettingsDesc;

  /// No description provided for @changePinCode.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رمز المرور (PIN Code)'**
  String get changePinCode;

  /// No description provided for @backupAndReports.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي وتصدير التقارير'**
  String get backupAndReports;

  /// No description provided for @exportReport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير تقرير المحفظة والأرباح (Excel/PDF)'**
  String get exportReport;

  /// No description provided for @exportReportDesc.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل كشف حساب شامل وتوزيعات الشركاء'**
  String get exportReportDesc;

  /// No description provided for @cloudSync.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة السحابية الفورية'**
  String get cloudSync;

  /// No description provided for @cloudSyncDesc.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة ناجحة: اليوم 09:30 ص'**
  String get cloudSyncDesc;

  /// No description provided for @connected.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get connected;

  /// No description provided for @reportExportSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير كشف الحساب بنجاح!'**
  String get reportExportSuccess;

  /// No description provided for @aboutSystem.
  ///
  /// In ar, this message translates to:
  /// **'عن النظام والدعم'**
  String get aboutSystem;

  /// No description provided for @systemName.
  ///
  /// In ar, this message translates to:
  /// **'نظام إدارة أصول تاكسيات مدينة السادات'**
  String get systemName;

  /// No description provided for @systemDescription.
  ///
  /// In ar, this message translates to:
  /// **'منصة استثمارية متخصصة لإدارة حصص الشركاء، عقود الإيجار، وتوزيعات الأرباح الشهرية للأسطول التجاري.'**
  String get systemDescription;

  /// No description provided for @systemVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار 1.0.0 (Build 2026) - El Sadat City Fleet Manager'**
  String get systemVersion;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات مطابقة'**
  String get noData;

  /// No description provided for @vehicleAndLicenseInfo.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المركبة والترخيص'**
  String get vehicleAndLicenseInfo;

  /// No description provided for @shareholdersAndEquityAllocation.
  ///
  /// In ar, this message translates to:
  /// **'المساهمين في الأصل وتوزيع الحصص'**
  String get shareholdersAndEquityAllocation;

  /// No description provided for @totalEquityAllocation.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الحصص'**
  String get totalEquityAllocation;

  /// No description provided for @rentalAndFinancialDetails.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الإيجار والتشغيل والتعاقد'**
  String get rentalAndFinancialDetails;

  /// No description provided for @monthlyRent.
  ///
  /// In ar, this message translates to:
  /// **'الإيجار الشهري'**
  String get monthlyRent;

  /// No description provided for @annualRentIncreaseRate.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق زيادة سنوية 10% على قيمة الإيجار'**
  String get annualRentIncreaseRate;

  /// No description provided for @annualRentIncreaseDesc.
  ///
  /// In ar, this message translates to:
  /// **'زيادة تراكمية سنوية تلقائية في العقود السنوية وطويلة الأجل'**
  String get annualRentIncreaseDesc;

  /// No description provided for @statusAndDates.
  ///
  /// In ar, this message translates to:
  /// **'الحالة وتواريخ التراخيص'**
  String get statusAndDates;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث...'**
  String get search;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
