import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/repositories/cards_repository.dart';
import 'package:urban_roots/features/payments/models/saved_card.dart';

class CardsController extends GetxController {
  CardsController({CardsRepository? repository})
      : _repository = repository ?? ApiCardsRepository();

  final CardsRepository _repository;

  final RxList<SavedCard> cards = <SavedCard>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> loadCards() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _repository.listCards();
    isLoading(false);

    if (result is ApiFailure<List<SavedCard>>) {
      errorMessage.value = result.message;
      cards.clear();
      return;
    }
    cards.assignAll((result as ApiSuccess<List<SavedCard>>).data);
  }

  Future<ApiResult<CardSaveSession>> startSaveCard() async {
    isSaving(true);
    errorMessage.value = '';
    final result = await _repository.initiateSave();
    isSaving(false);
    if (result is ApiFailure<CardSaveSession>) {
      errorMessage.value = result.message;
    }
    return result;
  }

  Future<ApiResult<SavedCard>> confirmSave({
    required String transactionId,
  }) async {
    final result = await _repository.confirmSave(transactionId: transactionId);
    if (result is ApiSuccess<SavedCard>) {
      await loadCards();
    }
    return result;
  }

  Future<ApiResult<void>> deleteCard(String cardTokenId) async {
    final result = await _repository.deleteCard(cardTokenId: cardTokenId);
    if (result is ApiSuccess<void>) {
      cards.removeWhere((c) => c.cardTokenId == cardTokenId);
    }
    return result;
  }

  static CardsController findOrPut() {
    if (Get.isRegistered<CardsController>()) {
      return Get.find<CardsController>();
    }
    return Get.put(CardsController());
  }
}
