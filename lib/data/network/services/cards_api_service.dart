import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class CardsApiService {
  CardsApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  /// Starts PhonePe card-on-file tokenization (₹1 CARD-only checkout).
  Future<ApiResult<Map<String, dynamic>>> save() =>
      _client.post(APIClass.cardsSave);

  /// Finalizes tokenization after PhonePe redirect.
  Future<ApiResult<Map<String, dynamic>>> confirm({
    required String transactionId,
  }) =>
      _client.post(
        APIClass.cardsConfirm,
        body: {'transaction_id': transactionId},
      );

  Future<ApiResult<Map<String, dynamic>>> list() =>
      _client.get(APIClass.cardsList);

  Future<ApiResult<Map<String, dynamic>>> delete({
    required String cardTokenId,
  }) =>
      _client.post(
        APIClass.cardsDelete,
        body: {'card_token_id': cardTokenId},
      );
}
