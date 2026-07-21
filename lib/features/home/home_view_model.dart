import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/home_repository.dart';
import 'package:urban_roots/data/repositories/offers_repository.dart';
import 'package:urban_roots/features/home/models/home_models.dart';
import 'package:urban_roots/features/offers/models/offer_model.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart'
    show Category;
import 'package:urban_roots/features/products/models/Product.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    HomeRepository? repository,
    OffersRepository? offersRepository,
  })  : _repository = repository ?? ApiHomeRepository(),
        _offersRepository = offersRepository ?? ApiOffersRepository();

  final HomeRepository _repository;
  final OffersRepository _offersRepository;

  static const int _featuredLimit = 6;
  static const int _categoryProductLimit = 10;

  UiState<HomeUiData> state = const UiLoading();

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// notifyListeners that is safe to call after an in-flight async load
  /// completes once the widget (and this view model) has been disposed.
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> load() async {
    if (_disposed) return;
    state = const UiLoading();
    _safeNotify();

    List<Category> categories = [];
    List<Product> featured = [];
    List<OfferModel> offers = [];

    var categoriesOk = false;

    await Future.wait([
      _repository.fetchCategories().then((value) {
        categories = value;
        categoriesOk = true;
      }).catchError((_) {}),
      _repository
          .fetchFeaturedProducts(limit: _featuredLimit)
          .then((value) => featured = value)
          .catchError((_) => featured = <Product>[]),
      _offersRepository.fetchOffers().then((value) => offers = value).catchError(
            (_) => offers = <OfferModel>[],
          ),
    ]);

    if (_disposed) return;

    if (!categoriesOk && featured.isEmpty) {
      state = const UiError(
        'Unable to load home content. Please check your connection and try again.',
      );
      _safeNotify();
      return;
    }

    final sections = <CategorySection>[];
    if (categories.isNotEmpty) {
      final sectionResults = await Future.wait(
        categories.map((category) async {
          try {
            final products = await _repository.fetchProductsByCategory(
              categoryId: category.id,
              limit: _categoryProductLimit,
              page: 1,
            );
            if (products.isEmpty) return null;
            return CategorySection(category: category, products: products);
          } catch (_) {
            return null;
          }
        }),
      );
      sections.addAll(
        sectionResults.whereType<CategorySection>(),
      );
    }

    if (_disposed) return;

    state = UiSuccess(
      HomeUiData(
        categories: categories,
        featuredProducts: featured,
        categorySections: sections,
        offers: offers,
      ),
    );
    _safeNotify();
  }
}
