import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class ReviewsApiService {
  ReviewsApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> listProductReviews({
    required String productId,
  }) =>
      _client.get(
        APIClass.reviewsList,
        token: TokenMode.none,
        queryParameters: {'product_id': productId},
      );

  Future<ApiResult<Map<String, dynamic>>> addReview({
    required String productId,
    required int rating,
    required String review,
  }) =>
      _client.post(
        APIClass.reviewsAdd,
        body: {
          'product_id': productId,
          'rating': rating,
          'review': review,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> vendorReviews({
    required String vendorId,
  }) =>
      _client.get(
        APIClass.vendorReviewsList,
        token: TokenMode.none,
        queryParameters: {'vendor_id': vendorId},
      );
}
