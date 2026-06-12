import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/cart/domain/cart_controller.dart';
import 'package:urban_roots/features/orders/domain/order_payment_utils.dart';
import 'package:urban_roots/features/orders/domain/orders_controller.dart';
import 'package:urban_roots/features/orders/presentation/order_success_screen.dart';
import 'package:urban_roots/features/wallet/presentation/wallet_payment_webview.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.amount});
  final double amount;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _landmark = TextEditingController();
  String _payment = 'cod';
  ApiViewStatus _status = ApiViewStatus.idle;

  Future<void> _finishSuccessfulOrder(CartController cart, String orderId) async {
    await cart.loadCart();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId)),
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _status = ApiViewStatus.loading);
    final cart = Get.find<CartController>();
    final products = cartItemsToProducts(cart.items);
    if (products.isEmpty) {
      setState(() => _status = ApiViewStatus.idle);
      showApiSnackBar(context, 'Cart is empty', isError: true);
      return;
    }

    final address = {
      'firstName': _fname.text.trim(),
      'lastName': _lname.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'state': _state.text.trim(),
      'city': _city.text.trim(),
      'address': _address.text.trim(),
      'pincode': _pincode.text.trim(),
      'landmark': _landmark.text.trim(),
      'addressType': 'home',
    };

    ApiResult<Map<String, dynamic>> result;
    final cartCheckout = await cart.checkoutCart(
      firstName: address['firstName']!,
      lastName: address['lastName']!,
      email: address['email']!,
      phone: address['phone']!,
      state: address['state']!,
      city: address['city']!,
      address: address['address']!,
      pincode: address['pincode']!,
      landmark: address['landmark']!,
      addressType: address['addressType']!,
      paymentMethod: _payment,
      amount: widget.amount,
    );

    if (cartCheckout is ApiSuccess<Map<String, dynamic>>) {
      result = cartCheckout;
    } else if (_payment == 'cod') {
      result = await UrbanRootsApi.instance.orders.placeCodOrder(
        firstName: address['firstName']!,
        lastName: address['lastName']!,
        email: address['email']!,
        phone: address['phone']!,
        state: address['state']!,
        city: address['city']!,
        address: address['address']!,
        pincode: address['pincode']!,
        landmark: address['landmark']!,
        addressType: address['addressType']!,
        products: products,
        amount: widget.amount,
      );
    } else {
      result = await UrbanRootsApi.instance.orders.placeOnlineOrder(
        firstName: address['firstName']!,
        lastName: address['lastName']!,
        email: address['email']!,
        phone: address['phone']!,
        state: address['state']!,
        city: address['city']!,
        address: address['address']!,
        pincode: address['pincode']!,
        landmark: address['landmark']!,
        addressType: address['addressType']!,
        products: products,
        amount: widget.amount,
      );
    }

    if (!mounted) return;
    setState(() => _status = ApiViewStatus.idle);

    if (result is ApiFailure<Map<String, dynamic>>) {
      showApiSnackBar(context, result.message, isError: true);
      return;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final orderId = extractOrderId(data) ?? '';

    if (_payment == 'online') {
      final paymentUrl = extractPaymentUrl(data);
      if (paymentUrl == null || paymentUrl.isEmpty) {
        await SweetAlert.error(
          context,
          message:
              'Could not start online payment. Please try again or use Cash on Delivery.',
        );
        return;
      }

      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => WalletPaymentWebView(
            paymentUrl: paymentUrl,
            amount: widget.amount,
            onReturnVerify: orderId.isEmpty
                ? null
                : () => OrdersController.findOrPut()
                    .verifyOrderPayment(int.parse(orderId)),
          ),
        ),
      );

      if (!mounted) return;
      if (paid != true) {
        await SweetAlert.warning(
          context,
          message: orderId.isNotEmpty
              ? 'Payment was not completed. Order #$orderId is pending until payment succeeds.'
              : 'Payment was not completed. Please try again.',
        );
        return;
      }

      if (orderId.isNotEmpty) {
        final verified = await OrdersController.findOrPut()
            .verifyOrderPayment(int.parse(orderId));
        if (!verified) {
          await SweetAlert.warning(
            context,
            message:
                'Payment was not completed. Order #$orderId is pending until payment succeeds.',
          );
          return;
        }
      }
    }

    await _finishSuccessfulOrder(cart, orderId);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
      ),
      body: ApiStateView(
        status: _status,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Obx(() {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Items (${cart.items.length})',
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...cart.items.map((item) {
                      final name = item['name']?.toString() ??
                          item['product_name']?.toString() ??
                          'Product';
                      final qty =
                          int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '$name × $qty',
                          style: GoogleFonts.rubik(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
            TextField(controller: _fname, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: _lname, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: _landmark, decoration: const InputDecoration(labelText: 'Landmark')),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
            TextField(controller: _state, decoration: const InputDecoration(labelText: 'State')),
            TextField(controller: _pincode, decoration: const InputDecoration(labelText: 'Pincode')),
            const SizedBox(height: 16),
            RadioListTile(
              value: 'cod',
              groupValue: _payment,
              onChanged: (v) => setState(() => _payment = v!),
              title: const Text('Pay at Delivery (Cash on Delivery)'),
            ),
            RadioListTile(
              value: 'online',
              groupValue: _payment,
              onChanged: (v) => setState(() => _payment = v!),
              title: const Text('Pay Online'),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: ₹${widget.amount.toStringAsFixed(0)}',
              style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _status == ApiViewStatus.loading ? null : _placeOrder,
              child: Text(_payment == 'online' ? 'Pay & Place Order' : 'Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
