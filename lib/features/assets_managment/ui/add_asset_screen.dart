import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/app_button.dart';
import '../../../../core/shared/widgets/app_text_field.dart';
import '../../../../core/shared/widgets/app_card.dart';
import '../../../../core/shared/models/asset_model.dart';
import '../../../../core/shared/models/partner_share_model.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/shared/enums/app_enums.dart';
import '../../../../core/shared/repos/partner_repository.dart';
import '../../../../core/dependency_injection/di.dart';
import '../../../../core/utils/validators.dart';
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

  DateTime? _licenseExpiryDate;
  DateTime? _contractExpiryDate;

  List<ShareholderModel> _registeredShareholders = [];
  final List<_PartnerShareInput> _partnerShares = [];

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
      driverPhone: _driverPhoneController.text.trim(),
      licenseExpiryDate: _licenseExpiryDate,
      contractExpiryDate: _contractExpiryDate,
      lastMaintenanceDate: DateTime.now(),
      notes: _notesController.text.trim(),
      partnerShares: builtShares,
      documents: isEdit ? widget.assetToEdit!.documents : const [],
    );

    context.read<HomeCubit>().addOrUpdateAsset(asset);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'تم تحديث بيانات الأصل بنجاح' : 'تمت إضافة الأصل الجديد للمحفظة بنجاح'),
        backgroundColor: const Color(0xFF137333),
      ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل بيانات الأصل' : 'إضافة أصل جديد للمحفظة'),
        centerTitle: false,
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
                    const Text(
                      'نوع الأصل الاستثماري',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F56B3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeSelectionCard(
                            label: 'تاكسي كامل',
                            icon: Icons.local_taxi_rounded,
                            isSelected: _selectedType == AssetType.fullTaxi,
                            onTap: () => setState(() => _selectedType = AssetType.fullTaxi),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TypeSelectionCard(
                            label: 'لوحة فقط',
                            icon: Icons.credit_card_rounded,
                            isSelected: _selectedType == AssetType.plateOnly,
                            onTap: () => setState(() => _selectedType = AssetType.plateOnly),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TypeSelectionCard(
                            label: 'مركبة فقط',
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

              // 2. Vehicle & Identification Details (including Engine Number)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'بيانات المركبة والترخيص',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F56B3),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'رقم اللوحة التجارية',
                      hint: 'مثال: أ ب ج 1234 أو لوحة 5566',
                      controller: _plateNumberController,
                      validator: (val) => AppValidators.requiredField(val, message: 'رقم اللوحة مطلوب'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'الموديل وسنة الصنع',
                      hint: 'مثال: تويوتا كورولا 2023 / هيونداي إلنترا 2022',
                      controller: _carModelYearController,
                      validator: (val) => AppValidators.requiredField(val, message: 'موديل وسنة الصنع مطلوب'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'رقم الماتور / المحرك',
                      hint: 'مثال: 1NZ-FE-7894562 أو رقم المحرك المثبت بالرخصة',
                      controller: _engineNumberController,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'رقم الشاسيه / الهيكل (VIN)',
                      hint: 'رقم هيكل السيارة',
                      controller: _chassisNumberController,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'القيمة التقديرية للأصل (ج.م)',
                      hint: 'مثال: 550000',
                      controller: _assetValuationController,
                      keyboardType: TextInputType.number,
                      validator: (val) => AppValidators.validNumber(val, message: 'يرجى إدخال قيمة صحيحة'),
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
                        const Text(
                          'المساهمين في الأصل وتوزيع الحصص',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F56B3),
                          ),
                        ),
                        // Total equity badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: totalShares == 100
                                ? const Color(0xFFE6F4EA)
                                : totalShares < 100
                                    ? const Color(0xFFFEF7E0)
                                    : const Color(0xFFFCE8E6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'الإجمالي: ${totalShares.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: totalShares == 100
                                  ? const Color(0xFF137333)
                                  : totalShares < 100
                                      ? const Color(0xFFB06000)
                                      : const Color(0xFFC5221F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Partner shares list
                    if (_partnerShares.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'لم يتم إضافة مساهمين بعد. اضغط على الزر أدناه لإضافة مساهم.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _registeredShareholders.any((s) => s.id == item.partnerId)
                                          ? item.partnerId
                                          : null,
                                      hint: Text(
                                        item.partnerName,
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                      ),
                                      isExpanded: true,
                                      items: _registeredShareholders.map((s) {
                                        return DropdownMenuItem<String>(
                                          value: s.id,
                                          child: Text(
                                            s.name,
                                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F56B3)),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newId) {
                                        if (newId != null) {
                                          final selected = _registeredShareholders.firstWhere((s) => s.id == newId);
                                          setState(() {
                                            item.partnerId = selected.id;
                                            item.partnerName = selected.name;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Percentage Input
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: item.percentageController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    suffixText: '%',
                                    suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F56B3)),
                                    hintText: 'النسبة',
                                    hintStyle: const TextStyle(fontSize: 11.5),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                              ),

                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFC5221F), size: 22),
                                onPressed: () => _removePartnerShare(index),
                                tooltip: 'حذف المساهم',
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 6),

                    // Add Shareholder Button
                    OutlinedButton.icon(
                      onPressed: _addPartnerShare,
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: Color(0xFF0F56B3)),
                      label: const Text(
                        'إضافة مساهم / شريك في الأصل',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F56B3)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0F56B3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Rental & Financial Details (including 10% Increase & Contract Renewal Fee)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'بيانات الإيجار والتشغيل والتعاقد',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F56B3),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'الإيجار الشهري المحصل (ج.م)',
                      hint: 'مثال: 6000',
                      controller: _monthlyRentController,
                      keyboardType: TextInputType.number,
                      validator: (val) => AppValidators.validNumber(val, message: 'يرجى إدخال مبلغ الإيجار الشهري'),
                    ),
                    const SizedBox(height: 14),

                    // 10% Annual Rent Increase Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: _hasAnnualTenPercentIncrease ? const Color(0xFFE8F0FE) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasAnnualTenPercentIncrease ? const Color(0xFF0F56B3) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: SwitchListTile.adaptive(
                        value: _hasAnnualTenPercentIncrease,
                        onChanged: (val) => setState(() => _hasAnnualTenPercentIncrease = val),
                        activeThumbColor: const Color(0xFF0F56B3),
                        title: const Text(
                          'تطبيق زيادة سنوية 10% على قيمة الإيجار',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        subtitle: const Text(
                          'زيادة تراكمية سنوية تلقائية في العقود السنوية وطويلة الأجل',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Contract Renewal Fee Field
                    AppTextField(
                      label: 'قيمة / رسوم تجديد عقد الإيجار عند انتهاء مدته (ج.م)',
                      hint: 'مثال: 5000 (رسوم التجديد عند انتهاء المدة)',
                      controller: _contractRenewalFeeController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'متوسط المصروفات الشهرية المقدرة (ج.م)',
                      hint: 'مثال: 500 (صيانة دورية وزيوت)',
                      controller: _averageExpensesController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'اسم السائق / المستأجر الحالي',
                      hint: 'مثال: أحمد محمود علي',
                      controller: _driverNameController,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'رقم هاتف السائق',
                      hint: '010XXXXXXXX',
                      controller: _driverPhoneController,
                      keyboardType: TextInputType.phone,
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
                    const Text(
                      'الحالة وتواريخ التراخيص',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F56B3),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status Dropdown
                    Row(
                      children: [
                        const Text(
                          'حالة الأصل:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<AssetStatus>(
                          value: _selectedStatus,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: AssetStatus.active,
                              child: Text('نشط ومؤجر', style: TextStyle(color: Color(0xFF137333), fontWeight: FontWeight.bold)),
                            ),
                            DropdownMenuItem(
                              value: AssetStatus.maintenance,
                              child: Text('في الصيانة', style: TextStyle(color: Color(0xFFB06000), fontWeight: FontWeight.bold)),
                            ),
                            DropdownMenuItem(
                              value: AssetStatus.inactive,
                              child: Text('غير نشط / متاح', style: TextStyle(color: Color(0xFF5F6368), fontWeight: FontWeight.bold)),
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
                            label: 'انتهاء الرخصة',
                            date: _licenseExpiryDate,
                            onTap: () => _pickDate(isLicense: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DatePickerTile(
                            label: 'انتهاء العقد',
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

              // 6. Notes
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملاحظات وبنود التعاقد',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F56B3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'ملاحظات إضافية',
                      hint: 'أي تفاصيل خاصة بحالة المركبة، التأمين، أو السائق...',
                      controller: _notesController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              AppButton(
                text: isEdit ? 'حفظ التعديلات' : 'تسجيل وإضافة الأصل',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0FE) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F56B3) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF0F56B3) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F56B3) : const Color(0xFF1F2937),
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
    final dateStr = date != null
        ? '${date!.year}/${date!.month.toString().padLeft(2, '0')}/${date!.day.toString().padLeft(2, '0')}'
        : 'اختر التاريخ';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F56B3),
                  ),
                ),
                const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF0F56B3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
