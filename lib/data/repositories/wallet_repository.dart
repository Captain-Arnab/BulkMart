import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class WalletTopUpResult {
  const WalletTopUpResult({
    required this.redirectUrl,
    required this.transactionId,
  });

  final String redirectUrl;
  final String transactionId;
}

abstract class WalletRepository {
  Future<ApiResult<double>> getBalance();
  Future<ApiResult<WalletTopUpResult>> topUpWallet(double amount);
  Future<ApiResult<String>> verifyTopUp(String txnId);
  Future<ApiResult<Map<String, dynamic>>> getTransactions({required int page});
}

class ApiWalletRepository implements WalletRepository {
  ApiWalletRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<double>> getBalance() async {
    final result = await _api.wallet.balance();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final inner = data['data'];
    final raw = inner is Map
        ? inner['balance']
        : data['balance'];
    return ApiSuccess(double.tryParse(raw?.toString() ?? '0') ?? 0);
  }

  @override
  Future<ApiResult<WalletTopUpResult>> topUpWallet(double amount) async {
    final result = await _api.wallet.topUpInitiate(amount: amount);
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final inner = data['data'];
    final map = inner is Map
        ? Map<String, dynamic>.from(inner)
        : data;
    final redirect = map['redirect_url']?.toString() ?? '';
    final txnId = map['transaction_id']?.toString() ??
        map['txn_id']?.toString() ??
        '';
    if (redirect.isEmpty) {
      return const ApiFailure(
        'Payment gateway is not ready yet. Please try again later.',
      );
    }
    return ApiSuccess(
      WalletTopUpResult(redirectUrl: redirect, transactionId: txnId),
    );
  }

  @override
  Future<ApiResult<String>> verifyTopUp(String txnId) =>
      _api.wallet.topUpVerify(txnId: txnId);

  @override
  Future<ApiResult<Map<String, dynamic>>> getTransactions({
    required int page,
  }) =>
      _api.wallet.transactions(page: page);
}
