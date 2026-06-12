import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';
import 'package:urban_roots/features/orders/domain/orders_controller.dart';
import 'package:urban_roots/features/orders/models/order_model.dart';
import 'package:urban_roots/features/orders/presentation/order_detail_screen.dart';

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

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

  String _displayStatus(String status) {
    if (status.trim().isEmpty) return 'Processing';
    return status;
  }

  void _openOrderDetail(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          orderId: order.orderId,
          summary: order,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = OrdersController.findOrPut();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => BlocProvider.of<DashboardBloc>(context)
              .add(DashboardUpdateEvent(index: 4, category: 0)),
        ),
        title: Text(
          'Order History',
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF019934)),
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
        if (controller.orders.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.empty,
            emptyMessage: 'No orders yet',
            child: const SizedBox(),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF019934),
          onRefresh: controller.loadOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              final status = _displayStatus(order.status);
              final itemPreview = order.items.isEmpty
                  ? 'Tap to view details'
                  : order.items.length == 1
                      ? order.items.first.name
                      : '${order.items.length} items';

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
                              color: const Color(0xFF019934)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF019934),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.orderId}',
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
                                  color: const Color(0xFF019934),
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
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
