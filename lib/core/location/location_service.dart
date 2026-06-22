import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class DetectedAddress {
  const DetectedAddress({
    required this.latitude,
    required this.longitude,
    this.addressLine = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.landmark = '',
  });

  final double latitude;
  final double longitude;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final String landmark;
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<Position> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<DetectedAddress> detectCurrentAddress() async {
    final position = await getCurrentPosition();
    return reverseGeocode(position.latitude, position.longitude);
  }

  Future<DetectedAddress> reverseGeocode(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) {
      return DetectedAddress(latitude: lat, longitude: lng);
    }

    final place = placemarks.first;
    final line = [
      place.street,
      place.subLocality,
      place.locality,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

    return DetectedAddress(
      latitude: lat,
      longitude: lng,
      addressLine: line,
      city: place.locality ?? place.subAdministrativeArea ?? '',
      state: place.administrativeArea ?? '',
      pincode: place.postalCode ?? '',
      landmark: place.subLocality ?? '',
    );
  }
}
