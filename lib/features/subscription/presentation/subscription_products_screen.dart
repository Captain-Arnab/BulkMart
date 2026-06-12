import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/checkout/checkout_screen.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/subscription/subscription_flow_controller.dart';
import 'package:urban_roots/features/subscription/subscription_product_utils.dart';

class SubscriptionProductsScreen extends StatefulWidget {
  const SubscriptionProductsScreen({super.key});

  @override
  State<SubscriptionProductsScreen> createState() =>
      _SubscriptionProductsScreenState();
}

class _SubscriptionProductsScreenState extends State<SubscriptionProductsScreen> {
  final _productsController = Get.put(ProductsController());
  final _flow = SubscriptionFlowController.findOrPut();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _addingProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final list = await _productsController.fetchAllProducts();
    if (!mounted) return;
    setState(() {
      _products = list;
      _isLoading = false;
    });
  }

  Map<String, dynamic> get _plan => _flow.selectedPlan.value ?? {};

  Future<void> _addSubscriptionProduct(Product product) async {
    final plan = _plan;
    if (plan.isEmpty) return;

    setState(() => _addingProductId = product.id);
    final cart = CartController.findOrPut();
    final startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final success = await cart.addProduct(
      product.id,
      quantity: 1,
      deliveryType: plan['subscription_type']?.toString(),
      weeklyDays: plan['weekly_days']?.toString(),
      subscriptionStartDate: startDate,
    );
    if (!mounted) return;
    setState(() => _addingProductId = null);

    if (success) {
      await SweetAlert.success(
        context,
        message: '${product.name} added for subscription',
      );
    } else {
      await SweetAlert.error(
        context,
        message: cart.errorMessage.value.isNotEmpty
            ? cart.errorMessage.value
            : 'Could not add product',
      );
    }
  }

  void _goToCheckout() {
    final cart = CartController.findOrPut();
    if (cart.items.isEmpty) {
      showApiSnackBar(context, 'Add at least one product first', isError: true);
      return;
    }
    final amount = cart.finalAmount.value > 0
        ? cart.finalAmount.value
        : cart.totalValue;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          amount: amount,
          isSubscriptionCheckout: true,
        ),
      ),
    );
  }

  void _exitSubscriptionMode() {
    _flow.clear();
    DashboardController.findOrPut().goToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final planName = _plan['name']?.toString() ?? 'Subscription';
    final rateLabel = subscriptionRateLabel(_plan);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
          'Subscription Products',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _exitSubscriptionMode,
            child: Text(
              'Exit',
              style: GoogleFonts.rubik(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose products below — prices show subscription rates ($rateLabel).',
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Text(
                          'No products available',
                          style: GoogleFonts.rubik(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final rate =
                              subscriptionRateForProduct(product, _plan);
                          final isAdding = _addingProductId == product.id;

                          return ModernListTile(
                            title: product.name,
                            subtitle:
                                '${product.grams} • ₹${rate.toStringAsFixed(0)} $rateLabel',
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: NetworkOrAssetImage(
                                url: product.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () =>
                                      openProductDetails(context, product),
                                ),
                                IconButton(
                                  icon: isAdding
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.add_shopping_cart_rounded,
                                          color: AppColors.primary,
                                        ),
                                  onPressed: isAdding
                                      ? null
                                      : () => _addSubscriptionProduct(product),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _goToCheckout,
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: Text(
          'Go to Checkout',
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
