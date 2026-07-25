import '../../models/product.dart';

/// Demo catalog — hardcoded for client walkthroughs (no backend required).
class MockProducts {
  MockProducts._();

  static String picsumFallback(String productName) {
    final slug = productName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'https://picsum.photos/seed/$slug/400/400';
  }

  static const List<ProductCategory> categories = [
    ProductCategory(id: 'all', name: 'All'),
    ProductCategory(id: 'grains', name: 'Grains & Rice'),
    ProductCategory(id: 'oil', name: 'Cooking Oil'),
    ProductCategory(id: 'dal', name: 'Pulses & Dal'),
    ProductCategory(id: 'spices', name: 'Spices'),
    ProductCategory(id: 'dry_fruits', name: 'Dry Fruits'),
  ];

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'Sona Masoori Rice',
      category: 'Grains & Rice',
      categoryId: 'grains',
      unitSize: '25 kg bag',
      unitLabel: 'bag',
      wholesalePrice: 1180,
      moq: 4,
      moqDisplay: '25kg',
      stockCount: 340,
      imageUrl: 'https://loremflickr.com/400/400/rice,sack',
    ),
    Product(
      id: 'p2',
      name: 'Sunflower Oil',
      category: 'Cooking Oil',
      categoryId: 'oil',
      unitSize: '15 L tin',
      unitLabel: 'tin',
      wholesalePrice: 2340,
      moq: 2,
      moqDisplay: '15L',
      stockCount: 120,
      imageUrl: 'https://loremflickr.com/400/400/cookingoil',
    ),
    Product(
      id: 'p3',
      name: 'Toor Dal',
      category: 'Pulses & Dal',
      categoryId: 'dal',
      unitSize: '10 kg pack',
      unitLabel: 'pack',
      wholesalePrice: 1050,
      moq: 3,
      moqDisplay: '10kg',
      stockCount: 210,
      imageUrl: 'https://loremflickr.com/400/400/lentils',
    ),
    Product(
      id: 'p4',
      name: 'Turmeric Powder',
      category: 'Spices',
      categoryId: 'spices',
      unitSize: '5 kg pack',
      unitLabel: 'pack',
      wholesalePrice: 640,
      moq: 5,
      moqDisplay: '5kg',
      stockCount: 95,
      imageUrl: 'https://loremflickr.com/400/400/turmeric,spice',
    ),
    Product(
      id: 'p5',
      name: 'Basmati Rice Premium',
      category: 'Grains & Rice',
      categoryId: 'grains',
      unitSize: '25 kg bag',
      unitLabel: 'bag',
      wholesalePrice: 1850,
      moq: 2,
      moqDisplay: '25kg',
      stockCount: 60,
      imageUrl: 'https://loremflickr.com/400/400/basmatirice',
    ),
    Product(
      id: 'p6',
      name: 'Mustard Oil',
      category: 'Cooking Oil',
      categoryId: 'oil',
      unitSize: '15 L tin',
      unitLabel: 'tin',
      wholesalePrice: 2100,
      moq: 2,
      moqDisplay: '15L',
      stockCount: 88,
      imageUrl: 'https://loremflickr.com/400/400/mustardoil,bottle',
    ),
    Product(
      id: 'p7',
      name: 'Chana Dal',
      category: 'Pulses & Dal',
      categoryId: 'dal',
      unitSize: '10 kg pack',
      unitLabel: 'pack',
      wholesalePrice: 980,
      moq: 3,
      moqDisplay: '10kg',
      stockCount: 150,
      imageUrl: 'https://loremflickr.com/400/400/chickpeas',
    ),
    Product(
      id: 'p8',
      name: 'Red Chilli Powder',
      category: 'Spices',
      categoryId: 'spices',
      unitSize: '5 kg pack',
      unitLabel: 'pack',
      wholesalePrice: 720,
      moq: 5,
      moqDisplay: '5kg',
      stockCount: 40,
      imageUrl: 'https://loremflickr.com/400/400/chillipowder',
    ),
    Product(
      id: 'p9',
      name: 'Cashew Nuts',
      category: 'Dry Fruits',
      categoryId: 'dry_fruits',
      unitSize: '5 kg pack',
      unitLabel: 'pack',
      wholesalePrice: 3200,
      moq: 2,
      moqDisplay: '5kg',
      stockCount: 25,
      imageUrl: 'https://loremflickr.com/400/400/cashew,nuts',
    ),
    Product(
      id: 'p10',
      name: 'Almonds',
      category: 'Dry Fruits',
      categoryId: 'dry_fruits',
      unitSize: '5 kg pack',
      unitLabel: 'pack',
      wholesalePrice: 3600,
      moq: 2,
      moqDisplay: '5kg',
      stockCount: 30,
      imageUrl: 'https://loremflickr.com/400/400/almonds',
    ),
  ];

  static Product byId(String id) => products.firstWhere((p) => p.id == id);
}
