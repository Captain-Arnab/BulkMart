import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/orders/domain/order_payment_utils.dart';
import 'package:urban_roots/features/orders/models/order_model.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/utils/catalog_filters.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

List<dynamic> extractList(dynamic data, {String key = 'data'}) {
  if (data is List) return data;
  if (data is Map) {
    final value = data[key];
    if (value is List) return value;
    if (value is Map) return [value];
  }
  return [];
}

List<Product> parseProducts(dynamic raw) {
  final products = extractList(raw)
      .whereType<Map>()
      .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
      .toList();
  return filterCatalogProducts(products);
}

List<Category> parseCategories(dynamic raw) {
  return extractList(raw)
      .whereType<Map>()
      .map((e) {
        final m = Map<String, dynamic>.from(e);
        return Category(
          id: m['category_id']?.toString() ?? m['id']?.toString() ?? '',
          name: m['category_name']?.toString() ?? m['name']?.toString() ?? '',
          image: pickImageUrl(m),
          status: m['status']?.toString() ?? '0',
        );
      })
      .toList();
}

Map<String, dynamic> parseProfile(Map<String, dynamic> envelope) {
  final raw = envelope['data'];
  final Map<String, dynamic> profile;
  if (raw is Map) {
    profile = Map<String, dynamic>.from(raw);
  } else {
    profile = Map<String, dynamic>.from(envelope);
  }

  final firstName = _profilePick(profile, ['cust_fname', 'fname', 'first_name']);
  final lastName = _profilePick(profile, ['cust_lname', 'lname', 'last_name']);
  final email = _profilePick(profile, ['cust_email', 'email']);
  final mobile = _profilePick(profile, ['cust_mobile', 'mobile', 'phone', 'phone_number']);
  final city = _profilePick(profile, ['city']);
  final state = _profilePick(profile, ['state']);
  final address = _profilePickAddress(profile);
  final name = '$firstName $lastName'.trim().isNotEmpty
      ? '$firstName $lastName'.trim()
      : _profilePick(profile, ['name', 'full_name']);

  return {
    'cust_id': _profilePick(profile, ['cust_id', 'id', 'user_id']),
    'cust_fname': firstName,
    'cust_lname': lastName,
    'cust_email': email,
    'cust_mobile': mobile,
    'address': address,
    'city': city,
    'state': state,
    'name': name,
    'email': email,
    'phone': mobile,
  };
}

String _profilePick(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is Map || value is List) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '';
}

String _profilePickAddress(Map<String, dynamic> profile) {
  final address = profile['address'];
  if (address is String) {
    final text = address.trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  if (address is Map) {
    final map = Map<String, dynamic>.from(address);
    final line = _profilePick(map, ['address', 'full_address', 'street', 'line1']);
    if (line.isNotEmpty) return line;

    final parts = <String>[
      _profilePick(map, ['landmark']),
      _profilePick(map, ['city']),
      _profilePick(map, ['state']),
      _profilePick(map, ['pincode', 'zip']),
    ].where((part) => part.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
  }
  return _profilePick(profile, ['address_line', 'street_address', 'full_address']);
}

List<Map<String, dynamic>> parseSubscriptionPlans(Map<String, dynamic> envelope) {
  List<dynamic> raw = const [];
  if (envelope['plans'] is List) {
    raw = envelope['plans'] as List;
  } else if (envelope['data'] is List) {
    raw = envelope['data'] as List;
  } else if (envelope['data'] is Map) {
    final inner = Map<String, dynamic>.from(envelope['data'] as Map);
    if (inner['plans'] is List) {
      raw = inner['plans'] as List;
    }
  }
  if (raw.isEmpty) {
    raw = extractList(envelope, key: 'plans');
  }

  return raw.whereType<Map>().map((plan) {
    final map = Map<String, dynamic>.from(plan);
    final featuresRaw = map['features'];
    List<String> features;
    if (featuresRaw is List) {
      features = featuresRaw.map((e) => e.toString()).toList();
    } else if (featuresRaw is String && featuresRaw.isNotEmpty) {
      features = featuresRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      features = _defaultSubscriptionFeatures(map);
    }

    final popularValue = map['popular'] ?? map['is_popular'];
    final isPopular = popularValue == true ||
        popularValue == 1 ||
        popularValue?.toString() == '1' ||
        popularValue?.toString().toLowerCase() == 'true';

    final subscriptionType =
        map['subscription_type']?.toString().toLowerCase() ?? '';
    final durationDays = map['duration_days'];

    return {
      'id': map['plan_id']?.toString() ?? map['id']?.toString() ?? '',
      'product_id': map['product_id']?.toString() ?? map['pd_id']?.toString() ?? '0',
      'name': map['name']?.toString() ?? map['plan_name']?.toString() ?? '',
      'price': _parseSubscriptionPrice(map),
      'duration': _parseSubscriptionDuration(map),
      'subscription_type': subscriptionType,
      'duration_days': durationDays,
      'weekly_days': map['weekly_days']?.toString() ?? '',
      'description': map['description']?.toString().isNotEmpty == true
          ? map['description'].toString()
          : _defaultSubscriptionDescription(map),
      'features': features,
      'popular': isPopular,
    };
  }).toList();
}

num _parseSubscriptionPrice(Map<String, dynamic> map) {
  for (final key in [
    'price',
    'amount',
    'plan_price',
    'subscription_price',
    'cost',
  ]) {
    final value = map[key];
    if (value == null) continue;
    final parsed = num.tryParse(value.toString());
    if (parsed != null && parsed > 0) return parsed;
  }
  return 0;
}

String _parseSubscriptionDuration(Map<String, dynamic> map) {
  final explicit = map['duration']?.toString() ??
      map['interval']?.toString() ??
      map['billing_cycle']?.toString() ??
      '';
  if (explicit.trim().isNotEmpty) return explicit.trim();

  final type = map['subscription_type']?.toString().toLowerCase() ?? '';
  switch (type) {
    case 'daily':
      return 'day';
    case 'weekly':
      return 'week';
    case 'monthly':
      return 'month';
    case 'yearly':
    case 'annual':
      return 'year';
  }

  final days = map['duration_days'];
  if (days != null && days.toString().isNotEmpty) {
    return '${days.toString()} days';
  }
  return '';
}

String _defaultSubscriptionDescription(Map<String, dynamic> map) {
  final type = map['subscription_type']?.toString().toLowerCase() ?? '';
  final days = map['duration_days']?.toString();
  final weeklyDays = map['weekly_days']?.toString() ?? '';

  switch (type) {
    case 'daily':
      return days != null && days.isNotEmpty
          ? 'Fresh groceries delivered daily for $days days.'
          : 'Fresh groceries delivered every day.';
    case 'weekly':
      if (weeklyDays.isNotEmpty) {
        return 'Deliveries on $weeklyDays${days != null && days.isNotEmpty ? ' • $days day plan' : ''}.';
      }
      return days != null && days.isNotEmpty
          ? 'Weekly delivery plan for $days days.'
          : 'Weekly delivery of fresh organic groceries.';
    case 'monthly':
      return days != null && days.isNotEmpty
          ? 'Monthly delivery plan for $days days.'
          : 'Monthly delivery of fresh organic groceries.';
    default:
      return 'Regular delivery of fresh organic groceries.';
  }
}

List<String> _defaultSubscriptionFeatures(Map<String, dynamic> map) {
  final features = <String>[];
  final type = map['subscription_type']?.toString().toLowerCase() ?? '';
  final days = map['duration_days']?.toString();
  final weeklyDays = map['weekly_days']?.toString() ?? '';

  if (type.isNotEmpty) {
    features.add('${type[0].toUpperCase()}${type.substring(1)} subscription');
  }
  if (days != null && days.isNotEmpty) {
    features.add('$days day billing cycle');
  }
  if (weeklyDays.isNotEmpty) {
    features.add('Delivery days: $weeklyDays');
  }
  if (features.isEmpty) {
    features.add('Flexible subscription plan');
  }
  return features;
}

String stripHtmlTags(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  return raw
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

Map<String, dynamic> parseProductDetail(Map<String, dynamic> details) {
  final gramsRaw = details['product_grams']?.toString() ??
      details['grams']?.toString() ??
      '';
  final grams = gramsRaw.isNotEmpty && !gramsRaw.toLowerCase().contains('g')
      ? '${gramsRaw}g'
      : gramsRaw;

  final packingRaw = details['packing_type']?.toString() ?? '';
  final packingType = stripHtmlTags(packingRaw).isNotEmpty
      ? stripHtmlTags(packingRaw)
      : packingRaw;

  return {
    'imageUrl': pickImageUrl(details),
    'name': details['name']?.toString() ??
        details['product_name']?.toString() ??
        'Product',
    'description': details['long_description']?.toString() ??
        details['short_description']?.toString() ??
        details['description']?.toString() ??
        details['product_description']?.toString() ??
        '',
    'healthBenefits': details['health_benifits']?.toString() ??
        details['health_benefits']?.toString() ??
        '',
    'nutritionalInfo': details['nutritional_info']?.toString() ?? '',
    'sellingPoints': details['unique_selling_points']?.toString() ??
        details['selling_points']?.toString() ??
        '',
    'price': details['price']?.toString() ?? '0',
    'grams': grams,
    'stock': details['product_stock']?.toString() ??
        details['stock']?.toString() ??
        '0',
    'gst': details['gst']?.toString() ?? '5',
    'packingType': packingType,
  };
}

Map<String, dynamic>? parseSubscriptionStatus(Map<String, dynamic> envelope) {
  dynamic raw = envelope['subscription'] ?? envelope['data'];
  if (raw == null) return null;
  if (raw is! Map) return null;

  final sub = Map<String, dynamic>.from(raw);
  final status = sub['status']?.toString().toLowerCase() ?? '';
  if (status.contains('inactive') || status.contains('cancel') || status == '0') {
    return null;
  }

  final planName = sub['plan_name']?.toString() ??
      sub['name']?.toString() ??
      sub['plan']?.toString() ??
      '';
  if (planName.isEmpty &&
      sub['plan_id'] == null &&
      sub['subscription_id'] == null) {
    return null;
  }

  return {
    'planId': sub['plan_id']?.toString() ?? sub['id']?.toString() ?? '',
    'planName': planName.isNotEmpty ? planName : 'Active Plan',
    'price': sub['price'] ?? sub['amount'] ?? '',
    'renewalDate': sub['renewal_date']?.toString() ??
        sub['end_date']?.toString() ??
        sub['next_billing_date']?.toString() ??
        '',
    'startDate': sub['start_date']?.toString() ?? '',
    'status': sub['status']?.toString() ?? 'Active',
  };
}

List<Order> parseOrders(dynamic raw) {
  final rows = extractList(raw)
      .whereType<Map>()
      .map((orderRaw) => Map<String, dynamic>.from(orderRaw))
      .toList();
  if (rows.isEmpty) return [];

  final grouped = <int, List<Map<String, dynamic>>>{};
  for (final row in rows) {
    final orderId = int.tryParse(
          row['order_id']?.toString() ?? row['id']?.toString() ?? '0',
        ) ??
        0;
    grouped.putIfAbsent(orderId, () => []).add(row);
  }

  return grouped.values.map(_mergeOrderRows).toList()
    ..sort((a, b) => b.orderId.compareTo(a.orderId));
}

Order? parseOrderDetail(Map<String, dynamic> envelope) {
  dynamic raw = envelope['data'] ?? envelope['order'] ?? envelope;
  if (raw is List && raw.isNotEmpty) {
    final rows = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (rows.isNotEmpty) {
      return _applyPaymentUrl(_mergeOrderRows(rows), envelope);
    }
  }
  if (raw is Map) {
    return _applyPaymentUrl(
      parseOrderFromMap(_flattenOrderDetailMap(Map<String, dynamic>.from(raw))),
      envelope,
    );
  }
  return null;
}

Map<String, dynamic> _flattenOrderDetailMap(Map<String, dynamic> raw) {
  final flat = Map<String, dynamic>.from(raw);

  final customer = raw['customer'];
  if (customer is Map) {
    final customerMap = Map<String, dynamic>.from(customer);
    flat.putIfAbsent('customer_name', () => customerMap['name']);
    flat.putIfAbsent('email', () => customerMap['email']);
    flat.putIfAbsent('phone', () => customerMap['phone']);
  }
  final shipping = raw['shipping_address'] ?? raw['billing_address'];
  if (shipping is Map) {
    final addressMap = Map<String, dynamic>.from(shipping);
    flat.putIfAbsent('address', () => addressMap['address']);
    flat.putIfAbsent('city', () => addressMap['city']);
    flat.putIfAbsent('state', () => addressMap['state']);
    flat.putIfAbsent('pincode', () => addressMap['pincode']);
    flat.putIfAbsent('landmark', () => addressMap['landmark']);
  }

  final payment = raw['payment'];
  if (payment is Map) {
    final paymentMap = Map<String, dynamic>.from(payment);
    flat.putIfAbsent('payment_method', () => paymentMap['method']);
    flat.putIfAbsent('payment_status', () => paymentMap['status']);
    flat.putIfAbsent('amount', () => paymentMap['amount']);
  }

  final summary = raw['summary'];
  if (summary is Map) {
    final summaryMap = Map<String, dynamic>.from(summary);
    flat.putIfAbsent('grand_total', () => summaryMap['total']);
  }

  flat.putIfAbsent('order_status', () => raw['order_status']);
  flat.putIfAbsent('txn_id', () => raw['txn_id']);

  return flat;
}

Order _applyPaymentUrl(Order order, Map<String, dynamic> envelope) {
  final paymentUrl = extractPaymentUrl(envelope);
  if (paymentUrl == null ||
      paymentUrl.isEmpty ||
      order.pendingPaymentUrl.isNotEmpty) {
    return order;
  }
  return _copyOrder(order, pendingPaymentUrl: paymentUrl);
}

Order _mergeOrderRows(List<Map<String, dynamic>> rows) {
  if (rows.length == 1) {
    return parseOrderFromMap(rows.first);
  }

  final first = parseOrderFromMap(rows.first);
  final items = <OrderItem>[];
  for (final row in rows) {
    items.addAll(parseOrderFromMap(row).items);
  }

  var total = first.total;
  if (total <= 0) {
    total = _sumItemSubtotals(items);
  }

  return _copyOrder(first, items: items, total: total);
}

Order _copyOrder(
  Order order, {
  List<OrderItem>? items,
  double? total,
  String? pendingPaymentUrl,
}) {
  return Order(
    orderId: order.orderId,
    date: order.date,
    total: total ?? order.total,
    status: order.status,
    items: items ?? order.items,
    paymentMethod: order.paymentMethod,
    paymentStatus: order.paymentStatus,
    pendingPaymentUrl: pendingPaymentUrl ?? order.pendingPaymentUrl,
    customerName: order.customerName,
    email: order.email,
    phone: order.phone,
    address: order.address,
    city: order.city,
    state: order.state,
    pincode: order.pincode,
    landmark: order.landmark,
  );
}

double _sumItemSubtotals(List<OrderItem> items) {
  return items.fold(0.0, (sum, item) => sum + item.subtotal);
}

double _parseLineAmount(Map<String, dynamic> item, int quantity) {
  for (final key in [
    'subtotal',
    'line_total',
    'item_total',
    'total',
    'amount',
    'order_amount',
  ]) {
    final value = double.tryParse(item[key]?.toString() ?? '');
    if (value != null && value > 0) return value;
  }

  final unitPrice = double.tryParse(
        item['price']?.toString() ??
            item['product_price']?.toString() ??
            item['item_price']?.toString() ??
            item['rate']?.toString() ??
            '0',
      ) ??
      0;
  if (unitPrice > 0) {
    return unitPrice * quantity;
  }
  return 0;
}

List<OrderItem> _parseOrderItems(Map<String, dynamic> order) {
  List<dynamic> itemsRaw = const [];
  for (final key in [
    'items',
    'products',
    'order_items',
    'order_details',
    'order_products',
    'line_items',
    'cart_items',
  ]) {
    final value = order[key];
    if (value is List) {
      itemsRaw = value;
      break;
    }
  }

  final items = itemsRaw.whereType<Map>().map((itemRaw) {
    final item = Map<String, dynamic>.from(itemRaw);
    final qty = int.tryParse(
          item['quantity']?.toString() ?? item['qty']?.toString() ?? '1',
        ) ??
        1;

    return OrderItem(
      productId: item['product_id']?.toString() ??
          item['pd_id']?.toString() ??
          item['productId']?.toString() ??
          '',
      name: item['name']?.toString() ??
          item['product_name']?.toString() ??
          'Product',
      quantity: qty,
      subtotal: _parseLineAmount(item, qty),
      imageUrl: pickImageUrl(item),
    );
  }).toList();

  if (items.isEmpty) {
    final productName = order['product_name']?.toString() ??
        order['name']?.toString() ??
        order['item_name']?.toString();
    if (productName != null && productName.trim().isNotEmpty) {
      final qty = int.tryParse(order['quantity']?.toString() ?? '1') ?? 1;
      items.add(
        OrderItem(
          productId: order['product_id']?.toString() ??
              order['pd_id']?.toString() ??
              order['productId']?.toString() ??
              '',
          name: productName.trim(),
          quantity: qty,
          subtotal: _parseLineAmount(order, qty),
          imageUrl: pickImageUrl(order),
        ),
      );
    }
  }

  return items;
}

Order _finalizeOrderTotals(Order order) {
  var total = order.total;
  if (total <= 0 && order.items.isNotEmpty) {
    total = _sumItemSubtotals(order.items);
  }
  if (total == order.total) return order;
  return _copyOrder(order, total: total);
}

Order parseOrderFromMap(Map<String, dynamic> order) {
  final orderId = int.tryParse(
        order['order_id']?.toString() ?? order['id']?.toString() ?? '0',
      ) ??
      0;

  final date = order['order_date']?.toString() ??
      order['created_at']?.toString() ??
      order['date']?.toString() ??
      '';

  final total = double.tryParse(
        order['total']?.toString() ??
            order['amount']?.toString() ??
            order['order_total']?.toString() ??
            order['grand_total']?.toString() ??
            order['final_amount']?.toString() ??
            order['order_amount']?.toString() ??
            order['payable_amount']?.toString() ??
            '0',
      ) ??
      0;

  final status = order['status']?.toString() ??
      order['order_status']?.toString() ??
      '';

  final paymentStatus = order['payment_status']?.toString() ??
      order['pay_status']?.toString() ??
      order['payment_state']?.toString() ??
      '';

  final items = _parseOrderItems(order);

  final firstName = order['first_name']?.toString() ?? '';
  final lastName = order['last_name']?.toString() ?? '';
  final customerName = '$firstName $lastName'.trim().isNotEmpty
      ? '$firstName $lastName'.trim()
      : order['customer_name']?.toString() ??
          order['full_name']?.toString() ??
          '';

  return _finalizeOrderTotals(
    Order(
      orderId: orderId,
      date: date,
      total: total,
      status: status,
      items: items,
      paymentMethod: order['payment_method']?.toString() ??
          order['payment_type']?.toString() ??
          order['payment_mode']?.toString() ??
          '',
      paymentStatus: paymentStatus,
      pendingPaymentUrl: extractPaymentUrl(order) ?? '',
      customerName: customerName,
      email: order['email']?.toString() ?? order['cust_email']?.toString() ?? '',
      phone: order['phone']?.toString() ?? order['mobile']?.toString() ?? '',
      address:
          order['address']?.toString() ?? order['delivery_address']?.toString() ?? '',
      city: order['city']?.toString() ?? '',
      state: order['state']?.toString() ?? '',
      pincode: order['pincode']?.toString() ?? order['zip']?.toString() ?? '',
      landmark: order['landmark']?.toString() ?? '',
    ),
  );
}

List<Address> parseAddresses(dynamic raw) {
  return extractList(raw).whereType<Map>().map((addressRaw) {
    final map = Map<String, dynamic>.from(addressRaw);
    final addressLine = map['address']?.toString() ??
        map['address_line1']?.toString() ??
        map['addressLine1']?.toString() ??
        '';
    final landmark = map['landmark']?.toString() ?? map['address_line2']?.toString() ?? '';

    return Address(
      id: map['address_id']?.toString() ??
          map['id']?.toString() ??
          '',
      fullName: map['full_name']?.toString() ?? map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? map['mobile']?.toString() ?? '',
      addressLine1: addressLine,
      addressLine2: landmark.isNotEmpty ? landmark : null,
      state: map['state']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      pincode: map['pincode']?.toString() ?? map['zip']?.toString() ?? '',
      category: map['address_type']?.toString() ??
          map['category']?.toString() ??
          'Home',
      deliveryInstructions: map['delivery_instructions']?.toString(),
      isDefault: map['is_default'] == true ||
          map['is_default'] == 1 ||
          map['add_default'] == 1 ||
          map['default']?.toString() == '1',
    );
  }).toList();
}

List<Map<String, dynamic>> parseWalletTransactions(dynamic raw) {
  return extractList(raw).whereType<Map>().map((txRaw) {
    final tx = Map<String, dynamic>.from(txRaw);
    final amountRaw = tx['amount'] ?? tx['txn_amount'] ?? tx['value'] ?? 0;
    final amountNum = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw.toString()) ?? 0;

    final created = tx['created_at'] ?? tx['date'] ?? tx['txn_date'];
    int createdAtSeconds = 0;
    if (created is num) {
      final ts = created.toInt();
      createdAtSeconds = ts > 9999999999 ? ts ~/ 1000 : ts;
    } else if (created is String && created.isNotEmpty) {
      final parsed = DateTime.tryParse(created);
      if (parsed != null) {
        createdAtSeconds = parsed.millisecondsSinceEpoch ~/ 1000;
      }
    }

    return {
      'amount': amountNum,
      'amount_in_paise': amountNum >= 1000 ? amountNum.toInt() : (amountNum * 100).toInt(),
      'created_at': createdAtSeconds,
      'description': tx['description']?.toString() ??
          tx['remark']?.toString() ??
          tx['type']?.toString() ??
          tx['title']?.toString() ??
          'Transaction',
      'method': tx['method']?.toString() ??
          tx['payment_method']?.toString() ??
          'Wallet',
      'gateway': tx['gateway']?.toString() ?? tx['provider']?.toString() ?? '',
      'status': tx['status']?.toString() ?? 'success',
    };
  }).toList();
}

String? extractAuthToken(Map<String, dynamic> data) {
  for (final key in ['token', 'access_token', 'api_token']) {
    final value = data[key];
    if (value is String && value.isNotEmpty) return value;
  }

  final inner = data['data'];
  if (inner is Map) {
    final nested = Map<String, dynamic>.from(inner);
    for (final key in ['token', 'access_token', 'api_token']) {
      final value = nested[key];
      if (value is String && value.isNotEmpty) return value;
    }
  }

  return null;
}

String? extractUserId(Map<String, dynamic> data) {
  for (final key in ['user_id', 'cust_id', 'id']) {
    final value = data[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }

  final inner = data['data'];
  if (inner is Map) {
    final nested = Map<String, dynamic>.from(inner);
    for (final key in ['user_id', 'cust_id', 'id']) {
      final value = nested[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
  }

  return null;
}

String? extractOtp(Map<String, dynamic> data) {
  for (final key in ['otp', 'login_otp', 'verification_otp']) {
    final value = data[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  final inner = data['data'];
  if (inner is Map) {
    return extractOtp(Map<String, dynamic>.from(inner));
  }

  return null;
}

String? extractUserDisplayName(Map<String, dynamic> data) {
  final inner = data['data'];
  if (inner is Map) {
    final profile = Map<String, dynamic>.from(inner);
    final fname = profile['fname']?.toString() ??
        profile['first_name']?.toString() ??
        profile['cust_fname']?.toString() ??
        '';
    final lname = profile['lname']?.toString() ??
        profile['last_name']?.toString() ??
        profile['cust_lname']?.toString() ??
        '';
    final fullName = '$fname $lname'.trim();
    if (fullName.isNotEmpty) return fullName;
    return profile['name']?.toString();
  }

  for (final key in ['name', 'full_name', 'display_name']) {
    final value = data[key]?.toString();
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }

  return null;
}

String normalizeOtpInput(String otp) =>
    otp.replaceAll(RegExp(r'\D'), '').trim();

/// Normalizes user input to a 10-digit Indian mobile number for auth APIs.
String? normalizeIndianMobile(String phone) {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) {
    digits = digits.substring(2);
  } else if (digits.length == 11 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.length != 10) return null;
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) return null;
  return digits;
}
