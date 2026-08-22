import 'package:flutter/foundation.dart';

import '../models/offer.dart';
import '../repositories/offer_repository.dart';

class OfferViewModel extends ChangeNotifier {
  OfferViewModel({required OfferRepository repository}) : _repository = repository;

  final OfferRepository _repository;

  List<Offer> offers = [];
  List<Offer> featured = [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    final all = await _repository.getAll();
    final feat = await _repository.getFeatured();
    all.when(
      success: (list) => offers = list,
      failure: (message, {statusCode, code, fields}) => error = message,
    );
    feat.when(
      success: (list) => featured = list,
      failure: (message, {statusCode, code, fields}) {
        if (kDebugMode) {
          debugPrint('[OfferViewModel] featured load failed: $message');
        }
      },
    );
    isLoading = false;
    notifyListeners();
  }
}
