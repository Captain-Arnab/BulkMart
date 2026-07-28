import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.light,
      primary: AppColors.green,
      onPrimary: AppColors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.ink,
      error: AppColors.alert,
      surface: AppColors.white,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.section,
      canvasColor: AppColors.white,
      dividerColor: AppColors.line,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display(fontSize: 32),
        displayMedium: AppTextStyles.display(fontSize: 26),
        displaySmall: AppTextStyles.display(fontSize: 22),
        headlineMedium: AppTextStyles.display(fontSize: 20),
        headlineSmall: AppTextStyles.display(fontSize: 18),
        titleLarge: AppTextStyles.display(fontSize: 17, fontWeight: FontWeight.w700),
        titleMedium: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall: AppTextStyles.body(fontSize: 13, fontWeight: FontWeight.w600),
        bodyLarge: AppTextStyles.body(fontSize: 15),
        bodyMedium: AppTextStyles.body(fontSize: 14),
        bodySmall: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
        labelLarge: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: AppTextStyles.label(),
        labelSmall: AppTextStyles.label(fontSize: 10),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.display(fontSize: 18, color: AppColors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        labelStyle: AppTextStyles.label(),
        hintStyle: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}
