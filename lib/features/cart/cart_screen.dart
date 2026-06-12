import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/cart/cart_summary_footer.dart';
import 'package:urban_roots/features/checkout/checkout_summary.dart';
import 'package:urban_roots/features/checkout/checkout_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cart = CartController.findOrPut();

  @override
  void initState() {
    super.initState();
    _cart.loadCart();
  }

  Future<void> _changeQuantity(String cartItemId, int quantity) async {
    final ok = await _cart.updateQuantity(cartItemId, quantity);
    if (!ok && mounted) {
      await SweetAlert.error(
        context,
        message: _cart.errorMessage.value.isNotEmpty
            ? _cart.errorMessage.value
            : 'Could not update quantity',
      );
    }
  }

  Future<void> _removeItem(String cartItemId) async {
    final ok = await _cart.removeItem(cartItemId);
    if (!ok && mounted) {
      await SweetAlert.error(
        context,
        message: _cart.errorMessage.value.isNotEmpty
            ? _cart.errorMessage.value
            : 'Could not remove item',
      );
    }
  }

  Future<void> _confirmClear() async {
    await SweetAlert.confirm(
      context,
      title: 'Clear Cart?',
      message: 'Remove all items from your cart?',
      confirmText: 'Clear',
      onConfirm: () async {
        final success = await _cart.clearCart();
        if (!mounted) return;
        if (success) {
          await SweetAlert.success(context, message: 'Cart cleared');
        } else {
          await SweetAlert.error(
            context,
            message: _cart.errorMessage.value.isNotEmpty
                ? _cart.errorMessage.value
                : 'Could not clear cart',
          );
        }
      },
    );
  }

  void _goToCheckout(double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(amount: amount),
      ),
    );
  }

  Widget _couponCard() {
    final applied = _cart.appliedCoupon.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDecorations.softCard(radius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: applied.isEmpty ? () => _showCouponDialog(context) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applied.isEmpty ? 'Apply Coupon' : 'Coupon applied',
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        applied.isEmpty
                            ? 'Save more on this order'
                            : applied,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: applied.isEmpty
                              ? Colors.grey.shade600
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (applied.isNotEmpty)
                  TextButton(
                    onPressed: _cart.removeCoupon,
                    child: Text(
                      'Remove',
                      style: GoogleFonts.rubik(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartItemCard({
    required Map<String, dynamic> item,
    required int index,
    required bool isUpdating,
  }) {
    final cartItemId = item['cart_item_id']?.toString() ?? '';
    final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
    final unitPrice = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
    final lineTotal = unitPrice * qty;
    final imageUrl = pickImageUrl(item);
    final name = item['name']?.toString() ??
        item['product_name']?.toString() ??
        'Product';
    final grams = item['product_grams']?.toString() ??
        item['grams']?.toString() ??
        '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(cartItemId.isNotEmpty ? cartItemId : 'cart_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        onDismissed: (_) => _removeItem(cartItemId),
        child: Container(
          decoration: AppDecorations.softCard(radius: 18),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: NetworkOrAssetImage(
                      url: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        if (grams.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            grams,
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '₹${unitPrice.toStringAsFixed(0)} × $qty',
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${lineTotal.toStringAsFixed(0)}',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isUpdating)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    QuantityStepper(
                      quantity: qty,
                      minQuantity: 1,
                      onDecrement: qty > 1
                          ? () => _changeQuantity(cartItemId, qty - 1)
                          : () => _removeItem(cartItemId),
                      onIncrement: () => _changeQuantity(cartItemId, qty + 1),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Obx(() {
          final count = _cart.items.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Cart',
                style: GoogleFonts.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (count > 0)
                Text(
                  '$count item${count == 1 ? '' : 's'}',
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          );
        }),
        actions: [
          Obx(
            () => _cart.items.isNotEmpty
                ? TextButton(
                    onPressed: _confirmClear,
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade400,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (_cart.isLoading.value && _cart.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (_cart.errorMessage.value.isNotEmpty && _cart.items.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.error,
            errorMessage: _cart.errorMessage.value,
            onRetry: _cart.loadCart,
            child: const SizedBox(),
          );
        }
        if (_cart.items.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _cart.loadCart,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: const ApiStateView(
                    status: ApiViewStatus.empty,
                    emptyMessage: 'Your cart is empty',
                    child: SizedBox(),
                  ),
                ),
              ],
            ),
          );
        }

        final summary = buildCheckoutSummary(_cart);
        final payable = summary.grandTotal > 0
            ? summary.grandTotal
            : _cart.totalValue;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _cart.loadCart,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  children: [
                    _couponCard(),
                    ...List.generate(_cart.items.length, (index) {
                      final item = _cart.items[index];
                      final cartItemId =
                          item['cart_item_id']?.toString() ?? '';
                      final isUpdating =
                          _cart.updatingItemId.value == cartItemId;
                      return _cartItemCard(
                        item: item,
                        index: index,
                        isUpdating: isUpdating,
                      );
                    }),
                  ],
                ),
              ),
            ),
            CartSummaryFooter(
              summary: summary,
              isLoading: _cart.isLoading.value,
              onCheckout: () => _goToCheckout(payable),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _showCouponDialog(BuildContext context) async {
    final code = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Apply Coupon',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: code,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter coupon code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final couponCode = code.text.trim();
              Navigator.pop(ctx);
              final result = await _cart.applyCoupon(couponCode);
              if (!context.mounted) return;
              if (result is ApiFailure<Map<String, dynamic>>) {
                showApiSnackBar(context, result.message, isError: true);
              } else {
                showApiSnackBar(context, 'Coupon applied');
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    code.dispose();
  }
}
