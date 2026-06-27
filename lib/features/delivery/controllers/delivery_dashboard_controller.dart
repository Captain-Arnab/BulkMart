import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_roots/features/delivery/services/delivery_api_service.dart';

class DeliveryDashboardController extends GetxController {
  static const _kLastClockIn = 'last_clock_in';

  final DeliveryApiService _api = DeliveryApiService.instance;

  final isClockedIn = false.obs;
  final clockInTime = Rxn<DateTime>();
  final lastSessionHours = RxnString();
  final isProcessing = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kLastClockIn);
    if (stored != null && stored.isNotEmpty) {
      final dt = DateTime.tryParse(stored);
      if (dt != null) {
        clockInTime.value = dt;
        isClockedIn.value = true;
      }
    }
  }

  Future<void> toggleClock() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    errorMessage.value = '';
    final action = isClockedIn.value ? 'clock_out' : 'clock_in';
    final result = await _api.clock(action);
    isProcessing.value = false;

    if (result.error != null) {
      errorMessage.value = result.error!;
      Get.snackbar('Error', result.error!, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final serverTime = DateTime.tryParse(result.data?.time ?? '');

    if (action == 'clock_in') {
      final start = serverTime ?? DateTime.now();
      clockInTime.value = start;
      isClockedIn.value = true;
      lastSessionHours.value = null;
      await prefs.setString(_kLastClockIn, start.toIso8601String());
    } else {
      final start = clockInTime.value;
      final end = serverTime ?? DateTime.now();
      if (start != null) {
        final hours = end.difference(start).inMinutes / 60.0;
        lastSessionHours.value = hours.toStringAsFixed(2);
      }
      isClockedIn.value = false;
      clockInTime.value = null;
      await prefs.remove(_kLastClockIn);
    }
  }
}
