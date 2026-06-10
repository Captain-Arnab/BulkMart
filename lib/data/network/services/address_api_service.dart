import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class AddressApiService {
  AddressApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> listAddresses() =>
      _client.get(APIClass.getAddresses);

  Future<ApiResult<Map<String, dynamic>>> addAddress({
    required String fullName,
    required String phone,
    required String pincode,
    required String address,
    required String landmark,
    required String city,
    required String state,
    required bool addDefault,
  }) =>
      _client.post(
        APIClass.addAddress,
        body: {
          'full_name': fullName,
          'phone': phone,
          'pincode': pincode,
          'address': address,
          'landmark': landmark,
          'city': city,
          'state': state,
          'add_default': addDefault ? 1 : 0,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> deleteAddress({
    required String addressId,
  }) =>
      _client.post(
        APIClass.deleteAddress,
        body: {'address_id': addressId},
      );

  Future<ApiResult<Map<String, dynamic>>> setDefaultAddress({
    required String id,
  }) =>
      _client.post(
        APIClass.setDefaultAddress,
        body: {'id': id},
      );
}
