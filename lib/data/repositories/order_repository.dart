import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/orders/order_model.dart';

abstract class OrderRepository {
  Future<ApiResult<List<Order>>> getOrderList();
  Future<ApiResult<Map<String, dynamic>>> getOrderDetail({
    int? orderId,
    String? txnId,
  });
}

class ApiOrderRepository implements OrderRepository {
  ApiOrderRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<List<Order>>> getOrderList() async {
    final result = await _api.orders.listOrders();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return ApiSuccess(parseOrders(data));
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getOrderDetail({
    int? orderId,
    String? txnId,
  }) {
    final hasTxn = txnId != null && txnId.trim().isNotEmpty;
    final hasOrderId = orderId != null && orderId > 0;
    return _api.orders.orderDetail(
      orderId: hasTxn ? null : (hasOrderId ? orderId.toString() : null),
      txnId: hasTxn ? txnId.trim() : null,
    );
  }
}
