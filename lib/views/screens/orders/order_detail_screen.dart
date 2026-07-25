import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../repositories/order_repository.dart';
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
    final result = await context.read<OrderRepository>().fetchOrderDetail(widget.orderId);
    if (!mounted) return;
    result.when(
      success: (order) {
        setState(() {
          _order = order;
          _loading = false;
        });
      },
      failure: (message, {statusCode}) {
        setState(() {
          _error = message;
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Order ${widget.orderId}',
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
                  order.id,
                  style: AppTextStyles.mono(fontSize: 11, color: AppColors.slate),
                ),
                const SizedBox(height: 4),
                Text(
                  _priceFormat.format(order.total),
                  style: AppTextStyles.display(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placed ${DateFormat('d MMM yyyy, h:mm a').format(order.placedAt)} · COD',
                  style: AppTextStyles.body(fontSize: 12, color: AppColors.slate),
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
                          'Qty ${item.quantity.toString().padLeft(2, '0')} · ${item.product.unitSize}',
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
        ],
      ),
    );
  }
}
