import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/vendor_repository.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';

class VendorDashboardViewModel extends ChangeNotifier {
  VendorDashboardViewModel({VendorRepository? repository})
      : _repository = repository ?? MockVendorRepository();

  final VendorRepository _repository;

  UiState<VendorDashboardStats> state = const UiLoading();
  String selectedPeriod = 'today';

  Future<void> load({String? period}) async {
    if (period != null) selectedPeriod = period;
    state = const UiLoading();
    notifyListeners();
    try {
      final stats = await _repository.getDashboardStats(selectedPeriod);
      state = UiSuccess(stats);
    } catch (e) {
      state = UiError(e.toString());
    }
    notifyListeners();
  }
}
