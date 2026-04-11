import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/products/models/Product.dart';

class ProductsController extends GetxController {
  RxList<Product> products = RxList<Product>();
  RxList<Category> categories = RxList<Category>();
  RxBool isLoading = false.obs;
  RxBool isCategoriesLoading = false.obs;

  Future<List<Category>> fetchCategories() async {
    isCategoriesLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));

    List<Category> categoriesList = DummyData.categories
        .map((c) => Category(
              id: c['id']!,
              name: c['name']!,
              image: c['image']!,
              status: '0',
            ))
        .toList();

    categories.assignAll(categoriesList);
    isCategoriesLoading(false);
    return categoriesList;
  }

  Future<List<Product>> fetchAllProducts({BuildContext? context}) async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));
    List<Product> productsList = List.from(DummyData.products);
    products.assignAll(productsList);
    isLoading(false);
    return productsList;
  }

  Future<List<Product>> fetchProductsByCategory(String categoryId,
      {BuildContext? context}) async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));
    List<Product> productsList = DummyData.getProductsByCategory(categoryId);
    products.assignAll(productsList);
    isLoading(false);
    return productsList;
  }

  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DummyData.getProductDetails(productId);
  }

  Future<Map<String, dynamic>> fetchProductData(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final details = DummyData.getProductDetails(productId);
    return {
      'imageUrl': details['imageUrl'] ?? '',
      'name': details['name'] ?? 'Product',
      'description': details['description'] ?? '',
      'healthBenefits': details['healthBenefits'] ?? '',
      'nutritionalInfo': details['nutritionalInfo'] ?? '',
      'sellingPoints': details['sellingPoints'] ?? '',
    };
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
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 400));
    List<Product> productsList;

    if (categoryId == 0) {
      productsList = List.from(DummyData.products);
    } else {
      productsList = DummyData.getProductsByCategory(categoryId.toString());
    }

    productsList = productsList.where((product) {
      double productPrice = double.tryParse(product.price) ?? 0;
      bool priceMatch = productPrice >= minPrice && productPrice <= maxPrice;

      bool gramsMatch = true;
      if (minGrams != null && maxGrams != null && minGrams > 0 && maxGrams > 0) {
        String gramsStr = product.grams.replaceAll(RegExp(r'[^0-9]'), '');
        int productGrams = int.tryParse(gramsStr) ?? 0;
        gramsMatch = productGrams >= minGrams && productGrams <= maxGrams;
      }

      bool packingMatch = true;
      if (packingType != null && packingType.isNotEmpty) {
        packingMatch =
            product.packingType.toLowerCase().contains(packingType.toLowerCase());
      }

      return priceMatch && gramsMatch && packingMatch;
    }).toList();

    int totalProducts = productsList.length;
    int startIndex = (page - 1) * pageSize;
    int endIndex = startIndex + pageSize;

    if (startIndex < totalProducts) {
      if (endIndex > totalProducts) endIndex = totalProducts;
      productsList = productsList.sublist(startIndex, endIndex);
    } else {
      productsList = [];
    }

    isLoading(false);
    return productsList;
  }

  Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    return "Bangalore";
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
