import 'package:urban_roots/core/ui/category_icon_helper.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/orders/order_payment_utils.dart';
import 'package:urban_roots/features/orders/order_model.dart';
import 'package:urban_roots/features/orders/order_tracking_models.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/utils/catalog_filters.dart';
import 'package:urban_roots/features/products/models/category.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

List<dynamic> extractList(dynamic data, {String key = 'data'}) {
  if (data is List) return data;
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);

    for (final listKey in [key, 'products', 'items', 'list']) {
      final value = map[listKey];
      final resolved = _unwrapListValue(value, key: key);
      if (resolved != null) return resolved;
    }

    for (final altKey in [
      'transactions',
      'payments',
      'history',
      'records',
      'orders',
      'order_list',
    ]) {
      if (altKey == key) continue;
      final alt = map[altKey];
      if (alt is List) return alt;
    }

    final inner = map['data'];
    final innerResolved = _unwrapListValue(inner, key: key);
    if (innerResolved != null) return innerResolved;
  }
  return [];
}

List<dynamic>? _unwrapListValue(dynamic value, {String key = 'data'}) {
  if (value is List) return value;
  if (value is! Map) return null;

  final nested = Map<String, dynamic>.from(value);
  for (final nestedKey in [
    'products',
    'items',
    'list',
    key,
    'data',
    'transactions',
    'payments',
    'orders',
    'order_list',
  ]) {
    final nestedValue = nested[nestedKey];
    if (nestedValue is List) return nestedValue;
    if (nestedValue is Map) {
      final deeper = _unwrapListValue(nestedValue, key: key);
      if (deeper != null) return deeper;
    }
  }
  return null;
}

List<Product> parseProducts(dynamic raw) {
  final products = extractList(raw)
      .whereType<Map>()
      .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
      .toList();
  return filterCatalogProducts(products);
}

List<Category> parseCategories(dynamic raw) {
  return extractList(raw).whereType<Map>().map((e) {
    final m = Map<String, dynamic>.from(e);
    return Category(
      id: m['categ_id']?.toString() ??
          m['category_id']?.toString() ??
          m['id']?.toString() ??
          '',
      name: formatCategoryDisplayName(
        m['categ_name']?.toString() ??
            m['category_name']?.toString() ??
            m['name']?.toString() ??
            '',
      ),
      image: pickImageUrl(m),
      status: m['status']?.toString() ?? '0',
    );
  }).toList();
}

Map<String, dynamic> parseProfile(Map<String, dynamic> envelope) {
  final raw = envelope['data'];
  final Map<String, dynamic> profile;
  if (raw is Map) {
    profile = Map<String, dynamic>.from(raw);
  } else {
    profile = Map<String, dynamic>.from(envelope);
  }

  final firstName =
      _profilePick(profile, ['cust_fname', 'fname', 'first_name']);
  final lastName = _profilePick(profile, ['cust_lname', 'lname', 'last_name']);
  final email = _profilePick(profile, ['cust_email', 'email']);
  final mobile =
      _profilePick(profile, ['cust_mobile', 'mobile', 'phone', 'phone_number']);
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
    final line =
        _profilePick(map, ['address', 'full_address', 'street', 'line1']);
    if (line.isNotEmpty) return line;

    final parts = <String>[
      _profilePick(map, ['landmark']),
      _profilePick(map, ['city']),
      _profilePick(map, ['state']),
      _profilePick(map, ['pincode', 'zip']),
    ].where((part) => part.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
  }
  return _profilePick(
      profile, ['address_line', 'street_address', 'full_address']);
}

List<Map<String, dynamic>> parseSubscriptionPlans(
    Map<String, dynamic> envelope) {
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
      features = featuresRaw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
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
      'product_id':
          map['product_id']?.toString() ?? map['pd_id']?.toString() ?? '0',
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
  if (status.contains('inactive') ||
      status.contains('cancel') ||
      status == '0') {
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
  final rows = _extractOrderRows(raw);
  if (rows.isEmpty) return [];

  return rows.map(parseOrderFromMap).toList()
    ..sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return b.orderId.compareTo(a.orderId);
    });
}

bool _isOrderRow(Map<String, dynamic> row) {
  return row.containsKey('order_id') ||
      row.containsKey('id') ||
      row.containsKey('products') ||
      row.containsKey('order_items') ||
      row.containsKey('items') ||
      row.containsKey('total_amount') ||
      row.containsKey('txn_id');
}

List<dynamic> _findOrderRowList(dynamic raw, [int depth = 0]) {
  if (depth > 6) return const [];
  if (raw is List) {
    if (raw.isEmpty) return raw;
    final first = raw.first;
    if (first is Map && _isOrderRow(Map<String, dynamic>.from(first))) {
      return raw;
    }
    return const [];
  }
  if (raw is! Map) return const [];

  final map = Map<String, dynamic>.from(raw);
  for (final key in ['data', 'orders', 'order_list', 'list', 'items']) {
    if (!map.containsKey(key)) continue;
    final value = map[key];
    if (value is List) {
      if (value.isEmpty) return value;
      final first = value.first;
      if (first is Map && _isOrderRow(Map<String, dynamic>.from(first))) {
        return value;
      }
      continue;
    }
    if (value is Map) {
      final nested = _findOrderRowList(value, depth + 1);
      if (nested.isNotEmpty) return nested;
    }
  }

  if (_isOrderRow(map)) return [map];
  return const [];
}

Map<String, dynamic> _flattenOrderListRow(Map<String, dynamic> raw) {
  final flat = Map<String, dynamic>.from(raw);

  final payment = raw['payment'];
  if (payment is Map) {
    final paymentMap = Map<String, dynamic>.from(payment);
    flat.putIfAbsent(
      'payment_method',
      () =>
          paymentMap['method'] ??
          paymentMap['payment_method'] ??
          paymentMap['type'],
    );
    flat.putIfAbsent(
      'payment_status',
      () => paymentMap['status'] ?? paymentMap['payment_status'],
    );
  }

  final customer = raw['customer'];
  if (customer is Map) {
    final customerMap = Map<String, dynamic>.from(customer);
    flat.putIfAbsent('customer_name', () => customerMap['name']);
    flat.putIfAbsent('first_name', () => customerMap['first_name']);
    flat.putIfAbsent('last_name', () => customerMap['last_name']);
    flat.putIfAbsent('email', () => customerMap['email']);
    flat.putIfAbsent('phone', () => customerMap['phone']);
  }

  final addressFields = _parseOrderAddressFields(raw);
  if (addressFields.address.isNotEmpty) flat['address'] = addressFields.address;
  if (addressFields.city.isNotEmpty) flat['city'] = addressFields.city;
  if (addressFields.state.isNotEmpty) flat['state'] = addressFields.state;
  if (addressFields.pincode.isNotEmpty) flat['pincode'] = addressFields.pincode;
  if (addressFields.landmark.isNotEmpty)
    flat['landmark'] = addressFields.landmark;

  return flat;
}

List<Map<String, dynamic>> _extractOrderRows(dynamic raw) {
  final list = _findOrderRowList(raw);
  return list
      .whereType<Map>()
      .map((row) => _flattenOrderListRow(Map<String, dynamic>.from(row)))
      .where(_isOrderRow)
      .toList();
}

Order? parseOrderDetail(Map<String, dynamic> envelope) {
  dynamic raw = envelope['data'] ?? envelope['order'] ?? envelope;
  if (raw is List && raw.isNotEmpty) {
    final rows =
        raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
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

  final addressFields = _parseOrderAddressFields(raw);
  flat['address'] = addressFields.address;
  flat['city'] = addressFields.city;
  flat['state'] = addressFields.state;
  flat['pincode'] = addressFields.pincode;
  flat['landmark'] = addressFields.landmark;

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
  String? txnId,
}) {
  return Order(
    orderId: order.orderId,
    txnId: txnId ?? order.txnId,
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

    final unitPrice = double.tryParse(
          item['price']?.toString() ??
              item['product_price']?.toString() ??
              item['item_price']?.toString() ??
              item['rate']?.toString() ??
              '0',
        ) ??
        0;
    final subtotal = _parseLineAmount(item, qty);
    final resolvedUnitPrice =
        unitPrice > 0 ? unitPrice : (qty > 0 ? subtotal / qty : 0.0);

    return OrderItem(
      productId: item['product_id']?.toString() ??
          item['pd_id']?.toString() ??
          item['productId']?.toString() ??
          '',
      name: item['name']?.toString() ??
          item['product_name']?.toString() ??
          'Product',
      quantity: qty,
      unitPrice: resolvedUnitPrice,
      subtotal: subtotal,
      imageUrl: pickImageUrl(item),
    );
  }).toList();

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

class _OrderAddressFields {
  const _OrderAddressFields({
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.landmark = '',
  });

  final String address;
  final String city;
  final String state;
  final String pincode;
  final String landmark;
}

_OrderAddressFields _parseOrderAddressFields(Map<String, dynamic> order) {
  var address = '';
  var city = '';
  var state = '';
  var pincode = '';
  var landmark = '';

  void applyMap(Map<String, dynamic> map) {
    final line = map['address']?.toString() ??
        map['address_line1']?.toString() ??
        map['address_line']?.toString() ??
        map['street']?.toString() ??
        '';
    if (line.isNotEmpty) address = line;

    final mapCity = map['city']?.toString() ?? '';
    if (mapCity.isNotEmpty) city = mapCity;

    final mapState = map['state']?.toString() ?? '';
    if (mapState.isNotEmpty) state = mapState;

    final mapPin = map['pincode']?.toString() ?? map['zip']?.toString() ?? '';
    if (mapPin.isNotEmpty) pincode = mapPin;

    final mapLandmark =
        map['landmark']?.toString() ?? map['address_line2']?.toString() ?? '';
    if (mapLandmark.isNotEmpty && mapLandmark != '-') landmark = mapLandmark;
  }

  final nestedAddress = order['address'];
  if (nestedAddress is Map) {
    applyMap(Map<String, dynamic>.from(nestedAddress));
  }

  for (final key in [
    'shipping_address',
    'billing_address',
    'delivery_address',
  ]) {
    final value = order[key];
    if (value is Map) {
      applyMap(Map<String, dynamic>.from(value));
    }
  }

  if (address.isEmpty && nestedAddress is! Map) {
    final raw = nestedAddress?.toString() ?? '';
    if (raw.isNotEmpty && !raw.trim().startsWith('{')) {
      address = raw;
    }
  }
  if (address.isEmpty) {
    final delivery = order['delivery_address'];
    if (delivery is Map) {
      applyMap(Map<String, dynamic>.from(delivery));
    } else {
      final raw = delivery?.toString() ?? '';
      if (raw.isNotEmpty && !raw.trim().startsWith('{')) address = raw;
    }
  }

  if (city.isEmpty) city = order['city']?.toString() ?? '';
  if (state.isEmpty) state = order['state']?.toString() ?? '';
  if (pincode.isEmpty) {
    pincode = order['pincode']?.toString() ?? order['zip']?.toString() ?? '';
  }
  if (landmark.isEmpty) {
    final raw = order['landmark']?.toString() ?? '';
    if (raw.isNotEmpty && raw != '-') landmark = raw;
  }

  return _OrderAddressFields(
    address: address,
    city: city,
    state: state,
    pincode: pincode,
    landmark: landmark,
  );
}

Order parseOrderFromMap(Map<String, dynamic> order) {
  final orderId = int.tryParse(
        order['order_id']?.toString() ?? order['id']?.toString() ?? '0',
      ) ??
      0;

  final date = order['order_date']?.toString() ??
      order['created_at']?.toString() ??
      order['created_on']?.toString() ??
      order['date']?.toString() ??
      '';

  final total = double.tryParse(
        order['total_amount']?.toString() ??
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

  final txnId = order['txn_id']?.toString() ?? order['txnId']?.toString() ?? '';

  final status = order['status']?.toString() ??
      order['order_status']?.toString() ??
      order['delivery_status']?.toString() ??
      '';

  final paymentStatus = order['payment_status']?.toString() ??
      order['pay_status']?.toString() ??
      order['payment_state']?.toString() ??
      '';

  var paymentMethod = order['payment_method']?.toString() ??
      order['payment_type']?.toString() ??
      order['payment_mode']?.toString() ??
      order['pay_method']?.toString() ??
      order['pay_type']?.toString() ??
      '';

  // List API sometimes stores the method in payment_status (e.g. "Cash on Delivery").
  final payLower = paymentStatus.toLowerCase();
  if (paymentMethod.isEmpty &&
      (payLower.contains('cod') ||
          payLower.contains('cash') ||
          payLower.contains('delivery') ||
          payLower.contains('online') ||
          payLower.contains('wallet') ||
          payLower.contains('upi'))) {
    paymentMethod = paymentStatus;
  }

  final items = _parseOrderItems(order);
  final addressFields = _parseOrderAddressFields(order);

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
      txnId: txnId,
      date: date,
      total: total,
      status: status,
      items: items,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      pendingPaymentUrl: extractPaymentUrl(order) ?? '',
      customerName: customerName,
      email:
          order['email']?.toString() ?? order['cust_email']?.toString() ?? '',
      phone: order['phone']?.toString() ?? order['mobile']?.toString() ?? '',
      address: addressFields.address,
      city: addressFields.city,
      state: addressFields.state,
      pincode: addressFields.pincode,
      landmark: addressFields.landmark,
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
    final landmark =
        map['landmark']?.toString() ?? map['address_line2']?.toString() ?? '';

    return Address(
      id: map['address_id']?.toString() ?? map['id']?.toString() ?? '',
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

int parseTimestampSeconds(dynamic created) {
  if (created is num) {
    final ts = created.toInt();
    return ts > 9999999999 ? ts ~/ 1000 : ts;
  }
  if (created is String && created.isNotEmpty) {
    final parsed = DateTime.tryParse(created);
    if (parsed != null) {
      return parsed.millisecondsSinceEpoch ~/ 1000;
    }
  }
  return 0;
}

String _resolveWalletPaymentStatus(Map<String, dynamic> tx) {
  final raw = (tx['status'] ?? tx['payment_status'] ?? tx['txn_status'])
      ?.toString()
      .toLowerCase()
      .trim();
  if (raw != null && raw.isNotEmpty) return raw;

  final type = tx['type']?.toString().toLowerCase() ?? '';
  if (type.contains('fail')) return 'failed';
  if (type.contains('cancel')) return 'cancelled';
  if (type.contains('pending')) return 'pending';
  if (type == 'credit' || type == 'debit') return 'success';
  return 'success';
}

List<Map<String, dynamic>> parseWalletTransactions(dynamic raw) {
  return extractList(raw).whereType<Map>().map((txRaw) {
    final tx = Map<String, dynamic>.from(txRaw);
    final amountRaw = tx['amount'] ?? tx['txn_amount'] ?? tx['value'] ?? 0;
    final amountNum = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw.toString()) ?? 0;

    final created =
        tx['created_at'] ?? tx['date'] ?? tx['txn_date'] ?? tx['created_on'];
    final createdAtSeconds = parseTimestampSeconds(created);
    final orderId = tx['order_id']?.toString() ?? '';
    final txnId = tx['transaction_id']?.toString() ??
        tx['txn_id']?.toString() ??
        tx['id']?.toString() ??
        '';

    final gateway = tx['gateway']?.toString() ??
        tx['provider']?.toString() ??
        tx['payment_gateway']?.toString() ??
        '';

    return {
      'amount': amountNum.abs(),
      'amount_in_paise': amountNum.abs() >= 1000
          ? amountNum.abs().toInt()
          : (amountNum.abs() * 100).toInt(),
      'created_at': createdAtSeconds,
      'description': tx['description']?.toString() ??
          tx['remark']?.toString() ??
          tx['title']?.toString() ??
          (orderId.isNotEmpty ? 'Order #$orderId' : 'Wallet transaction'),
      'method': tx['method']?.toString() ??
          tx['payment_method']?.toString() ??
          'Wallet',
      'gateway': gateway,
      'status': _resolveWalletPaymentStatus(tx),
      'order_id': orderId,
      'txn_id': txnId,
      'source': 'wallet',
      'dedupe_key': orderId.isNotEmpty
          ? 'order_$orderId'
          : 'wallet_${txnId.isNotEmpty ? txnId : createdAtSeconds}_$amountNum',
    };
  }).toList();
}

String resolveOrderPaymentStatus(Order order) {
  final pay = order.paymentStatus.toLowerCase().trim();
  if (order.isCancelled || pay.contains('cancel')) return 'cancelled';
  if (pay.contains('fail') ||
      pay.contains('declined') ||
      pay.contains('refund')) {
    return 'failed';
  }
  if (pay.contains('pending') ||
      pay.contains('unpaid') ||
      pay.contains('initiated')) {
    return 'pending';
  }
  if (order.isPaymentComplete ||
      pay.contains('paid') ||
      pay.contains('success') ||
      pay.contains('complete')) {
    return 'success';
  }

  final method = order.paymentMethod.toLowerCase();
  if (method.contains('cod') || method.contains('cash')) {
    final status = order.status.toLowerCase();
    if (status.contains('deliver') || status.contains('complete')) {
      return 'success';
    }
    if (order.isCancelled) return 'cancelled';
    return 'pending';
  }

  return pay.isNotEmpty ? pay : 'pending';
}

List<Map<String, dynamic>> paymentRecordsFromOrders(List<Order> orders) {
  return orders.where((order) => !order.isCodLike).map((order) {
    final method =
        order.paymentMethod.trim().isNotEmpty ? order.paymentMethod : 'Online';
    final gateway = method.toLowerCase().contains('wallet')
        ? 'Wallet'
        : method.toLowerCase().contains('cod') ||
                method.toLowerCase().contains('cash')
            ? 'COD'
            : method.toLowerCase().contains('online') ||
                    method.toLowerCase().contains('upi') ||
                    method.toLowerCase().contains('phonepe')
                ? 'Online'
                : method;

    final itemSummary = order.items.isNotEmpty
        ? order.items.first.name
        : 'Order #${order.orderId}';

    return {
      'amount': order.total,
      'created_at': parseTimestampSeconds(order.date),
      'description': 'Order #${order.orderId} · $itemSummary',
      'method': method,
      'gateway': gateway,
      'status': resolveOrderPaymentStatus(order),
      'order_id': order.orderId.toString(),
      'txn_id': '',
      'source': 'order',
      'dedupe_key': 'order_${order.orderId}',
    };
  }).toList();
}

List<Map<String, dynamic>> mergePaymentRecords(
  List<Map<String, dynamic>> walletRecords,
  List<Map<String, dynamic>> orderRecords,
) {
  final merged = <String, Map<String, dynamic>>{};

  void put(Map<String, dynamic> record) {
    final key = record['dedupe_key']?.toString() ??
        '${record['source']}_${record['order_id'] ?? record['txn_id']}_${record['amount']}';
    final existing = merged[key];
    if (existing == null) {
      merged[key] = record;
      return;
    }
    // Prefer order records over wallet rows when both refer to the same payment.
    if (existing['source'] == 'wallet' && record['source'] == 'order') {
      merged[key] = record;
    }
  }

  for (final record in walletRecords) {
    if (record['order_id']?.toString().isNotEmpty == true) {
      continue;
    }
    put(record);
  }
  for (final record in orderRecords) {
    put(record);
  }

  final list = merged.values.toList()
    ..sort((a, b) {
      final aTs = a['created_at'] as int? ?? 0;
      final bTs = b['created_at'] as int? ?? 0;
      return bTs.compareTo(aTs);
    });
  return list;
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

double? _pickCoordinateComponent(
  Map<String, dynamic> map,
  List<String> keys,
) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    final parsed = double.tryParse(value.toString().trim());
    if (parsed != null) return parsed;
  }
  return null;
}

TrackingCoordinate? _parseTrackingCoordinate(dynamic raw) {
  if (raw is! Map) return null;
  final map = Map<String, dynamic>.from(raw);
  final lat = _pickCoordinateComponent(map, [
    'lat',
    'latitude',
    'delivery_lat',
    'dest_lat',
    'destination_lat',
    'address_lat',
    'customer_lat',
    'drop_lat',
  ]);
  final lng = _pickCoordinateComponent(map, [
    'lng',
    'lon',
    'long',
    'longitude',
    'delivery_lng',
    'delivery_lon',
    'dest_lng',
    'destination_lng',
    'address_lng',
    'customer_lng',
    'drop_lng',
  ]);
  if (lat == null || lng == null) return null;
  final coordinate = TrackingCoordinate(latitude: lat, longitude: lng);
  return coordinate.isValid ? coordinate : null;
}

TrackingCoordinate? _findTrackingCoordinate(Map<String, dynamic> map) {
  for (final key in [
    'destination',
    'delivery_location',
    'delivery_address',
    'drop_location',
    'address',
    'customer_location',
  ]) {
    final nested = _parseTrackingCoordinate(map[key]);
    if (nested != null) return nested;
  }

  final direct = _parseTrackingCoordinate(map);
  if (direct != null) return direct;

  return null;
}

TrackingCoordinate? _findAgentCoordinate(Map<String, dynamic> map) {
  for (final key in [
    'agent',
    'delivery_agent',
    'delivery_boy',
    'driver',
    'rider',
    'courier',
    'current_location',
    'live_location',
    'location',
  ]) {
    final nested = _parseTrackingCoordinate(map[key]);
    if (nested != null) return nested;
  }

  final lat = _pickCoordinateComponent(map, [
    'agent_lat',
    'agent_latitude',
    'rider_lat',
    'driver_lat',
    'delivery_boy_lat',
    'boy_lat',
    'current_lat',
    'live_lat',
  ]);
  final lng = _pickCoordinateComponent(map, [
    'agent_lng',
    'agent_lon',
    'agent_longitude',
    'rider_lng',
    'driver_lng',
    'delivery_boy_lng',
    'boy_lng',
    'current_lng',
    'live_lng',
  ]);
  if (lat == null || lng == null) return null;
  final coordinate = TrackingCoordinate(latitude: lat, longitude: lng);
  return coordinate.isValid ? coordinate : null;
}

String _pickTrackingTimestamp(Map<String, dynamic> map) {
  for (final key in [
    'timestamp',
    'time',
    'date',
    'updated_at',
    'created_at',
    'status_time',
  ]) {
    final value = map[key]?.toString().trim() ?? '';
    if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
  }
  return '';
}

String _pickTrackingStepLabel(Map<String, dynamic> map) {
  for (final key in ['step', 'title', 'label', 'name', 'tracking_status']) {
    final value = map[key]?.toString().trim() ?? '';
    if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) return value;
  }
  return '';
}

bool _parseBoolField(dynamic value) {
  if (value is bool) return value;
  if (value == 1 || value == '1') return true;
  final text = value?.toString().toLowerCase() ?? '';
  return text == 'true' || text == 'yes';
}

List<OrderTrackingStep> _parseTrackingSteps(Map<String, dynamic> map) {
  dynamic raw;
  for (final key in [
    'tracking_steps',
    'tracking_history',
    'status_history',
    'timeline',
    'history',
    'steps',
    'tracking',
    'tracking_data',
  ]) {
    final value = map[key];
    if (value is List && value.isNotEmpty) {
      raw = value;
      break;
    }
  }

  if (raw is! List) return const [];

  return raw
      .whereType<Map>()
      .map((entry) {
        final stepMap = Map<String, dynamic>.from(entry);
        final label = _pickTrackingStepLabel(stepMap);
        if (label.isEmpty) return null;
        return OrderTrackingStep(
          label: label,
          statusCode:
              int.tryParse(stepMap['status_code']?.toString() ?? '') ?? 0,
          timestamp: _pickTrackingTimestamp(stepMap),
          completed: _parseBoolField(stepMap['completed']),
          isCurrent: _parseBoolField(stepMap['is_current']),
        );
      })
      .whereType<OrderTrackingStep>()
      .toList();
}

String _pickDeliveryBoyName(Map<String, dynamic> map) {
  final boy = map['delivery_boy'];
  if (boy is Map) {
    final name = boy['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
  }
  for (final key in ['agent_name', 'delivery_boy_name', 'driver_name']) {
    final value = map[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _pickDeliveryBoyPhone(Map<String, dynamic> map) {
  final boy = map['delivery_boy'];
  if (boy is Map) {
    final phone = boy['phone']?.toString().trim() ??
        boy['mobile']?.toString().trim() ??
        '';
    if (phone.isNotEmpty) return phone;
  }
  for (final key in ['agent_phone', 'delivery_boy_phone', 'phone', 'mobile']) {
    final value = map[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

TrackingCoordinate? _parseLocationObject(dynamic raw) {
  if (raw is! Map) return null;
  final map = Map<String, dynamic>.from(raw);
  final lat = double.tryParse(map['lat']?.toString() ?? '') ??
      double.tryParse(map['latitude']?.toString() ?? '');
  final lng = double.tryParse(map['lng']?.toString() ?? '') ??
      double.tryParse(map['longitude']?.toString() ?? '');
  if (lat == null || lng == null) return null;
  final coordinate = TrackingCoordinate(latitude: lat, longitude: lng);
  return coordinate.isValid ? coordinate : null;
}

String _pickTrackingEta(Map<String, dynamic> map) {
  for (final key in ['eta', 'eta_minutes', 'estimated_delivery']) {
    final value = map[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

Map<String, dynamic> _unwrapTrackingEnvelope(Map<String, dynamic> envelope) {
  final data = envelope['data'] ?? envelope['tracking'] ?? envelope;
  if (data is Map) return Map<String, dynamic>.from(data);
  return envelope;
}

OrderTrackingData? parseOrderTracking(Map<String, dynamic> envelope) {
  final map = _unwrapTrackingEnvelope(envelope);
  final orderStatus = map['order_status']?.toString().trim() ?? '';
  final statusCode = int.tryParse(map['status_code']?.toString() ?? '') ?? 0;
  final completed = _parseBoolField(map['completed']);
  final steps = _parseTrackingSteps(map);
  final destination = _findTrackingCoordinate(map);

  if (orderStatus.isEmpty && statusCode == 0 && steps.isEmpty) {
    return null;
  }

  return OrderTrackingData(
    orderId: int.tryParse(map['order_id']?.toString() ?? '') ?? 0,
    txnId: map['txn_id']?.toString() ?? '',
    orderStatus: orderStatus,
    statusCode: statusCode,
    completed: completed,
    steps: steps,
    destination: destination,
    agentName: _pickDeliveryBoyName(map),
    agentPhone: _pickDeliveryBoyPhone(map),
    eta: _pickTrackingEta(map),
  );
}

OrderLiveTrackingData? parseLiveTracking(Map<String, dynamic> envelope) {
  final map = _unwrapTrackingEnvelope(envelope);
  final location = _parseLocationObject(map['location']) ??
      _findAgentCoordinate(map) ??
      _findTrackingCoordinate(map);
  final agent = _findAgentCoordinate(map);

  if (location == null &&
      agent == null &&
      _pickDeliveryBoyName(map).isEmpty &&
      _pickTrackingEta(map).isEmpty) {
    return null;
  }

  return OrderLiveTrackingData(
    location: location,
    agent: agent,
    agentName: _pickDeliveryBoyName(map),
    agentPhone: _pickDeliveryBoyPhone(map),
    eta: _pickTrackingEta(map),
  );
}

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
