import 'package:urban_roots/core/order/order_status.dart';

class TrackingCoordinate {
  const TrackingCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  bool get isValid =>
      latitude.abs() > 0.000001 && longitude.abs() > 0.000001;
}

class OrderTrackingStep {
  const OrderTrackingStep({
    required this.label,
    this.statusCode = 0,
    this.timestamp = '',
    this.completed = false,
    this.isCurrent = false,
  });

  final String label;
  final int statusCode;
  final String timestamp;
  final bool completed;
  final bool isCurrent;
}

class OrderTrackingData {
  const OrderTrackingData({
    this.orderId = 0,
    this.txnId = '',
    this.orderStatus = '',
    this.statusCode = 0,
    this.completed = false,
    this.steps = const [],
    this.destination,
    this.agentName = '',
    this.agentPhone = '',
    this.eta = '',
  });

  final int orderId;
  final String txnId;
  final String orderStatus;
  final int statusCode;
  final bool completed;
  final List<OrderTrackingStep> steps;
  final TrackingCoordinate? destination;
  final String agentName;
  final String agentPhone;
  final String eta;

  bool get showLiveMap => statusCode >= 3 && !completed;
}

class OrderLiveTrackingData {
  const OrderLiveTrackingData({
    this.location,
    this.agent,
    this.agentName = '',
    this.agentPhone = '',
    this.eta = '',
  });

  final TrackingCoordinate? location;
  final TrackingCoordinate? agent;
  final String agentName;
  final String agentPhone;
  final String eta;
}

List<OrderTrackingStep> buildFallbackTrackingSteps(String status) {
  final orderStatus = OrderStatus.fromString(status);
  final code = orderStatus.trackingCode;

  OrderTrackingStep step({
    required String label,
    required int statusCode,
  }) {
    final completed = code > statusCode ||
        (code == statusCode && orderStatus.isTerminal);
    final isCurrent = code == statusCode && !orderStatus.isTerminal;
    return OrderTrackingStep(
      label: label,
      statusCode: statusCode,
      completed: completed,
      isCurrent: isCurrent,
    );
  }

  if (orderStatus == OrderStatus.cancelled) {
    return [
      step(label: 'Order Placed', statusCode: 1),
      step(label: 'Cancelled', statusCode: 6),
    ];
  }

  return [
    step(label: 'Order Placed', statusCode: 1),
    step(label: 'Processing', statusCode: 2),
    step(label: 'Dispatched', statusCode: 3),
    step(label: 'Out for Delivery', statusCode: 4),
    step(label: 'Delivered', statusCode: 5),
  ];
}
