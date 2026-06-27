import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/features/delivery/models/delivery_models.dart';
import 'package:urban_roots/features/delivery/services/delivery_api_service.dart';

class DeliveryWorkLogController extends GetxController {
  final DeliveryApiService _api = DeliveryApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final logs = <WorkLogEntry>[].obs;
  final selectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateTime.now();
    load();
  }

  String? get _dateParam {
    final d = selectedDate.value;
    if (d == null) return null;
    return DateFormat('yyyy-MM-dd').format(d);
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.workLog(date: _dateParam);
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    logs.assignAll(result.logs);
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
    load();
  }
}
