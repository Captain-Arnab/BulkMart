import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/orders/order_detail_screen.dart';
import 'package:urban_roots/features/orders/order_model.dart';
import 'package:urban_roots/features/orders/order_segment.dart';
import 'package:urban_roots/features/orders/orders_controller.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  void initState() {
    super.initState();
    OrdersController.findOrPut().loadOrders();
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('deliver') || lower.contains('complete')) {
      return Colors.green.shade700;
    }
    if (lower.contains('cancel') || lower.contains('fail')) {
      return Colors.red.shade700;
    }
    return Colors.orange.shade800;
  }

  Color _statusBg(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('deliver') || lower.contains('complete')) {
      return Colors.green.shade50;
    }
    if (lower.contains('cancel') || lower.contains('fail')) {
      return Colors.red.shade50;
    }
    return Colors.orange.shade50;
  }

  String _displayStatus(Order order, OrderSegment segment) {
    return order.displayStatusForSegment(segment);
  }

  void _openOrderDetail(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          orderId: order.orderId > 0 ? order.orderId : null,
          txnId: order.txnId.isNotEmpty ? order.txnId : null,
          summary: order,
        ),
      ),
    );
  }

  String _itemPreview(Order order) {
    if (order.items.isEmpty) return 'Tap to view details';
    if (order.items.length == 1) return order.items.first.name;
    return '${order.items.length} items · ${order.items.first.name}';
  }

  Widget _orderTile(
    BuildContext context,
    Order order,
    OrderSegment segment,
  ) {
    final status = _displayStatus(order, segment);
    final itemPreview = _itemPreview(order);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openOrderDetail(context, order),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderId > 0
                            ? 'Order #${order.orderId}'
                            : 'Order ${order.txnId.isNotEmpty ? order.txnId : ''}',
                        style: GoogleFonts.rubik(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.date,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemPreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\u20B9${order.total.toStringAsFixed(0)}',
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.rubik(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _segmentList(
    BuildContext context,
    OrdersController controller,
    OrderSegment segment,
    String emptyMessage,
  ) {
    final orders =
        controller.orders.where((o) => o.segment == segment).toList();

    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: ApiStateView(
              status: ApiViewStatus.empty,
              emptyMessage: emptyMessage,
              child: const SizedBox(),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) =>
          _orderTile(context, orders[index], segment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = OrdersController.findOrPut();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => DashboardController.findOrPut().backToProfile(),
          ),
          title: Text(
            'Order History',
            style: GoogleFonts.rubik(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.rubik(fontSize: 12),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: orderSegmentLabel(OrderSegment.willDeliver)),
              Tab(text: orderSegmentLabel(OrderSegment.delivered)),
              Tab(text: orderSegmentLabel(OrderSegment.cancelledOrUnpaid)),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.orders.isEmpty) {
            return ApiStateView(
              status: ApiViewStatus.error,
              errorMessage: controller.errorMessage.value,
              onRetry: controller.loadOrders,
              child: const SizedBox(),
            );
          }

          return TabBarView(
            children: [
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.loadOrders,
                child: _segmentList(
                  context,
                  controller,
                  OrderSegment.willDeliver,
                  'No active orders to deliver',
                ),
              ),
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.loadOrders,
                child: _segmentList(
                  context,
                  controller,
                  OrderSegment.delivered,
                  'No delivered orders yet',
                ),
              ),
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.loadOrders,
                child: _segmentList(
                  context,
                  controller,
                  OrderSegment.cancelledOrUnpaid,
                  'No pending or cancelled orders',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
