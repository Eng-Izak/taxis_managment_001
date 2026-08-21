import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Complete Warm Earthy & Terracotta Theme Configuration for Light and Dark modes.
class AppTheme {
  AppTheme._();

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.terracotta,
      scaffoldBackgroundColor: AppColors.lightBackground, // #F7F5F0
      colorScheme: const ColorScheme.light(
        primary: AppColors.terracotta, // #C86644
        secondary: AppColors.warmApricot, // #E5A164
        surface: AppColors.lightSurface, // #FFFFFF
        error: AppColors.error, // #BD3A2B
        onPrimary: Colors.white, // #FFFFFF
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary, // #3A342B
        onError: Colors.white,
      ),
      textTheme: AppTypography.getTextTheme(isDark: false),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.terracotta, // #C86644
        foregroundColor: Colors.white, // #FFFFFF
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard, // #FFFFFF
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Border radius 12
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1), // Border outline #E5DFD3
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta, // #C86644
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 10-12px rounded corners
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1), // Subtle border #E5DFD3
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface, // #FFFFFF
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightCardBorder), // #E5DFD3
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightCardBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCharcoal,
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightCardBorder,
        thickness: 1,
        space: 24,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.warmApricot,
      scaffoldBackgroundColor: AppColors.darkBackground, // #1E1B17 (Avoiding pure black)
      colorScheme: const ColorScheme.dark(
        primary: AppColors.warmApricot, // #E5A164
        secondary: AppColors.terracotta, // #C86644
        surface: AppColors.darkSurface, // #2D2822
        error: AppColors.errorDark, // #E57368
        onPrimary: AppColors.darkBackground, // #1E1B17
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary, // #F5EFE6
        onError: AppColors.darkBackground,
      ),
      textTheme: AppTypography.getTextTheme(isDark: true),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface, // #2D2822
        foregroundColor: AppColors.darkTextPrimary, // #F5EFE6
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard, // #2D2822
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Border radius 12
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1), // Border outline #3E372E
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warmApricot, // #E5A164
          foregroundColor: AppColors.darkBackground, // #1E1B17
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 10-12px rounded corners
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warmApricot,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1), // Subtle border #3E372E
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface, // #2D2822
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkCardBorder), // #3E372E
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.warmApricot, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorDark),
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkCardBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.darkCardBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkCardBorder,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
