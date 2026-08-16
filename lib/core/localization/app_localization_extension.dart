import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../utils/formatters.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  String formatNumber(num number) => AppFormatters.formatNumber(number, isArabic: isArabic);
  String formatCurrency(double amount, {String? suffix}) => AppFormatters.formatCurrency(amount, isArabic: isArabic, suffix: suffix ?? l10n.egp);
  String formatPercentage(double percentage) => AppFormatters.formatPercentage(percentage, isArabic: isArabic);
  String digits(dynamic input) => AppFormatters.convertDigits(input, isArabic: isArabic);
  String formatDate(DateTime? date) => AppFormatters.formatDate(date, isArabic: isArabic);
  String formatShortDate(DateTime? date) => AppFormatters.formatShortDate(date, isArabic: isArabic);
}
