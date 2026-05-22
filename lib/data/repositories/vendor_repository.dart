import 'package:urban_roots/data/vendor_mock_data.dart';

abstract class VendorRepository {
  Future<VendorDashboardStats> getDashboardStats(String period);
  Future<List<VendorProduct>> getProducts();
  Future<VendorProduct?> getProductById(String id);
  Future<void> deleteProduct(String id);
  Future<List<VendorCategory>> getCategories();
  Future<VendorProfile> getProfile();
}

class MockVendorRepository implements VendorRepository {
  final List<VendorProduct> _products =
      List<VendorProduct>.from(VendorMockData.products);

  @override
  Future<VendorDashboardStats> getDashboardStats(String period) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return VendorMockData.dashboardStats(period: period);
  }

  @override
  Future<List<VendorProduct>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return List<VendorProduct>.from(_products);
  }

  @override
  Future<VendorProduct?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<VendorCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<VendorCategory>.from(VendorMockData.categories);
  }

  @override
  Future<VendorProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return VendorMockData.profile;
  }
}
