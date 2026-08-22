import '../core/config/app_config.dart';
import '../data/mock/mock_offers.dart';
import '../models/offer.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

abstract class OfferRepository {
  factory OfferRepository({ApiClient? apiClient}) {
    if (AppConfig.kDemoMode) return MockOfferRepository();
    return ApiOfferRepository(apiClient: apiClient!);
  }

  Future<Result<List<Offer>>> getAll();
  Future<Result<List<Offer>>> getFeatured();
}

class MockOfferRepository implements OfferRepository {
  @override
  Future<Result<List<Offer>>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Success(List.unmodifiable(MockOffers.all));
  }

  @override
  Future<Result<List<Offer>>> getFeatured() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return Success(
      List.unmodifiable(MockOffers.all.where((o) => o.featured)),
    );
  }
}

class ApiOfferRepository implements OfferRepository {
  ApiOfferRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<List<Offer>>> _load() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.offers);
      return ApiEnvelope.parse(response, (data) {
        final raw = data is Map && data['offers'] is List
            ? data['offers'] as List
            : const [];
        return raw
            .map((e) => Offer.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<List<Offer>>> getAll() => _load();

  @override
  Future<Result<List<Offer>>> getFeatured() async {
    final all = await _load();
    return all.when(
      success: (list) => Success(list.where((o) => o.featured).toList()),
      failure: (message, {statusCode, code, fields}) => Failure(
        message,
        statusCode: statusCode,
        code: code,
        fields: fields,
      ),
    );
  }
}
