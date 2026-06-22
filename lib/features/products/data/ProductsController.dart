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
    final id = productId.trim();
    if (id.isEmpty) {
      errorMessage.value = 'Invalid product ID';
      return null;
    }

    final result = await _api.catalog.productDetail(productId: id);
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      return null;
    }
    errorMessage.value = '';
    final envelope = (result as ApiSuccess<Map<String, dynamic>>).data;
    dynamic raw = envelope['data'] ?? envelope['product'] ?? envelope;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  Map<String, dynamic> _previewFromProduct(Product product) {
    return parseProductDetail({
      'pd_id': product.id,
      'name': product.name,
      'price': product.price,
      'product_grams': product.grams,
      'product_stock': product.stock,
      'main_image': product.imageUrl,
      'packing_type': product.packingType,
      'gst': product.gst,
    });
  }

  Future<Map<String, dynamic>> fetchProductData(
    String productId, {
    Product? preview,
  }) async {
    final details = await fetchProductById(productId);
    if (details != null && details.isNotEmpty) {
      return parseProductDetail(details);
    }

    if (preview != null) {
      return _previewFromProduct(preview);
    }

    final cached = products.where((p) => p.id == productId.trim());
    if (cached.isNotEmpty) {
      return _previewFromProduct(cached.first);
    }

    return {};
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
