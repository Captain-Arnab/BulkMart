import 'package:urban_roots/features/orders/order_model.dart';

enum OrderSegment {
  cancelledOrUnpaid,
  willDeliver,
  delivered,
}

extension OrderSegmentX on Order {
  bool get isDelivered {
    final value = status.toLowerCase();
    return value.contains('delivered') ||
        value.contains('completed') ||
        value.contains('complete');
  }

  bool get isCancelledOrNotPaid {
    if (isCancelled) return true;
    if (isDelivered) return false;

    final pay = paymentStatus.toLowerCase();
    if (pay.contains('fail') ||
        pay.contains('unpaid') ||
        pay.contains('declined') ||
        pay.contains('refund')) {
      return true;
    }

    final method = paymentMethod.toLowerCase();
    final isCod = method.contains('cod') || method.contains('cash');

    if (!isPaymentComplete && !isCod) return true;

    final statusLower = status.toLowerCase();
    if (statusLower.contains('unpaid') ||
        statusLower.contains('payment pending') ||
        statusLower.contains('not paid')) {
      return true;
    }

    return false;
  }

  bool get isWillDeliver {
    if (isDelivered || isCancelledOrNotPaid) return false;
    return true;
  }

  OrderSegment get segment {
    if (isDelivered) return OrderSegment.delivered;
    if (isCancelledOrNotPaid) return OrderSegment.cancelledOrUnpaid;
    return OrderSegment.willDeliver;
  }
}

String orderSegmentLabel(OrderSegment segment) {
  switch (segment) {
    case OrderSegment.cancelledOrUnpaid:
      return 'Cancelled / Not Paid';
    case OrderSegment.willDeliver:
      return 'Will Deliver';
    case OrderSegment.delivered:
      return 'Delivered';
  }
}
