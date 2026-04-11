import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/AppSearchBarWidget.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/image_slider.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/products_slider.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

class ProductScreenNew extends StatefulWidget {
  @override
  _ProductScreenNewState createState() => _ProductScreenNewState();
}

class _ProductScreenNewState extends State<ProductScreenNew> {
  late Future<List<Product>> futureProducts;
  String _currentCity = "Bangalore";
  ProductsController productsController = Get.put(ProductsController());

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() {
    setState(() {
      futureProducts = productsController.listProducts(context, 0, 0, 10000, null, null, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppSearchBarWidget(currentCity: _currentCity),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(height: 170, child: SliderPage()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text("Shop by Category", style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
            ),
            ProductSliderPage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Popular Products", style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                  GestureDetector(
                    onTap: () => BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateEvent(index: 1, category: 0)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF019934).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text("See All", style: GoogleFonts.rubik(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF019934))),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFF019934))));
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 200,
                    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Something went wrong', style: GoogleFonts.rubik(color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: loadProducts, child: const Text('Retry')),
                    ])),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(height: 200, child: Center(child: Text('No products available', style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey))));
                }
                final products = snapshot.data!;
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
                      return GestureDetector(
                        onTap: () => BlocProvider.of<DashboardBloc>(context).add(NavigateToProductDescriptionEvent(productId: product.id)),
                        child: ProductCard(id: int.parse(product.id), name: product.name, grams: product.grams, stock: product.stock, price: product.price, imageUrl: product.imageUrl),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
