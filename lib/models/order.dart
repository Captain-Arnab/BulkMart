import 'cart_item.dart';
import 'order_status.dart';

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.placedAt,
    this.estimatedDeliveryDate,
    this.deliveryAddress,
    this.paymentMethod = 'COD',
  });

  final String id;
  final List<CartItem> items;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime placedAt;
  final DateTime? estimatedDeliveryDate;
  final String? deliveryAddress;
  final String paymentMethod;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id']?.toString() ?? json['order_id']?.toString() ?? '',
      items: rawItems
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.fromApi(json['status']?.toString()),
      subtotal: ((json['subtotal'] ?? 0) as num).toDouble(),
      deliveryFee: ((json['delivery_fee'] ?? json['deliveryFee'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
      placedAt: DateTime.tryParse(json['placed_at']?.toString() ?? json['placedAt']?.toString() ?? '') ??
          DateTime.now(),
      estimatedDeliveryDate: DateTime.tryParse(
        json['estimated_delivery_date']?.toString() ??
            json['estimatedDeliveryDate']?.toString() ??
            '',
      ),
      deliveryAddress: json['delivery_address']?.toString() ?? json['deliveryAddress']?.toString(),
      paymentMethod: json['payment_method']?.toString() ?? json['paymentMethod']?.toString() ?? 'COD',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.toApi(),
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total': total,
        'placed_at': placedAt.toIso8601String(),
        if (estimatedDeliveryDate != null)
          'estimated_delivery_date': estimatedDeliveryDate!.toIso8601String(),
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
      };
}
