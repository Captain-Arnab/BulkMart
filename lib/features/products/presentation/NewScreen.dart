import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/AppSearchBarWidget.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/image_slider.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/products_slider.dart';
import 'package:urban_roots/features/home/delivery_location_controller.dart';
import 'package:urban_roots/features/notifications/notifications_controller.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

class ProductScreenNew extends StatefulWidget {
  const ProductScreenNew({super.key});

  @override
  State<ProductScreenNew> createState() => _ProductScreenNewState();
}

class _ProductScreenNewState extends State<ProductScreenNew> {
  final ProductsController _productsController = Get.put(ProductsController());
  final DeliveryLocationController _locationController =
      DeliveryLocationController.findOrPut();
  final NotificationsController _notificationsController =
      NotificationsController.findOrPut();

  @override
  void initState() {
    super.initState();
    _bootstrapHome();
  }

  Future<void> _bootstrapHome() async {
    await Future.wait([
      _locationController.resolve(),
      _notificationsController.refreshUnreadCount(),
      _productsController.fetchAllProducts(context: context),
      _productsController.fetchCategories(),
      _productsController.fetchBanners(),
    ]);
  }

  Future<void> _refreshHome() async {
    await _bootstrapHome();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const AppSearchBarWidget(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refreshHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const SizedBox(height: 170, child: SliderPage()),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SectionHeader(title: 'Shop by Category'),
              ),
              const ProductSliderPage(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SectionHeader(
                  title: 'Popular Products',
                  action: 'See All',
                  onActionTap: () => DashboardController.findOrPut().goToTab(1),
                ),
              ),
              Obx(() {
                if (_productsController.isLoading.value) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (_productsController.errorMessage.value.isNotEmpty) {
                  return SizedBox(
                    height: 220,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _productsController.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubik(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _refreshHome,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = _productsController.products;
                if (products.isEmpty) {
                  return SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        'No products available',
                        style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                final displayCount = products.length < 6 ? products.length : 6;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: displayCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: screenWidth < 400 ? 0.65 : 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        id: int.tryParse(product.id) ?? 0,
                        name: product.name,
                        grams: product.grams,
                        stock: product.stock,
                        price: product.price,
                        imageUrl: product.imageUrl,
                        onProductTap: () => openProductDetails(context, product),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
