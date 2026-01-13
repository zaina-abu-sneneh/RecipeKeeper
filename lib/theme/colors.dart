import 'package:flutter/material.dart';

class AppColors {
  // --- ACCENTS (10%) ---
  // These stay consistent in both themes
  static const Color primaryTeal = Color(0xFF43927D);
  static const Color tealAccent = Color(0xFF00897B);
  static const Color rubyRed = Color(0xFFD32F2F);

  // --- LIGHT MODE (60% / 30%) ---
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color charcoalGray = Color(0xFF454545);
  static const Color mediumGray = Color(0xFF707070);
  static const Color lightGray = Color(0xFFE5E5E5);

  // --- DARK MODE (60% / 30%) ---
  static const Color backgroundDark = Color(0xFF121212); // Deep background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Card/Surface background
  static const Color textPrimaryDark = Color(0xFFE1E1E1); // Bright gray text
  static const Color textSecondaryDark = Color(0xFFAAAAAA); // Muted gray text
  static const Color inputFillDark = Color(
    0xFF2C2C2C,
  ); // Darker input background
}
