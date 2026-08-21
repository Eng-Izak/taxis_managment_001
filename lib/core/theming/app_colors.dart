import 'package:flutter/material.dart';

/// Centralized Color System adhering to the Warm Terracotta & Earthy Tones specification.
class AppColors {
  AppColors._();

  // Core Palette Definitions
  static const Color terracotta = Color(0xFFC86644); // Terracotta Clay (#C86644)
  static const Color warmApricot = Color(0xFFE5A164); // Warm Apricot (#E5A164)
  static const Color warmSand = Color(0xFFE5DFD3); // Warm Sand / Off-White (#E5DFD3)
  static const Color darkCharcoal = Color(0xFF3A342B); // Dark Charcoal Brown (#3A342B)

  // Primary & Brand Colors
  static const Color primary = Color(0xFFC86644); // Terracotta Clay
  static const Color primaryLight = Color(0xFFE5A164); // Warm Apricot
  static const Color primaryDark = Color(0xFFA24A2D);
  static const Color primaryContainer = Color(0xFFFBECE6);
  static const Color primaryContainerDark = Color(0xFF422115);

  // Secondary Colors
  static const Color secondary = Color(0xFFE5A164); // Warm Apricot
  static const Color secondaryDark = Color(0xFFC86644); // Terracotta Clay
  static const Color secondaryLight = Color(0xFFF3D2B5);

  // Semantic Colors (Success, Error, Warning, Info)
  // Sage Green (Success): #4E8752 (Light) / #6DB872 (Dark)
  static const Color success = Color(0xFF4E8752);
  static const Color successDark = Color(0xFF6DB872);
  static const Color successContainer = Color(0xFFEBF4EC);
  static const Color successContainerDark = Color(0xFF1E3A20);

  // Rust / Soft Coral (Error): #BD3A2B (Light) / #E57368 (Dark)
  static const Color error = Color(0xFFBD3A2B);
  static const Color errorDark = Color(0xFFE57368);
  static const Color errorContainer = Color(0xFFFCEBE9);
  static const Color errorContainerDark = Color(0xFF4A1A15);

  // Financial Yield / Indicator Aliases
  static const Color yieldPositive = Color(0xFF4E8752);
  static const Color yieldPositiveDark = Color(0xFF6DB872);
  static const Color yieldPositiveLight = Color(0xFFEBF4EC);
  static const Color yieldPositiveContainerDark = Color(0xFF1E3A20);

  static const Color yieldNegative = Color(0xFFBD3A2B);
  static const Color yieldNegativeDark = Color(0xFFE57368);
  static const Color yieldNegativeLight = Color(0xFFFCEBE9);
  static const Color yieldNegativeContainerDark = Color(0xFF4A1A15);

  // Warning & Info
  static const Color warning = Color(0xFFD97706);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningContainerDark = Color(0xFF78350F);

  static const Color info = Color(0xFF2563EB);
  static const Color infoDark = Color(0xFF60A5FA);
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color infoContainerDark = Color(0xFF1E3A8A);

  static const Color gold = Color(0xFFD97706);
  static const Color goldDark = Color(0xFFFBBF24);
  static const Color goldLight = Color(0xFFFEF3C7);

  // Light Theme Palette (Warm Sand & Off-White)
  static const Color lightBackground = Color(0xFFF7F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE5DFD3);
  static const Color lightTextPrimary = Color(0xFF3A342B); // Dark Charcoal Brown
  static const Color lightTextSecondary = Color(0xFF7A7165); // Secondary / Muted
  static const Color lightTextTertiary = Color(0xFFA39A8E);

  // Dark Theme Palette (Earthy Dark Charcoal)
  static const Color darkBackground = Color(0xFF1E1B17); // Deep Earthy Charcoal (Avoiding pure black)
  static const Color darkSurface = Color(0xFF2D2822); // Warm Dark Surface
  static const Color darkCard = Color(0xFF2D2822);
  static const Color darkCardBorder = Color(0xFF3E372E);
  static const Color darkCardElevated = Color(0xFF352F28);
  static const Color darkTextPrimary = Color(0xFFF5EFE6); // Off-white / Cream Text
  static const Color darkTextSecondary = Color(0xFFA89F91); // Muted Earthy Secondary Text
  static const Color darkTextTertiary = Color(0xFF7A7165);

  // Asset Model Colors
  static const Color fullTaxiColor = Color(0xFFC86644);
  static const Color plateOnlyColor = Color(0xFFE5A164);
  static const Color vehicleOnlyColor = Color(0xFF7A7165);
}
