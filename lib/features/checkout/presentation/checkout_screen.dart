import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/cart/domain/cart_controller.dart';
import 'package:urban_roots/features/orders/presentation/order_success_screen.dart';

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

  Future<void> _placeOrder() async {
    setState(() => _status = ApiViewStatus.loading);
    final cart = Get.find<CartController>();
    final firstItem = cart.items.isNotEmpty ? cart.items.first : null;
    if (firstItem == null) {
      setState(() => _status = ApiViewStatus.idle);
      showApiSnackBar(context, 'Cart is empty', isError: true);
      return;
    }

    final body = {
      'first_name': _fname.text,
      'last_name': _lname.text,
      'email': _email.text,
      'phone': _phone.text,
      'state': _state.text,
      'city': _city.text,
      'address': _address.text,
      'pincode': _pincode.text,
      'landmark': _landmark.text,
      'address_type': 'home',
      'product_id': firstItem['product_id']?.toString() ?? '',
      'quantity': int.tryParse(firstItem['quantity']?.toString() ?? '1') ?? 1,
      'amount': widget.amount,
    };

    ApiResult<Map<String, dynamic>> result;
    if (_payment == 'cod') {
      result = await UrbanRootsApi.instance.orders.placeCodOrder(
        firstName: body['first_name'] as String,
        lastName: body['last_name'] as String,
        email: body['email'] as String,
        phone: body['phone'] as String,
        state: body['state'] as String,
        city: body['city'] as String,
        address: body['address'] as String,
        pincode: body['pincode'] as String,
        landmark: body['landmark'] as String,
        addressType: body['address_type'] as String,
        productId: body['product_id'] as String,
        quantity: body['quantity'] as int,
        amount: body['amount'] as double,
      );
    } else {
      result = await UrbanRootsApi.instance.orders.placeOnlineOrder(
        firstName: body['first_name'] as String,
        lastName: body['last_name'] as String,
        email: body['email'] as String,
        phone: body['phone'] as String,
        state: body['state'] as String,
        city: body['city'] as String,
        address: body['address'] as String,
        pincode: body['pincode'] as String,
        landmark: body['landmark'] as String,
        addressType: body['address_type'] as String,
        productId: body['product_id'] as String,
        quantity: body['quantity'] as int,
        amount: body['amount'] as double,
      );
    }

    if (!mounted) return;
    setState(() => _status = ApiViewStatus.idle);

    if (result is ApiFailure<Map<String, dynamic>>) {
      showApiSnackBar(context, result.message, isError: true);
      return;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final orderId = data['order_id']?.toString() ?? '';
    if (_payment == 'online' && data['payment_url'] != null) {
      // Payment URL — open in WebView when integrated
      showApiSnackBar(context, 'Open payment: ${data['payment_url']}');
    }

    await cart.loadCart();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout', style: GoogleFonts.rubik(fontWeight: FontWeight.w600))),
      body: ApiStateView(
        status: _status,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            RadioListTile(value: 'cod', groupValue: _payment, onChanged: (v) => setState(() => _payment = v!), title: const Text('Cash on Delivery')),
            RadioListTile(value: 'online', groupValue: _payment, onChanged: (v) => setState(() => _payment = v!), title: const Text('Online Payment')),
            const SizedBox(height: 16),
            Text('Amount: ₹${widget.amount.toStringAsFixed(0)}', style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _placeOrder, child: const Text('Place Order')),
          ],
        ),
      ),
    );
  }
}
