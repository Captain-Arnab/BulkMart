import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/orders/presentation/OrderHistory.dart';

class DummyData {
  static const String demoUserName = 'Arnab Som';
  static const String demoUserEmail = 'arnab@urbanroots.com';
  static const String demoUserPhone = '+91 97385 50132';
  static const String demoUserId = 'USR001';

  static final List<Map<String, String>> categories = [
    {'id': '1', 'name': 'Nuts & Dry Fruits', 'image': 'assets/nuts_cover.jpg'},
    {'id': '2', 'name': 'Whole Spices', 'image': 'assets/spices_cover.jpg'},
    {'id': '3', 'name': 'Seeds', 'image': 'assets/seeds_cover.jpg'},
    {'id': '4', 'name': 'Herbs', 'image': 'assets/herbs_cover.jpg'},
    {'id': '5', 'name': 'Millets', 'image': 'assets/millets_cover.jpg'},
    {'id': '6', 'name': 'Pulses & Cereals', 'image': 'assets/cereals_cover.jpg'},
    {'id': '7', 'name': 'Dates', 'image': 'assets/dates_cover.jpg'},
  ];

  static const Map<String, String> productImages = {
    '1': 'assets/nuts_cover.jpg',
    '2': 'assets/nuts_cover.jpg',
    '3': 'assets/pista_image.png',
    '4': 'assets/black_dates.png',
    '5': 'assets/spices.png',
    '6': 'assets/spices_cover.jpg',
    '7': 'assets/spices.png',
    '8': 'assets/seeds.png',
    '9': 'assets/seeds_cover.jpg',
    '10': 'assets/millet.png',
    '11': 'assets/millets_cover.jpg',
    '12': 'assets/herbs.png',
    '13': 'assets/cereals.png',
    '14': 'assets/cereals_cover.jpg',
    '15': 'assets/nuts_cover.jpg',
    '16': 'assets/nuts_cover.jpg',
    '17': 'assets/spices.png',
    '18': 'assets/spices_cover.jpg',
    '19': 'assets/seeds.png',
    '20': 'assets/cereals.png',
    '21': 'assets/seeds_cover.jpg',
    '22': 'assets/nuts_cover.jpg',
    '23': 'assets/spices.png',
    '24': 'assets/millets_cover.jpg',
  };

  static String getProductImage(String productId) {
    return productImages[productId] ?? 'assets/sample.png';
  }

  static final List<Product> products = [
    Product(id: '1', name: 'California Almonds Premium', price: '649', grams: '500g', stock: '50', imageUrl: 'assets/nuts_cover.jpg', packingType: 'UNIQUE POUCH', gst: '5'),
    Product(id: '2', name: 'Whole Cashew Nuts W320', price: '799', grams: '500g', stock: '35', imageUrl: 'assets/nuts_cover.jpg', packingType: 'UNIQUE POUCH', gst: '5'),
    Product(id: '3', name: 'Premium Pistachios', price: '899', grams: '250g', stock: '40', imageUrl: 'assets/pista_image.png', packingType: 'Glass Jar', gst: '5'),
    Product(id: '4', name: 'Medjool Dates', price: '549', grams: '500g', stock: '30', imageUrl: 'assets/black_dates.png', packingType: 'UNIQUE POUCH', gst: '5'),
    Product(id: '5', name: 'Kashmiri Saffron', price: '1299', grams: '5g', stock: '20', imageUrl: 'assets/spices.png', packingType: 'Glass Jar', gst: '12'),
    Product(id: '6', name: 'Organic Turmeric Powder', price: '199', grams: '200g', stock: '100', imageUrl: 'assets/spices_cover.jpg', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '7', name: 'Black Pepper Whole', price: '349', grams: '200g', stock: '80', imageUrl: 'assets/spices.png', packingType: 'UNIQUE POUCH', gst: '5'),
    Product(id: '8', name: 'Organic Chia Seeds', price: '299', grams: '250g', stock: '60', imageUrl: 'assets/seeds.png', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '9', name: 'Flax Seeds Golden', price: '179', grams: '500g', stock: '70', imageUrl: 'assets/seeds_cover.jpg', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '10', name: 'Ragi Flour (Finger Millet)', price: '149', grams: '1kg', stock: '90', imageUrl: 'assets/millet.png', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '11', name: 'Foxtail Millet', price: '169', grams: '1kg', stock: '85', imageUrl: 'assets/millets_cover.jpg', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '12', name: 'Dried Rosemary Herbs', price: '249', grams: '100g', stock: '45', imageUrl: 'assets/herbs.png', packingType: 'Glass Jar', gst: '5'),
    Product(id: '13', name: 'Organic Moong Dal', price: '189', grams: '1kg', stock: '110', imageUrl: 'assets/cereals.png', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '14', name: 'Toor Dal Premium', price: '159', grams: '1kg', stock: '120', imageUrl: 'assets/cereals_cover.jpg', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '15', name: 'Walnut Kernels', price: '699', grams: '250g', stock: '25', imageUrl: 'assets/nuts_cover.jpg', packingType: 'UNIQUE POUCH', gst: '5'),
    Product(id: '16', name: 'Dried Figs (Anjeer)', price: '499', grams: '250g', stock: '30', imageUrl: 'assets/nuts_cover.jpg', packingType: 'UNIQUE POUCH', gst: '5'),
    Product(id: '17', name: 'Cinnamon Sticks', price: '279', grams: '100g', stock: '55', imageUrl: 'assets/spices.png', packingType: 'Glass Jar', gst: '5'),
    Product(id: '18', name: 'Cardamom Green Whole', price: '1099', grams: '100g', stock: '40', imageUrl: 'assets/spices_cover.jpg', packingType: 'Glass Jar', gst: '5'),
    Product(id: '19', name: 'Pumpkin Seeds Raw', price: '329', grams: '250g', stock: '50', imageUrl: 'assets/seeds.png', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '20', name: 'Basmati Rice Aged', price: '249', grams: '1kg', stock: '100', imageUrl: 'assets/cereals.png', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '21', name: 'Sunflower Seeds', price: '199', grams: '250g', stock: '65', imageUrl: 'assets/seeds_cover.jpg', packingType: 'COMMON POUCH', gst: '5'),
    Product(id: '22', name: 'Dried Apricots', price: '449', grams: '250g', stock: '25', imageUrl: 'assets/nuts_cover.jpg', packingType: 'UNIQUE POUCH', gst: '5'),
    Product(id: '23', name: 'Cloves Whole', price: '399', grams: '100g', stock: '50', imageUrl: 'assets/spices.png', packingType: 'Glass Jar', gst: '5'),
    Product(id: '24', name: 'Barnyard Millet', price: '159', grams: '500g', stock: '75', imageUrl: 'assets/millets_cover.jpg', packingType: 'COMMON POUCH', gst: '5'),
  ];

  static final Map<String, String> productCategoryMap = {
    '1': '1', '2': '1', '3': '1', '15': '1', '16': '1', '22': '1',
    '5': '2', '6': '2', '7': '2', '17': '2', '18': '2', '23': '2',
    '8': '3', '9': '3', '19': '3', '21': '3',
    '12': '4',
    '10': '5', '11': '5', '24': '5',
    '13': '6', '14': '6', '20': '6',
    '4': '7',
  };

  static List<Product> getProductsByCategory(String categoryId) {
    if (categoryId == '0') return products;
    return products.where((p) => productCategoryMap[p.id] == categoryId).toList();
  }

  static Map<String, dynamic> getProductDetails(String productId) {
    final product = products.firstWhere((p) => p.id == productId, orElse: () => products.first);
    final descriptions = _productDescriptions[productId] ?? _defaultDescription;
    return {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'grams': product.grams,
      'stock': product.stock,
      'imageUrl': product.imageUrl,
      'packingType': product.packingType,
      'gst': product.gst,
      'description': descriptions['description'],
      'healthBenefits': descriptions['healthBenefits'],
      'nutritionalInfo': descriptions['nutritionalInfo'],
      'sellingPoints': descriptions['sellingPoints'],
    };
  }

  static final Map<String, Map<String, String>> _productDescriptions = {
    '1': {
      'description': '<p>Premium California Almonds sourced directly from the finest orchards. These crunchy, naturally sweet almonds are carefully selected for their superior quality and rich flavour.</p>',
      'healthBenefits': '<ul><li>Rich in Vitamin E and antioxidants</li><li>Supports heart health and lowers cholesterol</li><li>Excellent source of protein and healthy fats</li><li>Aids in weight management</li></ul>',
      'nutritionalInfo': '<p><b>Per 100g:</b></p><ul><li>Calories: 579 kcal</li><li>Protein: 21.2g</li><li>Fat: 49.9g</li><li>Carbohydrates: 21.6g</li><li>Fiber: 12.5g</li></ul>',
      'sellingPoints': '<ul><li>100% Natural, no preservatives</li><li>Handpicked premium grade</li><li>Farm-fresh quality guaranteed</li></ul>',
    },
    '2': {
      'description': '<p>Whole Cashew Nuts W320 grade — the gold standard. These creamy, buttery cashews are sourced from the Malabar coast.</p>',
      'healthBenefits': '<ul><li>Rich in heart-healthy monounsaturated fats</li><li>Good source of copper and magnesium</li><li>Boosts immunity and energy levels</li></ul>',
      'nutritionalInfo': '<p><b>Per 100g:</b></p><ul><li>Calories: 553 kcal</li><li>Protein: 18.2g</li><li>Fat: 43.8g</li><li>Carbohydrates: 30.2g</li></ul>',
      'sellingPoints': '<ul><li>W320 Premium Grade</li><li>Zero cholesterol</li><li>Hygienically packed</li></ul>',
    },
    '6': {
      'description': '<p>Organic Turmeric Powder made from freshly harvested Lakadong turmeric, known for its high curcumin content.</p>',
      'healthBenefits': '<ul><li>High curcumin content (7-12%)</li><li>Powerful anti-inflammatory properties</li><li>Boosts immunity naturally</li></ul>',
      'nutritionalInfo': '<p><b>Per 100g:</b></p><ul><li>Calories: 312 kcal</li><li>Protein: 9.7g</li><li>Fat: 3.3g</li><li>Carbohydrates: 67.1g</li></ul>',
      'sellingPoints': '<ul><li>USDA Organic Certified</li><li>Lakadong variety</li><li>Stone-ground for purity</li></ul>',
    },
  };

  static final Map<String, String> _defaultDescription = {
    'description': '<p>Premium quality product sourced from trusted organic farms across India. Carefully processed and packed to retain maximum nutrition and freshness.</p>',
    'healthBenefits': '<ul><li>100% Natural and Chemical-free</li><li>Rich in essential vitamins and minerals</li><li>Supports overall health and wellness</li></ul>',
    'nutritionalInfo': '<p>Detailed nutritional information is available on the product packaging.</p>',
    'sellingPoints': '<ul><li>Premium quality guaranteed</li><li>Farm-to-table freshness</li><li>Eco-friendly packaging</li></ul>',
  };

  static List<Map<String, dynamic>> cartItems = [
    {'product_id': '1', 'name': 'California Almonds Premium', 'price': '649', 'quantity': 2, 'imageUrl': 'assets/nuts_cover.jpg'},
    {'product_id': '6', 'name': 'Organic Turmeric Powder', 'price': '199', 'quantity': 1, 'imageUrl': 'assets/spices_cover.jpg'},
    {'product_id': '8', 'name': 'Organic Chia Seeds', 'price': '299', 'quantity': 1, 'imageUrl': 'assets/seeds.png'},
  ];

  static List<Map<String, dynamic>> wishlistItems = [
    {'user_id': 'USR001', 'product_id': '3', 'name': 'Premium Pistachios', 'price': '899', 'imageUrl': 'assets/pista_image.png'},
    {'user_id': 'USR001', 'product_id': '5', 'name': 'Kashmiri Saffron', 'price': '1299', 'imageUrl': 'assets/spices.png'},
    {'user_id': 'USR001', 'product_id': '15', 'name': 'Walnut Kernels', 'price': '699', 'imageUrl': 'assets/nuts_cover.jpg'},
  ];

  static List<Order> sampleOrders = [
    Order(orderId: 1001, date: "2026-04-05", total: 1847.00, items: [
      OrderItem(name: "California Almonds Premium", quantity: 2, subtotal: 1298.00, imageUrl: "assets/nuts_cover.jpg"),
      OrderItem(name: "Organic Turmeric Powder", quantity: 1, subtotal: 199.00, imageUrl: "assets/spices_cover.jpg"),
      OrderItem(name: "Black Pepper Whole", quantity: 1, subtotal: 349.00, imageUrl: "assets/spices.png"),
    ]),
    Order(orderId: 1002, date: "2026-03-28", total: 1248.00, items: [
      OrderItem(name: "Whole Cashew Nuts W320", quantity: 1, subtotal: 799.00, imageUrl: "assets/nuts_cover.jpg"),
      OrderItem(name: "Dried Figs (Anjeer)", quantity: 1, subtotal: 449.00, imageUrl: "assets/nuts_cover.jpg"),
    ]),
    Order(orderId: 1003, date: "2026-03-15", total: 926.00, items: [
      OrderItem(name: "Organic Chia Seeds", quantity: 1, subtotal: 299.00, imageUrl: "assets/seeds.png"),
      OrderItem(name: "Pumpkin Seeds Raw", quantity: 1, subtotal: 329.00, imageUrl: "assets/seeds.png"),
      OrderItem(name: "Flax Seeds Golden", quantity: 1, subtotal: 179.00, imageUrl: "assets/seeds_cover.jpg"),
      OrderItem(name: "Ragi Flour (Finger Millet)", quantity: 1, subtotal: 149.00, imageUrl: "assets/millet.png"),
    ]),
  ];

  static final List<Map<String, dynamic>> samplePayments = [
    {"id": "pay_UR001A2026Q2", "amount": 184700, "currency": "INR", "status": "captured", "method": "UPI", "email": demoUserEmail, "contact": demoUserPhone, "description": "Payment for Order #1001", "created_at": 1743868200},
    {"id": "pay_UR002B2026Q1", "amount": 124800, "currency": "INR", "status": "captured", "method": "Card", "email": demoUserEmail, "contact": demoUserPhone, "description": "Payment for Order #1002", "created_at": 1743177000},
    {"id": "pay_UR003C2026Q1", "amount": 92600, "currency": "INR", "status": "captured", "method": "Net Banking", "email": demoUserEmail, "contact": demoUserPhone, "description": "Payment for Order #1003", "created_at": 1742054400},
  ];

  static Map<String, dynamic> get userProfile => {
    'name': demoUserName,
    'email': demoUserEmail,
    'phone': demoUserPhone,
    'addresses': ['123, MG Road, Bangalore - 560001'],
  };
}
