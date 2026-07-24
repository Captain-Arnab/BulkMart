import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class PaymentHistoryPage {
  const PaymentHistoryPage({
    required this.payments,
    this.hasMore = false,
    this.page = 1,
  });

  final List<Map<String, dynamic>> payments;
  final bool hasMore;
  final int page;
}

abstract class PaymentRepository {
  Future<ApiResult<PaymentHistoryPage>> getPaymentHistory({
    int page = 1,
    int limit = 20,
    String? type,
  });
}

class ApiPaymentRepository implements PaymentRepository {
  ApiPaymentRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<PaymentHistoryPage>> getPaymentHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    final result = await _api.payments.history(
      page: page,
      limit: limit,
      type: type,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final payments = parsePaymentHistory(data);
    final hasMore = _resolveHasMore(data, page: page, limit: limit, loaded: payments.length);

    return ApiSuccess(
      PaymentHistoryPage(
        payments: payments,
        hasMore: hasMore,
        page: page,
      ),
    );
  }

  bool _resolveHasMore(
    Map<String, dynamic> data, {
    required int page,
    required int limit,
    required int loaded,
  }) {
    for (final key in ['has_more', 'hasMore', 'next_page']) {
      final value = data[key];
      if (value is bool) return value;
      if (value == 1 || value == '1' || value == true) return true;
      if (value == 0 || value == '0' || value == false) return false;
      if (key == 'next_page' && value != null) {
        final next = int.tryParse(value.toString());
        if (next != null) return next > page;
      }
    }

    final inner = data['data'];
    if (inner is Map) {
      final map = Map<String, dynamic>.from(inner);
      for (final key in ['has_more', 'hasMore']) {
        final value = map[key];
        if (value is bool) return value;
      }
      final totalPages = int.tryParse(
        (map['total_pages'] ?? map['last_page'] ?? '').toString(),
      );
      if (totalPages != null) return page < totalPages;
    }

    final total = int.tryParse(
      (data['total'] ?? data['count'] ?? '').toString(),
    );
    if (total != null) return page * limit < total;

    // Heuristic: a full page usually means more may exist.
    return loaded >= limit;
  }
}
