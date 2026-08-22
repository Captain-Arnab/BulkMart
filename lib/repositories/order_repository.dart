import '../core/config/app_config.dart';
import '../data/mock/mock_orders.dart';
import '../data/mock/mock_products.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
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
        queryParameters: {'page': page, 'per_page': limit},
      );
      return ApiEnvelope.parse(response, (data) {
        final map = data is Map ? Map<String, dynamic>.from(data as Map) : null;
        final raw = map?['orders'] as List? ?? const [];
        var items = raw
            .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        switch (filter) {
          case 'pending':
            items = items
                .where(
                  (o) =>
                      o.status != OrderStatus.delivered &&
                      o.status != OrderStatus.cancelled,
                )
                .toList();
          case 'delivered':
            items =
                items.where((o) => o.status == OrderStatus.delivered).toList();
          case 'cancelled':
            items =
                items.where((o) => o.status == OrderStatus.cancelled).toList();
        }
        final pagination = map?['pagination'] as Map?;
        final total =
            (pagination?['total'] as num?)?.toInt() ?? items.length;
        final perPage =
            (pagination?['per_page'] as num?)?.toInt() ?? limit;
        final currentPage =
            (pagination?['page'] as num?)?.toInt() ?? page;
        final pages = (pagination?['pages'] as num?)?.toInt() ?? 1;
        return PaginatedOrders(
          items: items,
          page: currentPage,
          limit: perPage,
          total: total,
          hasMore: currentPage < pages,
        );
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  /// Syncs [items] into the server cart, then places a COD order.
  Future<Result<Order>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
    String? deliveryAddress,
  }) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
      final addressText =
          (deliveryAddress != null && deliveryAddress.trim().isNotEmpty)
              ? deliveryAddress.trim()
              : 'Address $addressId';
      final order = Order(
        id: 'VC-$stamp',
        items: const [],
        status: OrderStatus.placed,
        subtotal: 0,
        deliveryFee: 0,
        total: 0,
        placedAt: DateTime.now(),
        deliveryAddress: addressText,
        paymentMethod: 'COD',
      );
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
          paymentMethod: order.paymentMethod,
        );
        MockOrders.orders.insert(0, placed);
        return Success(placed);
      } catch (_) {
        MockOrders.orders.insert(0, order);
        return Success(order);
      }
    }

    try {
      // Server checkout reads from cart — replace server cart with local lines.
      try {
        final cartRes = await _apiClient!.dio.get(ApiEndpoints.cart);
        final cartData = cartRes.data is Map ? cartRes.data['data'] : null;
        final existing = cartData is Map && cartData['items'] is List
            ? cartData['items'] as List
            : const [];
        for (final row in existing) {
          if (row is Map && row['id'] != null) {
            await _apiClient!.dio
                .delete(ApiEndpoints.cartItem(row['id'].toString()));
          }
        }
      } catch (_) {
        // Continue — add items anyway.
      }

      for (final raw in items) {
        await _apiClient!.dio.post(
          ApiEndpoints.cartItems,
          data: {
            'product_id': int.tryParse(raw['product_id'].toString()) ??
                raw['product_id'],
            'quantity': raw['quantity'],
            'replace': true,
          },
        );
      }

      final response = await _apiClient!.dio.post(
        ApiEndpoints.placeOrder,
        data: {
          'address_id': int.tryParse(addressId) ?? addressId,
          'payment_method': 'COD',
        },
      );
      return ApiEnvelope.parse(response, (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final orderRaw = map['order'] ?? map;
        return Order.fromJson(Map<String, dynamic>.from(orderRaw as Map));
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<Order>> cancelOrder(String id) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final index = MockOrders.orders.indexWhere((o) => o.id == id);
      if (index < 0) {
        return const Failure('Order not found', statusCode: 404);
      }
      final current = MockOrders.orders[index];
      if (current.status != OrderStatus.placed &&
          current.status != OrderStatus.confirmed) {
        return const Failure('This order can no longer be cancelled');
      }
      final cancelled = Order(
        id: current.id,
        items: current.items,
        status: OrderStatus.cancelled,
        subtotal: current.subtotal,
        deliveryFee: current.deliveryFee,
        total: current.total,
        placedAt: current.placedAt,
        estimatedDeliveryDate: current.estimatedDeliveryDate,
        deliveryAddress: current.deliveryAddress,
        paymentMethod: current.paymentMethod,
      );
      MockOrders.orders[index] = cancelled;
      return Success(cancelled);
    }

    try {
      final response =
          await _apiClient!.dio.post(ApiEndpoints.orderCancel(id));
      return ApiEnvelope.parse(response, (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final orderRaw = map['order'] ?? map;
        return Order.fromJson(Map<String, dynamic>.from(orderRaw as Map));
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
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
      final response =
          await _apiClient!.dio.get(ApiEndpoints.orderDetail(id));
      return ApiEnvelope.parse(response, (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final orderRaw = map['order'] ?? map;
        return Order.fromJson(Map<String, dynamic>.from(orderRaw as Map));
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }
}
