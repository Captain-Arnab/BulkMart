import 'package:flutter/material.dart';

enum OrderStatus {
  placed,
  processing,
  dispatched,
  outForDelivery,
  delivered,
  cancelled,
  unknown;

  static OrderStatus fromString(String? value) {
    switch (value?.trim().toLowerCase() ?? '') {
      case 'placed':
        return OrderStatus.placed;
      case 'processing':
        return OrderStatus.processing;
      case 'dispatched':
        return OrderStatus.dispatched;
      case 'out for delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'completed':
      case 'complete':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.dispatched:
        return 'Dispatched';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.unknown:
        return 'Processing';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.delivered:
        return Colors.green.shade700;
      case OrderStatus.cancelled:
        return Colors.red.shade700;
      case OrderStatus.placed:
      case OrderStatus.processing:
      case OrderStatus.dispatched:
      case OrderStatus.outForDelivery:
        return Colors.orange.shade800;
      case OrderStatus.unknown:
        return Colors.orange.shade800;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.delivered:
        return Colors.green.shade50;
      case OrderStatus.cancelled:
        return Colors.red.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;

  int get trackingCode {
    switch (this) {
      case OrderStatus.placed:
        return 1;
      case OrderStatus.processing:
        return 2;
      case OrderStatus.dispatched:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return 6;
      case OrderStatus.unknown:
        return 0;
    }
  }
}
