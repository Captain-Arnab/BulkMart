import 'package:flutter/material.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/product_description.dart';
import 'package:urban_roots/features/products/models/Product.dart';

void openProductDetails(BuildContext context, Product product) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ProductDetailsPage(
        productVal: product.id,
        preview: product,
      ),
    ),
  );
}
