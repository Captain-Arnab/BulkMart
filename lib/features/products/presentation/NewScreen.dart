import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/AppSearchBarWidget.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/image_slider.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/products_slider.dart';
import 'package:urban_roots/features/home/domain/delivery_location_controller.dart';
import 'package:urban_roots/features/notifications/domain/notifications_controller.dart';
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
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: const AppSearchBarWidget(),
      body: RefreshIndicator(
        color: const Color(0xFF019934),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Shop by Category',
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const ProductSliderPage(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Products',
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => BlocProvider.of<DashboardBloc>(context)
                          .add(DashboardUpdateEvent(index: 1, category: 0)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF019934).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'See All',
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF019934),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (_productsController.isLoading.value) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF019934)),
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
