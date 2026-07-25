import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui/app_motion.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Pill-shaped violet-accent quantity stepper.
class StepperQty extends StatelessWidget {
  const StepperQty({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > min;
    final canIncrement = max == null || value < max!;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(value - 1);
            },
          ),
          SizedBox(
            width: 40,
            child: AnimatedSwitcher(
              duration: AppMotion.press,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: AppTextStyles.price(fontSize: 15, color: AppColors.violet),
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            enabled: canIncrement,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(value + 1);
            },
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 36,
        height: 40,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.violet : AppColors.muted.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
