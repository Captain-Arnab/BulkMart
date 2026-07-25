enum OrderStatus {
  placed,
  confirmed,
  deliveryDateSet,
  outForDelivery,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Awaiting Delivery Date';
      case OrderStatus.deliveryDateSet:
        return 'Delivery Date Set';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Fixed timeline step titles (Placed → Confirmed → …).
  String get timelineLabel {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.deliveryDateSet:
        return 'Delivery Date Set';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'placed':
        return OrderStatus.placed;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'delivery_date_set':
      case 'deliverydateset':
        return OrderStatus.deliveryDateSet;
      case 'out_for_delivery':
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }

  String toApi() {
    switch (this) {
      case OrderStatus.placed:
        return 'placed';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.deliveryDateSet:
        return 'delivery_date_set';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}
