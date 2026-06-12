import 'package:urban_roots/features/cart/cart_controller.dart';

class CheckoutLineItem {
  const CheckoutLineItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.gstPercent,
    required this.lineTotal,
    required this.gstAmount,
  });

  final String name;
  final int quantity;
  final double unitPrice;
  final double gstPercent;
  final double lineTotal;
  final double gstAmount;
}

class CheckoutSummary {
  const CheckoutSummary({
    required this.lines,
    required this.itemsTotal,
    required this.totalGst,
    required this.deliveryFee,
    required this.discount,
    required this.grandTotal,
  });

  final List<CheckoutLineItem> lines;
  final double itemsTotal;
  final double totalGst;
  final double deliveryFee;
  final double discount;
  final double grandTotal;

  double get savings => discount;
}

double gstFromInclusivePrice(double lineTotal, double gstPercent) {
  if (gstPercent <= 0 || lineTotal <= 0) return 0;
  return lineTotal * gstPercent / (100 + gstPercent);
}

double _readAmount(dynamic value) {
  if (value == null) return 0;
  return double.tryParse(value.toString()) ?? 0;
}

CheckoutSummary buildCheckoutSummary(CartController cart) {
  final lines = <CheckoutLineItem>[];
  var itemsTotal = 0.0;
  var totalGst = 0.0;

  for (final item in cart.items) {
    final name = item['name']?.toString() ??
        item['product_name']?.toString() ??
        'Product';
    final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
    final unitPrice = _readAmount(item['price'] ?? item['product_price']);
    final gstPercent = _readAmount(item['gst'] ?? item['tax_percent']);
    final lineTotal = unitPrice * qty;
    final gstAmount = gstFromInclusivePrice(lineTotal, gstPercent);

    itemsTotal += lineTotal;
    totalGst += gstAmount;
    lines.add(
      CheckoutLineItem(
        name: name,
        quantity: qty,
        unitPrice: unitPrice,
        gstPercent: gstPercent,
        lineTotal: lineTotal,
        gstAmount: gstAmount,
      ),
    );
  }

  final summary = cart.summary;
  var deliveryFee = _readAmount(
    summary['delivery_charge'] ?? summary['delivery'] ?? summary['shipping'],
  );
  var discount = cart.discount.value;
  if (discount <= 0) {
    discount = _readAmount(
      summary['discount'] ?? summary['coupon_discount'] ?? summary['savings'],
    );
  }

  var grandTotal = cart.finalAmount.value;
  if (grandTotal <= 0) {
    grandTotal = _readAmount(
      summary['grand_total'] ?? summary['total'] ?? summary['amount'],
    );
  }
  if (grandTotal <= 0) {
    grandTotal = itemsTotal + deliveryFee - discount;
  }

  if (totalGst <= 0) {
    totalGst = _readAmount(summary['gst'] ?? summary['tax'] ?? summary['gst_total']);
  }

  return CheckoutSummary(
    lines: lines,
    itemsTotal: itemsTotal,
    totalGst: totalGst,
    deliveryFee: deliveryFee,
    discount: discount,
    grandTotal: grandTotal,
  );
}

Map<String, String> checkoutFieldsFromAddress({
  required String fullName,
  required String phone,
  required String addressLine,
  required String landmark,
  required String city,
  required String state,
  required String pincode,
  required String addressType,
  required String email,
}) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  final firstName = parts.isNotEmpty ? parts.first : '';
  final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

  return {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'state': state,
    'city': city,
    'address': addressLine,
    'pincode': pincode,
    'landmark': landmark.isNotEmpty ? landmark : '-',
    'addressType': addressType.toLowerCase(),
  };
}
