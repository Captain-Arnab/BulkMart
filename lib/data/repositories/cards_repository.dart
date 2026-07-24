import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/orders/order_payment_utils.dart';
import 'package:urban_roots/features/payments/models/saved_card.dart';

abstract class CardsRepository {
  Future<ApiResult<CardSaveSession>> initiateSave();
  Future<ApiResult<SavedCard>> confirmSave({required String transactionId});
  Future<ApiResult<List<SavedCard>>> listCards();
  Future<ApiResult<void>> deleteCard({required String cardTokenId});
}

class ApiCardsRepository implements CardsRepository {
  ApiCardsRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<CardSaveSession>> initiateSave() async {
    final result = await _api.cards.save();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final url = extractPaymentUrl(data) ??
        data['redirectUrl']?.toString() ??
        data['redirect_url']?.toString() ??
        '';
    if (url.isEmpty) {
      return const ApiFailure('Could not start card save. Please try again.');
    }
    final txnId = extractTxnId(data) ?? '';
    return ApiSuccess(CardSaveSession(redirectUrl: url, transactionId: txnId));
  }

  @override
  Future<ApiResult<SavedCard>> confirmSave({
    required String transactionId,
  }) async {
    final result = await _api.cards.confirm(transactionId: transactionId);
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final cardRaw = data['card'] ??
        (data['data'] is Map
            ? (data['data'] as Map)['card']
            : null);
    if (cardRaw is! Map) {
      return ApiSuccess(
        SavedCard(
          cardTokenId: '',
          maskedNumber: data['message']?.toString() ?? 'Card saved',
          expiryDisplay: '',
          cardNetwork: '',
        ),
      );
    }
    return ApiSuccess(
      SavedCard.fromJson(Map<String, dynamic>.from(cardRaw)),
    );
  }

  @override
  Future<ApiResult<List<SavedCard>>> listCards() async {
    final result = await _api.cards.list();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return ApiSuccess(parseSavedCards(data));
  }

  @override
  Future<ApiResult<void>> deleteCard({required String cardTokenId}) async {
    final result = await _api.cards.delete(cardTokenId: cardTokenId);
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    return const ApiSuccess(null);
  }
}
