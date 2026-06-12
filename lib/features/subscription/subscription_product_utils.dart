import 'package:urban_roots/features/products/models/Product.dart';

/// Resolves per-product subscription rate for the selected plan type.
double subscriptionRateForProduct(Product product, Map<String, dynamic> plan) {
  final raw = product.rawJson;
  final type = plan['subscription_type']?.toString().toLowerCase() ?? '';

  double pick(List<String> keys) {
    for (final key in keys) {
      final value = num.tryParse(raw[key]?.toString() ?? '');
      if (value != null && value > 0) return value.toDouble();
    }
    return 0;
  }

  switch (type) {
    case 'daily':
      final daily = pick(['daily_price', 'subscription_daily_price', 'subscription_price']);
      if (daily > 0) return daily;
      break;
    case 'weekly':
      final weekly = pick(['weekly_price', 'subscription_weekly_price', 'subscription_price']);
      if (weekly > 0) return weekly;
      break;
    case 'monthly':
      final monthly = pick(['monthly_price', 'subscription_monthly_price', 'subscription_price']);
      if (monthly > 0) return monthly;
      break;
  }

  final generic = pick(['subscription_price', 'sub_price', 'price']);
  if (generic > 0) return generic;

  final planPrice = plan['price'];
  if (planPrice is num && planPrice > 0) return planPrice.toDouble();
  return product.priceValue;
}

String subscriptionRateLabel(Map<String, dynamic> plan) {
  final type = plan['subscription_type']?.toString().toLowerCase() ?? '';
  final duration = plan['duration']?.toString().trim() ?? '';
  if (duration.isNotEmpty) return 'per $duration';
  switch (type) {
    case 'daily':
      return 'per day';
    case 'weekly':
      return 'per week';
    case 'monthly':
      return 'per month';
    default:
      return 'subscription rate';
  }
}
