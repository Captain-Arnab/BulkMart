import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/cart/domain/cart_controller.dart';
import 'package:urban_roots/features/checkout/presentation/checkout_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cart = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    _cart.loadCart();
  }

  Future<void> _confirmClear() async {
    await SweetAlert.confirm(
      context,
      title: 'Clear Cart?',
      message: 'Remove all items from your cart?',
      confirmText: 'Clear',
      onConfirm: () async {
        final success = await _cart.clearCart();
        if (!success && mounted) {
          await SweetAlert.error(context, message: _cart.errorMessage.value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Cart', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        actions: [
          Obx(() => _cart.items.isNotEmpty
              ? TextButton(onPressed: _confirmClear, child: Text('Clear All', style: GoogleFonts.rubik(fontSize: 13, color: Colors.red.shade400)))
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (_cart.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF019934)));
        }
        if (_cart.errorMessage.value.isNotEmpty && _cart.items.isEmpty) {
          return ApiStateView(status: ApiViewStatus.error, errorMessage: _cart.errorMessage.value, onRetry: _cart.loadCart, child: const SizedBox());
        }
        if (_cart.items.isEmpty) {
          return ApiStateView(status: ApiViewStatus.empty, emptyMessage: 'Your cart is empty', child: const SizedBox());
        }
        final total = _cart.finalAmount.value > 0 ? _cart.finalAmount.value : _cart.totalValue;
        return Column(
          children: [
            if (_cart.appliedCoupon.value.isNotEmpty)
              ListTile(
                title: Text('Coupon: ${_cart.appliedCoupon.value}'),
                trailing: TextButton(onPressed: _cart.removeCoupon, child: const Text('Remove')),
              ),
            ListTile(
              title: const Text('Apply Coupon'),
              trailing: const Icon(Icons.local_offer_outlined),
              onTap: () => _showCouponDialog(context),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cart.items.length,
                itemBuilder: (context, index) {
                  final item = _cart.items[index];
                  final cartItemId = item['cart_item_id']?.toString() ?? '';
                  final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
                  final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
                  return Dismissible(
                    key: Key(cartItemId.isNotEmpty ? cartItemId : '$index'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _cart.removeItem(cartItemId),
                    background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                    child: Card(
                      child: ListTile(
                        title: Text(item['name']?.toString() ?? item['product_name']?.toString() ?? ''),
                        subtitle: Text('₹${price.toStringAsFixed(0)} × $qty'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove), onPressed: qty > 1 ? () => _cart.updateQuantity(cartItemId, qty - 1) : null),
                            Text('$qty'),
                            IconButton(icon: const Icon(Icons.add), onPressed: () => _cart.updateQuantity(cartItemId, qty + 1)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total'),
                    Text('₹${total.toStringAsFixed(0)}', style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(amount: total))),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ],
              ),
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
        title: const Text('Apply Coupon'),
        content: TextField(controller: code, decoration: const InputDecoration(hintText: 'Coupon code')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await _cart.applyCoupon(code.text);
              if (!mounted) return;
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
  }
}
