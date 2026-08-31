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
    this.itemCount,
    this.orderNumber,
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

  /// From list API (`item_count`) when full `items` are not included.
  final int? itemCount;
  final String? orderNumber;

  /// Prefer full items length; fall back to API `item_count` for list rows.
  int get displayItemCount =>
      items.isNotEmpty ? items.length : (itemCount ?? 0);

  String get displayId =>
      (orderNumber != null && orderNumber!.trim().isNotEmpty)
          ? orderNumber!.trim()
          : id;

  Order copyWith({
    String? id,
    List<CartItem>? items,
    OrderStatus? status,
    double? subtotal,
    double? deliveryFee,
    double? total,
    DateTime? placedAt,
    DateTime? estimatedDeliveryDate,
    String? deliveryAddress,
    String? paymentMethod,
    int? itemCount,
    String? orderNumber,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      placedAt: placedAt ?? this.placedAt,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      itemCount: itemCount ?? this.itemCount,
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    String? addressText = json['delivery_address']?.toString() ??
        json['deliveryAddress']?.toString();
    final addr = json['address'];
    if ((addressText == null || addressText.isEmpty) && addr is Map) {
      final parts = [
        addr['line1'],
        addr['line2'],
        addr['city'],
        addr['state'],
        addr['pincode'],
      ].where((e) => e != null && e.toString().trim().isNotEmpty);
      addressText = parts.join(', ');
    }
    final parsedItemCount = (json['item_count'] as num?)?.toInt() ??
        (json['itemCount'] as num?)?.toInt();
    return Order(
      id: json['id']?.toString() ??
          json['order_id']?.toString() ??
          json['order_number']?.toString() ??
          '',
      orderNumber: json['order_number']?.toString() ??
          json['orderNumber']?.toString(),
      items: rawItems
          .whereType<Map>()
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      itemCount: parsedItemCount,
      status: OrderStatus.fromApi(json['status']?.toString()),
      subtotal: ((json['subtotal'] ?? 0) as num).toDouble(),
      deliveryFee:
          ((json['delivery_fee'] ?? json['deliveryFee'] ?? 0) as num)
              .toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
      placedAt: DateTime.tryParse(
            json['placed_at']?.toString() ??
                json['placedAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      estimatedDeliveryDate: DateTime.tryParse(
        json['estimated_delivery_date']?.toString() ??
            json['estimatedDeliveryDate']?.toString() ??
            '',
      ),
      deliveryAddress: addressText,
      paymentMethod: json['payment_method']?.toString() ??
          json['paymentMethod']?.toString() ??
          'COD',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (orderNumber != null) 'order_number': orderNumber,
        'items': items.map((e) => e.toJson()).toList(),
        if (itemCount != null) 'item_count': itemCount,
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
