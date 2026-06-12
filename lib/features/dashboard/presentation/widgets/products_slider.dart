import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/all_products.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';

class ProductSliderPage extends StatefulWidget {
  const ProductSliderPage({super.key});

  @override
  State<ProductSliderPage> createState() => _ProductSliderPageState();
}

class _ProductSliderPageState extends State<ProductSliderPage> {
  final _controller = Get.put(ProductsController());

  @override
  void initState() {
    super.initState();
    _controller.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isCategoriesLoading.value) {
        return const SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF019934),
            ),
          ),
        );
      }

      final categories = _controller.categories;
      if (categories.isEmpty) {
        final message = _controller.errorMessage.value;
        return SizedBox(
          height: 120,
          child: Center(
            child: message.isEmpty
                ? Text(
                    'No categories yet',
                    style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: _controller.fetchCategories,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
          ),
        );
      }

      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final categoryId = int.tryParse(cat.id) ?? 0;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(
                      category: categoryId,
                      minPrice: 0,
                      maxPrice: 2000,
                    ),
                  ),
                );
              },
              child: Container(
                width: 90,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: NetworkOrAssetImage(
                          url: cat.image,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
