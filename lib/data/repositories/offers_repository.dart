import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/services/offers_api_service.dart';
import 'package:urban_roots/features/offers/models/offer_model.dart';

abstract class OffersRepository {
  Future<List<OfferModel>> fetchOffers();
}

class ApiOffersRepository implements OffersRepository {
  ApiOffersRepository({OffersApiService? api})
      : _api = api ?? OffersApiService();

  final OffersApiService _api;

  @override
  Future<List<OfferModel>> fetchOffers() async {
    final result = await _api.listOffers();
    if (result is ApiFailure<Map<String, dynamic>>) {
      throw OffersRepositoryException(result.message);
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final raw = data['offers'] ?? data['data'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
        .map((offer) {
          if (offer.imageUrl.isEmpty) return offer;
          return OfferModel(
            offerId: offer.offerId,
            title: offer.title,
            description: offer.description,
            couponCode: offer.couponCode,
            discountPercent: offer.discountPercent,
            validTill: offer.validTill,
            imageUrl: resolveImageUrl(offer.imageUrl),
          );
        })
        .toList();
  }
}

class OffersRepositoryException implements Exception {
  OffersRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
