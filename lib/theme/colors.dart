import 'package:flutter/material.dart';

/// BulkMart quick-commerce design tokens (Blinkit/Zepto-inspired language).
class AppColors {
  AppColors._();

  /// Electric Violet — brand, active states, CTAs (primary)
  static const Color violet = Color(0xFF7B2FF7);

  /// Success / Add to Cart / in-stock
  static const Color success = Color(0xFF0FA968);

  /// Accent yellow — MOQ badges, highlights
  static const Color accent = Color(0xFFFFC93C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color section = Color(0xFFF7F7FA);

  static const Color ink = Color(0xFF1A1A2E);
  static const Color muted = Color(0xFF6B6F7B);
  static const Color alert = Color(0xFFFF3B30);
  static const Color line = Color(0xFFECECF2);

  // --- Compatibility aliases (map old ledger tokens → new system) ---
  static const Color forest = violet;
  static const Color forestDark = ink;
  static const Color paper = section;
  static const Color paper2 = section;
  static const Color mustard = accent;
  static const Color rust = alert;
  static const Color slate = muted;
}
