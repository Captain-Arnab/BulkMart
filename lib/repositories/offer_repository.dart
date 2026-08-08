import '../core/config/app_config.dart';
import '../data/mock/mock_offers.dart';
import '../models/offer.dart';
import '../services/api/api_client.dart';
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

  // ignore: unused_field — reserved for live offer endpoints
  final ApiClient _apiClient;

  @override
  Future<Result<List<Offer>>> getAll() async {
    throw UnimplementedError('ApiOfferRepository.getAll');
  }

  @override
  Future<Result<List<Offer>>> getFeatured() async {
    throw UnimplementedError('ApiOfferRepository.getFeatured');
  }
}
