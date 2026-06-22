import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/offers_repository.dart';
import 'package:urban_roots/features/offers/models/offer_model.dart';

class OffersViewModel extends ChangeNotifier {
  OffersViewModel({OffersRepository? repository})
      : _repository = repository ?? ApiOffersRepository();

  final OffersRepository _repository;

  UiState<List<OfferModel>> state = const UiLoading();

  Future<void> load() async {
    state = const UiLoading();
    notifyListeners();

    try {
      final offers = await _repository.fetchOffers();
      if (offers.isEmpty) {
        state = const UiError('No offers available right now.');
      } else {
        state = UiSuccess(offers);
      }
    } on OffersRepositoryException catch (e) {
      state = UiError(e.message);
    } catch (_) {
      state = const UiError('Unable to load offers. Please try again.');
    }
    notifyListeners();
  }
}
