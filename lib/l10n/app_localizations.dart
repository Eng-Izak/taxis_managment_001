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
  /// **'إدارة أصول التاكسي - مدينة السادات'**
  String get appTitle;

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

  /// No description provided for @totalGrossRent.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي عوائد الإيجار'**
  String get totalGrossRent;

  /// No description provided for @totalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروفات'**
  String get totalExpenses;

  /// No description provided for @totalPartners.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الشركاء'**
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

  /// No description provided for @assetDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الأصول'**
  String get assetDistribution;

  /// No description provided for @fullTaxis.
  ///
  /// In ar, this message translates to:
  /// **'سيارات أجرة كاملة'**
  String get fullTaxis;

  /// No description provided for @rentedPlatesOnly.
  ///
  /// In ar, this message translates to:
  /// **'لوحات مؤجرة (فقط)'**
  String get rentedPlatesOnly;

  /// No description provided for @vehiclesOnly.
  ///
  /// In ar, this message translates to:
  /// **'مركبات بدون لوحات'**
  String get vehiclesOnly;

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

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @assetsList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الأصول'**
  String get assetsList;

  /// No description provided for @addNewAsset.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أصل جديد'**
  String get addNewAsset;

  /// No description provided for @assetDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الأصل'**
  String get assetDetails;

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

  /// No description provided for @modelType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الأصل / نموذج الملكية'**
  String get modelType;

  /// No description provided for @monthlyRent.
  ///
  /// In ar, this message translates to:
  /// **'الإيجار الشهري'**
  String get monthlyRent;

  /// No description provided for @driverOrRenter.
  ///
  /// In ar, this message translates to:
  /// **'السائق / المستأجر'**
  String get driverOrRenter;

  /// No description provided for @licenseExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ انتهاء الرخصة'**
  String get licenseExpiryDate;

  /// No description provided for @equityPartners.
  ///
  /// In ar, this message translates to:
  /// **'الشركاء وحصص الملكية'**
  String get equityPartners;

  /// No description provided for @ownershipEquity.
  ///
  /// In ar, this message translates to:
  /// **'نسب الملكية'**
  String get ownershipEquity;

  /// No description provided for @sharePercentage.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الحصة'**
  String get sharePercentage;

  /// No description provided for @monthlyPayout.
  ///
  /// In ar, this message translates to:
  /// **'العائد الشهري للطرف'**
  String get monthlyPayout;

  /// No description provided for @payoutMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التحويل'**
  String get payoutMethod;

  /// No description provided for @statusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط وعامل'**
  String get statusActive;

  /// No description provided for @statusMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'في الصيانة'**
  String get statusMaintenance;

  /// No description provided for @statusInactive.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get statusInactive;

  /// No description provided for @partnersList.
  ///
  /// In ar, this message translates to:
  /// **'سجل المساهمين'**
  String get partnersList;

  /// No description provided for @addPartner.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مساهم'**
  String get addPartner;

  /// No description provided for @partnerDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المساهم'**
  String get partnerDetails;

  /// No description provided for @partnerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المساهم'**
  String get partnerName;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @nationalId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي'**
  String get nationalId;

  /// No description provided for @bankAccountOrWallet.
  ///
  /// In ar, this message translates to:
  /// **'الحساب البنكي / المحفظة الذكية'**
  String get bankAccountOrWallet;

  /// No description provided for @totalInvestedEquity.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الحصص المستثمرة'**
  String get totalInvestedEquity;

  /// No description provided for @totalMonthlyDividends.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التوزيعات الشهرية'**
  String get totalMonthlyDividends;

  /// No description provided for @ownedAssetsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأصول المساهم بها'**
  String get ownedAssetsCount;

  /// No description provided for @investedAssets.
  ///
  /// In ar, this message translates to:
  /// **'الأصول المساهم بها'**
  String get investedAssets;

  /// No description provided for @financialsAndStats.
  ///
  /// In ar, this message translates to:
  /// **'التقارير والتحليلات المالية'**
  String get financialsAndStats;

  /// No description provided for @monthlyIncomeStatement.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الدخل والتدفق الشهري'**
  String get monthlyIncomeStatement;

  /// No description provided for @grossIncome.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get grossIncome;

  /// No description provided for @operationalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات التشغيلية'**
  String get operationalExpenses;

  /// No description provided for @netDistributableProfit.
  ///
  /// In ar, this message translates to:
  /// **'صافي الأرباح القابلة للتوزيع'**
  String get netDistributableProfit;

  /// No description provided for @milestoneRenewals.
  ///
  /// In ar, this message translates to:
  /// **'رسوم تجديد التراخيص والعقود (مرحلية)'**
  String get milestoneRenewals;

  /// No description provided for @roiAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل العائد على الاستثمار (ROI)'**
  String get roiAnalysis;

  /// No description provided for @annualYield.
  ///
  /// In ar, this message translates to:
  /// **'العائد السنوي المتوقع'**
  String get annualYield;

  /// No description provided for @cashflowTrend.
  ///
  /// In ar, this message translates to:
  /// **'حركة التدفق النقدي'**
  String get cashflowTrend;

  /// No description provided for @transactionsList.
  ///
  /// In ar, this message translates to:
  /// **'سجل المعاملات والتحصيلات'**
  String get transactionsList;

  /// No description provided for @addTransaction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل معاملة مالية'**
  String get addTransaction;

  /// No description provided for @transactionType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المعاملة'**
  String get transactionType;

  /// No description provided for @typeRentIncome.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل إيجار شهري'**
  String get typeRentIncome;

  /// No description provided for @typeOperationalExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف تشغيلي / صيانة'**
  String get typeOperationalExpense;

  /// No description provided for @typeRenewalFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم تجديد ترخيص / عقد'**
  String get typeRenewalFee;

  /// No description provided for @typeFine.
  ///
  /// In ar, this message translates to:
  /// **'مخالفة مرورية'**
  String get typeFine;

  /// No description provided for @typeDividendPayout.
  ///
  /// In ar, this message translates to:
  /// **'توزيع أرباح للشركاء'**
  String get typeDividendPayout;

  /// No description provided for @transactionAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get transactionAmount;

  /// No description provided for @transactionDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get transactionDate;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @paperworkAndDocuments.
  ///
  /// In ar, this message translates to:
  /// **'الأوراق والمستندات الرسمية'**
  String get paperworkAndDocuments;

  /// No description provided for @uploadDocument.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق مستند'**
  String get uploadDocument;

  /// No description provided for @documentType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المستند'**
  String get documentType;

  /// No description provided for @licenseCard.
  ///
  /// In ar, this message translates to:
  /// **'رخصة التسيير'**
  String get licenseCard;

  /// No description provided for @leaseContract.
  ///
  /// In ar, this message translates to:
  /// **'عقد الإيجار'**
  String get leaseContract;

  /// No description provided for @taxCard.
  ///
  /// In ar, this message translates to:
  /// **'البطاقة الضريبية'**
  String get taxCard;

  /// No description provided for @insuranceDoc.
  ///
  /// In ar, this message translates to:
  /// **'وثيقة التأمين'**
  String get insuranceDoc;

  /// No description provided for @cityElSadat.
  ///
  /// In ar, this message translates to:
  /// **'مدينة السادات - المنوفية'**
  String get cityElSadat;

  /// No description provided for @currencyEgp.
  ///
  /// In ar, this message translates to:
  /// **'جنيه مصري (EGP)'**
  String get currencyEgp;

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

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات حالياً'**
  String get noData;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get errorOccurred;

  /// No description provided for @successSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ بنجاح'**
  String get successSaved;

  /// No description provided for @securitySettings.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والتحقق البيومتري'**
  String get securitySettings;

  /// No description provided for @enableBiometrics.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل بصمة الإصبع / الوجه'**
  String get enableBiometrics;

  /// No description provided for @changePasscode.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رمز المرور'**
  String get changePasscode;

  /// No description provided for @themeSettings.
  ///
  /// In ar, this message translates to:
  /// **'المظهر والإعدادات'**
  String get themeSettings;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة (Language)'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;
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
