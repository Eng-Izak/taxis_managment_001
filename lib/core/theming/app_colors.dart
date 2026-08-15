import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Stitch Primary & Brand Colors
  static const Color primary = Color(0xFF0F56B3); // Stitch deep blue
  static const Color primaryDark = Color(0xFF0C4187);
  static const Color primaryLight = Color(0xFF1A73E8);
  static const Color primaryContainer = Color(0xFFE8F0FE);
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryDark = Color(0xFF475569);
  static const Color secondaryLight = Color(0xFF94A3B8);

  // Stitch Financial Indicators & Yields
  static const Color yieldPositive = Color(0xFF137333); // Emerald green for active & profits
  static const Color yieldPositiveLight = Color(0xFFE6F4EA);
  static const Color yieldNegative = Color(0xFFC5221F); // Red for overdue & expenses
  static const Color yieldNegativeLight = Color(0xFFFCE8E6);
  static const Color warning = Color(0xFFE37400); // Amber/orange for maintenance & renewals
  static const Color warningLight = Color(0xFFFEF7E0);
  static const Color info = Color(0xFF1A73E8);
  static const Color infoLight = Color(0xFFE8F0FE);
  static const Color gold = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFEF3C7);

  // Light Theme Palette (Stitch Preview Mockup)
  static const Color lightBackground = Color(0xFFF8F9FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFECEFF1);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Asset Model Colors
  static const Color fullTaxiColor = Color(0xFF1A73E8);
  static const Color plateOnlyColor = Color(0xFF6B7280);
  static const Color vehicleOnlyColor = Color(0xFF64748B);
}
