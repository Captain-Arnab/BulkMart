import 'package:urban_roots/core/ui/category_icon_helper.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/data/network/api_parsers.dart' show stripHtmlTags;

class Product {
  final String id;
  final String name;
  final String price;
  final String grams;
  final String stock;
  final String imageUrl;
  final String packingType;
  final String gst;
  final String? offerLabel;
  final Map<String, dynamic> rawJson;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.grams,
    required this.stock,
    required this.imageUrl,
    required this.packingType,
    required this.gst,
    this.offerLabel,
    Map<String, dynamic>? rawJson,
  }) : rawJson = rawJson ?? const {};

  factory Product.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    return Product(
      id: json['pd_id']?.toString() ??
          json['product_id']?.toString() ??
          json['id']?.toString() ??
          '',
      name: json['name']?.toString() ??
          json['product_name']?.toString() ??
          '',
      price: json['price']?.toString() ?? '0',
      grams: json['product_grams']?.toString() ??
          json['grams']?.toString() ??
          '0g',
      stock: json['product_stock']?.toString() ??
          json['stock']?.toString() ??
          '0',
      imageUrl: pickImageUrl(json),
      packingType: stripHtmlTags(
        json['packing_type']?.toString() ??
            json['packingType']?.toString() ??
            json['packing']?.toString() ??
            json['package_type']?.toString() ??
            json['pd_packing_type']?.toString() ??
            '',
      ),
      gst: json['gst']?.toString() ?? '0',
      offerLabel: productOfferLabel(map),
      rawJson: map,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pd_id': id,
      'name': name,
      'price': price,
      'product_grams': grams,
      'product_stock': stock,
      'imageUrl': imageUrl,
      'packing_type': packingType,
      'gst': gst,
    };
  }

  // Helper method to get numeric grams value
  int get gramsValue {
    String numericString = grams.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericString) ?? 0;
  }

  // Helper method to get numeric price value
  double get priceValue {
    return double.tryParse(price) ?? 0.0;
  }
}