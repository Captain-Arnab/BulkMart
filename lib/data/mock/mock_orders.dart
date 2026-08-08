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
      id: 'VC-10428',
      items: [
        CartItem(product: MockProducts.byId('gv-01'), quantity: 20),
        CartItem(product: MockProducts.byId('rv-04'), quantity: 30),
      ],
      status: OrderStatus.outForDelivery,
      subtotal: 42 * 20 + 26 * 30,
      deliveryFee: 0,
      total: 42 * 20 + 26 * 30,
      placedAt: DateTime.now().subtract(const Duration(days: 2)),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Delivered
    Order(
      id: 'VC-10391',
      items: [
        CartItem(product: MockProducts.byId('gv-04'), quantity: 15),
        CartItem(product: MockProducts.byId('rv-03'), quantity: 20),
        CartItem(product: MockProducts.byId('sf-03'), quantity: 12),
      ],
      status: OrderStatus.delivered,
      subtotal: 44 * 15 + 40 * 20 + 35 * 12,
      deliveryFee: 0,
      total: 44 * 15 + 40 * 20 + 35 * 12,
      placedAt: DateTime.now().subtract(const Duration(days: 12)),
      estimatedDeliveryDate: DateTime.now().subtract(const Duration(days: 8)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Awaiting Delivery Date (confirmed, no ETA yet)
    Order(
      id: 'VC-10455',
      items: [
        CartItem(product: MockProducts.byId('sf-01'), quantity: 10),
        CartItem(product: MockProducts.byId('gv-14'), quantity: 8),
      ],
      status: OrderStatus.confirmed,
      subtotal: 110 * 10 + 58 * 8,
      deliveryFee: 0,
      total: 110 * 10 + 58 * 8,
      placedAt: DateTime.now().subtract(const Duration(hours: 18)),
      estimatedDeliveryDate: null,
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Delivery date set — waiting for dispatch
    Order(
      id: 'VC-10440',
      items: [
        CartItem(product: MockProducts.byId('rv-05'), quantity: 25),
        CartItem(product: MockProducts.byId('hl-01'), quantity: 10),
        CartItem(product: MockProducts.byId('gv-09'), quantity: 15),
      ],
      status: OrderStatus.deliveryDateSet,
      subtotal: 28 * 25 + 20 * 10 + 32 * 15,
      deliveryFee: 0,
      total: 28 * 25 + 20 * 10 + 32 * 15,
      placedAt: DateTime.now().subtract(const Duration(days: 1)),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
    // Cancelled
    Order(
      id: 'VC-10350',
      items: [
        CartItem(product: MockProducts.byId('sf-02'), quantity: 6),
      ],
      status: OrderStatus.cancelled,
      subtotal: 120 * 6,
      deliveryFee: 0,
      total: 120 * 6,
      placedAt: DateTime.now().subtract(const Duration(days: 20)),
      deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
    ),
  ];
}
