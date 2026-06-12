import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

/// Resolves the delivery city shown on the home header.
/// Uses default address → profile city → Bangalore fallback.
/// Pincode can be validated via [checkPincode] (`/check_pincode.php`).
class DeliveryLocationController extends GetxController {
  DeliveryLocationController({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  static const String defaultCity = 'Bangalore';

  final RxString city = defaultCity.obs;
  final RxString pincode = ''.obs;
  final RxBool isLoading = false.obs;

  static DeliveryLocationController findOrPut() {
    if (Get.isRegistered<DeliveryLocationController>()) {
      return Get.find<DeliveryLocationController>();
    }
    return Get.put(DeliveryLocationController());
  }

  Future<void> resolve() async {
    isLoading.value = true;
    try {
      final fromAddress = await _cityFromAddresses();
      if (fromAddress != null) {
        city.value = fromAddress.city;
        pincode.value = fromAddress.pincode;
        return;
      }

      final fromProfile = await _cityFromProfile();
      if (fromProfile != null && fromProfile.isNotEmpty) {
        city.value = fromProfile;
        return;
      }

      city.value = defaultCity;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Address?> _cityFromAddresses() async {
    final result = await _api.address.listAddresses();
    if (result is! ApiSuccess<Map<String, dynamic>>) return null;

    final addresses = parseAddresses(result.data);
    if (addresses.isEmpty) return null;

    for (final address in addresses) {
      if (address.isDefault && address.city.trim().isNotEmpty) {
        return address;
      }
    }

    final withCity = addresses.where((a) => a.city.trim().isNotEmpty);
    if (withCity.isNotEmpty) return withCity.first;
    return addresses.first;
  }

  Future<String?> _cityFromProfile() async {
    final result = await _api.profile.getProfile();
    if (result is! ApiSuccess<Map<String, dynamic>>) return null;

    final profile = parseProfile(result.data);
    final profileCity = profile['city']?.toString().trim() ?? '';
    return profileCity.isNotEmpty ? profileCity : null;
  }

  /// Validates pincode with backend and updates city when available.
  Future<String?> checkAndSetPincode(String rawPincode) async {
    final pin = rawPincode.trim();
    if (pin.length != 6) return 'Enter a valid 6-digit pincode';

    final result = await _api.catalog.checkPincode(pincode: pin);
    if (result is ApiFailure<Map<String, dynamic>>) {
      return result.message;
    }

    final envelope = (result as ApiSuccess<Map<String, dynamic>>).data;
    final payload = envelope['data'] is Map
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;

    final available = payload['available'] == true ||
        payload['status'] == true ||
        envelope['status'] == true ||
        envelope['success'] == true;

    if (!available) {
      return payload['message']?.toString() ??
          envelope['message']?.toString() ??
          'Delivery is not available for this pincode';
    }

    pincode.value = pin;
    final resolvedCity = payload['city']?.toString().trim() ??
        payload['area']?.toString().trim() ??
        envelope['city']?.toString().trim() ??
        '';
    if (resolvedCity.isNotEmpty) {
      city.value = resolvedCity;
    }
    return null;
  }
}
