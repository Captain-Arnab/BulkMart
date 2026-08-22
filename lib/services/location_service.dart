import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

/// GPS position plus a human-readable place label for delivery UI.
class DetectedLocation {
  const DetectedLocation({
    required this.latitude,
    required this.longitude,
    required this.displayLabel,
    this.locality,
    this.subLocality,
    this.adminArea,
  });

  final double latitude;
  final double longitude;
  final String displayLabel;
  final String? locality;
  final String? subLocality;
  final String? adminArea;
}

/// Structured address fields from GPS + reverse geocoding for address forms.
class AddressLocationDetails {
  const AddressLocationDetails({
    required this.latitude,
    required this.longitude,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.summary,
  });

  final double latitude;
  final double longitude;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String summary;
}

class LocationService {
  LocationService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<DetectedLocation?> detectCurrentLocation() async {
    final details = await detectAddressFromCurrentLocation();
    if (details == null) return null;
    return DetectedLocation(
      latitude: details.latitude,
      longitude: details.longitude,
      displayLabel: details.summary,
      locality: details.city,
      subLocality: details.line2,
      adminArea: details.state,
    );
  }

  Future<AddressLocationDetails?> detectAddressFromCurrentLocation() async {
    if (!await ensurePermission()) return null;

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    ).timeout(const Duration(seconds: 8));

    return _reverseGeocodeAddress(pos.latitude, pos.longitude);
  }

  Future<AddressLocationDetails?> _reverseGeocodeAddress(
    double lat,
    double lon,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'VeggiiCart/1.0 (delivery-location)'},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final data = response.data;
      if (data == null) return null;

      final address = data['address'];
      if (address is Map) {
        final parsed = _parseAddressMap(
          Map<String, dynamic>.from(address),
          lat,
          lon,
          data['display_name']?.toString(),
        );
        if (parsed != null) return parsed;
      }

      final displayName = data['display_name']?.toString();
      if (displayName != null && displayName.isNotEmpty) {
        return AddressLocationDetails(
          latitude: lat,
          longitude: lon,
          line1: displayName.split(',').first.trim(),
          city: '',
          state: '',
          pincode: '',
          summary: displayName,
        );
      }
    } catch (_) {
      // Fall back below.
    }
    return null;
  }

  AddressLocationDetails? _parseAddressMap(
    Map<String, dynamic> address,
    double lat,
    double lon,
    String? displayName,
  ) {
    final houseNumber = _firstNonEmpty([address['house_number']]);
    final road = _firstNonEmpty([address['road'], address['pedestrian']]);
    final subLocality = _firstNonEmpty([
      address['suburb'],
      address['neighbourhood'],
      address['quarter'],
      address['residential'],
    ]);
    final city = _firstNonEmpty([
      address['city'],
      address['town'],
      address['village'],
      address['county'],
      address['city_district'],
    ]);
    final state = _firstNonEmpty([
      address['state'],
      address['state_district'],
    ]);
    final postcodeRaw = address['postcode']?.toString();
    final rawPostcode = postcodeRaw?.replaceAll(RegExp(r'\D'), '') ?? '';
    final pincode = rawPostcode.length >= 6
        ? rawPostcode.substring(0, 6)
        : rawPostcode;

    final line1Parts = <String>[
      if (houseNumber != null) houseNumber,
      if (road != null) road,
    ];
    var line1 = line1Parts.join(', ');
    if (line1.isEmpty) {
      line1 = subLocality ?? displayName?.split(',').first.trim() ?? '';
    }

    final line2 = subLocality != null && line1 != subLocality ? subLocality : null;

    final summaryParts = <String>[
      if (line1.isNotEmpty) line1,
      if (line2 != null) line2,
      if (city != null) city,
      if (state != null) state,
      if (pincode.isNotEmpty) pincode,
    ];

    if (line1.isEmpty && summaryParts.isEmpty) return null;

    return AddressLocationDetails(
      latitude: lat,
      longitude: lon,
      line1: line1,
      line2: line2,
      city: city ?? '',
      state: state ?? '',
      pincode: pincode,
      summary: summaryParts.isNotEmpty
          ? summaryParts.join(', ')
          : displayName ?? 'Current location',
    );
  }

  String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }
}
