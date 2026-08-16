import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final LocalStorageService _storageService;

  ThemeCubit(this._storageService) : super(_storageService.getThemeMode());

  bool get isDarkMode => state == ThemeMode.dark;

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(nextMode);
  }

  void setThemeMode(ThemeMode mode) {
    _storageService.setThemeMode(mode);
    emit(mode);
  }
}
