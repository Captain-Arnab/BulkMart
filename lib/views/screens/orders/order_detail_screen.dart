import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/cart_item.dart';
import '../../../models/order.dart';
import '../../../models/order_status.dart';
import '../../../models/payment_method.dart';
import '../../../repositories/order_repository.dart';
import '../../../repositories/product_repository.dart';
import '../../../services/api/result.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/product_network_image.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/ui_states.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loading = true;
  bool _cancelling = false;
  String? _error;
  Order? _order;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result =
        await context.read<OrderRepository>().fetchOrderDetail(widget.orderId);
    if (!mounted) return;
    if (result is Success<Order>) {
      final enriched = await _enrichMissingImages(result.data);
      if (!mounted) return;
      setState(() {
        _order = enriched;
        _loading = false;
      });
      return;
    }
    final failure = result as Failure<Order>;
    setState(() {
      _error = failure.message;
      _loading = false;
    });
  }

  /// List/detail payloads may omit image_url — fill from catalog when needed.
  Future<Order> _enrichMissingImages(Order order) async {
    final needsLookup = order.items.any(
      (i) => !i.product.hasImage && i.product.id.trim().isNotEmpty,
    );
    if (!needsLookup) return order;

    final products = context.read<ProductRepository>();
    final next = <CartItem>[];
    for (final item in order.items) {
      if (item.product.hasImage || item.product.id.trim().isEmpty) {
        next.add(item);
        continue;
      }
      final lookedUp = await products.getProductById(item.product.id);
      final catalog = lookedUp.dataOrNull;
      if (catalog != null && catalog.hasImage) {
        next.add(
          item.copyWith(
            product: item.product.copyWith(imageUrl: catalog.imageUrl),
          ),
        );
      } else {
        next.add(item);
      }
    }
    return order.copyWith(items: next);
  }

  @override
  Widget build(BuildContext context) {
    final titleId = _order?.displayId ?? widget.orderId;
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Order $titleId',
          style: AppTextStyles.display(fontSize: 17, color: AppColors.white),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.forest));
    }
    if (_error != null || _order == null) {
      return ErrorState(message: _error ?? 'Not found', onRetry: _load);
    }

    final order = _order!;
    return RefreshIndicator(
      color: AppColors.forest,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.displayId,
                  style: AppTextStyles.mono(fontSize: 11, color: AppColors.slate),
                ),
                const SizedBox(height: 4),
                Text(
                  _priceFormat.format(order.total),
                  style: AppTextStyles.display(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placed ${DateFormat('d MMM yyyy, h:mm a').format(order.placedAt)}',
                  style: AppTextStyles.body(fontSize: 12, color: AppColors.slate),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Payment',
                      style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                    ),
                    const Spacer(),
                    Text(
                      order.paymentMethod.paymentMethodLabel,
                      style: AppTextStyles.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Tracking', style: AppTextStyles.display(fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: StatusTimeline(
              steps: StatusTimeline.forStatus(
                order.status,
                estimatedDelivery: order.estimatedDeliveryDate,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Items', style: AppTextStyles.display(fontSize: 16)),
          const SizedBox(height: 10),
          ...order.items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: ProductNetworkImage(
                        product: item.product,
                        iconSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: AppTextStyles.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Qty ${item.quantity.toString().padLeft(2, '0')} · ${item.product.unit}',
                          style: AppTextStyles.mono(fontSize: 10, color: AppColors.slate),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _priceFormat.format(item.lineTotal),
                    style: AppTextStyles.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestDark,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_canCancel(order)) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _cancelling ? null : () => _confirmCancel(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rust,
                side: const BorderSide(color: AppColors.rust),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _cancelling ? 'Cancelling…' : 'Cancel Order',
                style: AppTextStyles.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.rust,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canCancel(Order order) {
    return order.status == OrderStatus.placed ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.deliveryDateSet;
  }

  Future<void> _confirmCancel(Order order) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel order?'),
        content: Text('Cancel order ${order.displayId}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _cancelling = true);
    final result = await context.read<OrderRepository>().cancelOrder(order.id);
    if (!mounted) return;
    result.when(
      success: (updated) {
        setState(() {
          _order = updated.copyWith(
            items: _order?.items ?? updated.items,
            orderNumber: updated.orderNumber ?? _order?.orderNumber,
          );
          _cancelling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
      },
      failure: (message, {statusCode, code, fields}) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }
}
