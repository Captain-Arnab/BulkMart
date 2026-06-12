import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final rubik = GoogleFonts.rubikTextTheme();

    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      hintColor: AppColors.hint,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.rubik(fontSize: 14, color: AppColors.hint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100,
        thickness: 1,
      ),
      textTheme: rubik.copyWith(
        titleLarge: GoogleFonts.rubik(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        titleMedium: GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.rubik(
          fontSize: 12,
          color: AppColors.hint,
        ),
      ),
    );
  }
}
