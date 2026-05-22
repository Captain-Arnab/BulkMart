import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/vendor_repository.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';

class VendorProfileViewModel extends ChangeNotifier {
  VendorProfileViewModel({VendorRepository? repository})
      : _repository = repository ?? MockVendorRepository();

  final VendorRepository _repository;
  UiState<VendorProfile> state = const UiLoading();

  Future<void> load() async {
    state = const UiLoading();
    notifyListeners();
    try {
      final profile = await _repository.getProfile();
      state = UiSuccess(profile);
    } catch (e) {
      state = UiError(e.toString());
    }
    notifyListeners();
  }
}
