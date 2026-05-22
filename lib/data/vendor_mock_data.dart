enum VendorProductStatus { online, draft, outOfStock }

extension VendorProductStatusX on VendorProductStatus {
  String get label {
    switch (this) {
      case VendorProductStatus.online:
        return 'Online';
      case VendorProductStatus.draft:
        return 'Draft';
      case VendorProductStatus.outOfStock:
        return 'Out of Stock';
    }
  }
}

class VendorProduct {
  const VendorProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.status,
    required this.imageAsset,
    this.category = 'Nuts',
    this.gstPercent = 5,
    this.hsnCode = '',
    this.eanCode = '',
    this.weightGrams = 500,
    this.shortDescription = '',
    this.healthBenefits = '',
    this.usp = '',
    this.nutritionalInfo = '',
    this.galleryAssets = const [],
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final VendorProductStatus status;
  final String imageAsset;
  final String category;
  final int gstPercent;
  final String hsnCode;
  final String eanCode;
  final int weightGrams;
  final String shortDescription;
  final String healthBenefits;
  final String usp;
  final String nutritionalInfo;
  final List<String> galleryAssets;

  VendorProduct copyWith({
    String? name,
    double? price,
    int? stock,
    VendorProductStatus? status,
  }) {
    return VendorProduct(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      imageAsset: imageAsset,
      category: category,
      gstPercent: gstPercent,
      hsnCode: hsnCode,
      eanCode: eanCode,
      weightGrams: weightGrams,
      shortDescription: shortDescription,
      healthBenefits: healthBenefits,
      usp: usp,
      nutritionalInfo: nutritionalInfo,
      galleryAssets: galleryAssets,
    );
  }
}

class VendorCategory {
  const VendorCategory({
    required this.id,
    required this.name,
    required this.iconAsset,
  });

  final String id;
  final String name;
  final String iconAsset;
}

class VendorDashboardStats {
  const VendorDashboardStats({
    required this.totalProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalRevenue,
  });

  final int totalProducts;
  final int totalOrders;
  final int pendingOrders;
  final double totalRevenue;
}

class VendorProfile {
  const VendorProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.gstNo,
    required this.panNo,
    required this.fssai,
  });

  final String name;
  final String email;
  final String phone;
  final String gstNo;
  final String panNo;
  final String fssai;
}

class VendorMockData {
  static final List<VendorProduct> products = [
    const VendorProduct(
      id: 'vp1',
      name: 'Premium Pista',
      price: 899,
      stock: 120,
      status: VendorProductStatus.online,
      imageAsset: 'assets/pista_image.png',
      category: 'Nuts',
      gstPercent: 5,
      hsnCode: '08025200',
      weightGrams: 500,
      shortDescription: 'Hand-picked premium pistachios.',
      healthBenefits: 'Rich in protein and healthy fats.',
      usp: 'Farm-direct sourcing',
      nutritionalInfo: 'Per 100g: Protein 20g, Fat 45g',
      galleryAssets: ['assets/pista_cover.jpg', 'assets/slider1.png'],
    ),
    const VendorProduct(
      id: 'vp2',
      name: 'Black Dates',
      price: 349,
      stock: 0,
      status: VendorProductStatus.outOfStock,
      imageAsset: 'assets/black_dates.png',
      category: 'Dry Fruits',
      gstPercent: 5,
      shortDescription: 'Naturally sweet black dates.',
      galleryAssets: ['assets/dates_cover.jpg'],
    ),
    const VendorProduct(
      id: 'vp3',
      name: 'Organic Millet Mix',
      price: 199,
      stock: 45,
      status: VendorProductStatus.draft,
      imageAsset: 'assets/millet.png',
      category: 'Millets',
      gstPercent: 0,
      shortDescription: 'Multi-grain millet blend.',
      galleryAssets: ['assets/millets_cover.jpg'],
    ),
    const VendorProduct(
      id: 'vp4',
      name: 'Herbs Collection',
      price: 249,
      stock: 80,
      status: VendorProductStatus.online,
      imageAsset: 'assets/herbs.png',
      category: 'Herbs',
      gstPercent: 12,
      shortDescription: 'Assorted dried herbs pack.',
      galleryAssets: ['assets/herbs_cover.jpg'],
    ),
  ];

  static final List<VendorCategory> categories = [
    const VendorCategory(id: 'c1', name: 'Nuts', iconAsset: 'assets/nuts_cover.jpg'),
    const VendorCategory(id: 'c2', name: 'Dry Fruits', iconAsset: 'assets/dates_cover.jpg'),
    const VendorCategory(id: 'c3', name: 'Millets', iconAsset: 'assets/millets_cover.jpg'),
    const VendorCategory(id: 'c4', name: 'Herbs', iconAsset: 'assets/herbs_cover.jpg'),
  ];

  static const VendorProfile profile = VendorProfile(
    name: 'Urban Roots Vendor',
    email: 'vendor@urbanroots.com',
    phone: '+91 98765 43210',
    gstNo: '29ABCDE1234F1Z5',
    panNo: 'ABCDE1234F',
    fssai: '12345678901234',
  );

  static VendorDashboardStats dashboardStats({required String period}) {
    switch (period) {
      case 'week':
        return const VendorDashboardStats(
          totalProducts: 24,
          totalOrders: 86,
          pendingOrders: 12,
          totalRevenue: 42850,
        );
      case 'month':
        return const VendorDashboardStats(
          totalProducts: 24,
          totalOrders: 312,
          pendingOrders: 28,
          totalRevenue: 156200,
        );
      default:
        return const VendorDashboardStats(
          totalProducts: 24,
          totalOrders: 18,
          pendingOrders: 5,
          totalRevenue: 9420,
        );
    }
  }
}
