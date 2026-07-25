import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';
import 'mock_products.dart';

/// Demo orders for Order Tracking / History walkthrough.
class MockOrders {
  MockOrders._();

  static final List<Order> orders = [
    // Out for Delivery
    Order(
      id: 'BM-10428',
      items: [
        CartItem(product: MockProducts.byId('p1'), quantity: 8),
        CartItem(product: MockProducts.byId('p2'), quantity: 2),
      ],
      status: OrderStatus.outForDelivery,
      subtotal: 1180 * 8 + 2340 * 2,
      deliveryFee: 0,
      total: 1180 * 8 + 2340 * 2,
      placedAt: DateTime.now().subtract(const Duration(days: 2)),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Delivered
    Order(
      id: 'BM-10391',
      items: [
        CartItem(product: MockProducts.byId('p3'), quantity: 6),
        CartItem(product: MockProducts.byId('p4'), quantity: 5),
        CartItem(product: MockProducts.byId('p8'), quantity: 5),
      ],
      status: OrderStatus.delivered,
      subtotal: 1050 * 6 + 640 * 5 + 720 * 5,
      deliveryFee: 0,
      total: 1050 * 6 + 640 * 5 + 720 * 5,
      placedAt: DateTime.now().subtract(const Duration(days: 12)),
      estimatedDeliveryDate: DateTime.now().subtract(const Duration(days: 8)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Awaiting Delivery Date (confirmed, no ETA yet)
    Order(
      id: 'BM-10455',
      items: [
        CartItem(product: MockProducts.byId('p5'), quantity: 4),
        CartItem(product: MockProducts.byId('p9'), quantity: 2),
      ],
      status: OrderStatus.confirmed,
      subtotal: 1850 * 4 + 3200 * 2,
      deliveryFee: 0,
      total: 1850 * 4 + 3200 * 2,
      placedAt: DateTime.now().subtract(const Duration(hours: 18)),
      estimatedDeliveryDate: null,
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Delivery date set — waiting for dispatch
    Order(
      id: 'BM-10440',
      items: [
        CartItem(product: MockProducts.byId('p6'), quantity: 4),
        CartItem(product: MockProducts.byId('p7'), quantity: 3),
        CartItem(product: MockProducts.byId('p10'), quantity: 2),
      ],
      status: OrderStatus.deliveryDateSet,
      subtotal: 2100 * 4 + 980 * 3 + 3600 * 2,
      deliveryFee: 0,
      total: 2100 * 4 + 980 * 3 + 3600 * 2,
      placedAt: DateTime.now().subtract(const Duration(days: 1)),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Cancelled
    Order(
      id: 'BM-10350',
      items: [
        CartItem(product: MockProducts.byId('p2'), quantity: 2),
      ],
      status: OrderStatus.cancelled,
      subtotal: 2340 * 2,
      deliveryFee: 0,
      total: 2340 * 2,
      placedAt: DateTime.now().subtract(const Duration(days: 20)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
  ];
}
