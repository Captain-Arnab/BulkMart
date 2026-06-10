import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/products/models/Product.dart';

class ProductsController extends GetxController {
  RxList<Product> products = RxList<Product>();
  RxList<Category> categories = RxList<Category>();
  RxList<Map<String, dynamic>> banners = RxList<Map<String, dynamic>>();
  RxBool isLoading = false.obs;
  RxBool isCategoriesLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final _api = UrbanRootsApi.instance;

  Future<List<Category>> fetchCategories() async {
    isCategoriesLoading(true);
    errorMessage.value = '';
    final result = await _api.catalog.listCategories();
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      isCategoriesLoading(false);
      return [];
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final list = parseCategories(data);
    categories.assignAll(list);
    isCategoriesLoading(false);
    return list;
  }

  Future<List<Map<String, dynamic>>> fetchBanners() async {
    final result = await _api.catalog.homeBanners();
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final list = extractList(result.data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      banners.assignAll(list);
      return list;
    }
    return [];
  }

  Future<List<Product>> fetchAllProducts({BuildContext? context}) async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.catalog.listAllProducts();
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      isLoading(false);
      return [];
    }
    final list = parseProducts((result as ApiSuccess).data);
    products.assignAll(list);
    isLoading(false);
    return list;
  }

  Future<List<Product>> fetchProductsByCategory(String categoryId,
      {int page = 1, int limit = 20}) async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.catalog.productsByCategory(
      categoryId: categoryId,
      limit: limit,
      page: page,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      isLoading(false);
      return [];
    }
    final list = parseProducts((result as ApiSuccess).data);
    products.assignAll(list);
    isLoading(false);
    return list;
  }

  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    final result = await _api.catalog.productDetail(productId: productId);
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final data = result.data['data'];
      if (data is Map<String, dynamic>) return data;
      return result.data;
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchProductData(String productId) async {
    final details = await fetchProductById(productId);
    if (details == null) return {};
    return {
      'imageUrl': details['imageUrl'] ?? details['product_image'] ?? '',
      'name': details['name'] ?? details['product_name'] ?? 'Product',
      'description': details['description'] ?? details['product_description'] ?? '',
      'healthBenefits': details['health_benefits'] ?? '',
      'nutritionalInfo': details['nutritional_info'] ?? '',
      'sellingPoints': details['selling_points'] ?? '',
      'price': details['price']?.toString() ?? '0',
    };
  }

  Future<List<Product>> searchProducts({
    required String keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    isLoading(true);
    final result = await _api.catalog.searchProducts(
      keyword: keyword,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      inStock: inStock,
      sort: sort,
      page: page,
      limit: limit,
    );
    isLoading(false);
    if (result is ApiSuccess<Map<String, dynamic>>) {
      return parseProducts(result.data);
    }
    return [];
  }

  Future<List<Product>> listProducts(
    BuildContext context,
    int categoryId,
    double minPrice,
    double maxPrice,
    int? maxGrams,
    int? minGrams,
    String? packingType, {
    int page = 1,
    int pageSize = 20,
  }) async {
    List<Product> productsList;
    if (categoryId == 0) {
      productsList = await fetchAllProducts(context: context);
    } else {
      productsList =
          await fetchProductsByCategory(categoryId.toString(), page: page, limit: pageSize);
    }

    productsList = productsList.where((product) {
      final priceMatch =
          product.priceValue >= minPrice && product.priceValue <= maxPrice;
      var gramsMatch = true;
      if (minGrams != null && maxGrams != null && minGrams > 0 && maxGrams > 0) {
        gramsMatch = product.gramsValue >= minGrams && product.gramsValue <= maxGrams;
      }
      var packingMatch = true;
      if (packingType != null && packingType.isNotEmpty) {
        packingMatch =
            product.packingType.toLowerCase().contains(packingType.toLowerCase());
      }
      return priceMatch && gramsMatch && packingMatch;
    }).toList();

    return productsList;
  }

  Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    return 'Bangalore';
  }
}

class Category {
  final String id;
  final String name;
  final String image;
  final String status;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
  });
}
