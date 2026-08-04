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
import '../../widgets/product_card.dart';
import '../../widgets/product_network_image.dart';
import '../../widgets/stepper_qty.dart';
import '../../widgets/ui_states.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _loading = true;
  String? _error;
  Product? _product;
  int _qty = 1;
  bool _ctaPulse = false;
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
      failure: (message, {statusCode}) {
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
                          child: Hero(
                            tag: ProductCard.heroTag(product.id),
                            child: Material(
                              type: MaterialType.transparency,
                              child: ProductNetworkImage(product: product, iconSize: 64),
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
                      if (product.inStock)
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 20,
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
                          '${product.unit} · wholesale',
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
