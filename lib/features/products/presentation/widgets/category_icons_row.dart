import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/category_icon_helper.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/all_products.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';

class CategoryIconsRow extends StatefulWidget {
  const CategoryIconsRow({super.key});

  @override
  State<CategoryIconsRow> createState() => _CategoryIconsRowState();
}

class _CategoryIconsRowState extends State<CategoryIconsRow> {
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
          height: 110,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      }

      final categories = _controller.categories;
      if (categories.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final categoryId = int.tryParse(cat.id) ?? 0;
            final hasImage = cat.image.trim().isNotEmpty;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductPage(
                      category: categoryId,
                      minPrice: 0,
                      maxPrice: 2000,
                    ),
                  ),
                );
              },
              child: Container(
                width: 84,
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: hasImage
                            ? NetworkOrAssetImage(
                                url: cat.image,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                categoryFallbackIcon(cat.name),
                                color: AppColors.primary,
                                size: 28,
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
