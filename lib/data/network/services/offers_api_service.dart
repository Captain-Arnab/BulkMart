import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class OffersApiService {
  OffersApiService({ApiClient? client}) : _client = client ?? ApiClient.site;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> listOffers() =>
      _client.get(APIClass.offersList, token: TokenMode.none);
}
