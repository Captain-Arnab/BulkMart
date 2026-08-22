import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/saved_address.dart';
import '../repositories/address_repository.dart';
import '../services/location_service.dart';

class AddressViewModel extends ChangeNotifier {
  AddressViewModel({
    required AddressRepository addressRepository,
    LocationService? locationService,
  })  : _addressRepository = addressRepository,
        _locationService = locationService ?? LocationService() {
    load();
  }

  final AddressRepository _addressRepository;
  final LocationService _locationService;

  List<SavedAddress> _addresses = [];
  SavedAddress? _lastDeleted;
  int? _lastDeletedIndex;
  DetectedLocation? detectedLocation;
  bool isLoading = false;
  bool isDetectingLocation = false;
  String? error;

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);

  SavedAddress? get defaultAddress {
    for (final a in _addresses) {
      if (a.isDefault) return a;
    }
    return _addresses.isEmpty ? null : _addresses.first;
  }

  /// Header label for home / cart delivery row.
  String get deliveryLocationLabel {
    if (isDetectingLocation) return 'Detecting location…';
    final delivery = defaultAddress;
    if (delivery != null) {
      return '${delivery.label} · ${delivery.city}';
    }
    if (detectedLocation != null) {
      return detectedLocation!.displayLabel;
    }
    return 'Add delivery address';
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    final result = await _addressRepository.fetchAddresses();
    result.when(
      success: (list) {
        _addresses = List.from(list);
        isLoading = false;
        notifyListeners();
        _detectAndMatchLocation();
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        isLoading = false;
        notifyListeners();
        _detectAndMatchLocation();
      },
    );
  }

  Future<void> detectCurrentLocation() => _detectAndMatchLocation();

  Future<void> _detectAndMatchLocation() async {
    isDetectingLocation = true;
    notifyListeners();

    try {
      final detected = await _locationService
          .detectCurrentLocation()
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
      detectedLocation = detected;
      if (detected != null) {
        await _autoSelectNearestAddress(detected);
      }
    } catch (_) {
      // Keep last known label / saved addresses.
    } finally {
      isDetectingLocation = false;
      notifyListeners();
    }
  }

  Future<void> _autoSelectNearestAddress(DetectedLocation detected) async {
    if (_addresses.isEmpty) return;

    SavedAddress? nearest;
    double nearestDistance = double.infinity;

    for (final address in _addresses) {
      if (address.geoLat == null || address.geoLng == null) continue;
      final distance = Geolocator.distanceBetween(
        detected.latitude,
        detected.longitude,
        address.geoLat!,
        address.geoLng!,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = address;
      }
    }

    if (nearest != null && nearestDistance <= 2000 && !nearest.isDefault) {
      await setDefault(nearest.id);
      return;
    }

    if (nearest == null && detected.locality != null) {
      final city = detected.locality!.toLowerCase();
      SavedAddress? match;
      for (final address in _addresses) {
        if (address.city.toLowerCase() == city) {
          match = address;
          break;
        }
      }
      if (match != null && !match.isDefault) {
        await setDefault(match.id);
      }
    }
  }

  Future<void> setDefault(String id) async {
    final result = await _addressRepository.setDefault(id);
    result.when(
      success: (_) {
        _addresses = _addresses.map((e) => e.copyWith(isDefault: e.id == id)).toList();
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        notifyListeners();
      },
    );
  }

  Future<void> upsert(SavedAddress address) async {
    final result = await _addressRepository.upsert(address);
    result.when(
      success: (saved) {
        final index = _addresses.indexWhere((e) => e.id == saved.id);
        var next = List<SavedAddress>.from(_addresses);
        if (saved.isDefault) {
          next = next.map((e) => e.copyWith(isDefault: false)).toList();
        }
        if (index >= 0) {
          next[index] = saved;
        } else {
          next.add(saved);
        }
        _addresses = next;
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        notifyListeners();
      },
    );
  }

  Future<SavedAddress?> remove(String id) async {
    final index = _addresses.indexWhere((e) => e.id == id);
    if (index < 0) return null;
    final removed = _addresses[index];
    final result = await _addressRepository.delete(id);
    return result.when(
      success: (_) {
        _lastDeleted = removed;
        _lastDeletedIndex = index;
        _addresses = List.from(_addresses)..removeAt(index);
        notifyListeners();
        return removed;
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        notifyListeners();
        return null;
      },
    );
  }

  Future<void> undoDelete() async {
    if (_lastDeleted == null || _lastDeletedIndex == null) return;
    final restored = _lastDeleted!;
    await upsert(restored);
    _lastDeleted = null;
    _lastDeletedIndex = null;
  }

  /// Creates a default "Business Address" from registration fields.
  Future<void> seedFromRegistration({
    required String line1,
    required String pincode,
    String city = 'Bengaluru',
    String? line2,
  }) async {
    final address = SavedAddress(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      label: 'Business Address',
      line1: line1.trim(),
      line2: (line2 == null || line2.trim().isEmpty) ? null : line2.trim(),
      city: city.trim().isEmpty ? 'Bengaluru' : city.trim(),
      pincode: pincode.trim(),
      isDefault: true,
    );
    await upsert(address);
  }
}
