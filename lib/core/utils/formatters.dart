import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static const List<String> _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  static const List<String> _englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  /// Converts any string or number to Eastern Arabic digits or Western English digits.
  static String convertDigits(dynamic input, {required bool isArabic}) {
    if (input == null) return '';
    String str = input.toString();
    if (isArabic) {
      for (int i = 0; i < 10; i++) {
        str = str.replaceAll(_englishDigits[i], _arabicDigits[i]);
      }
    } else {
      for (int i = 0; i < 10; i++) {
        str = str.replaceAll(_arabicDigits[i], _englishDigits[i]);
      }
    }
    return str;
  }

  /// Formats a number with comma separators (e.g. 1,500,000 in EN or ١,٥٠٠,٠٠٠ in AR).
  static String formatNumber(num number, {bool isArabic = true}) {
    final enFormatted = NumberFormat('#,##0', 'en_US').format(number);
    return isArabic ? convertDigits(enFormatted, isArabic: true) : enFormatted;
  }

  /// Formats currency with amount and currency suffix (e.g. 1,500 EGP or ١,٥٠٠ ج.م).
  static String formatCurrency(double amount, {bool isArabic = true, String? suffix}) {
    final formattedNumber = formatNumber(amount, isArabic: isArabic);
    final currencySuffix = suffix ?? (isArabic ? 'ج.م' : 'EGP');
    return '$formattedNumber $currencySuffix';
  }

  /// Formats percentage (e.g. 14.8% in EN or ١٤.٨% in AR).
  static String formatPercentage(double percentage, {bool isArabic = true}) {
    final valueStr = percentage == percentage.roundToDouble()
        ? '${percentage.toInt()}'
        : percentage.toStringAsFixed(1);
    final formatted = isArabic ? convertDigits(valueStr, isArabic: true) : valueStr;
    return '$formatted%';
  }

  /// Formats date (e.g. 2026/08/16 in EN or ٢٠٢٦/٠٨/١٦ in AR).
  static String formatDate(DateTime? date, {bool isArabic = true}) {
    if (date == null) return '-';
    final enDate = DateFormat('yyyy/MM/dd', 'en').format(date);
    return isArabic ? convertDigits(enDate, isArabic: true) : enDate;
  }

  /// Formats short date.
  static String formatShortDate(DateTime? date, {bool isArabic = true}) {
    if (date == null) return '-';
    final enDate = DateFormat('dd MMM', 'en').format(date);
    return isArabic ? convertDigits(enDate, isArabic: true) : enDate;
  }
}
