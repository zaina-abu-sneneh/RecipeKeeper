import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_keeper/theme/colors.dart';

final ThemeData myTheme = ThemeData(
  useMaterial3: true,
  // defines the color roles
  colorScheme: ColorScheme.light(
    primary: AppColors.tealAccent, // Main interactive color
    onPrimary: AppColors.pureWhite,
    secondary: AppColors.mediumGray, // Secondary interactive color
    onSecondary: AppColors.pureWhite,
    error: AppColors.rubyRed, // Error color
    onError: AppColors.pureWhite,
    background: AppColors.pureWhite, // Background for the Scaffold
    onBackground: AppColors.charcoalGray,
    surface: AppColors.pureWhite, // Surface for Cards, Dialogs, etc.
    onSurface: AppColors.charcoalGray, // Text on surfaces
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.pureWhite,

  textTheme: TextTheme(
    // DISPLAY STYLES (Largest, boldest text)
    displayLarge: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 57,
      fontWeight: FontWeight.w800,
    ),
    displayMedium: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 45,
      fontWeight: FontWeight.w800,
    ),
    displaySmall: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 36,
      fontWeight: FontWeight.w700,
    ),

    // HEADLINE STYLES (Primary Screen Titles)
    headlineLarge: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),

    // TITLE STYLES (Subtitles and Prominent Text)
    titleLarge: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),

    // BODY STYLES (Regular Text)
    bodyLarge: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.poppins(
      color: AppColors.charcoalGray,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),

    // LABEL STYLES (Buttons, Input Labels, Muted Text)
    labelLarge: GoogleFonts.poppins(
      color: AppColors.mediumGray,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.poppins(
      color: AppColors.mediumGray,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.poppins(
      color: AppColors.mediumGray,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: AppColors.pureWhite,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),

      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      minimumSize: Size(double.infinity, 52),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightGray.withOpacity(0.5),
    labelStyle: GoogleFonts.poppins(
      color: AppColors.mediumGray,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    // meaning of ? that if the bodyMedium theme not null do the copy of it and make some change
    // ! force the flutter that the value it is not null
    hintStyle: GoogleFonts.poppins(
      color: AppColors.mediumGray.withOpacity(0.7),
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),

    // space inside between border and the content
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),

    // Enabled Border (Identical to default)
    // there is no need to this because if it not decalred the default will be taken from the border
    // enabledBorder: OutlineInputBorder(
    //   borderRadius: BorderRadius.circular(12),
    //   borderSide: const BorderSide(
    //     color: AppColors.mediumGray,
    //     width: 1.0,
    //   ),
    // ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.tealAccent, width: 2.0),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.rubyRed, width: 2.0),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.rubyRed, width: 2.0),
    ),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
    foregroundColor: AppColors.charcoalGray,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.charcoalGray,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryTeal,
    foregroundColor: AppColors.pureWhite,
    elevation: 4,
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.pureWhite,
    selectedItemColor: AppColors.primaryTeal,
    unselectedItemColor: AppColors.mediumGray,

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
    elevation: 2.0, // Subtle shadow for depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // Rounded corners
    ),
    color: AppColors.pureWhite,
  ),
);
