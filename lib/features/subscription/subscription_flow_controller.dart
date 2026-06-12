import 'package:get/get.dart';

/// Holds the subscription plan the user picked before browsing products.
class SubscriptionFlowController extends GetxController {
  final Rxn<Map<String, dynamic>> selectedPlan = Rxn<Map<String, dynamic>>();

  bool get hasActivePlan => selectedPlan.value != null;

  void selectPlan(Map<String, dynamic> plan) {
    selectedPlan.value = Map<String, dynamic>.from(plan);
  }

  void clear() {
    selectedPlan.value = null;
  }

  static SubscriptionFlowController findOrPut() {
    if (Get.isRegistered<SubscriptionFlowController>()) {
      return Get.find<SubscriptionFlowController>();
    }
    return Get.put(SubscriptionFlowController());
  }
}
