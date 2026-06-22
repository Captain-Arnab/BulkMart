import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/home_repository.dart';
import 'package:urban_roots/features/home/models/home_models.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart'
    show Category;
import 'package:urban_roots/features/products/models/Product.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? ApiHomeRepository();

  final HomeRepository _repository;

  static const int _featuredLimit = 4;
  static const int _categoryProductLimit = 10;

  UiState<HomeUiData> state = const UiLoading();

  Future<void> load() async {
    state = const UiLoading();
    notifyListeners();

    List<Category> categories = [];
    List<Product> featured = [];

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
    ]);

    if (!categoriesOk && featured.isEmpty) {
      state = const UiError(
        'Unable to load home content. Please check your connection and try again.',
      );
      notifyListeners();
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

    state = UiSuccess(
      HomeUiData(
        featuredProducts: featured,
        categorySections: sections,
      ),
    );
    notifyListeners();
  }
}
