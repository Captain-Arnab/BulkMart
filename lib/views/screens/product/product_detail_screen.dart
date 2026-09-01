import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../../../viewmodels/wishlist_view_model.dart';
import '../../widgets/moq_badge.dart';
import '../../widgets/product_network_image.dart';
import '../../widgets/stepper_qty.dart';
import '../../widgets/ui_states.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    /// Must match the source [ProductCard.heroTag] for a shared-element flight.
    this.heroTag,
  });

  final String productId;
  final String? heroTag;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

enum _InfoTab { description, benefits, storageTips }

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _loading = true;
  String? _error;
  Product? _product;
  int _qty = 1;
  bool _ctaPulse = false;
  _InfoTab _infoTab = _InfoTab.description;
  final _ctaKey = GlobalKey();

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await context.read<ProductRepository>().getProductById(widget.productId);
    if (!mounted) return;
    result.when(
      success: (p) {
        setState(() {
          _product = p;
          _qty = p.moq;
          _loading = false;
        });
      },
      failure: (message, {statusCode, code, fields}) {
        setState(() {
          _error = message;
          _loading = false;
        });
      },
    );
  }

  void _setQty(int v) {
    setState(() {
      _qty = v;
      _ctaPulse = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _ctaPulse = false);
    });
  }

  Future<void> _addToCart(Product product) async {
    HapticFeedback.lightImpact();
    context.read<CartViewModel>().addProduct(product, quantity: _qty);

    final box = _ctaKey.currentContext?.findRenderObject() as RenderBox?;
    final from = box?.localToGlobal(box.size.center(Offset.zero)) ??
        Offset(MediaQuery.sizeOf(context).width / 2, MediaQuery.sizeOf(context).height - 80);

    await playFlyToCart(
      context: context,
      from: from,
      shell: context.read<ShellController>(),
      color: AppColors.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.section,
        body: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.violet),
          ),
        ),
      );
    }
    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: ErrorState(message: _error ?? 'Not found', onRetry: _load),
      );
    }

    final product = _product!;
    final total = product.displayPrice * _qty;

    return Scaffold(
      backgroundColor: AppColors.section,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 8),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            boxShadow: AppShadows.card,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.heroTag == null
                              ? ProductNetworkImage(product: product, iconSize: 64)
                              : Hero(
                                  tag: widget.heroTag!,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: ProductNetworkImage(
                                      product: product,
                                      iconSize: 64,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 16,
                        left: 24,
                        child: PressableScale(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.soft(opacity: 0.12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, size: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 16,
                        right: 24,
                        child: Consumer<WishlistViewModel>(
                          builder: (context, wishlist, _) {
                            final saved = wishlist.contains(product.id);
                            return PressableScale(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                wishlist.toggle(product.id);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: AppShadows.soft(opacity: 0.12),
                                ),
                                child: Icon(
                                  saved
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 20,
                                  color: saved ? AppColors.alert : AppColors.ink,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 28,
                        child: MoqBadge(
                          label: '${product.moq} ${product.unitNoun}',
                          color: AppColors.accent,
                          size: 52,
                          fontSize: 9,
                        ),
                      ),
                      if (product.inStock)
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 64,
                          right: 28,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(
                              'IN STOCK',
                              style: AppTextStyles.body(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: AppTextStyles.display(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(
                          '${product.category} · ${product.unit}',
                          style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.price == null
                              ? 'Price TBA'
                              : _priceFormat.format(product.price),
                          style: AppTextStyles.price(fontSize: 28, color: AppColors.violet),
                        ),
                        Text(
                          product.unit,
                          style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity',
                                      style: AppTextStyles.body(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Min ${product.moq} ${product.unitNoun}',
                                      style: AppTextStyles.body(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StepperQty(
                                value: _qty,
                                min: product.moq,
                                max: product.stockCount > 0 ? product.stockCount : 999,
                                onChanged: _setQty,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.stock == null
                                  ? 'Stock available'
                                  : '${product.stock} ${product.unitNoun} available',
                              style: AppTextStyles.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _ProductInfoSection(
                          product: product,
                          selected: _infoTab,
                          onChanged: (tab) => setState(() => _infoTab = tab),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: AppShadows.soft(opacity: 0.06),
            ),
            child: SafeArea(
              top: false,
              child: AnimatedScale(
                key: _ctaKey,
                scale: _ctaPulse ? 1.04 : 1,
                duration: AppMotion.fast,
                curve: AppMotion.pop,
                child: PressableScale(
                  onTap: () => _addToCart(product),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      boxShadow: AppShadows.button(color: AppColors.success),
                    ),
                    child: AnimatedSwitcher(
                      duration: AppMotion.fast,
                      child: Text(
                        'Add to Cart — ${_priceFormat.format(total)}',
                        key: ValueKey(total),
                        style: AppTextStyles.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Description / Benefits / Storage Tips — segmented tabs matching login method chips.
class _ProductInfoSection extends StatelessWidget {
  const _ProductInfoSection({
    required this.product,
    required this.selected,
    required this.onChanged,
  });

  final Product product;
  final _InfoTab selected;
  final ValueChanged<_InfoTab> onChanged;

  static const _emptyPlaceholder = 'Details coming soon';

  String? _rawFor(_InfoTab tab) {
    switch (tab) {
      case _InfoTab.description:
        return product.description;
      case _InfoTab.benefits:
        return product.benefits;
      case _InfoTab.storageTips:
        return product.storageTips;
    }
  }

  String _bodyFor(_InfoTab tab) {
    final raw = _rawFor(tab)?.trim();
    if (raw == null || raw.isEmpty) return _emptyPlaceholder;
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final body = _bodyFor(selected);
    final isEmpty = body == _emptyPlaceholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Info',
          style: AppTextStyles.body(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: _InfoTabChip(
                  label: 'Description',
                  selected: selected == _InfoTab.description,
                  onTap: () => onChanged(_InfoTab.description),
                ),
              ),
              Expanded(
                child: _InfoTabChip(
                  label: 'Benefits',
                  selected: selected == _InfoTab.benefits,
                  onTap: () => onChanged(_InfoTab.benefits),
                ),
              ),
              Expanded(
                child: _InfoTabChip(
                  label: 'Storage Tips',
                  selected: selected == _InfoTab.storageTips,
                  onTap: () => onChanged(_InfoTab.storageTips),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: AppMotion.fast,
          switchInCurve: AppMotion.ease,
          switchOutCurve: AppMotion.ease,
          child: Container(
            key: ValueKey(selected),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              body,
              style: AppTextStyles.body(
                fontSize: 13,
                fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w400,
                color: isEmpty ? AppColors.muted.withValues(alpha: 0.85) : AppColors.muted,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTabChip extends StatelessWidget {
  const _InfoTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: selected
              ? AppShadows.soft(color: AppColors.green, opacity: 0.22)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
