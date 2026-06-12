import 'package:urban_roots/features/orders/order_model.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

String? extractPaymentUrl(Map<String, dynamic> data) {
  for (final key in ['redirect_url', 'payment_url', 'pay_url']) {
    final value = data[key];
    if (value is String && value.isNotEmpty) return value;
  }
  final inner = data['data'];
  if (inner is Map) {
    for (final key in ['redirect_url', 'payment_url', 'pay_url']) {
      final value = inner[key];
      if (value is String && value.isNotEmpty) return value;
    }
  }
  return null;
}

String? extractOrderId(Map<String, dynamic> data) {
  for (final key in ['order_id', 'orderId']) {
    final value = data[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  final inner = data['data'];
  if (inner is Map) {
    for (final key in ['order_id', 'orderId']) {
      final value = inner[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
  }
  return null;
}

List<Map<String, dynamic>> cartItemsToProducts(
  List<Map<String, dynamic>> cartItems,
) {
  return cartItems
      .map((item) {
        final productId = item['product_id']?.toString() ??
            item['pd_id']?.toString() ??
            item['productId']?.toString() ??
            '';
        final quantity =
            int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
        return {
          'product_id': productId,
          'quantity': quantity,
        };
      })
      .where((item) => item['product_id'].toString().isNotEmpty)
      .toList();
}

class OrderPaymentFields {
  const OrderPaymentFields({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.state,
    required this.city,
    required this.address,
    required this.pincode,
    required this.landmark,
    required this.addressType,
    required this.amount,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.txnId = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String state;
  final String city;
  final String address;
  final String pincode;
  final String landmark;
  final String addressType;
  final double amount;
  final String orderId;
  final String productId;
  final int quantity;
  final String txnId;

  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        state.isNotEmpty &&
        city.isNotEmpty &&
        address.isNotEmpty &&
        pincode.isNotEmpty &&
        landmark.isNotEmpty &&
        productId.isNotEmpty &&
        quantity > 0 &&
        amount > 0 &&
        orderId.isNotEmpty;
  }

  List<String> get missingFields {
    final missing = <String>[];
    if (firstName.isEmpty) missing.add('first name');
    if (lastName.isEmpty) missing.add('last name');
    if (email.isEmpty) missing.add('email');
    if (phone.isEmpty) missing.add('phone');
    if (state.isEmpty) missing.add('state');
    if (city.isEmpty) missing.add('city');
    if (address.isEmpty) missing.add('address');
    if (pincode.isEmpty) missing.add('pincode');
    if (landmark.isEmpty) missing.add('landmark');
    if (productId.isEmpty) missing.add('product');
    if (quantity <= 0) missing.add('quantity');
    if (amount <= 0) missing.add('amount');
    if (orderId.isEmpty) missing.add('order id');
    return missing;
  }
}

({String first, String last}) splitFullName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return (first: '', last: '');
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) return (first: parts.first, last: '');
  return (first: parts.first, last: parts.sublist(1).join(' '));
}

OrderPaymentFields buildOrderPaymentFields({
  required Order order,
  Map<String, dynamic>? profile,
  Address? defaultAddress,
}) {
  final nameFromOrder = splitFullName(order.customerName);
  final nameFromAddress = defaultAddress == null
      ? (first: '', last: '')
      : splitFullName(defaultAddress.fullName);

  var firstName = nameFromOrder.first;
  var lastName = nameFromOrder.last;
  if (firstName.isEmpty && nameFromAddress.first.isNotEmpty) {
    firstName = nameFromAddress.first;
    lastName = nameFromAddress.last;
  }
  if (firstName.isEmpty && profile != null) {
    firstName = profile['cust_fname']?.toString() ?? '';
    lastName = profile['cust_lname']?.toString() ?? '';
  }
  if (lastName.isEmpty) {
    lastName = profile?['cust_lname']?.toString() ?? '';
  }
  if (lastName.isEmpty && firstName.isNotEmpty) {
    lastName = firstName;
  }

  final email = _firstNonEmpty([
    order.email,
    profile?['email']?.toString() ?? '',
    profile?['cust_email']?.toString() ?? '',
  ]);

  final phone = _firstNonEmpty([
    order.phone,
    defaultAddress?.phone ?? '',
    profile?['phone']?.toString() ?? '',
    profile?['cust_mobile']?.toString() ?? '',
  ]);

  final state = _firstNonEmpty([
    order.state,
    defaultAddress?.state ?? '',
    profile?['state']?.toString() ?? '',
  ]);

  final city = _firstNonEmpty([
    order.city,
    defaultAddress?.city ?? '',
    profile?['city']?.toString() ?? '',
  ]);

  final address = _firstNonEmpty([
    order.address,
    defaultAddress?.addressLine1 ?? '',
    profile?['address']?.toString() ?? '',
  ]);

  final pincode = _firstNonEmpty([
    order.pincode,
    defaultAddress?.pincode ?? '',
  ]);

  var landmark = _firstNonEmpty([
    order.landmark,
    defaultAddress?.addressLine2 ?? '',
  ]);
  if (landmark.isEmpty) landmark = '-';

  final addressType = defaultAddress?.category.trim().isNotEmpty == true
      ? defaultAddress!.category.toLowerCase()
      : 'home';

  final firstItem = order.items.isNotEmpty ? order.items.first : null;

  return OrderPaymentFields(
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    state: state,
    city: city,
    address: address,
    pincode: pincode,
    landmark: landmark,
    addressType: addressType,
    amount: order.total,
    orderId: order.orderId.toString(),
    productId: firstItem?.productId ?? '',
    quantity: firstItem?.quantity ?? 1,
  );
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}
