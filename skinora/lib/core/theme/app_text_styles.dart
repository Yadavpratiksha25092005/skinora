import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized text styles for Skinora
/// Font: Poppins (clean, modern, rounded — fits premium wellness aesthetic)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ---------- Display / Headings ----------
  static TextStyle h1 = _base(size: 32, weight: FontWeight.w700, height: 1.2);
  static TextStyle h2 = _base(size: 26, weight: FontWeight.w700, height: 1.25);
  static TextStyle h3 = _base(size: 22, weight: FontWeight.w600, height: 1.3);
  static TextStyle h4 = _base(size: 18, weight: FontWeight.w600, height: 1.3);

  // ---------- Body ----------
  static TextStyle bodyLarge = _base(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodyMedium = _base(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodySmall = _base(size: 12, weight: FontWeight.w400, height: 1.4);

  // ---------- Labels / Buttons ----------
  static TextStyle buttonLarge = _base(
    size: 16,
    weight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  static TextStyle buttonMedium = _base(
    size: 14,
    weight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle label = _base(size: 13, weight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle caption = _base(size: 11, weight: FontWeight.w400, color: AppColors.textMuted);

  // ---------- Special ----------
  static TextStyle logo = _base(
    size: 30,
    weight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static TextStyle statNumber = _base(size: 24, weight: FontWeight.w700, color: AppColors.primary);
  static TextStyle link = _base(size: 14, weight: FontWeight.w600, color: AppColors.primary);
}
