import '../../models/product.dart';

/// Demo fruits & vegetables wholesale catalog (no backend required).
///
/// Dummy [Product.price] / [Product.stock] values are display-only placeholders
/// pending real backend pricing & inventory. [Product.batchNo] / [Product.itemCode]
/// are reserved for admin/backend and are intentionally unused in the customer UI.
class MockProducts {
  MockProducts._();

  static String picsumFallback(String slug) =>
      'https://picsum.photos/seed/$slug/400/400';

  static String loremFlickr(String slug) =>
      'https://loremflickr.com/400/400/$slug';

  static const List<ProductCategory> categories = [
    ProductCategory(id: 'all', name: 'All'),
    ProductCategory(id: 'green_vegetables', name: 'Green Vegetables'),
    ProductCategory(id: 'root_vegetables', name: 'Root Vegetables'),
    ProductCategory(id: 'seasonal_fruits', name: 'Seasonal Fruits'),
    ProductCategory(id: 'herbs_leafy', name: 'Herbs & Leafy'),
  ];

  // ---------------------------------------------------------------------------
  // Prices below (₹20–₹120) are DUMMY placeholders pending backend pricing.
  // Description / benefits / storage tips mirror the website PDP tab content.
  // Only a few SKUs carry benefits & storage tips so empty-state fallback can
  // still be exercised in demo mode.
  // ---------------------------------------------------------------------------
  static final List<Product> products = List.unmodifiable(
    _rawProducts.map((p) {
      final extras = _infoExtras[p.id];
      return p.copyWith(
        description: extras?.description ?? _descriptionFor(p),
        benefits: extras?.benefits,
        storageTips: extras?.storageTips,
      );
    }),
  );

  static String _descriptionFor(Product p) {
    return 'Wholesale-grade ${p.name} sourced for restaurants, retailers, and '
        'bulk kitchens. Sold ${p.unit}. Minimum order quantity: ${p.moq} ${p.unitNoun}. '
        'Fresh produce packed for B2B COD delivery.';
  }

  static const Map<String, ({String description, String benefits, String storageTips})>
      _infoExtras = {
    'gv-01': (
      description:
          'Beans are an everyday kitchen vegetable known for their crisp bite and '
          'mild flavour. They work well in curries, stir-fries, salads, and bulk '
          'kitchen prep. VEGGIICART supplies fresh Beans suitable for household '
          'as well as commercial requirements.',
      benefits:
          'Beans naturally provide dietary fibre and plant-based nutrients. '
          'Including fresh beans as part of a balanced diet can support everyday '
          'meal variety for homes and food businesses.',
      storageTips:
          'Store unwashed Beans in a cool, dry place or refrigerate in a breathable '
          'bag. Avoid excess moisture before storage. Wash just before cooking.',
    ),
    'rv-04': (
      description:
          'Potatoes are a versatile staple with a mild flavour and reliable texture '
          'for boiling, frying, curries, and bulk kitchen use. VEGGIICART supplies '
          'fresh Potatoes suitable for household as well as commercial requirements.',
      benefits:
          'Potatoes are a natural source of carbohydrates and provide energy for '
          'everyday meals. They pair well with a wide range of Indian and commercial '
          'kitchen preparations.',
      storageTips:
          'Store Potatoes in a cool, dark, well-ventilated place away from direct '
          'sunlight. Do not refrigerate for everyday storage. Keep dry and separate '
          'from onions when possible.',
    ),
    'sf-01': (
      description:
          'Apples are popular fruits known for their crisp texture, naturally '
          'sweet-tart flavour, and convenient everyday use. They can be eaten fresh '
          'or incorporated into fruit salads, juices, desserts, breakfast '
          'preparations, bakery products, and catering menus.',
      benefits:
          'Apples naturally contain dietary fibre, vitamin C, and various plant '
          'compounds. Eating whole apples with the edible skin, after thorough '
          'washing, can provide more fibre than consuming only strained juice.',
      storageTips:
          'Store Apples in a cool place for short-term use or refrigerate for longer '
          'freshness. Keep away from damaged fruit, as one spoiled apple can affect '
          'surrounding produce. Wash immediately before eating or preparation.',
    ),
    'hl-01': (
      description:
          'Coriander Leaves are a fragrant leafy herb used widely for garnishing, '
          'chutneys, and seasoning. VEGGIICART supplies fresh bunches suitable for '
          'household as well as commercial kitchen use.',
      benefits:
          'Fresh coriander adds aroma and flavour to everyday meals. It is commonly '
          'used across Indian cuisine for finishing dishes and preparing green chutneys.',
      storageTips:
          'Wrap Coriander Leaves loosely in a damp paper towel and refrigerate in a '
          'container or bag. Use promptly for best aroma. Wash before use.',
    ),
  };

  static const List<Product> _rawProducts = [
    // —— Green Vegetables (17) ——
    Product(
      id: 'gv-01',
      name: 'Beans',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 42,
      stock: 280,
      imageUrl: 'https://loremflickr.com/400/400/greenbeans',
    ),
    Product(
      id: 'gv-02',
      name: 'Beans (Chikkudu / Flat Beans)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 48,
      stock: 190,
      imageUrl: 'https://loremflickr.com/400/400/flatbeans',
    ),
    Product(
      id: 'gv-03',
      name: 'Cluster Beans',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 36,
      stock: 220,
      imageUrl: 'https://loremflickr.com/400/400/clusterbeans',
    ),
    Product(
      id: 'gv-04',
      name: 'Ladyfinger (Okra)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 44,
      stock: 310,
      imageUrl: 'https://loremflickr.com/400/400/okra',
    ),
    Product(
      id: 'gv-05',
      name: 'Ivy Gourd',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 38,
      stock: 175,
      imageUrl: 'https://loremflickr.com/400/400/ivygourd,tindora',
    ),
    Product(
      id: 'gv-06',
      name: 'Bittergourd',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 40,
      stock: 200,
      imageUrl: 'https://loremflickr.com/400/400/bittergourd,karela',
    ),
    Product(
      id: 'gv-07',
      name: 'Bottle Gourd',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 12,
      price: 28,
      stock: 260,
      imageUrl: 'https://loremflickr.com/400/400/bottlegourd',
    ),
    Product(
      id: 'gv-08',
      name: 'Drumsticks',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 55,
      stock: 140,
      imageUrl: 'https://loremflickr.com/400/400/drumstick,vegetable',
    ),
    Product(
      id: 'gv-09',
      name: 'Cucumber (English, Black)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 32,
      stock: 350,
      imageUrl: 'https://loremflickr.com/400/400/cucumber',
    ),
    Product(
      id: 'gv-10',
      name: 'Cucumber Yellow (Round)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 34,
      stock: 180,
      imageUrl: 'https://loremflickr.com/400/400/roundcucumber',
    ),
    Product(
      id: 'gv-11',
      name: 'Brinjal (Black)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 30,
      stock: 240,
      imageUrl: 'https://loremflickr.com/400/400/eggplant,black',
    ),
    Product(
      id: 'gv-12',
      name: 'Brinjal (White)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 36,
      stock: 120,
      imageUrl: 'https://loremflickr.com/400/400/eggplant,white',
    ),
    Product(
      id: 'gv-13',
      name: 'Brinjal Long (Purple)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 35,
      stock: 210,
      imageUrl: 'https://loremflickr.com/400/400/eggplant,purple',
    ),
    Product(
      id: 'gv-14',
      name: 'Capsicum Green',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 58,
      stock: 160,
      imageUrl: 'https://loremflickr.com/400/400/greenbellpepper',
    ),
    Product(
      id: 'gv-15',
      name: 'Capsicum Red',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 72,
      stock: 95,
      imageUrl: 'https://loremflickr.com/400/400/redbellpepper',
    ),
    Product(
      id: 'gv-16',
      name: 'Cabbage (Big Size)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 12,
      price: 22,
      stock: 400,
      imageUrl: 'https://loremflickr.com/400/400/cabbage',
    ),
    Product(
      id: 'gv-17',
      name: 'Cabbage (Small Size)',
      category: 'Green Vegetables',
      categoryId: 'green_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 24,
      stock: 320,
      imageUrl: 'https://loremflickr.com/400/400/cabbage,small',
    ),

    // —— Root Vegetables (9) ——
    Product(
      id: 'rv-01',
      name: 'Arvi (Chamagadda)',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 45,
      stock: 150,
      imageUrl: 'https://loremflickr.com/400/400/taroroot',
    ),
    Product(
      id: 'rv-02',
      name: 'Beetroot',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 38,
      stock: 200,
      imageUrl: 'https://loremflickr.com/400/400/beetroot',
    ),
    Product(
      id: 'rv-03',
      name: 'Carrot',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 12,
      price: 40,
      stock: 380,
      imageUrl: 'https://loremflickr.com/400/400/carrot',
    ),
    Product(
      id: 'rv-04',
      name: 'Potato',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 15,
      price: 26,
      stock: 500,
      imageUrl: 'https://loremflickr.com/400/400/potato',
    ),
    Product(
      id: 'rv-05',
      name: 'Onion (Big Size)',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 15,
      price: 28,
      stock: 450,
      imageUrl: 'https://loremflickr.com/400/400/onion',
    ),
    Product(
      id: 'rv-06',
      name: 'Onion (Medium Size)',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 12,
      price: 30,
      stock: 420,
      imageUrl: 'https://loremflickr.com/400/400/onion,medium',
    ),
    Product(
      id: 'rv-07',
      name: 'Onion (Small Size)',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 10,
      price: 32,
      stock: 280,
      imageUrl: 'https://loremflickr.com/400/400/onion,small',
    ),
    Product(
      id: 'rv-08',
      name: 'Garlic',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 95,
      stock: 110,
      imageUrl: 'https://loremflickr.com/400/400/garlic',
    ),
    Product(
      id: 'rv-09',
      name: 'Ginger',
      category: 'Root Vegetables',
      categoryId: 'root_vegetables',
      unit: 'per kg',
      moq: 8,
      price: 88,
      stock: 130,
      imageUrl: 'https://loremflickr.com/400/400/ginger',
    ),

    // —— Herbs & Leafy (2) ——
    Product(
      id: 'hl-01',
      name: 'Coriander Leaves',
      category: 'Herbs & Leafy',
      categoryId: 'herbs_leafy',
      unit: 'per bunch',
      moq: 5,
      price: 20,
      stock: 90,
      imageUrl: 'https://loremflickr.com/400/400/corianderleaves',
    ),
    Product(
      id: 'hl-02',
      name: 'Mint Leaves',
      category: 'Herbs & Leafy',
      categoryId: 'herbs_leafy',
      unit: 'per bunch',
      moq: 5,
      price: 22,
      stock: 75,
      imageUrl: 'https://loremflickr.com/400/400/mintleaves',
    ),

    // —— Seasonal Fruits (5) ——
    Product(
      id: 'sf-01',
      name: 'Apple',
      category: 'Seasonal Fruits',
      categoryId: 'seasonal_fruits',
      unit: 'per kg',
      moq: 8,
      price: 110,
      stock: 160,
      imageUrl: 'https://loremflickr.com/400/400/apple,fruit',
    ),
    Product(
      id: 'sf-02',
      name: 'Avocado',
      category: 'Seasonal Fruits',
      categoryId: 'seasonal_fruits',
      unit: 'per kg',
      moq: 6,
      price: 120,
      stock: 60,
      imageUrl: 'https://loremflickr.com/400/400/avocado',
    ),
    Product(
      id: 'sf-03',
      name: 'Banana',
      category: 'Seasonal Fruits',
      categoryId: 'seasonal_fruits',
      unit: 'per kg',
      moq: 10,
      price: 35,
      stock: 300,
      imageUrl: 'https://loremflickr.com/400/400/banana',
    ),
    Product(
      id: 'sf-04',
      name: 'Papaya',
      category: 'Seasonal Fruits',
      categoryId: 'seasonal_fruits',
      unit: 'per kg',
      moq: 8,
      price: 42,
      stock: 140,
      imageUrl: 'https://loremflickr.com/400/400/papaya',
    ),
    Product(
      id: 'sf-05',
      name: 'Lemon',
      category: 'Seasonal Fruits',
      categoryId: 'seasonal_fruits',
      unit: 'per kg',
      moq: 8,
      price: 50,
      stock: 200,
      imageUrl: 'https://loremflickr.com/400/400/lemon,fruit',
    ),
  ];

  static Product byId(String id) => products.firstWhere((p) => p.id == id);

  static List<Product> byCategory(String categoryId) =>
      products.where((p) => p.categoryId == categoryId).toList();

  static List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List<Product>.from(products);
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q),
        )
        .toList();
  }
}
