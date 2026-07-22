import 'package:flutter/material.dart';

/// Skinora Color Palette
/// Theme: White + Soft Lavender/Purple, premium & minimal (Flo / MyFitnessPal inspired)
class AppColors {
  AppColors._();

  // ---------- Primary (Lavender / Purple) ----------
  static const Color primary = Color(0xFF8B5FBF); // core lavender-purple
  static const Color primaryDark = Color(0xFF6D3FA3);
  static const Color primaryLight = Color(0xFFB794E0);
  static const Color primarySoft = Color(0xFFF3E8FD); // very light lavender bg
  static const Color primaryLighter = Color(0xFFEDE3FA);

  // ---------- Secondary (Pink accent, used sparingly) ----------
  static const Color secondary = Color(0xFFF48FB1);
  static const Color secondarySoft = Color(0xFFFCE4EC);

  // ---------- Gradient ----------
  static const List<Color> primaryGradient = [
    Color(0xFF9D6FE0),
    Color(0xFFC084E8),
  ];

  static const List<Color> heroGradient = [
    Color(0xFFB794E0),
    Color(0xFFF48FB1),
  ];

  // ---------- Background / Surface ----------
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFAF8FD); // faint lavender-white
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF0EAFA);

  // ---------- Text ----------
  static const Color textPrimary = Color(0xFF2A2437);
  static const Color textSecondary = Color(0xFF6F6880);
  static const Color textMuted = Color(0xFFA39CB0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------- Status ----------
  static const Color success = Color(0xFF4CAF83);
  static const Color successSoft = Color(0xFFE3F6ED);
  static const Color warning = Color(0xFFF5A85B);
  static const Color warningSoft = Color(0xFFFDF1E4);
  static const Color error = Color(0xFFE86C6C);
  static const Color errorSoft = Color(0xFFFCEAEA);
  static const Color info = Color(0xFF5FA8E0);
  static const Color infoSoft = Color(0xFFE8F3FC);

  // ---------- Module Accent Colors (dashboard cards) ----------
  static const Color skinAccent = Color(0xFFB794E0); // skin routine
  static const Color hairAccent = Color(0xFFF4A9C0); // hair routine
  static const Color waterAccent = Color(0xFF6FC3E8); // water intake
  static const Color sleepAccent = Color(0xFF8E8FE0); // sleep tracking
  static const Color uvAccent = Color(0xFFF5B85B); // UV index
  static const Color streakAccent = Color(0xFFF48FB1); // daily streak

  // ---------- Misc ----------
  static const Color divider = Color(0xFFEFEBF5);
  static const Color shadow = Color(0x1A8B5FBF); // soft purple-tinted shadow
  static const Color overlay = Color(0x66000000);
  static const Color disabled = Color(0xFFD9D4E3);
}
