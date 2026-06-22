import 'dart:async';

import 'package:get/get.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/location/location_service.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/home/delivery_location_store.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

/// Manages the delivery city shown in the app header.
class DeliveryLocationController extends GetxController {
  DeliveryLocationController({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  static const String defaultCity = 'Bangalore';
  static const Duration _pincodeTimeout = Duration(seconds: 15);
  static const Duration _gpsTimeout = Duration(seconds: 12);

  final RxString city = defaultCity.obs;
  final RxString pincode = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isDetecting = false.obs;

  static DeliveryLocationController findOrPut() {
    if (Get.isRegistered<DeliveryLocationController>()) {
      return Get.find<DeliveryLocationController>();
    }
    return Get.put(DeliveryLocationController());
  }

  Future<void> resolve() async {
    isLoading.value = true;
    try {
      final saved = await DeliveryLocationStore.instance.read();
      if (saved != null) {
        if (saved.pincode.isNotEmpty) pincode.value = saved.pincode;
        if (saved.city.isNotEmpty) city.value = saved.city;
        if (saved.pincode.isNotEmpty || saved.city.isNotEmpty) return;
      }

      if (await AuthSession.instance.isLoggedIn()) {
        final fromAddress = await _cityFromAddresses();
        if (fromAddress != null) {
          city.value = fromAddress.city;
          pincode.value = fromAddress.pincode;
          await _persist();
          return;
        }

        final fromProfile = await _cityFromProfile();
        if (fromProfile != null && fromProfile.isNotEmpty) {
          city.value = fromProfile;
          await _persist();
          return;
        }
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

  Future<String?> detectAndSetFromGps() async {
    isDetecting.value = true;
    try {
      final detected = await LocationService.instance
          .detectCurrentAddress()
          .timeout(_gpsTimeout);
      final detectedPin = detected.pincode.trim();
      if (detectedPin.length != 6) {
        return 'Could not detect pincode from your location. Please enter it manually.';
      }
      final error = await checkAndSetPincode(detectedPin);
      if (error != null) return error;
      if (detected.city.isNotEmpty && city.value.isEmpty) {
        city.value = detected.city;
        await _persist();
      }
      return null;
    } on TimeoutException {
      return 'Location detection timed out. Please try again or enter pincode manually.';
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return message.isNotEmpty
          ? message
          : 'Could not detect location. Please enter pincode manually.';
    } finally {
      isDetecting.value = false;
    }
  }

  Future<String?> checkAndSetPincode(String rawPincode) async {
    final pin = rawPincode.trim();
    if (pin.length != 6) return 'Enter a valid 6-digit pincode';

    try {
      final result = await _api.catalog
          .checkPincode(pincode: pin)
          .timeout(_pincodeTimeout);
      if (result is ApiFailure<Map<String, dynamic>>) {
        return result.message;
      }

      final envelope = (result as ApiSuccess<Map<String, dynamic>>).data;
      final payload = envelope['data'] is Map
          ? Map<String, dynamic>.from(envelope['data'] as Map)
          : envelope;

      final available = payload['available'] == true ||
          payload['serviceable'] == true ||
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
          payload['location']?.toString().trim() ??
          envelope['city']?.toString().trim() ??
          '';
      if (resolvedCity.isNotEmpty) {
        city.value = resolvedCity;
      }
      await _persist();
      return null;
    } on TimeoutException {
      return 'Pincode check timed out. Check your internet and try again.';
    }
  }

  Future<void> _persist() async {
    await DeliveryLocationStore.instance.save(
      pincode: pincode.value,
      city: city.value,
    );
  }
}
