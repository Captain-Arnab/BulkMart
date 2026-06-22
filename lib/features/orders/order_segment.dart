import 'package:urban_roots/core/order/order_status.dart';
import 'package:urban_roots/features/orders/order_model.dart';

enum OrderSegment {
  cancelledOrUnpaid,
  willDeliver,
  delivered,
}

extension OrderSegmentX on Order {
  bool get isWillDeliverSegment {
    if (isCodLike && isDeliveryProcessing) return true;
    if (isOnlinePayment &&
        isOnlinePaymentCompleted &&
        isDeliveryProcessing) {
      return true;
    }
    return false;
  }

  bool get isDeliveredSegment {
    if (isCodLike && isDeliveryCompleted) return true;
    if (isOnlinePayment &&
        isOnlinePaymentCompleted &&
        isDeliveryCompleted) {
      return true;
    }
    return false;
  }

  bool get isCancelledSegment {
    if (isCancelled) return true;
    if (isOnlinePayment && isOnlinePaymentPending) return true;
    return false;
  }

  OrderSegment get segment {
    if (isCancelledSegment) return OrderSegment.cancelledOrUnpaid;
    if (isDeliveredSegment) return OrderSegment.delivered;
    if (isWillDeliverSegment) return OrderSegment.willDeliver;

    // Sensible fallbacks when API fields are sparse.
    if (isDeliveryCompleted) return OrderSegment.delivered;
    if (isOnlinePayment && isOnlinePaymentPending) {
      return OrderSegment.cancelledOrUnpaid;
    }
    if (isCodLike || isOnlinePaymentCompleted) {
      return OrderSegment.willDeliver;
    }
    return OrderSegment.willDeliver;
  }

  /// Badge label for order history list tiles — uses API status when present.
  String displayStatusForSegment(OrderSegment segment) {
    final deliveryStatus = status.trim();
    if (deliveryStatus.isNotEmpty) {
      return OrderStatus.fromString(deliveryStatus).label;
    }

    switch (segment) {
      case OrderSegment.willDeliver:
        return OrderStatus.processing.label;
      case OrderSegment.delivered:
        return OrderStatus.delivered.label;
      case OrderSegment.cancelledOrUnpaid:
        if (isCancelled) return OrderStatus.cancelled.label;
        final pay = paymentStatus.trim();
        if (pay.isNotEmpty) return pay;
        return 'Pending';
    }
  }
}

String orderSegmentLabel(OrderSegment segment) {
  switch (segment) {
    case OrderSegment.cancelledOrUnpaid:
      return 'Cancelled';
    case OrderSegment.willDeliver:
      return 'Will Deliver';
    case OrderSegment.delivered:
      return 'Delivered';
  }
}
