import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class NotificationsController extends GetxController {
  NotificationsController({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  static NotificationsController findOrPut() {
    if (Get.isRegistered<NotificationsController>()) {
      return Get.find<NotificationsController>();
    }
    return Get.put(NotificationsController());
  }

  Future<void> refreshUnreadCount() async {
    isLoading.value = true;
    final result = await _api.notifications.list();
    isLoading.value = false;

    if (result is ApiFailure<Map<String, dynamic>>) {
      unreadCount.value = 0;
      return;
    }

    final items = extractList((result as ApiSuccess).data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    unreadCount.value = items.where((n) {
      final read = n['is_read'];
      return read != 1 && read != true;
    }).length;
  }
}
