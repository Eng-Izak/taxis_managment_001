// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'El Sadat City Taxi Asset Management';

  @override
  String get appSubtitle =>
      'Dedicated investment platform for fleet management & partner shares';

  @override
  String get fleetManager => 'Fleet Manager';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get welcomeBack => 'Welcome Back, Fleet Manager';

  @override
  String get portfolioOverview =>
      'Overview of your portfolio performance today';

  @override
  String get totalPortfolioValue => 'Total Portfolio Value';

  @override
  String get netMonthlyRevenue => 'Net Monthly Revenue';

  @override
  String get grossRentIncome => 'Gross Rent Income';

  @override
  String get totalOperationalExpenses => 'Operational Expenses';

  @override
  String get totalPartners => 'Total Shareholders';

  @override
  String get totalAssets => 'Total Assets';

  @override
  String get activeAssets => 'Active Assets';

  @override
  String get egp => 'EGP';

  @override
  String get growthThisMonth => '+5% This Month';

  @override
  String get assetDistribution => 'Asset Distribution';

  @override
  String get fullTaxis => 'Full Taxi';

  @override
  String get fullTaxisDesc => 'Vehicle + Commercial Plate';

  @override
  String get rentedPlatesOnly => 'Plate Only';

  @override
  String get rentedPlatesOnlyDesc => 'Rented Commercial Plate';

  @override
  String get vehiclesOnly => 'Vehicle Only';

  @override
  String get vehiclesOnlyDesc => 'Car Without Plate';

  @override
  String get ownershipModels => 'Ownership Models';

  @override
  String get modelFullTaxi => 'Full Taxi (Vehicle + Plate)';

  @override
  String get modelPlateOnly => 'Plate Only (Rented Out)';

  @override
  String get modelVehicleOnly => 'Vehicle Only (Plate Leased In)';

  @override
  String get alertsAndSchedules => 'Alerts & Schedules';

  @override
  String get viewAll => 'View All';

  @override
  String get rentDue => 'Rent Due';

  @override
  String get periodicMaintenance => 'Periodic Maintenance';

  @override
  String get licenseRenewal => 'License Renewal';

  @override
  String get contractRenewal => 'Contract Renewal';

  @override
  String get trafficFine => 'Traffic Fine';

  @override
  String get overdue => 'Overdue';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get info => 'Info';

  @override
  String get navHome => 'Home';

  @override
  String get navAssets => 'Assets';

  @override
  String get navPartners => 'Partners';

  @override
  String get navFinancials => 'Financials';

  @override
  String get navSettings => 'Settings';

  @override
  String get assetsManagement => 'Assets Management';

  @override
  String get assetsList => 'Assets List';

  @override
  String get addNewAsset => 'Add Asset';

  @override
  String get addNewAssetFull => 'Add New Asset to Portfolio';

  @override
  String get editAsset => 'Edit Asset Details';

  @override
  String get assetDetails => 'Asset Details';

  @override
  String get searchAssetsHint => 'Search by plate number, model...';

  @override
  String get filterAll => 'All';

  @override
  String get filterFullTaxi => 'Full Taxi';

  @override
  String get filterPlateOnly => 'Plate Only';

  @override
  String get filterVehicleOnly => 'Vehicle Only';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get monthlyReturnYield => 'Monthly Yield';

  @override
  String get swipeToEdit => 'Edit Asset Data';

  @override
  String get swipeToArchive => 'Archive Asset';

  @override
  String get archiveAssetConfirmTitle => 'Confirm Asset Archiving';

  @override
  String get archiveAssetConfirmMessage =>
      'Are you sure you want to move this asset to the inactive archives?';

  @override
  String get plateNumber => 'Plate Number';

  @override
  String get chassisNumber => 'Chassis Number';

  @override
  String get engineNumber => 'Engine Number';

  @override
  String get carModelYear => 'Car Model & Year';

  @override
  String get assetValuation => 'Estimated Market Valuation';

  @override
  String get assetValuationShort => 'Market Value';

  @override
  String get assetType => 'Asset Type';

  @override
  String get assetStatus => 'Operational Status';

  @override
  String get statusActive => 'Active (Operating)';

  @override
  String get statusMaintenance => 'Maintenance';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusPlateRented => 'Rented Plate';

  @override
  String get sincePurchase => 'Since Purchase';

  @override
  String get equityShares => 'Asset Shareholders & Equity Allocation';

  @override
  String get equityDistribution => 'Ownership Ratios & Distribution';

  @override
  String get totalEquity => 'Total';

  @override
  String get unassignedShare => 'Unassigned Share';

  @override
  String get noPartnersAssigned =>
      'No shareholders added yet. Click the button below to add a partner.';

  @override
  String get addPartnerShare => 'Add Asset Shareholder / Partner';

  @override
  String get selectShareholder => 'Select Shareholder';

  @override
  String get sharePercentage => 'Percentage';

  @override
  String get payoutMethod => 'Payout Method';

  @override
  String get payoutInstapay => 'InstaPay';

  @override
  String get payoutVodafoneCash => 'Vodafone Cash';

  @override
  String get payoutBankTransfer => 'Bank Transfer';

  @override
  String get rentalAndContractData => 'Rental & Operational Contract Details';

  @override
  String get collectedMonthlyRent => 'Collected Monthly Rent (EGP)';

  @override
  String get contractRenewalFee => 'Annual Contract Renewal Fee (EGP)';

  @override
  String get hasAnnualIncrease => 'Apply 10% Annual Rent Increase';

  @override
  String get annualIncreaseNotice =>
      'Rent will automatically increase by 10% annually on contract renewal date';

  @override
  String get averageMonthlyExpenses =>
      'Avg. Monthly Expenses & Maintenance (EGP)';

  @override
  String get contractExpiryDate => 'Current Lease Contract Expiry Date';

  @override
  String get licenseExpiryDate => 'Vehicle License Expiry Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get driverData => 'Current Driver (Tenant) Information';

  @override
  String get driverName => 'Full Driver Name';

  @override
  String get driverPhone => 'Driver Phone Number';

  @override
  String get documentsAndNotes => 'Documents & Additional Notes';

  @override
  String get notesHint =>
      'Record any notes regarding the vehicle, driver, or maintenance cycles...';

  @override
  String get saveAsset => 'Save Asset Details';

  @override
  String get updateAsset => 'Update Asset Details';

  @override
  String get saveSuccess => 'Asset saved successfully!';

  @override
  String get updateSuccess => 'Asset details updated successfully!';

  @override
  String get documentsRegistry => 'Documents & Licenses Registry';

  @override
  String get addDocument => 'Add Document';

  @override
  String get vehicleLicense => 'Vehicle License';

  @override
  String get insurancePolicy => 'Insurance Policy';

  @override
  String get purchaseContract => 'Purchase Contract';

  @override
  String get validUntil => 'Valid until';

  @override
  String get comprehensiveInsurance => 'Comprehensive Insurance';

  @override
  String get originalCopy => 'Original Copy';

  @override
  String get archiveAssetButton => 'Archive Asset';

  @override
  String get archiveAssetSubtext => 'Move asset to inactive registry';

  @override
  String get shareholders => 'Shareholders';

  @override
  String get shareholdersList => 'Shareholders & Partners Registry';

  @override
  String get addShareholder => 'Add Partner';

  @override
  String get addShareholderTitle => 'Add New Shareholder';

  @override
  String get editShareholderTitle => 'Edit Shareholder Details';

  @override
  String get shareholderDetails => 'Shareholder Details';

  @override
  String get shareholderName => 'Partner / Shareholder Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get nationalId => 'National ID (14 digits)';

  @override
  String get accountDetails => 'Payout Account (InstaPay / Wallet / Bank)';

  @override
  String get totalInvestedEquity => 'Total Shares';

  @override
  String get ownedAssetsCount => 'Assets Count';

  @override
  String get totalInvestment => 'Total Investment';

  @override
  String get currentMonthReturn => 'Current Month Return';

  @override
  String get investedAssetsList => 'Invested Assets';

  @override
  String get ownershipRatio => 'Ownership Ratio';

  @override
  String get mainInvestor => 'Lead Investor';

  @override
  String get partnerInvestor => 'Co-Investor';

  @override
  String get founderPartner => 'Founding Partner';

  @override
  String get underReview => 'Under Review';

  @override
  String get noShareholders => 'No registered shareholders found';

  @override
  String get viewShareholderDetails => 'View Details';

  @override
  String get financialAnalysis => 'Financial Analysis';

  @override
  String get thisMonth => 'This Month';

  @override
  String get currentQuarter => 'Current Quarter';

  @override
  String get fiscalYear2026 => 'Fiscal Year 2026';

  @override
  String get financialPerformanceBreakdown =>
      'Performance & Cashflow Statement';

  @override
  String get monthlyGrossIncome => 'Gross Income';

  @override
  String get maintenanceAndOps => 'Maintenance & Expenses';

  @override
  String get netDistributableCashflow => 'Net Distributable Cashflow';

  @override
  String get estimatedAnnualROI => 'Projected Annual ROI';

  @override
  String get roiCalculationNote =>
      'Calculated based on total asset portfolio market valuation';

  @override
  String get monthlyRentCollections => 'Monthly Rent Collections';

  @override
  String get receivedStatus => 'Received';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get overdueStatus => 'Overdue';

  @override
  String get maintenanceCost => 'Periodic Maintenance';

  @override
  String get notifications => 'Notifications';

  @override
  String get filterFinancial => 'Financial';

  @override
  String get filterMaintenance => 'Maintenance';

  @override
  String get filterDocuments => 'Documents';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String minutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String get archive => 'Archive';

  @override
  String get archiveTitle => 'Files & Records Archive';

  @override
  String get searchArchiveHint =>
      'Search archive (assets, contracts, maintenance...)...';

  @override
  String get catSoldAssets => 'Sold & Retired Assets';

  @override
  String get catPastContracts => 'Past Lease Contracts';

  @override
  String get catMaintenanceLogs => 'Archived Maintenance Logs';

  @override
  String get catExpiredDocs => 'Expired Documents & Licenses';

  @override
  String get restoreFromArchive => 'Restore from Archive';

  @override
  String get permanentDelete => 'Delete Permanently';

  @override
  String get confirmPermanentDelete => 'Confirm Permanent Deletion';

  @override
  String get confirmPermanentDeleteMsg =>
      'Are you sure you want to permanently delete this record from the archive? This action cannot be undone.';

  @override
  String get itemRestored => 'Record restored from archive successfully';

  @override
  String get itemDeleted => 'Record permanently deleted from archive';

  @override
  String get settings => 'Settings';

  @override
  String get appearanceAndTheme => 'Appearance & Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get lightModeDesc => 'Bright, high-contrast daytime interface';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Eye-friendly, power-saving evening interface';

  @override
  String get systemTheme => 'System Default';

  @override
  String get systemThemeDesc =>
      'Automatically synchronize with your device settings';

  @override
  String get switchThemeToLight => 'Switch to Light Mode';

  @override
  String get switchThemeToDark => 'Switch to Dark Mode';

  @override
  String get languageSettings => 'App Language';

  @override
  String get arabicLanguage => 'العربية (RTL - Arabic)';

  @override
  String get englishLanguage => 'English (LTR)';

  @override
  String get notificationSettings => 'Notifications & Alerts Settings';

  @override
  String get rentDueAlerts => 'Rent Due Alerts';

  @override
  String get rentDueAlertsDesc =>
      'Instant alerts on driver rent due dates and delays';

  @override
  String get maintenanceAlerts => 'Maintenance Schedules';

  @override
  String get maintenanceAlertsDesc =>
      'Reminders for vehicle oil change and periodic checkups';

  @override
  String get licenseRenewalAlerts => 'License & Insurance Renewals';

  @override
  String get licenseRenewalAlertsDesc =>
      'Advance reminder 30 days before license expiration';

  @override
  String get securityAndProtection => 'Security & Data Protection';

  @override
  String get biometricAuth => 'Fingerprint / Face ID Verification';

  @override
  String get biometricAuthDesc =>
      'Require biometric authentication on app launch';

  @override
  String get autoSessionLock => 'Automatic Session Lock';

  @override
  String get autoSessionLockDesc =>
      'Lock screen upon leaving the application for security';

  @override
  String get passcodeSettings => 'Advanced Passcode Settings';

  @override
  String get passcodeSettingsDesc => 'Change portfolio secret PIN code';

  @override
  String get changePinCode => 'Change PIN Code';

  @override
  String get backupAndReports => 'Backup & Report Export';

  @override
  String get exportReport => 'Export Portfolio & Dividend Report (Excel/PDF)';

  @override
  String get exportReportDesc =>
      'Download comprehensive statement and partner dividends';

  @override
  String get cloudSync => 'Real-time Cloud Sync';

  @override
  String get cloudSyncDesc => 'Last successful sync: Today 09:30 AM';

  @override
  String get connected => 'Connected';

  @override
  String get reportExportSuccess =>
      'Portfolio statement exported successfully!';

  @override
  String get aboutSystem => 'About System & Support';

  @override
  String get systemName => 'El Sadat City Taxi Fleet Manager';

  @override
  String get systemDescription =>
      'Specialized investment platform for managing partner equity shares, lease contracts, and monthly fleet dividend payouts.';

  @override
  String get systemVersion =>
      'Version 1.0.0 (Build 2026) - El Sadat City Fleet Manager';

  @override
  String get noData => 'No matching data found';

  @override
  String get vehicleAndLicenseInfo => 'Vehicle & License Information';

  @override
  String get shareholdersAndEquityAllocation =>
      'Shareholders & Equity Allocation';

  @override
  String get totalEquityAllocation => 'Total Equity';

  @override
  String get rentalAndFinancialDetails =>
      'Rental, Operation & Contract Details';

  @override
  String get monthlyRent => 'Monthly Rent';

  @override
  String get annualRentIncreaseRate => 'Apply 10% Annual Rent Increase';

  @override
  String get annualRentIncreaseDesc =>
      'Compounding annual automatic increase on annual and long-term contracts';

  @override
  String get statusAndDates => 'Status & License Dates';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search...';

  @override
  String get close => 'Close';
}
