import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../../widgets/moq_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/stepper_qty.dart';
import '../../widgets/ui_states.dart';

/// Lightweight detail screen so catalog cards are tappable in the demo.
/// Full sticky-bar polish can deepen when product API is wired.
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
    final result = await context.read<ProductRepository>().fetchProduct(widget.productId);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.forest)),
      );
    }
    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: ErrorState(message: _error ?? 'Not found', onRetry: _load),
      );
    }

    final product = _product!;
    final total = product.wholesalePrice * _qty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppColors.paper2,
                  foregroundColor: AppColors.ink,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFEADFC4), AppColors.paper2],
                            ),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 72,
                            color: Color(0x402F6D4F),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: MoqBadge(
                            title: product.inStock ? 'IN' : 'OUT',
                            label: 'STOCK',
                            size: 56,
                            fontSize: 9,
                            color: product.inStock ? AppColors.forest : AppColors.rust,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: AppTextStyles.display(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          '${product.category} · Sold in ${product.unitSize}s',
                          style: AppTextStyles.body(fontSize: 12, color: AppColors.slate),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _priceFormat.format(product.wholesalePrice),
                              style: AppTextStyles.mono(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'per ${product.unitLabel} · wholesale rate',
                              style: AppTextStyles.body(fontSize: 11, color: AppColors.slate),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(12),
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Minimum order: ${product.moq} ${product.unitLabel}s',
                                      style: AppTextStyles.body(
                                        fontSize: 10,
                                        color: AppColors.slate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StepperQty(
                                value: _qty,
                                min: product.moq,
                                max: product.stockCount,
                                onChanged: (v) => setState(() => _qty = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.forest,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Live stock: ${product.stockCount} ${product.unitLabel}s available',
                              style: AppTextStyles.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.forestDark,
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
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL', style: AppTextStyles.label(fontSize: 10)),
                        Text(
                          _priceFormat.format(total),
                          style: AppTextStyles.mono(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: PrimaryButton(
                      label: 'Add to Cart',
                      expand: true,
                      backgroundColor: AppColors.rust,
                      onPressed: () {
                        context.read<CartViewModel>().addProduct(product, quantity: _qty);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $_qty × ${product.name} to cart'),
                            backgroundColor: AppColors.forest,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
