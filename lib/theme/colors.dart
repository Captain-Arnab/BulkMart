import 'package:flutter/material.dart';

/// BulkMart quick-commerce design tokens (fresh grocery green language).
class AppColors {
  AppColors._();

  /// Fresh Green — brand, active states, CTAs (primary)
  static const Color green = Color(0xFF0D9F58);

  /// Lighter green for gradients / hover highlights
  static const Color greenLight = Color(0xFF2BB673);

  /// Soft green tint — selected rows, auth backgrounds, chips
  static const Color greenSoft = Color(0xFFE8F7EF);

  /// Success / Add to Cart / in-stock (aligned with brand green)
  static const Color success = Color(0xFF0D9F58);

  /// Accent yellow — MOQ badges, highlights
  static const Color accent = Color(0xFFFFC93C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color section = Color(0xFFF4FAF6);

  static const Color ink = Color(0xFF12261A);
  static const Color muted = Color(0xFF5A6B62);
  static const Color alert = Color(0xFFFF3B30);
  static const Color line = Color(0xFFE2EEE6);

  // --- Compatibility aliases (map old tokens → new system) ---
  static const Color violet = green;
  static const Color forest = green;
  static const Color forestDark = ink;
  static const Color paper = section;
  static const Color paper2 = section;
  static const Color mustard = accent;
  static const Color rust = alert;
  static const Color slate = muted;
}
