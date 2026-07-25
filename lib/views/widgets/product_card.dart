import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_motion.dart';
import '../../core/ui/pressable_scale.dart';
import '../../models/product.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../viewmodels/cart_view_model.dart';
import 'product_network_image.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onQuickAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  static String heroTag(String productId) => 'product-image-$productId';

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _lifted = false;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();
    final qty = cart.quantityOf(widget.product.id);
    final inCart = qty > 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _lifted = true),
      onTapCancel: () => setState(() => _lifted = false),
      onTapUp: (_) => setState(() => _lifted = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _lifted ? 1.02 : 1,
        duration: AppMotion.press,
        curve: AppMotion.ease,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line),
            boxShadow: _lifted ? AppShadows.floating : AppShadows.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 62,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: ProductCard.heroTag(widget.product.id),
                      child: Material(
                        type: MaterialType.transparency,
                        child: ProductNetworkImage(product: widget.product),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          boxShadow: AppShadows.soft(opacity: 0.12),
                        ),
                        child: Text(
                          'MOQ ${widget.product.moq} ${widget.product.unitLabel}s',
                          style: AppTextStyles.body(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _QuickAddControl(
                        qty: qty,
                        inCart: inCart,
                        onAdd: () {
                          HapticFeedback.lightImpact();
                          cart.quickAdd(widget.product);
                          widget.onQuickAdd?.call();
                        },
                        onIncrement: () {
                          HapticFeedback.lightImpact();
                          cart.quickAdd(widget.product);
                          widget.onQuickAdd?.call();
                        },
                        onDecrement: () {
                          HapticFeedback.lightImpact();
                          cart.quickDecrement(widget.product);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 38,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _priceFormat.format(widget.product.wholesalePrice),
                                style: AppTextStyles.price(
                                  fontSize: 15,
                                  color: AppColors.violet,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.product.unitSize,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddControl extends StatelessWidget {
  const _QuickAddControl({
    required this.qty,
    required this.inCart,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int qty;
  final bool inCart;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.fast,
      curve: AppMotion.pop,
      alignment: Alignment.centerRight,
      child: AnimatedSwitcher(
        duration: AppMotion.fast,
        switchInCurve: AppMotion.pop,
        switchOutCurve: AppMotion.ease,
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: inCart
            ? _StepperPill(
                key: const ValueKey('stepper'),
                qty: qty,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              )
            : PressableScale(
                key: const ValueKey('plus'),
                onTap: onAdd,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.button(color: AppColors.success),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                ),
              ),
      ),
    );
  }
}

class _StepperPill extends StatelessWidget {
  const _StepperPill({
    super.key,
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.button(color: AppColors.success),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepIcon(icon: Icons.remove_rounded, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedSwitcher(
              duration: AppMotion.press,
              child: Text(
                '$qty',
                key: ValueKey(qty),
                style: AppTextStyles.price(fontSize: 13, color: AppColors.white),
              ),
            ),
          ),
          _StepIcon(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 36,
        child: Icon(icon, color: AppColors.white, size: 18),
      ),
    );
  }
}
