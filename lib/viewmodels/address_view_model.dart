import 'package:flutter/foundation.dart';

import '../models/saved_address.dart';

class AddressViewModel extends ChangeNotifier {
  AddressViewModel() {
    _addresses = [
      const SavedAddress(
        id: 'a1',
        label: 'Shop',
        line1: '12, Wholesale Market Road',
        line2: 'Near Mandi Gate',
        city: 'Bengaluru',
        pincode: '560001',
        isDefault: true,
      ),
      const SavedAddress(
        id: 'a2',
        label: 'Warehouse',
        line1: 'Plot 44, Industrial Area Phase 2',
        city: 'Bengaluru',
        pincode: '560058',
      ),
    ];
  }

  List<SavedAddress> _addresses = [];
  SavedAddress? _lastDeleted;
  int? _lastDeletedIndex;

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);

  void upsert(SavedAddress address) {
    final index = _addresses.indexWhere((e) => e.id == address.id);
    var next = List<SavedAddress>.from(_addresses);
    if (address.isDefault) {
      next = next.map((e) => e.copyWith(isDefault: false)).toList();
    }
    if (index >= 0) {
      next[index] = address;
    } else {
      next.add(address);
    }
    _addresses = next;
    notifyListeners();
  }

  SavedAddress? remove(String id) {
    final index = _addresses.indexWhere((e) => e.id == id);
    if (index < 0) return null;
    _lastDeleted = _addresses[index];
    _lastDeletedIndex = index;
    _addresses = List.from(_addresses)..removeAt(index);
    notifyListeners();
    return _lastDeleted;
  }

  void undoDelete() {
    if (_lastDeleted == null || _lastDeletedIndex == null) return;
    final list = List<SavedAddress>.from(_addresses);
    final idx = _lastDeletedIndex!.clamp(0, list.length);
    list.insert(idx, _lastDeleted!);
    _addresses = list;
    _lastDeleted = null;
    _lastDeletedIndex = null;
    notifyListeners();
  }
}
