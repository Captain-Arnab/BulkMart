import 'package:urban_roots/features/products/data/ProductsController.dart'
    show Category;
import 'package:urban_roots/features/products/models/Product.dart';

class HomeBanner {
  const HomeBanner({
    required this.imageUrl,
    this.link = '',
  });

  final String imageUrl;
  final String link;

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    final link = json['link']?.toString() ??
        json['redirect']?.toString() ??
        json['redirect_url']?.toString() ??
        json['url']?.toString() ??
        '';
    return HomeBanner(
      imageUrl: json['banner_image']?.toString() ??
          json['image']?.toString() ??
          json['image_url']?.toString() ??
          '',
      link: link,
    );
  }
}

class CategorySection {
  const CategorySection({
    required this.category,
    required this.products,
  });

  final Category category;
  final List<Product> products;
}

class HomeUiData {
  const HomeUiData({
    required this.featuredProducts,
    required this.categorySections,
  });

  final List<Product> featuredProducts;
  final List<CategorySection> categorySections;
}
