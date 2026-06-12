class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double subtotal;
  final String imageUrl;

  OrderItem({
    this.productId = '',
    required this.name,
    required this.quantity,
    required this.subtotal,
    required this.imageUrl,
  });
}

class Order {
  final int orderId;
  final String date;
  final double total;
  final String status;
  final List<OrderItem> items;
  final String paymentMethod;
  final String paymentStatus;
  final String pendingPaymentUrl;
  final String customerName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String landmark;

  Order({
    required this.orderId,
    required this.date,
    required this.total,
    this.status = '',
    required this.items,
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.pendingPaymentUrl = '',
    this.customerName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.landmark = '',
  });

  String get formattedAddress {
    final parts = [
      address,
      landmark,
      city,
      state,
      pincode,
    ].where((part) => part.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  bool get isCancelled {
    final value = status.toLowerCase();
    return value.contains('cancel') || value.contains('reject');
  }

  bool get isPaymentComplete {
    final pay = paymentStatus.toLowerCase();
    if (pay.contains('paid') ||
        pay.contains('success') ||
        pay == '1' ||
        pay.contains('completed')) {
      return true;
    }
    final method = paymentMethod.toLowerCase();
    if (method.contains('cod') || method.contains('cash')) {
      return !pay.contains('failed') && !pay.contains('unpaid');
    }
    return false;
  }

  bool get needsPaymentAction {
    if (isCancelled || isPaymentComplete) return false;
    final pay = paymentStatus.toLowerCase();
    final orderStatus = status.toLowerCase();
    if (pay.contains('pending') ||
        pay.contains('unpaid') ||
        pay.contains('failed') ||
        pay.contains('due')) {
      return true;
    }
    if (orderStatus.contains('pending') &&
        paymentMethod.toLowerCase().contains('online')) {
      return true;
    }
    if (orderStatus.contains('processing') &&
        !paymentMethod.toLowerCase().contains('cod') &&
        !paymentMethod.toLowerCase().contains('cash')) {
      return true;
    }
    if (total > 0 &&
        orderStatus.contains('processing') &&
        paymentStatus.trim().isEmpty) {
      return true;
    }
    return pendingPaymentUrl.isNotEmpty;
  }
}
