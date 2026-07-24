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

/// PhonePe `/check-status.php` response.state values.
enum PhonePePaymentState {
  completed,
  failed,
  pending,
  unknown,
}

class PaymentStatusCheck {
  const PaymentStatusCheck({
    required this.state,
    this.merchantTransactionId = '',
    this.raw = const {},
  });

  final PhonePePaymentState state;
  final String merchantTransactionId;
  final Map<String, dynamic> raw;

  bool get isCompleted => state == PhonePePaymentState.completed;
  bool get isFailed => state == PhonePePaymentState.failed;
  bool get isPending => state == PhonePePaymentState.pending;
}

abstract class PaymentRepository {
  Future<ApiResult<PaymentHistoryPage>> getPaymentHistory({
    int page = 1,
    int limit = 20,
    String? type,
  });

  /// Single poll of site-root `/check-status.php` — reads response.`state` only.
  Future<ApiResult<PaymentStatusCheck>> checkPaymentStatus({
    required String transactionId,
  });

  /// Polls until COMPLETED / FAILED (or attempts exhausted while PENDING).
  Future<ApiResult<PaymentStatusCheck>> pollPaymentStatus({
    required String transactionId,
    int maxAttempts = 8,
    Duration interval = const Duration(seconds: 2),
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
    final hasMore =
        _resolveHasMore(data, page: page, limit: limit, loaded: payments.length);

    return ApiSuccess(
      PaymentHistoryPage(
        payments: payments,
        hasMore: hasMore,
        page: page,
      ),
    );
  }

  @override
  Future<ApiResult<PaymentStatusCheck>> checkPaymentStatus({
    required String transactionId,
  }) async {
    final result = await _api.payments.checkStatus(
      transactionId: transactionId,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return ApiSuccess(_parseCheckStatus(data));
  }

  @override
  Future<ApiResult<PaymentStatusCheck>> pollPaymentStatus({
    required String transactionId,
    int maxAttempts = 8,
    Duration interval = const Duration(seconds: 2),
  }) async {
    PaymentStatusCheck? last;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(interval);
      }
      final result = await checkPaymentStatus(transactionId: transactionId);
      if (result is ApiFailure<PaymentStatusCheck>) {
        // Transient API errors: keep trying while attempts remain.
        if (attempt == maxAttempts - 1) return result;
        continue;
      }
      last = (result as ApiSuccess<PaymentStatusCheck>).data;
      if (last.state != PhonePePaymentState.pending) {
        return ApiSuccess(last);
      }
    }
    return ApiSuccess(
      last ??
          const PaymentStatusCheck(state: PhonePePaymentState.pending),
    );
  }

  PaymentStatusCheck _parseCheckStatus(Map<String, dynamic> data) {
    // Authoritative field is `state` (COMPLETED / FAILED / PENDING).
    final rawState = (data['state'] ??
            (data['data'] is Map
                ? (data['data'] as Map)['state']
                : null))
        ?.toString()
        .trim()
        .toUpperCase() ??
        '';

    final PhonePePaymentState state;
    switch (rawState) {
      case 'COMPLETED':
        state = PhonePePaymentState.completed;
      case 'FAILED':
        state = PhonePePaymentState.failed;
      case 'PENDING':
        state = PhonePePaymentState.pending;
      default:
        state = PhonePePaymentState.unknown;
    }

    final merchantTxn = data['merchantTransactionId']?.toString() ??
        (data['data'] is Map
            ? (data['data'] as Map)['merchantTransactionId']?.toString()
            : null) ??
        '';

    return PaymentStatusCheck(
      state: state,
      merchantTransactionId: merchantTxn,
      raw: data,
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

    return loaded >= limit;
  }
}
