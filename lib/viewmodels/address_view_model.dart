import 'package:flutter/foundation.dart';

import '../models/saved_address.dart';
import '../repositories/address_repository.dart';

class AddressViewModel extends ChangeNotifier {
  AddressViewModel({required AddressRepository addressRepository})
      : _addressRepository = addressRepository {
    load();
  }

  final AddressRepository _addressRepository;

  List<SavedAddress> _addresses = [];
  SavedAddress? _lastDeleted;
  int? _lastDeletedIndex;
  bool isLoading = false;
  String? error;

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);

  SavedAddress? get defaultAddress {
    for (final a in _addresses) {
      if (a.isDefault) return a;
    }
    return _addresses.isEmpty ? null : _addresses.first;
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
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> setDefault(String id) async {
    final result = await _addressRepository.setDefault(id);
    result.when(
      success: (_) {
        _addresses = _addresses.map((e) => e.copyWith(isDefault: e.id == id)).toList();
        notifyListeners();
      },
      failure: (message, {statusCode}) {
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
      failure: (message, {statusCode}) {
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
      failure: (message, {statusCode}) {
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
