import '../models/order.dart';
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

/// Order repository stub — empty list until order APIs are wired.
class OrderRepository {
  Future<Result<PaginatedOrders>> fetchOrders({
    int page = 1,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    // Real call: GET ApiEndpoints.orders?page=&limit=
    return Success(
      PaginatedOrders(
        items: const [],
        page: page,
        limit: limit,
        total: 0,
        hasMore: false,
      ),
    );
  }

  Future<Result<Order>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    // Real call: POST ApiEndpoints.placeOrder
    return const Failure('Place order API not connected yet');
  }

  Future<Result<Order>> fetchOrderDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Real call: GET ApiEndpoints.orderDetail(id)
    return const Failure('Order not found', statusCode: 404);
  }
}
