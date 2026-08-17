import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theming/app_colors.dart';
import '../../localization/app_localization_extension.dart';

class CountryInfo {
  final String nameAr;
  final String nameEn;
  final String dialCode;
  final String flag;
  final int minDigits;
  final int maxDigits;
  final String example;
  final String? prefixPattern; // e.g. for Egypt starts with 01 or 1, Saudi starts with 5

  const CountryInfo({
    required this.nameAr,
    required this.nameEn,
    required this.dialCode,
    required this.flag,
    required this.minDigits,
    required this.maxDigits,
    required this.example,
    this.prefixPattern,
  });

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;

  static const List<CountryInfo> supportedCountries = [
    CountryInfo(
      nameAr: 'مصر',
      nameEn: 'Egypt',
      dialCode: '+20',
      flag: '🇪🇬',
      minDigits: 10,
      maxDigits: 11,
      example: '01012345678',
      prefixPattern: r'^(01|1)[0125]',
    ),
    CountryInfo(
      nameAr: 'المملكة العربية السعودية',
      nameEn: 'Saudi Arabia',
      dialCode: '+966',
      flag: '🇸🇦',
      minDigits: 9,
      maxDigits: 9,
      example: '501234567',
      prefixPattern: r'^5',
    ),
    CountryInfo(
      nameAr: 'الإمارات العربية المتحدة',
      nameEn: 'United Arab Emirates',
      dialCode: '+971',
      flag: '🇦🇪',
      minDigits: 9,
      maxDigits: 9,
      example: '501234567',
      prefixPattern: r'^5',
    ),
    CountryInfo(
      nameAr: 'الكويت',
      nameEn: 'Kuwait',
      dialCode: '+965',
      flag: '🇰🇼',
      minDigits: 8,
      maxDigits: 8,
      example: '91234567',
    ),
    CountryInfo(
      nameAr: 'قطر',
      nameEn: 'Qatar',
      dialCode: '+974',
      flag: '🇶🇦',
      minDigits: 8,
      maxDigits: 8,
      example: '33123456',
    ),
    CountryInfo(
      nameAr: 'البحرين',
      nameEn: 'Bahrain',
      dialCode: '+973',
      flag: '🇧🇭',
      minDigits: 8,
      maxDigits: 8,
      example: '39123456',
    ),
    CountryInfo(
      nameAr: 'سلطنة عُمان',
      nameEn: 'Oman',
      dialCode: '+968',
      flag: '🇴🇲',
      minDigits: 8,
      maxDigits: 8,
      example: '91234567',
    ),
    CountryInfo(
      nameAr: 'الأردن',
      nameEn: 'Jordan',
      dialCode: '+962',
      flag: '🇯🇴',
      minDigits: 9,
      maxDigits: 9,
      example: '791234567',
      prefixPattern: r'^7',
    ),
    CountryInfo(
      nameAr: 'العراق',
      nameEn: 'Iraq',
      dialCode: '+964',
      flag: '🇮🇶',
      minDigits: 10,
      maxDigits: 10,
      example: '7701234567',
      prefixPattern: r'^7',
    ),
    CountryInfo(
      nameAr: 'لبنان',
      nameEn: 'Lebanon',
      dialCode: '+961',
      flag: '🇱🇧',
      minDigits: 8,
      maxDigits: 8,
      example: '71123456',
    ),
    CountryInfo(
      nameAr: 'ليبيا',
      nameEn: 'Libya',
      dialCode: '+218',
      flag: '🇱🇾',
      minDigits: 9,
      maxDigits: 9,
      example: '911234567',
      prefixPattern: r'^9',
    ),
    CountryInfo(
      nameAr: 'السودان',
      nameEn: 'Sudan',
      dialCode: '+249',
      flag: '🇸🇩',
      minDigits: 9,
      maxDigits: 9,
      example: '912345678',
      prefixPattern: r'^9',
    ),
    CountryInfo(
      nameAr: 'المغرب',
      nameEn: 'Morocco',
      dialCode: '+212',
      flag: '🇲🇦',
      minDigits: 9,
      maxDigits: 9,
      example: '612345678',
      prefixPattern: r'^[67]',
    ),
    CountryInfo(
      nameAr: 'الجزائر',
      nameEn: 'Algeria',
      dialCode: '+213',
      flag: '🇩🇿',
      minDigits: 9,
      maxDigits: 9,
      example: '551234567',
      prefixPattern: r'^[567]',
    ),
    CountryInfo(
      nameAr: 'تونس',
      nameEn: 'Tunisia',
      dialCode: '+216',
      flag: '🇹🇳',
      minDigits: 8,
      maxDigits: 8,
      example: '98123456',
    ),
    CountryInfo(
      nameAr: 'الولايات المتحدة',
      nameEn: 'United States',
      dialCode: '+1',
      flag: '🇺🇸',
      minDigits: 10,
      maxDigits: 10,
      example: '2025550123',
    ),
    CountryInfo(
      nameAr: 'المملكة المتحدة',
      nameEn: 'United Kingdom',
      dialCode: '+44',
      flag: '🇬🇧',
      minDigits: 10,
      maxDigits: 10,
      example: '7911123456',
    ),
  ];

  static CountryInfo get defaultCountry => supportedCountries.first; // Egypt (+20)

  static CountryInfo findByDialCode(String dialCode) {
    return supportedCountries.firstWhere(
      (c) => c.dialCode == dialCode,
      orElse: () => defaultCountry,
    );
  }
}

class AppPhoneField extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final ValueChanged<CountryInfo>? onCountryChanged;
  final bool isRequired;
  final String? initialDialCode;

  const AppPhoneField({
    super.key,
    this.label,
    required this.controller,
    this.onCountryChanged,
    this.isRequired = false,
    this.initialDialCode,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late CountryInfo _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryInfo.defaultCountry;

    // Detect country from controller initial text or initialDialCode
    _parseInitialCountry();
  }

  void _parseInitialCountry() {
    final text = widget.controller.text.trim();
    if (widget.initialDialCode != null) {
      _selectedCountry = CountryInfo.findByDialCode(widget.initialDialCode!);
    } else if (text.startsWith('+')) {
      for (final country in CountryInfo.supportedCountries) {
        if (text.startsWith(country.dialCode)) {
          _selectedCountry = country;
          widget.controller.text = text.substring(country.dialCode.length).trim();
          break;
        }
      }
    }
  }

  void _showCountryPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final isArabic = context.isArabic;
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = CountryInfo.supportedCountries.where((c) {
              if (query.isEmpty) return true;
              return c.nameAr.toLowerCase().contains(query) ||
                  c.nameEn.toLowerCase().contains(query) ||
                  c.dialCode.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Material(
                color: isDark ? const Color(0xFF131D31) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                  // Modal Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isArabic ? 'اختر الدولة ورمز الاتصال' : 'Select Country & Dial Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search Field
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: isArabic ? 'بحث باسم الدولة أو الكود (+20)...' : 'Search country name or code (+20)...',
                      prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Countries List
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark ? AppColors.darkCardBorder.withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, index) {
                        final country = filtered[index];
                        final isSelected = country.dialCode == _selectedCountry.dialCode;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 26),
                          ),
                          title: Text(
                            country.getName(isArabic),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? primaryColor : (isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937)),
                            ),
                          ),
                          subtitle: Text(
                            '${isArabic ? "مثال:" : "e.g."} ${country.example} (${country.minDigits == country.maxDigits ? "${country.maxDigits} ${isArabic ? 'أرقام' : 'digits'}" : "${country.minDigits}-${country.maxDigits} ${isArabic ? 'أرقام' : 'digits'}"})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              country.dialCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? primaryColor : (isDark ? AppColors.darkTextSecondary : const Color(0xFF475569)),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
                            });
                            widget.onCountryChanged?.call(country);
                            Navigator.of(modalCtx).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  String? _validatePhone(String? value, bool isArabic) {
    if (value == null || value.trim().isEmpty) {
      if (widget.isRequired) {
        return isArabic ? 'يرجى إدخال رقم الهاتف' : 'Phone number is required';
      }
      return null;
    }

    final clean = value.replaceAll(RegExp(r'\s+'), '');

    // 1. Must be numeric only
    if (!RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return isArabic ? 'يجب أن يحتوي رقم الهاتف على أرقام فقط' : 'Phone must contain digits only';
    }

    // 2. Length validation based on selected country
    if (clean.length < _selectedCountry.minDigits || clean.length > _selectedCountry.maxDigits) {
      if (_selectedCountry.minDigits == _selectedCountry.maxDigits) {
        return isArabic
            ? 'رقم الهاتف لدولة ${_selectedCountry.nameAr} يجب أن يتكون من ${_selectedCountry.maxDigits} أرقام بالضبط (مثال: ${_selectedCountry.example})'
            : 'Phone number for ${_selectedCountry.nameEn} must be exactly ${_selectedCountry.maxDigits} digits (e.g. ${_selectedCountry.example})';
      } else {
        return isArabic
            ? 'رقم الهاتف يجب أن يكون بين ${_selectedCountry.minDigits} و ${_selectedCountry.maxDigits} أرقام (مثال: ${_selectedCountry.example})'
            : 'Phone must be between ${_selectedCountry.minDigits} and ${_selectedCountry.maxDigits} digits (e.g. ${_selectedCountry.example})';
      }
    }

    // 3. Prefix pattern check if defined
    if (_selectedCountry.prefixPattern != null) {
      final reg = RegExp(_selectedCountry.prefixPattern!);
      if (!reg.hasMatch(clean)) {
        return isArabic
            ? 'صيغة الرقم غير صحيحة لدولة ${_selectedCountry.nameAr} (مثال: ${_selectedCountry.example})'
            : 'Invalid format for ${_selectedCountry.nameEn} (e.g. ${_selectedCountry.example})';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final isArabic = context.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_selectedCountry.getName(isArabic)} (${_selectedCountry.minDigits == _selectedCountry.maxDigits ? "${_selectedCountry.maxDigits} ${isArabic ? 'أرقام' : 'digits'}" : "${_selectedCountry.minDigits}-${_selectedCountry.maxDigits}"})',
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_selectedCountry.maxDigits),
          ],
          validator: (val) => _validatePhone(val, isArabic),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: _selectedCountry.example,
            filled: true,
            counterText: '',
            prefixIcon: InkWell(
              onTap: () => _showCountryPicker(context),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(left: 8, right: 4),
                decoration: BoxDecoration(
                  border: Border(
                    left: isArabic ? BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0), width: 1) : BorderSide.none,
                    right: !isArabic ? BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0), width: 1) : BorderSide.none,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCountry.dialCode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
