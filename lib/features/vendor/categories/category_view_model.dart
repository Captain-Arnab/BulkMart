import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/vendor_repository.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel({VendorRepository? repository})
      : _repository = repository ?? MockVendorRepository();

  final VendorRepository _repository;
  UiState<List<VendorCategory>> state = const UiLoading();

  Future<void> load() async {
    state = const UiLoading();
    notifyListeners();
    try {
      final list = await _repository.getCategories();
      state = UiSuccess(list);
    } catch (e) {
      state = UiError(e.toString());
    }
    notifyListeners();
  }
}
