class BestSellingProduct {
  const BestSellingProduct({
    required this.productId,
    required this.name,
    required this.totalSold,
    required this.revenue,
  });

  final String productId;
  final String name;
  final String totalSold;
  final String revenue;

  /// total_sold parsed as a number for charts (0 if not numeric).
  double get totalSoldValue => double.tryParse(totalSold) ?? 0;

  factory BestSellingProduct.fromJson(Map<String, dynamic> json) {
    return BestSellingProduct(
      productId: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['product_name']?.toString() ?? '',
      totalSold: json['total_sold']?.toString() ?? '0',
      revenue: json['revenue']?.toString() ?? '0',
    );
  }
}

class VendorDashboardData {
  const VendorDashboardData({
    this.ordersToday = '0',
    this.revenue = '0',
    this.isOpen = true,
    this.totalEarnings = '0',
    this.pendingPayout = '0',
    this.bestSelling = const [],
  });

  final String ordersToday;
  final String revenue;
  final bool isOpen;
  final String totalEarnings;
  final String pendingPayout;
  final List<BestSellingProduct> bestSelling;

  factory VendorDashboardData.fromJson(Map<String, dynamic> json) {
    return VendorDashboardData(
      ordersToday: json['orders_today']?.toString() ?? '0',
      revenue: json['revenue']?.toString() ?? '0',
      isOpen: json['is_open']?.toString() != '0',
      totalEarnings: json['total_earnings']?.toString() ?? '0',
      pendingPayout: json['pending_payout']?.toString() ?? '0',
      bestSelling:
          parseList(json, 'best_selling_products', BestSellingProduct.fromJson),
    );
  }
}

class MonthlyRevenuePoint {
  const MonthlyRevenuePoint({required this.month, required this.revenue});

  final String month;
  final String revenue;

  double get revenueValue => double.tryParse(revenue) ?? 0;

  factory MonthlyRevenuePoint.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenuePoint(
      month: json['month']?.toString() ?? '',
      revenue: json['revenue']?.toString() ?? '0',
    );
  }
}

class OrderStatusBreakdown {
  const OrderStatusBreakdown({
    this.pending = 0,
    this.accepted = 0,
    this.delivered = 0,
    this.cancelled = 0,
  });

  final double pending;
  final double accepted;
  final double delivered;
  final double cancelled;

  double get total => pending + accepted + delivered + cancelled;

  bool get isEmpty => total <= 0;

  factory OrderStatusBreakdown.fromJson(Map<String, dynamic> json) {
    double v(String k) => double.tryParse(json[k]?.toString() ?? '0') ?? 0;
    return OrderStatusBreakdown(
      pending: v('pending'),
      accepted: v('accepted'),
      delivered: v('delivered'),
      cancelled: v('cancelled'),
    );
  }
}

class VendorAnalyticsData {
  const VendorAnalyticsData({
    this.totalEarnings = '0',
    this.pendingPayout = '0',
    this.bestSelling = const [],
    this.monthlyRevenue = const [],
    this.orderStatus = const OrderStatusBreakdown(),
  });

  final String totalEarnings;
  final String pendingPayout;
  final List<BestSellingProduct> bestSelling;
  final List<MonthlyRevenuePoint> monthlyRevenue;
  final OrderStatusBreakdown orderStatus;

  factory VendorAnalyticsData.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['order_status_breakdown'];
    return VendorAnalyticsData(
      totalEarnings: json['total_earnings']?.toString() ?? '0',
      pendingPayout: json['pending_payout']?.toString() ?? '0',
      bestSelling:
          parseList(json, 'best_selling_products', BestSellingProduct.fromJson),
      monthlyRevenue:
          parseList(json, 'monthly_revenue', MonthlyRevenuePoint.fromJson),
      orderStatus: rawStatus is Map
          ? OrderStatusBreakdown.fromJson(Map<String, dynamic>.from(rawStatus))
          : const OrderStatusBreakdown(),
    );
  }
}

class PayoutHistoryItem {
  const PayoutHistoryItem({
    required this.payoutId,
    required this.amount,
    required this.commissionDeducted,
    required this.netAmount,
    required this.date,
    required this.status,
  });

  final String payoutId;
  final String amount;
  final String commissionDeducted;
  final String netAmount;
  final String date;
  final String status;

  factory PayoutHistoryItem.fromJson(Map<String, dynamic> json) {
    return PayoutHistoryItem(
      payoutId: json['payout_id']?.toString() ?? json['id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      commissionDeducted: json['commission_deducted']?.toString() ?? '0',
      netAmount: json['net_amount']?.toString() ?? '0',
      date: json['date']?.toString() ?? json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class SupportTicket {
  const SupportTicket({
    required this.ticketId,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String ticketId;
  final String subject;
  final String message;
  final String status;
  final String createdAt;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      ticketId: json['ticket_id']?.toString() ?? json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt:
          json['created_at']?.toString() ?? json['date']?.toString() ?? '',
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
      status:
          json['status']?.toString() ?? json['order_status']?.toString() ?? '',
    );
  }

  bool get isPending {
    final s = status.toLowerCase();
    return s.contains('pending') || s.contains('placed');
  }
}

class VendorPayout {
  const VendorPayout({
    required this.payoutId,
    required this.amount,
    required this.date,
    required this.status,
  });

  final String payoutId;
  final String amount;
  final String date;
  final String status;

  factory VendorPayout.fromJson(Map<String, dynamic> json) {
    return VendorPayout(
      payoutId: json['payout_id']?.toString() ?? json['id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      date: json['date']?.toString() ?? json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class VendorEarningsData {
  const VendorEarningsData({
    this.earnings = '0',
    this.breakdown = const {},
    this.payouts = const [],
  });

  /// Best-effort total earnings figure for the headline display.
  final String earnings;

  /// Full key/value breakdown when `earnings` is an object (empty otherwise).
  final Map<String, String> breakdown;

  final List<VendorPayout> payouts;

  factory VendorEarningsData.fromJson(Map<String, dynamic> json) {
    // `earnings` can be a scalar (e.g. "1200") or an object ({ total: ... }).
    final rawEarnings = json['earnings'];
    var earnings = '0';
    var breakdown = <String, String>{};
    if (rawEarnings is Map) {
      breakdown = rawEarnings.map((k, v) => MapEntry('$k', '${v ?? ''}'));
      // Pull a headline total from common keys; else fall back to first value.
      for (final key in [
        'total_earnings',
        'total',
        'net_earnings',
        'net',
        'amount',
        'earnings',
        'balance',
      ]) {
        final match = breakdown.entries.firstWhere(
          (e) => e.key.toLowerCase() == key,
          orElse: () => const MapEntry('', ''),
        );
        if (match.key.isNotEmpty && match.value.trim().isNotEmpty) {
          earnings = match.value;
          break;
        }
      }
      if (earnings == '0' && breakdown.values.isNotEmpty) {
        final first = breakdown.values.firstWhere(
          (v) => v.trim().isNotEmpty,
          orElse: () => '0',
        );
        earnings = first;
      }
    } else if (rawEarnings != null) {
      earnings = rawEarnings.toString();
    }

    // `payouts` is intentionally an empty array [] for now — not an error.
    final rawPayouts = json['payouts'];
    final payouts = <VendorPayout>[];
    if (rawPayouts is List) {
      for (final item in rawPayouts) {
        if (item is Map) {
          payouts.add(VendorPayout.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return VendorEarningsData(
      earnings: earnings,
      breakdown: breakdown,
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

  /// Backend sends status as a flag (`1`/`0`) or a word. Map it to whether the
  /// vendor is currently active/open.
  bool get isActive {
    final s = status.trim().toLowerCase();
    return s == '1' || s == 'active' || s == 'open' || s == 'true';
  }

  /// Human-readable status label for the UI.
  String get displayStatus {
    final s = status.trim().toLowerCase();
    if (s.isEmpty) return 'Unknown';
    if (s == '1' || s == 'active' || s == 'open' || s == 'true') {
      return 'Active';
    }
    if (s == '0' || s == 'inactive' || s == 'closed' || s == 'false') {
      return 'Inactive';
    }
    // Unknown non-flag value — show it capitalised as-is.
    return status[0].toUpperCase() + status.substring(1);
  }

  /// Uppercase initials for the avatar (max 2 letters).
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'V';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
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
