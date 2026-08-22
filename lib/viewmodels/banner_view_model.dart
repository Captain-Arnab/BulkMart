import 'package:flutter/foundation.dart';

import '../models/home_banner.dart';
import '../repositories/banner_repository.dart';

class BannerViewModel extends ChangeNotifier {
  BannerViewModel({required BannerRepository repository})
      : _repository = repository;

  final BannerRepository _repository;

  List<HomeBanner> banners = [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _repository.getActive();
    result.when(
      success: (list) {
        banners = list;
        if (kDebugMode) {
          debugPrint('[BannerViewModel] loaded ${banners.length} banner(s)');
        }
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        banners = [];
        if (kDebugMode) {
          debugPrint('[BannerViewModel] load failed: $message');
        }
      },
    );

    isLoading = false;
    notifyListeners();
  }
}
