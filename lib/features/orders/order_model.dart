class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String imageUrl;

  OrderItem({
    this.productId = '',
    required this.name,
    required this.quantity,
    this.unitPrice = 0,
    required this.subtotal,
    required this.imageUrl,
  });
}

class Order {
  final int orderId;
  final String txnId;
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
    this.txnId = '',
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
    final line = address.trim().startsWith('{') ? '' : address.trim();
    final parts = [
      line,
      if (landmark.trim().isNotEmpty && landmark.trim() != '-') landmark.trim(),
      city.trim(),
      state.trim(),
      pincode.trim(),
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  bool get isCancelled {
    final value = status.toLowerCase();
    return value.contains('cancel') || value.contains('reject');
  }

  /// True for cash-on-delivery / pay-later style orders.
  /// Backend often still assigns a txn_id for COD, so we must not treat
  /// "has txn_id" as proof of online payment.
  bool get isCodLike {
    final method = paymentMethod.toLowerCase();
    final pay = paymentStatus.toLowerCase();
    final hints = '$method $pay';

    if (hints.contains('cod') ||
        hints.contains('cash') ||
        hints.contains('cash on delivery') ||
        hints.contains('pay at delivery') ||
        hints.contains('pay on delivery')) {
      return true;
    }
    if (hints.contains('online') ||
        hints.contains('upi') ||
        hints.contains('wallet') ||
        hints.contains('card') ||
        hints.contains('phonepe') ||
        hints.contains('razorpay')) {
      return false;
    }
    // Sparse API fields: prefer COD-like so the order appears under
    // "Will Deliver" instead of being hidden in "Cancelled / unpaid".
    if (paymentMethod.trim().isEmpty && paymentStatus.trim().isEmpty) {
      return true;
    }
    return txnId.isEmpty && orderId > 0;
  }

  bool get isOnlinePayment => !isCodLike;

  /// Delivery still in progress (order status from API).
  bool get isDeliveryProcessing {
    if (isCancelled || isDeliveryCompleted) return false;
    final s = status.toLowerCase().trim();
    if (s.isEmpty) return true;
    return s.contains('process') ||
        s.contains('pending') ||
        s.contains('confirm') ||
        s.contains('placed') ||
        s.contains('ship') ||
        s.contains('pack') ||
        s.contains('out for') ||
        s.contains('active') ||
        s.contains('new') ||
        s.contains('accepted');
  }

  /// Delivery finished (order status from API).
  bool get isDeliveryCompleted {
    final s = status.toLowerCase().trim();
    if (s.isEmpty) return false;
    return s.contains('delivered') ||
        s.contains('completed') ||
        s == 'complete' ||
        s.endsWith(' completed');
  }

  bool get isOnlinePaymentPending {
    if (isCodLike) return false;
    final pay = paymentStatus.toLowerCase().trim();
    if (pay.isEmpty) {
      // Only treat as unpaid when there is an explicit pending payment URL,
      // not merely because a txn_id exists.
      return pendingPaymentUrl.trim().isNotEmpty && !isDeliveryCompleted;
    }
    return pay.contains('pending') ||
        pay.contains('unpaid') ||
        pay.contains('initiated') ||
        pay.contains('due') ||
        pay.contains('failed');
  }

  bool get isOnlinePaymentCompleted {
    if (isCodLike) return false;
    final pay = paymentStatus.toLowerCase().trim();
    return pay.contains('complete') ||
        pay.contains('paid') ||
        pay.contains('success') ||
        pay == '1';
  }

  bool get isPaymentComplete {
    if (isCodLike) {
      final pay = paymentStatus.toLowerCase();
      return !pay.contains('failed') && !pay.contains('declined');
    }
    return isOnlinePaymentCompleted;
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
