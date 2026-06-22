import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the user's chosen delivery pincode and city across app restarts.
class DeliveryLocationStore {
  DeliveryLocationStore._();
  static final DeliveryLocationStore instance = DeliveryLocationStore._();

  static const _keyPincode = 'delivery_pincode';
  static const _keyCity = 'delivery_city';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<({String pincode, String city})?> read() async {
    final pincode = (await _storage.read(key: _keyPincode))?.trim() ?? '';
    final city = (await _storage.read(key: _keyCity))?.trim() ?? '';
    if (pincode.isEmpty && city.isEmpty) return null;
    return (pincode: pincode, city: city);
  }

  Future<void> save({required String pincode, required String city}) async {
    await _storage.write(key: _keyPincode, value: pincode.trim());
    await _storage.write(key: _keyCity, value: city.trim());
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyPincode);
    await _storage.delete(key: _keyCity);
  }
}
