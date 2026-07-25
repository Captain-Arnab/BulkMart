import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
      primary: AppColors.forest,
      onPrimary: AppColors.white,
      secondary: AppColors.mustard,
      onSecondary: AppColors.ink,
      error: AppColors.rust,
      surface: AppColors.white,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.paper,
      canvasColor: AppColors.white,
      dividerColor: AppColors.line,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display(fontSize: 32),
        displayMedium: AppTextStyles.display(fontSize: 26),
        displaySmall: AppTextStyles.display(fontSize: 22),
        headlineMedium: AppTextStyles.display(fontSize: 20),
        headlineSmall: AppTextStyles.display(fontSize: 18),
        titleLarge: AppTextStyles.display(fontSize: 17),
        titleMedium: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall: AppTextStyles.body(fontSize: 13, fontWeight: FontWeight.w600),
        bodyLarge: AppTextStyles.body(fontSize: 15),
        bodyMedium: AppTextStyles.body(fontSize: 14),
        bodySmall: AppTextStyles.body(fontSize: 12, color: AppColors.slate),
        labelLarge: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: AppTextStyles.label(),
        labelSmall: AppTextStyles.mono(fontSize: 10, color: AppColors.slate),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.display(fontSize: 18, color: AppColors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.forest, width: 1.5),
        ),
        labelStyle: AppTextStyles.label(),
        hintStyle: AppTextStyles.body(fontSize: 13, color: AppColors.slate),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paper2,
        selectedColor: AppColors.forest,
        labelStyle: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w600),
        secondaryLabelStyle: AppTextStyles.body(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.forest,
        unselectedItemColor: AppColors.slate,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.mono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.forest,
        ),
        unselectedLabelStyle: AppTextStyles.mono(fontSize: 10, color: AppColors.slate),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}
