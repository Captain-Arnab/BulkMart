import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veggiicart/models/product.dart';
import 'package:veggiicart/views/widgets/category_icons.dart';

void main() {
  test('ProductCategory.fromJson parses image_url', () {
    final cat = ProductCategory.fromJson({
      'id': 1,
      'name': 'Green Vegetables',
      'image_url': 'https://veggiicart.com/public/uploads/categories/test.jpg',
    });
    expect(cat.imageUrl, contains('test.jpg'));
    expect(cat.hasImage, isTrue);
  });

  testWidgets('CategoryCircleImage falls back when image_url is missing', (tester) async {
    const category = ProductCategory(id: '1', name: 'Green Vegetables');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CategoryCircleImage(
              category: category,
              size: 56,
              iconSize: 26,
            ),
          ),
        ),
      ),
    );

    expect(category.hasImage, isFalse);
    expect(find.byType(CategoryIcon), findsOneWidget);
  });

  testWidgets('categoryShortLabel keeps chip labels', (tester) async {
    final categories = [
      ProductCategory.fromJson({
        'id': 1,
        'name': 'Green Vegetables',
        'image_url': 'https://example.com/g.jpg',
      }),
      ProductCategory.fromJson({
        'id': 4,
        'name': 'Herbs & Leafy',
        'image_url': 'https://example.com/h.jpg',
      }),
      ProductCategory.fromJson({
        'id': 2,
        'name': 'Root Vegetables',
        'image_url': 'https://example.com/r.jpg',
      }),
      ProductCategory.fromJson({
        'id': 3,
        'name': 'Seasonal Fruits',
        'image_url': 'https://example.com/f.jpg',
      }),
    ];

    expect(categoryShortLabel(categories[0]), 'Greens');
    expect(categoryShortLabel(categories[1]), 'Herbs');
    expect(categoryShortLabel(categories[2]), 'Roots');
    expect(categoryShortLabel(categories[3]), 'Fruits');
  });
}
