import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: foregroundColor ?? AppColors.white,
            ),
          )
        : Text(
            label,
            style: AppTextStyles.body(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: foregroundColor ?? AppColors.white,
            ),
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.forest,
        foregroundColor: foregroundColor ?? AppColors.white,
        disabledBackgroundColor: (backgroundColor ?? AppColors.forest).withValues(alpha: 0.5),
        minimumSize: Size(expand ? double.infinity : 0, 50),
        elevation: 0,
        shadowColor: AppColors.forest.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: child,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: onPressed == null || isLoading
            ? null
            : [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.forest).withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: button,
    );
  }
}
