import 'package:flutter/material.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/home/presentation/category_products_screen.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

class HomeHorizontalProductRow extends StatelessWidget {
  const HomeHorizontalProductRow({
    super.key,
    required this.products,
    this.categoryId,
    this.categoryName,
    this.sectionTitle,
    this.showSeeAll = false,
    this.onSeeAll,
  });

  final List<Product> products;
  final String? categoryId;
  final String? categoryName;
  final String? sectionTitle;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  static const double _cardWidth = 168;
  static const double _rowHeight = 260;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SectionHeader(
              title: sectionTitle!,
              action: showSeeAll ? 'See All' : null,
              onActionTap: showSeeAll
                  ? (onSeeAll ??
                      (categoryId != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryProductsScreen(
                                    categoryId: categoryId!,
                                    categoryName:
                                        categoryName ?? sectionTitle!,
                                  ),
                                ),
                              );
                            }
                          : null))
                  : null,
            ),
          ),
        SizedBox(
          height: _rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: _cardWidth,
                child: ProductCard(
                  id: int.tryParse(product.id) ?? 0,
                  name: product.name,
                  grams: product.grams,
                  stock: product.stock,
                  price: product.price,
                  imageUrl: product.imageUrl,
                  offerLabel: product.offerLabel,
                  onProductTap: () => openProductDetails(context, product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
