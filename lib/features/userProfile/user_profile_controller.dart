import 'package:get/get.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class UserProfileController extends GetxController {
  final _api = UrbanRootsApi.instance;

  Future<Map<String, dynamic>> fetchUserData([String? custId]) async {
    final result = await _api.profile.getProfile();
    if (result is ApiSuccess<Map<String, dynamic>>) {
      return parseProfile(result.data);
    }
    if (result is ApiFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
    return {};
  }

  Future<ApiResult<Map<String, dynamic>>> updateProfile({
    required String custFname,
    required String custLname,
    required String custEmail,
    required String custMobile,
    required String address,
    required String city,
    required String state,
  }) async {
    var custId = await AuthSession.instance.getUserId() ?? '';
    if (custId.isEmpty) {
      final profile = await fetchUserData();
      custId = profile['cust_id']?.toString() ?? '';
    }
    return _api.profile.updateProfile(
      custId: custId,
      custFname: custFname,
      custLname: custLname,
      custEmail: custEmail,
      custMobile: custMobile,
      address: address,
      city: city,
      state: state,
    );
  }

  Future<void> logout() async {
    try {
      await _api.auth.logout();
    } finally {
      await AuthSession.instance.clear();
    }
  }
}
