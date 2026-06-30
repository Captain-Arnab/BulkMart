import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorSupportController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;
  final tickets = <SupportTicket>[].obs;

  Future<void> loadTickets() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.supportTickets();
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    tickets.assignAll(result.tickets);
  }

  /// Returns the new ticket id on success, or an error message on failure.
  Future<({String? ticketId, String? error})> raiseTicket({
    required String subject,
    required String message,
    String? payoutId,
  }) async {
    isSubmitting.value = true;
    final result = await _api.raiseTicket(
      subject: subject,
      message: message,
      payoutId: payoutId,
    );
    isSubmitting.value = false;
    if (result.error == null) {
      await loadTickets();
    }
    return result;
  }
}
