import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

/// Shows up to 4 featured products in a 2×2 grid with add-to-cart.
class HomeFeaturedGrid extends StatelessWidget {
  const HomeFeaturedGrid({
    super.key,
    required this.products,
    this.onViewAll,
  });

  final List<Product> products;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final featured = products.take(4).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Popular Picks',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featured.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = featured[index];
              return ProductCard(
                id: int.tryParse(product.id) ?? 0,
                name: product.name,
                grams: product.grams,
                stock: product.stock,
                price: product.price,
                imageUrl: product.imageUrl,
                offerLabel: product.offerLabel,
                onProductTap: () => openProductDetails(context, product),
              );
            },
          ),
        ),
        if (onViewAll != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
