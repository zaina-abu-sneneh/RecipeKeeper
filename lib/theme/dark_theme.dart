import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_keeper/theme/colors.dart';

final ThemeData myDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: ColorScheme.dark(
    primary: AppColors.tealAccent,
    onPrimary: AppColors.pureWhite,
    secondary: AppColors.mediumGray,
    onSecondary: AppColors.pureWhite,
    error: AppColors.rubyRed,
    onError: AppColors.pureWhite,
    background: AppColors.backgroundDark,
    onBackground: AppColors.textPrimaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,

  // --- TEXT THEME ---
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 57,
      fontWeight: FontWeight.w800,
    ),
    displayMedium: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 45,
      fontWeight: FontWeight.w800,
    ),
    displaySmall: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 36,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.poppins(
      color: AppColors.textPrimaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: GoogleFonts.poppins(
      color: AppColors.textSecondaryDark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.poppins(
      color: AppColors.textSecondaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.poppins(
      color: AppColors.textSecondaryDark,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  ),

  // --- BUTTON THEMES ---
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      minimumSize: const Size(double.infinity, 52),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryTeal,
    foregroundColor: AppColors.pureWhite,
    elevation: 4,
  ),

  // --- INPUT DECORATION (FORMS) ---
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark, // Using surface color for inputs
    labelStyle: GoogleFonts.poppins(
      color: AppColors.textSecondaryDark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: GoogleFonts.poppins(
      color: AppColors.textSecondaryDark.withOpacity(0.5),
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.tealAccent, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.rubyRed, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.rubyRed, width: 2.0),
    ),
  ),

  // --- NAVIGATION & BAR THEMES ---
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.tealAccent,
    unselectedItemColor: AppColors.textSecondaryDark,
    selectedLabelStyle: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
    elevation: 8,
    showUnselectedLabels: true,
  ),

  cardTheme: CardThemeData(
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    color: AppColors.surfaceDark,
  ),
);
