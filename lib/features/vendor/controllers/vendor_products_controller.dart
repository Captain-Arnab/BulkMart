import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorProductsController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final products = <VendorProductItem>[].obs;
  final searchQuery = ''.obs;

  /// Active category filter. Empty string = "All".
  final selectedCategory = ''.obs;

  /// Distinct, sorted categories present in the loaded products.
  List<String> get categories {
    final set = <String>{};
    for (final p in products) {
      final c = p.category.trim();
      if (c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<VendorProductItem> get filteredProducts {
    final q = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value.trim().toLowerCase();
    return products.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final matchesCategory =
          cat.isEmpty || p.category.trim().toLowerCase() == cat;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  void setSearch(String value) => searchQuery.value = value;

  void setCategory(String category) => selectedCategory.value = category;

  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.listProducts();
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    products.assignAll(result.products);
  }

  Future<bool> deleteProduct(String productId) async {
    final error = await _api.deleteProduct(productId);
    if (error != null) {
      Get.snackbar('Error', error);
      return false;
    }
    await loadProducts();
    return true;
  }

  Future<bool> addProduct({
    required String name,
    required String price,
    required String category,
    required String stock,
    required String gst,
    required String descriptions,
    String images = '',
    String? imagePath,
  }) async {
    isLoading.value = true;
    final error = await _api.addProduct(
      name: name,
      price: price,
      category: category,
      stock: stock,
      gst: gst,
      descriptions: descriptions,
      images: images,
      imagePath: imagePath,
    );
    isLoading.value = false;
    if (error != null) {
      Get.snackbar('Error', error);
      return false;
    }
    await loadProducts();
    return true;
  }

  Future<bool> updateProduct(Map<String, dynamic> fields) async {
    isLoading.value = true;
    final error = await _api.updateProduct(fields);
    isLoading.value = false;
    if (error != null) {
      Get.snackbar('Error', error);
      return false;
    }
    await loadProducts();
    return true;
  }

  Future<bool> addCategory({
    required String name,
    required String iconName,
    required String categoryIcon,
  }) async {
    final error = await _api.addCategory(
      name: name,
      iconName: iconName,
      categoryIcon: categoryIcon,
    );
    if (error != null) {
      Get.snackbar('Error', error);
      return false;
    }
    Get.snackbar('Success', 'Category added');
    return true;
  }

  VendorProductItem? findProduct(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }
}
