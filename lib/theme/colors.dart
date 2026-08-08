import 'package:flutter/material.dart';

/// VeggiiCart brand tokens — sampled from the official logo greens + charcoal.
class AppColors {
  AppColors._();

  /// Primary Green — buttons, active states, brand mark (logo leaf)
  static const Color green = Color(0xFF12833B);

  /// Slightly brighter leaf highlight for gradients / hover
  static const Color greenLight = Color(0xFF1A9A48);

  /// Soft green tint — selected rows, auth backgrounds, chips
  static const Color greenSoft = Color(0xFFE8F7EF);

  /// Deep Forest — headers, emphasis, pressed states
  static const Color forest = Color(0xFF0B5C27);

  /// Success / Add to Cart / in-stock (aligned with primary)
  static const Color success = Color(0xFF12833B);

  /// Warm amber — MOQ badges / offers only (sparingly)
  static const Color accent = Color(0xFFF5A623);

  static const Color white = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color section = Color(0xFFF4FAF6);

  /// Ink / charcoal — primary body text (logo cart mark tone)
  static const Color ink = Color(0xFF1E1F22);

  /// Muted / secondary text
  static const Color muted = Color(0xFF6B7268);

  /// Error / urgent
  static const Color alert = Color(0xFFD64545);

  static const Color line = Color(0xFFE2EEE6);

  // --- Compatibility aliases (screens still reference these names) ---
  /// Maps to Primary Green — former violet CTAs / chips / links.
  static const Color violet = green;

  static const Color forestDark = forest;
  static const Color paper = section;
  static const Color paper2 = section;
  static const Color mustard = accent;
  static const Color rust = alert;
  static const Color slate = muted;
}
