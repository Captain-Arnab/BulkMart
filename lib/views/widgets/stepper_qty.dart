import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Quantity stepper that cannot go below [min] (MOQ).
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundBtn(
          icon: Icons.remove,
          enabled: canDecrement,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: AppTextStyles.mono(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        _RoundBtn(
          icon: Icons.add,
          enabled: canIncrement,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.ink : AppColors.paper2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: enabled ? AppColors.white : AppColors.slate,
          ),
        ),
      ),
    );
  }
}
