import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Chunky geometric display — Plus Jakarta Sans
  static TextStyle display({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.ink,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Prices / quantities — bold Inter (not monospace)
  static TextStyle price({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.ink,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// @deprecated Use [price] — kept so call sites compile during redesign.
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return price(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
  }

  static TextStyle label({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.muted,
    double letterSpacing = 0.2,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
