import '../core/config/app_config.dart';
import '../data/mock/mock_orders.dart';
import '../models/order.dart';
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
  }) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final all = MockOrders.orders;
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
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return const Failure('Demo mode — place-order UI success flow coming next');
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
