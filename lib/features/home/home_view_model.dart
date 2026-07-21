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
  /// Cap home rows — remaining categories are still reachable via Products tab.
  static const int _maxHomeSections = 8;
  /// Limit parallel category fetches to avoid flooding the network/UI isolate.
  static const int _categoryConcurrency = 3;

  UiState<HomeUiData> state = const UiLoading();

  bool _disposed = false;
  int _loadGeneration = 0;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void _publish({
    required List<Category> categories,
    required List<Product> featured,
    required List<CategorySection> sections,
    required List<OfferModel> offers,
    bool sectionsLoading = false,
  }) {
    if (_disposed) return;
    state = UiSuccess(
      HomeUiData(
        categories: categories,
        featuredProducts: featured,
        categorySections: sections,
        offers: offers,
        sectionsLoading: sectionsLoading,
      ),
    );
    _safeNotify();
  }

  Future<void> load() async {
    if (_disposed) return;
    final generation = ++_loadGeneration;

    state = const UiLoading();
    _safeNotify();

    List<Category> categories = [];
    List<OfferModel> offers = [];
    var categoriesOk = false;

    // Phase 1 — lightweight shell (categories + offers). Avoids waiting on the
    // huge get-product.php payload and every category row before first paint.
    await Future.wait([
      _repository.fetchCategories().then((value) {
        categories = value;
        categoriesOk = true;
      }).catchError((_) {}),
      _offersRepository.fetchOffers().then((value) => offers = value).catchError(
            (_) => offers = <OfferModel>[],
          ),
    ]);

    if (_disposed || generation != _loadGeneration) return;

    if (!categoriesOk) {
      state = const UiError(
        'Unable to load home content. Please check your connection and try again.',
      );
      _safeNotify();
      return;
    }

    _publish(
      categories: categories,
      featured: const [],
      sections: const [],
      offers: offers,
      sectionsLoading: categories.isNotEmpty,
    );

    // Phase 2 — category rows in small batches; featured taken from the first
    // non-empty batch (no 400KB+ listAllProducts download).
    final sections = <CategorySection>[];
    var featured = <Product>[];
    final toLoad = categories.take(_maxHomeSections).toList();

    for (var i = 0; i < toLoad.length; i += _categoryConcurrency) {
      if (_disposed || generation != _loadGeneration) return;

      final batch = toLoad.skip(i).take(_categoryConcurrency).toList();
      final batchResults = await Future.wait(
        batch.map((category) async {
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

      if (_disposed || generation != _loadGeneration) return;

      for (final section in batchResults.whereType<CategorySection>()) {
        sections.add(section);
        if (featured.isEmpty) {
          featured = section.products.take(_featuredLimit).toList();
        }
      }

      final moreRemaining = i + _categoryConcurrency < toLoad.length;
      _publish(
        categories: categories,
        featured: featured,
        sections: List<CategorySection>.from(sections),
        offers: offers,
        sectionsLoading: moreRemaining,
      );

      // Yield so frames can paint between batches.
      await Future<void>.delayed(Duration.zero);
    }

    if (_disposed || generation != _loadGeneration) return;

    _publish(
      categories: categories,
      featured: featured,
      sections: sections,
      offers: offers,
      sectionsLoading: false,
    );
  }
}
