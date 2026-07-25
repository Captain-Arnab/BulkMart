import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft({Color color = AppColors.ink, double opacity = 0.07}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.violet.withValues(alpha: 0.22),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> button({Color color = AppColors.violet}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.32),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppRadii {
  AppRadii._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 28;
}

class AppMotion {
  AppMotion._();
  static const Duration press = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration page = Duration(milliseconds: 220);
  static const Duration fly = Duration(milliseconds: 400);

  static const Curve ease = Curves.easeOutCubic;
  static const Curve pop = Curves.easeOutBack;
  static const Curve springy = Curves.elasticOut;
  static const Curve flyCurve = Curves.easeInOutCubic;
}
