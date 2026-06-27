import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';
import 'package:urban_roots/features/admin/services/admin_api_service.dart';

class AdminDeliveryAttendanceController extends GetxController {
  AdminDeliveryAttendanceController({
    required this.deliveryBoyId,
    this.initialName = '',
  });

  final String deliveryBoyId;
  final String initialName;

  final AdminApiService _api = AdminApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final report = Rxn<AttendanceReport>();
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    fromDate.value = DateTime(now.year, now.month, 1);
    toDate.value = now;
    load();
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.deliveryAttendance(
      deliveryBoyId: deliveryBoyId,
      from: fromDate.value != null ? _fmt(fromDate.value!) : null,
      to: toDate.value != null ? _fmt(toDate.value!) : null,
    );
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    report.value = result.data;
  }

  void setRange({DateTime? from, DateTime? to}) {
    if (from != null) fromDate.value = from;
    if (to != null) toDate.value = to;
    load();
  }
}
