import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/local_storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  final LocalStorageService _storageService;

  LocaleCubit(this._storageService) : super(_storageService.getLocale());

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';

  void toggleLocale() {
    final nextLocale = state.languageCode == 'ar'
        ? const Locale('en', 'US')
        : const Locale('ar', 'EG');
    setLocale(nextLocale);
  }

  void setLocale(Locale locale) {
    _storageService.setLocale(locale);
    emit(locale);
  }

  void setArabic() => setLocale(const Locale('ar', 'EG'));
  void setEnglish() => setLocale(const Locale('en', 'US'));
}
