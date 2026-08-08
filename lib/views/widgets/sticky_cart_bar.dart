import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_motion.dart';
import '../../core/ui/pressable_scale.dart';
import '../../core/ui/shell_controller.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../viewmodels/cart_view_model.dart';

/// Floating sticky cart bar — spring slide-up when cart has items.
class StickyCartBar extends StatelessWidget {
  const StickyCartBar({super.key, this.bottomInset = 0});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final itemCount = context.select<CartViewModel, int>((c) => c.itemCount);
    final total = context.select<CartViewModel, double>((c) => c.total);
    final tabIndex = context.select<ShellController, int>((s) => s.tabIndex);
    final visible = itemCount > 0 && tabIndex != ShellController.cartTab;
    final shell = context.read<ShellController>();

    return AnimatedSlide(
      duration: const Duration(milliseconds: 420),
      curve: AppMotion.springy,
      offset: visible ? Offset.zero : const Offset(0, 1.4),
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
            child: PressableScale(
              onTap: shell.goToCart,
              child: Container(
                height: 58,
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  boxShadow: AppShadows.floating,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        '$itemCount item${itemCount == 1 ? '' : 's'}',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedCartTotal(
                        value: total,
                        style: AppTextStyles.price(fontSize: 16, color: AppColors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        'View Cart',
                        style: AppTextStyles.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedCartTotal extends StatefulWidget {
  const AnimatedCartTotal({
    super.key,
    required this.value,
    required this.style,
  });

  final double value;
  final TextStyle style;

  @override
  State<AnimatedCartTotal> createState() => _AnimatedCartTotalState();
}

class _AnimatedCartTotalState extends State<AnimatedCartTotal> {
  double _previous = 0;

  static final _format = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _previous = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedCartTotal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previous = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _previous, end: widget.value),
      duration: AppMotion.normal,
      curve: AppMotion.ease,
      builder: (_, v, __) => Text(_format.format(v), style: widget.style),
    );
  }
}
