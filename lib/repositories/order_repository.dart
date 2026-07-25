import '../core/config/app_config.dart';
import '../data/mock/mock_orders.dart';
import '../data/mock/mock_products.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/result.dart';

class PaginatedOrders {
  const PaginatedOrders({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  final List<Order> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
}

/// Order repository. Demo vs live is controlled by [AppConfig.kDemoMode].
class OrderRepository {
  OrderRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  Future<Result<PaginatedOrders>> fetchOrders({
    int page = 1,
    int limit = 20,
    String? filter,
  }) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      var all = List<Order>.from(MockOrders.orders);
      switch (filter) {
        case 'pending':
          all = all
              .where(
                (o) =>
                    o.status != OrderStatus.delivered &&
                    o.status != OrderStatus.cancelled,
              )
              .toList();
        case 'delivered':
          all = all.where((o) => o.status == OrderStatus.delivered).toList();
        case 'cancelled':
          all = all.where((o) => o.status == OrderStatus.cancelled).toList();
        default:
          break;
      }
      final start = (page - 1) * limit;
      if (start >= all.length) {
        return Success(
          PaginatedOrders(
            items: const [],
            page: page,
            limit: limit,
            total: all.length,
            hasMore: false,
          ),
        );
      }
      final end = (start + limit).clamp(0, all.length);
      return Success(
        PaginatedOrders(
          items: all.sublist(start, end),
          page: page,
          limit: limit,
          total: all.length,
          hasMore: end < all.length,
        ),
      );
    }

    try {
      final response = await _apiClient!.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      final raw = data['items'] as List<dynamic>? ?? data['orders'] as List<dynamic>? ?? [];
      final items = raw.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      final total = (data['total'] as num?)?.toInt() ?? items.length;
      return Success(
        PaginatedOrders(
          items: items,
          page: page,
          limit: limit,
          total: total,
          hasMore: page * limit < total,
        ),
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Order>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
  }) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
      final order = Order(
        id: 'BM-$stamp',
        items: const [],
        status: OrderStatus.placed,
        subtotal: 0,
        deliveryFee: 0,
        total: 0,
        placedAt: DateTime.now(),
        deliveryAddress: '12, Wholesale Market Road, Bengaluru 560001',
      );
      // Prefer reconstructing from cart payload via mock products when available.
      try {
        final builtItems = items.map((raw) {
          final product = MockProducts.byId(raw['product_id'].toString());
          final qty = (raw['quantity'] as num?)?.toInt() ?? product.moq;
          return CartItem(product: product, quantity: qty);
        }).toList();
        final subtotal = builtItems.fold<double>(0, (s, i) => s + i.lineTotal);
        final placed = Order(
          id: order.id,
          items: builtItems,
          status: OrderStatus.placed,
          subtotal: subtotal,
          deliveryFee: 0,
          total: subtotal,
          placedAt: order.placedAt,
          deliveryAddress: order.deliveryAddress,
        );
        MockOrders.orders.insert(0, placed);
        return Success(placed);
      } catch (_) {
        MockOrders.orders.insert(0, order);
        return Success(order);
      }
    }

    try {
      final response = await _apiClient!.dio.post(
        ApiEndpoints.placeOrder,
        data: {'items': items, 'address_id': addressId, 'payment_method': 'COD'},
      );
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return Success(Order.fromJson(data));
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Order>> fetchOrderDetail(String id) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        final order = MockOrders.orders.firstWhere((o) => o.id == id);
        return Success(order);
      } catch (_) {
        return const Failure('Order not found', statusCode: 404);
      }
    }

    try {
      final response = await _apiClient!.dio.get(ApiEndpoints.orderDetail(id));
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return Success(Order.fromJson(data));
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
