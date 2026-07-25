import 'package:flutter/material.dart';

import '../../core/ui/app_motion.dart';
import '../../core/ui/pressable_scale.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

enum PrimaryButtonState { idle, loading, success }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.state = PrimaryButtonState.idle,
    this.backgroundColor,
    this.foregroundColor,
    this.expand = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PrimaryButtonState state;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.violet;
    final fg = foregroundColor ?? AppColors.white;
    final effective = isLoading ? PrimaryButtonState.loading : state;
    final busy = effective != PrimaryButtonState.idle;

    Widget content;
    switch (effective) {
      case PrimaryButtonState.loading:
        content = SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
        );
      case PrimaryButtonState.success:
        content = Icon(Icons.check_rounded, color: fg, size: 24);
      case PrimaryButtonState.idle:
        content = Text(
          label,
          style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w800, color: fg),
        );
    }

    return PressableScale(
      enabled: !busy && onPressed != null,
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.ease,
        width: expand ? double.infinity : null,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: busy ? bg.withValues(alpha: 0.85) : bg,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: busy ? null : AppShadows.button(color: bg),
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          child: KeyedSubtree(key: ValueKey(effective), child: content),
        ),
      ),
    );
  }
}
