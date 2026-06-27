import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';
import 'package:urban_roots/features/admin/services/admin_api_service.dart';

class AdminDeliveryMonitoringController extends GetxController {
  final AdminApiService _api = AdminApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final boys = <DeliveryMonitorItem>[].obs;
  final selectedDate = Rxn<DateTime>();

  Timer? _autoRefresh;

  int get activeCount => boys.where((b) => b.isActive).length;
  int get inactiveCount => boys.length - activeCount;

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateTime.now();
    load();
    // Auto-refresh every 30 seconds for near real-time monitoring.
    _autoRefresh = Timer.periodic(
      const Duration(seconds: 30),
      (_) => load(silent: true),
    );
  }

  @override
  void onClose() {
    _autoRefresh?.cancel();
    super.onClose();
  }

  String? get _dateParam {
    final d = selectedDate.value;
    if (d == null) return null;
    return DateFormat('yyyy-MM-dd').format(d);
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.deliveryMonitoring(date: _dateParam);
    if (!silent) isLoading.value = false;
    if (result.error != null) {
      // Don't wipe a good list on a silent auto-refresh hiccup.
      if (!silent || boys.isEmpty) errorMessage.value = result.error!;
      return;
    }
    boys.assignAll(result.boys);
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
    load();
  }
}
