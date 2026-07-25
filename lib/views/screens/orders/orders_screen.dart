import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../models/order_status.dart';
import '../../../repositories/order_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/ui_states.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  String? _error;
  List<Order> _orders = [];

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
    final result = await context.read<OrderRepository>().fetchOrders();
    if (!mounted) return;
    result.when(
      success: (page) {
        setState(() {
          _orders = page.items;
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
          'Orders',
          style: AppTextStyles.display(fontSize: 18, color: AppColors.white),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.forest,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.forest));
    }
    if (_error != null && _orders.isEmpty) {
      return ErrorState(message: _error!, onRetry: _load);
    }
    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          EmptyState(
            title: 'No orders yet',
            subtitle:
                'Active and past orders will show here once you place your first COD order.',
            icon: Icons.receipt_long_outlined,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.line),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.id,
                          style: AppTextStyles.mono(fontSize: 11, color: AppColors.slate),
                        ),
                      ),
                      _StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _priceFormat.format(order.total),
                    style: AppTextStyles.display(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} item${order.items.length == 1 ? '' : 's'} · '
                    '${DateFormat('d MMM yyyy').format(order.placedAt)} · COD',
                    style: AppTextStyles.body(fontSize: 11.5, color: AppColors.slate),
                  ),
                  if (order.estimatedDeliveryDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Est. delivery ${DateFormat('EEE, d MMM').format(order.estimatedDeliveryDate!)}',
                      style: AppTextStyles.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8A5C13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OrderStatus.delivered => (
          AppColors.forest.withValues(alpha: 0.14),
          AppColors.forestDark,
        ),
      OrderStatus.outForDelivery => (
          const Color(0xFF1E4E8C).withValues(alpha: 0.14),
          const Color(0xFF1E4E8C),
        ),
      OrderStatus.cancelled => (
          AppColors.rust.withValues(alpha: 0.14),
          AppColors.rust,
        ),
      _ => (
          AppColors.mustard.withValues(alpha: 0.18),
          const Color(0xFF8A5C13),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.mono(fontSize: 9, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
