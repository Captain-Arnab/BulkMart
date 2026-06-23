class VendorDashboardData {
  const VendorDashboardData({
    this.ordersToday = '0',
    this.revenue = '0',
    this.isOpen = true,
  });

  final String ordersToday;
  final String revenue;
  final bool isOpen;

  factory VendorDashboardData.fromJson(Map<String, dynamic> json) {
    return VendorDashboardData(
      ordersToday: json['orders_today']?.toString() ?? '0',
      revenue: json['revenue']?.toString() ?? '0',
      isOpen: json['is_open']?.toString() != '0',
    );
  }
}

class VendorProductItem {
  const VendorProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.gst,
    required this.descriptions,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final String price;
  final String category;
  final String stock;
  final String gst;
  final String descriptions;
  final String imageUrl;

  factory VendorProductItem.fromJson(Map<String, dynamic> json) {
    return VendorProductItem(
      id: json['product_id']?.toString() ??
          json['id']?.toString() ??
          json['prod_id']?.toString() ??
          '',
      name: json['name']?.toString() ?? json['product_name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      category: json['category']?.toString() ?? '',
      stock: json['stock']?.toString() ?? '0',
      gst: json['gst']?.toString() ?? '0',
      descriptions: json['descriptions']?.toString() ??
          json['description']?.toString() ??
          '',
      imageUrl: json['image']?.toString() ??
          json['images']?.toString() ??
          json['image_url']?.toString() ??
          '',
    );
  }
}

class VendorOrderItem {
  const VendorOrderItem({
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.status,
  });

  final String orderId;
  final String customerName;
  final String amount;
  final String status;

  factory VendorOrderItem.fromJson(Map<String, dynamic> json) {
    return VendorOrderItem(
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ??
          json['cust_name']?.toString() ??
          json['name']?.toString() ??
          'Customer',
      amount: json['amount']?.toString() ??
          json['total']?.toString() ??
          json['order_total']?.toString() ??
          '0',
      status: json['status']?.toString() ??
          json['order_status']?.toString() ??
          '',
    );
  }

  bool get isPending {
    final s = status.toLowerCase();
    return s.contains('pending') || s.contains('placed');
  }
}

class VendorEarningsData {
  const VendorEarningsData({
    this.earnings = '0',
    this.payouts = const [],
  });

  final String earnings;
  final List<String> payouts;

  factory VendorEarningsData.fromJson(Map<String, dynamic> json) {
    final rawPayouts = json['payouts'];
    final payouts = <String>[];
    if (rawPayouts is List) {
      for (final item in rawPayouts) {
        if (item is Map) {
          payouts.add(item.values.map((e) => e.toString()).join(' · '));
        } else {
          payouts.add(item.toString());
        }
      }
    } else if (rawPayouts != null) {
      payouts.add(rawPayouts.toString());
    }
    return VendorEarningsData(
      earnings: json['earnings']?.toString() ?? '0',
      payouts: payouts,
    );
  }
}

class VendorProfileData {
  const VendorProfileData({required this.fields});

  final Map<String, String> fields;

  factory VendorProfileData.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'];
    final map = vendor is Map
        ? Map<String, dynamic>.from(vendor)
        : Map<String, dynamic>.from(json);
    return VendorProfileData(
      fields: map.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
  }
}

class VendorDirectoryItem {
  const VendorDirectoryItem({required this.name, required this.status});

  final String name;
  final String status;

  factory VendorDirectoryItem.fromJson(Map<String, dynamic> json) {
    return VendorDirectoryItem(
      name: json['name']?.toString() ??
          json['vendor_name']?.toString() ??
          'Vendor',
      status: json['status']?.toString() ?? '',
    );
  }
}

List<T> parseList<T>(
  Map<String, dynamic> envelope,
  String listKey,
  T Function(Map<String, dynamic>) fromJson,
) {
  dynamic raw = envelope[listKey];
  if (raw == null && envelope['data'] is Map) {
    raw = (envelope['data'] as Map)[listKey];
  }
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => fromJson(Map<String, dynamic>.from(e)))
      .toList();
}
