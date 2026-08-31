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
import '../../viewmodels/wishlist_view_model.dart';
import 'product_network_image.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onQuickAdd,
    /// Must be unique within the current route (IndexedStack tabs share one route).
    /// Pass the same value into [ProductDetailScreen.heroTag] when opening detail.
    this.heroTag,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;
  final String? heroTag;

  /// Scoped hero tag so the same product can appear on Home + Wishlist + Browse
  /// without colliding under [IndexedStack].
  static String heroTagFor(
    String scope,
    String productId, [
    Object? disambiguator,
  ]) {
    final suffix = disambiguator == null ? '' : '-$disambiguator';
    return 'product-image-$scope-$productId$suffix';
  }

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _lifted = false;
  late final String _heroTag;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Unique per State instance when caller omits [heroTag] — avoids IndexedStack
    // collisions; detail flight only runs when caller passes a shared tag.
    _heroTag = widget.heroTag ??
        ProductCard.heroTagFor(
          'card',
          widget.product.id,
          identityHashCode(this),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild only when this product's qty changes — not on every cart edit.
    final qty = context.select<CartViewModel, int>(
      (c) => c.quantityOf(widget.product.id),
    );
    final cart = context.read<CartViewModel>();
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line),
            boxShadow: _lifted ? AppShadows.floating : AppShadows.card,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image fills remaining height; text block stays compact.
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: Hero(
                          tag: _heroTag,
                          child: Material(
                            type: MaterialType.transparency,
                            child: ProductNetworkImage(product: widget.product),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            'MOQ ${widget.product.moq} ${widget.product.unitNoun}',
                            style: AppTextStyles.body(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Consumer<WishlistViewModel>(
                          builder: (context, wishlist, _) {
                            final saved = wishlist.contains(widget.product.id);
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  wishlist.toggle(widget.product.id);
                                },
                                customBorder: const CircleBorder(),
                                child: Ink(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.92),
                                    shape: BoxShape.circle,
                                    boxShadow: AppShadows.soft(opacity: 0.08),
                                  ),
                                  child: Icon(
                                    saved
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 17,
                                    color: saved ? AppColors.alert : AppColors.muted,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.product.price == null
                            ? 'Price TBA'
                            : _priceFormat.format(widget.product.price),
                        style: AppTextStyles.price(
                          fontSize: 14,
                          color: AppColors.green,
                        ),
                      ),
                      Text(
                        widget.product.unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.button(color: AppColors.success),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
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
      height: 32,
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
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedSwitcher(
              duration: AppMotion.press,
              child: Text(
                '$qty',
                key: ValueKey(qty),
                style: AppTextStyles.price(fontSize: 12, color: AppColors.white),
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
        width: 28,
        height: 32,
        child: Icon(icon, color: AppColors.white, size: 16),
      ),
    );
  }
}
