import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/widgets/app_button.dart';
import '../../../../core/shared/widgets/app_text_field.dart';
import '../../../../core/shared/widgets/app_phone_field.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/widgets/app_toast.dart';
import '../../../../core/shared/widgets/documents_section_widget.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/shared/models/document_meta_model.dart';
import '../../../../core/shared/models/partner_share_model.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/shared/repos/partner_repository.dart';
import '../../../../core/dependency_injection/di.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../../home/logic/home_cubit.dart';

class AddAssetScreen extends StatefulWidget {
  final AssetModel? assetToEdit;

  const AddAssetScreen({
    super.key,
    this.assetToEdit,
  });

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  late AssetType _selectedType;
  late AssetStatus _selectedStatus;
  bool _hasAnnualTenPercentIncrease = false;

  late final TextEditingController _plateNumberController;
  late final TextEditingController _chassisNumberController;
  late final TextEditingController _engineNumberController;
  late final TextEditingController _carModelYearController;
  late final TextEditingController _assetValuationController;
  late final TextEditingController _monthlyRentController;
  late final TextEditingController _contractRenewalFeeController;
  late final TextEditingController _averageExpensesController;
  late final TextEditingController _driverNameController;
  late final TextEditingController _driverPhoneController;
  late final TextEditingController _notesController;

  CountryInfo _selectedCountry = CountryInfo.defaultCountry;

  DateTime? _licenseExpiryDate;
  DateTime? _contractExpiryDate;

  List<ShareholderModel> _registeredShareholders = [];
  final List<_PartnerShareInput> _partnerShares = [];
  List<DocumentMeta> _documents = [];

  @override
  void initState() {
    super.initState();
    final a = widget.assetToEdit;

    _selectedType = a?.modelType ?? AssetType.fullTaxi;
    _selectedStatus = a?.status ?? AssetStatus.active;
    _hasAnnualTenPercentIncrease = a?.hasAnnualTenPercentIncrease ?? false;

    _plateNumberController = TextEditingController(text: a?.plateNumber ?? '');
    _chassisNumberController = TextEditingController(text: a?.chassisNumber ?? '');
    _engineNumberController = TextEditingController(text: a?.engineNumber ?? '');
    _carModelYearController = TextEditingController(text: a?.carModelYear ?? '');
    _assetValuationController = TextEditingController(
      text: a != null && a.assetValuation > 0 ? a.assetValuation.toStringAsFixed(0) : '',
    );
    _monthlyRentController = TextEditingController(
      text: a != null && a.monthlyRent > 0 ? a.monthlyRent.toStringAsFixed(0) : '',
    );
    _contractRenewalFeeController = TextEditingController(
      text: a != null && a.contractRenewalFee > 0 ? a.contractRenewalFee.toStringAsFixed(0) : '',
    );
    _averageExpensesController = TextEditingController(
      text: a != null && a.averageMonthlyExpenses > 0 ? a.averageMonthlyExpenses.toStringAsFixed(0) : '0',
    );
    _driverNameController = TextEditingController(text: a?.driverOrRenterName ?? '');
    _driverPhoneController = TextEditingController(text: a?.driverPhone ?? '');
    _notesController = TextEditingController(text: a?.notes ?? '');

    _licenseExpiryDate = a?.licenseExpiryDate ?? DateTime.now().add(const Duration(days: 365));
    _contractExpiryDate = a?.contractExpiryDate ?? DateTime.now().add(const Duration(days: 730));
    _documents = a != null ? List<DocumentMeta>.from(a.documents) : [];

    // Load initial partner shares if editing
    if (a != null && a.partnerShares.isNotEmpty) {
      for (final share in a.partnerShares) {
        _partnerShares.add(_PartnerShareInput(
          partnerId: share.partnerId,
          partnerName: share.partnerName,
          percentageController: TextEditingController(text: share.percentage.toStringAsFixed(0)),
        ));
      }
    }

    _loadShareholders();
  }

  Future<void> _loadShareholders() async {
    try {
      final partners = await getIt<PartnerRepository>().getShareholders();
      if (mounted) {
        setState(() {
          _registeredShareholders = partners;
          // If creating new asset and shares are empty, add default 1st shareholder
          if (_partnerShares.isEmpty && partners.isNotEmpty) {
            _partnerShares.add(_PartnerShareInput(
              partnerId: partners.first.id,
              partnerName: partners.first.name,
              percentageController: TextEditingController(text: '100'),
            ));
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _chassisNumberController.dispose();
    _engineNumberController.dispose();
    _carModelYearController.dispose();
    _assetValuationController.dispose();
    _monthlyRentController.dispose();
    _contractRenewalFeeController.dispose();
    _averageExpensesController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _notesController.dispose();
    for (final p in _partnerShares) {
      p.percentageController.dispose();
    }
    super.dispose();
  }

  double get _totalSharesPercentage {
    double total = 0;
    for (final p in _partnerShares) {
      final val = double.tryParse(p.percentageController.text.trim()) ?? 0;
      total += val;
    }
    return total;
  }

  void _addPartnerShare() {
    setState(() {
      final remaining = (100 - _totalSharesPercentage).clamp(0, 100);
      final defaultPartner = _registeredShareholders.isNotEmpty
          ? _registeredShareholders.first
          : null;
      _partnerShares.add(_PartnerShareInput(
        partnerId: defaultPartner?.id ?? 'partner_${DateTime.now().millisecondsSinceEpoch}',
        partnerName: defaultPartner?.name ?? 'مساهم جديد',
        percentageController: TextEditingController(
          text: remaining > 0 ? remaining.toStringAsFixed(0) : '20',
        ),
      ));
    });
  }

  void _removePartnerShare(int index) {
    setState(() {
      _partnerShares[index].percentageController.dispose();
      _partnerShares.removeAt(index);
    });
  }

  void _saveAsset() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.assetToEdit != null;
    final valuation = double.tryParse(_assetValuationController.text.trim()) ?? 0.0;
    final rent = double.tryParse(_monthlyRentController.text.trim()) ?? 0.0;
    final renewalFee = double.tryParse(_contractRenewalFeeController.text.trim()) ?? 0.0;
    final expenses = double.tryParse(_averageExpensesController.text.trim()) ?? 0.0;

    final List<PartnerShare> builtShares = _partnerShares.map((p) {
      final pct = double.tryParse(p.percentageController.text.trim()) ?? 0.0;
      return PartnerShare(
        partnerId: p.partnerId,
        partnerName: p.partnerName,
        percentage: pct,
      );
    }).toList();

    // Format phone with dial code if provided
    final rawPhone = _driverPhoneController.text.trim();
    final fullPhone = rawPhone.isNotEmpty
        ? (rawPhone.startsWith('+') ? rawPhone : '${_selectedCountry.dialCode} $rawPhone')
        : '';

    final asset = AssetModel(
      id: isEdit ? widget.assetToEdit!.id : 'asset_${DateTime.now().millisecondsSinceEpoch}',
      plateNumber: _plateNumberController.text.trim(),
      chassisNumber: _chassisNumberController.text.trim().isNotEmpty
          ? _chassisNumberController.text.trim()
          : 'CH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      engineNumber: _engineNumberController.text.trim(),
      carModelYear: _carModelYearController.text.trim(),
      modelType: _selectedType,
      status: _selectedStatus,
      assetValuation: valuation,
      monthlyRent: rent,
      hasAnnualTenPercentIncrease: _hasAnnualTenPercentIncrease,
      contractRenewalFee: renewalFee,
      averageMonthlyExpenses: expenses,
      driverOrRenterName: _driverNameController.text.trim(),
      driverPhone: fullPhone,
      licenseExpiryDate: _licenseExpiryDate,
      contractExpiryDate: _contractExpiryDate,
      lastMaintenanceDate: DateTime.now(),
      notes: _notesController.text.trim(),
      partnerShares: builtShares,
      documents: _documents,
    );

    context.read<HomeCubit>().addOrUpdateAsset(asset);

    AppToast.show(
      context,
      message: isEdit
          ? (context.isArabic ? 'تم تحديث بيانات الأصل بنجاح' : 'Asset updated successfully')
          : (context.isArabic ? 'تمت إضافة الأصل الجديد للمحفظة بنجاح' : 'New asset added successfully'),
      duration: const Duration(seconds: 5),
    );

    Navigator.of(context).pop();
  }

  Future<void> _pickDate({required bool isLicense}) async {
    final initialDate = isLicense ? (_licenseExpiryDate ?? DateTime.now()) : (_contractExpiryDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isLicense) {
          _licenseExpiryDate = picked;
        } else {
          _contractExpiryDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.assetToEdit != null;
    final totalShares = _totalSharesPercentage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? l10n.editAsset : l10n.addNewAssetFull,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Asset Type Selector
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.assetType,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeSelectionCard(
                            label: l10n.fullTaxis,
                            icon: Icons.local_taxi_rounded,
                            isSelected: _selectedType == AssetType.fullTaxi,
                            onTap: () => setState(() => _selectedType = AssetType.fullTaxi),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TypeSelectionCard(
                            label: l10n.rentedPlatesOnly,
                            icon: Icons.credit_card_rounded,
                            isSelected: _selectedType == AssetType.plateOnly,
                            onTap: () => setState(() => _selectedType = AssetType.plateOnly),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TypeSelectionCard(
                            label: l10n.vehiclesOnly,
                            icon: Icons.directions_car_rounded,
                            isSelected: _selectedType == AssetType.vehicleOnly,
                            onTap: () => setState(() => _selectedType = AssetType.vehicleOnly),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Vehicle & Identification Details
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.vehicleAndLicenseInfo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Plate Number: Text + Numbers
                    AppTextField(
                      label: l10n.plateNumber,
                      hint: context.isArabic ? 'س أ د 4821' : 'ABC 1234',
                      controller: _plateNumberController,
                      keyboardType: TextInputType.text,
                      validator: (val) => AppValidators.requiredField(val, message: l10n.plateNumber),
                    ),
                    const SizedBox(height: 14),

                    // Car Model & Year: Text + Numbers
                    AppTextField(
                      label: l10n.carModelYear,
                      hint: 'Toyota Corolla 2023',
                      controller: _carModelYearController,
                      keyboardType: TextInputType.text,
                      validator: (val) => AppValidators.requiredField(val, message: l10n.carModelYear),
                    ),
                    const SizedBox(height: 14),

                    // Engine Number: Text + Numbers
                    AppTextField(
                      label: l10n.engineNumber,
                      hint: '1NZ-FE-7894562',
                      controller: _engineNumberController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),

                    // Chassis Number: Text + Numbers
                    AppTextField(
                      label: l10n.chassisNumber,
                      hint: 'VIN-EGY-982341-BYD',
                      controller: _chassisNumberController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),

                    // Asset Valuation: STRICTLY NUMBERS ONLY
                    AppTextField(
                      label: '${l10n.assetValuation} (${l10n.egp})',
                      hint: '550000',
                      controller: _assetValuationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) => AppValidators.validNumber(val, message: l10n.assetValuation),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Shareholders & Equity Allocation Section
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.shareholdersAndEquityAllocation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        // Total equity badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: totalShares == 100
                                ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA))
                                : totalShares < 100
                                    ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF7E0))
                                    : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFCE8E6)),
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(
                                    color: totalShares == 100
                                        ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                                        : totalShares < 100
                                            ? const Color(0xFFFBBF24).withValues(alpha: 0.3)
                                            : const Color(0xFFF87171).withValues(alpha: 0.3),
                                    width: 0.8,
                                  )
                                : null,
                          ),
                          child: Text(
                            '${l10n.totalEquityAllocation}: ${context.formatPercentage(totalShares)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: totalShares == 100
                                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333))
                                  : totalShares < 100
                                      ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB06000))
                                      : (isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Partner shares list
                    if (_partnerShares.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          l10n.noPartnersAssigned,
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      )
                    else
                      ...List.generate(_partnerShares.length, (index) {
                        final item = _partnerShares[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              // Shareholder Dropdown / Selector
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _registeredShareholders.any((s) => s.id == item.partnerId)
                                          ? item.partnerId
                                          : (_registeredShareholders.isNotEmpty ? _registeredShareholders.first.id : null),
                                      isExpanded: true,
                                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                                      ),
                                      onChanged: (val) {
                                        if (val != null) {
                                          final partner = _registeredShareholders.firstWhere((s) => s.id == val);
                                          setState(() {
                                            item.partnerId = partner.id;
                                            item.partnerName = partner.name;
                                          });
                                        }
                                      },
                                      items: _registeredShareholders.map((partner) {
                                        return DropdownMenuItem(
                                          value: partner.id,
                                          child: Text(partner.name),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Percentage TextField: STRICTLY NUMBERS ONLY (1 to 100)
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: item.percentageController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),
                                  ],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                                  ),
                                  decoration: InputDecoration(
                                    suffixText: '%',
                                    hintText: '25',
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF131D31) : const Color(0xFFF8F9FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                              ),

                              // Delete Button
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: isDark ? const Color(0xFFF87171) : const Color(0xFFC5221F),
                                  size: 22,
                                ),
                                onPressed: () => _removePartnerShare(index),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 6),

                    // Add Shareholder Button
                    OutlinedButton.icon(
                      onPressed: _addPartnerShare,
                      icon: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 18,
                        color: primaryColor,
                      ),
                      label: Text(
                        l10n.addPartnerShare,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Rental & Financial Details
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rentalAndFinancialDetails,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Monthly Rent: STRICTLY NUMBERS ONLY
                    AppTextField(
                      label: '${l10n.monthlyRent} (${l10n.egp})',
                      hint: '6000',
                      controller: _monthlyRentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) => AppValidators.validNumber(val, message: l10n.monthlyRent),
                    ),
                    const SizedBox(height: 14),

                    // 10% Annual Rent Increase Toggle
                    Material(
                      color: _hasAnnualTenPercentIncrease
                          ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFE8F0FE))
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _hasAnnualTenPercentIncrease ? primaryColor : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile.adaptive(
                        value: _hasAnnualTenPercentIncrease,
                        onChanged: (val) => setState(() => _hasAnnualTenPercentIncrease = val),
                        activeThumbColor: primaryColor,
                        title: Text(
                          l10n.annualRentIncreaseRate,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        subtitle: Text(
                          l10n.annualRentIncreaseDesc,
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Contract Renewal Fee: STRICTLY NUMBERS ONLY
                    AppTextField(
                      label: '${l10n.contractRenewalFee} (${l10n.egp})',
                      hint: '5000',
                      controller: _contractRenewalFeeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: 14),

                    // Average Monthly Expenses: STRICTLY NUMBERS ONLY
                    AppTextField(
                      label: '${l10n.averageMonthlyExpenses} (${l10n.egp})',
                      hint: '500',
                      controller: _averageExpensesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: 14),

                    // Driver Name: Text + Numbers
                    AppTextField(
                      label: l10n.driverName,
                      hint: context.isArabic ? 'كابتن أحمد محمود' : 'Captain Ahmed Mahmoud',
                      controller: _driverNameController,
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 14),

                    // Driver Phone: Country Selector & Strictly Validated Digit Count
                    AppPhoneField(
                      label: l10n.driverPhone,
                      controller: _driverPhoneController,
                      onCountryChanged: (country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5. Status and Dates
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.statusAndDates,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status Dropdown
                    Row(
                      children: [
                        Text(
                          '${l10n.assetStatus}:',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<AssetStatus>(
                          value: _selectedStatus,
                          dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                          items: [
                            DropdownMenuItem(
                              value: AssetStatus.active,
                              child: Text(l10n.statusActive, style: const TextStyle(color: Color(0xFF137333), fontWeight: FontWeight.bold)),
                            ),
                            DropdownMenuItem(
                              value: AssetStatus.maintenance,
                              child: Text(l10n.statusMaintenance, style: const TextStyle(color: Color(0xFFB06000), fontWeight: FontWeight.bold)),
                            ),
                            DropdownMenuItem(
                              value: AssetStatus.inactive,
                              child: Text(l10n.statusInactive, style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Date pickers
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerTile(
                            label: l10n.licenseExpiryDate,
                            date: _licenseExpiryDate,
                            onTap: () => _pickDate(isLicense: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DatePickerTile(
                            label: l10n.contractExpiryDate,
                            date: _contractExpiryDate,
                            onTap: () => _pickDate(isLicense: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 6. Documents & Multi-Image Attachments
              DocumentsSectionWidget(
                documents: _documents,
                onDocumentsChanged: (docs) {
                  setState(() => _documents = docs);
                },
              ),

              const SizedBox(height: 16),

              // 7. Notes: Text + Numbers
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.documentsAndNotes,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: l10n.documentsAndNotes,
                      hint: l10n.notesHint,
                      controller: _notesController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              AppButton(
                text: isEdit ? l10n.edit : l10n.save,
                onPressed: _saveAsset,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerShareInput {
  String partnerId;
  String partnerName;
  final TextEditingController percentageController;

  _PartnerShareInput({
    required this.partnerId,
    required this.partnerName,
    required this.percentageController,
  });
}

class _TypeSelectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelectionCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.35) : const Color(0xFFE8F0FE))
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primaryColor : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : (isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937)),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);

    final dateStr = date != null
        ? '${date!.year}/${date!.month.toString().padLeft(2, '0')}/${date!.day.toString().padLeft(2, '0')}'
        : 'اختر التاريخ';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Icon(Icons.calendar_month_rounded, size: 16, color: primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
