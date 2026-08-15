class AppValidators {
  AppValidators._();

  static String? requiredField(String? value, {String message = 'هذا الحقل مطلوب'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validNumber(String? value, {String message = 'يرجى إدخال رقم صحيح'}) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return message;
    }
    return null;
  }

  static String? validPercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل النسبة';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0 || parsed > 100) {
      return 'النسبة بين 1 و 100';
    }
    return null;
  }

  static String? validPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل رقم الهاتف';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (clean.length < 10) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }
}
