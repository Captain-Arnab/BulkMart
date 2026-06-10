import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class ProfileApiService {
  ProfileApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> getProfile() =>
      _client.get(APIClass.getProfile);

  /// Known issue: no auth — always send correct cust_id from session.
  Future<ApiResult<Map<String, dynamic>>> updateProfile({
    required String custId,
    required String custFname,
    required String custLname,
    required String custEmail,
    required String custMobile,
    required String address,
    required String city,
    required String state,
  }) =>
      _client.put(
        APIClass.updateProfile,
        token: TokenMode.none,
        body: {
          'cust_id': custId,
          'cust_fname': custFname,
          'cust_lname': custLname,
          'cust_email': custEmail,
          'cust_mobile': custMobile,
          'address': address,
          'city': city,
          'state': state,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> editAddress({
    required String addressId,
    required String fullName,
    required String phone,
    required String pincode,
    required String address,
    required String landmark,
    required String city,
    required String state,
  }) =>
      _client.put(
        APIClass.editAddress,
        body: {
          'address_id': addressId,
          'full_name': fullName,
          'phone': phone,
          'pincode': pincode,
          'address': address,
          'landmark': landmark,
          'city': city,
          'state': state,
        },
      );
}
