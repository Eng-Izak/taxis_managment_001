import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormatter = NumberFormat('#,##0', 'ar_EG');
  static final NumberFormat _enCurrencyFormatter = NumberFormat('#,##0', 'en_US');
  static final DateFormat _dateFormatter = DateFormat('yyyy/MM/dd', 'ar');
  static final DateFormat _shortDateFormatter = DateFormat('dd MMM', 'ar');

  static String formatCurrency(double amount, {bool isArabic = true, String suffix = 'ج.م'}) {
    final formatted = isArabic
        ? _currencyFormatter.format(amount)
        : _enCurrencyFormatter.format(amount);
    return '$formatted $suffix';
  }

  static String formatNumber(num number, {bool isArabic = true}) {
    return isArabic ? _currencyFormatter.format(number) : _enCurrencyFormatter.format(number);
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormatter.format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '-';
    return _shortDateFormatter.format(date);
  }

  static String formatPercentage(double percentage) {
    if (percentage == percentage.roundToDouble()) {
      return '${percentage.toInt()}%';
    }
    return '${percentage.toStringAsFixed(1)}%';
  }
}
