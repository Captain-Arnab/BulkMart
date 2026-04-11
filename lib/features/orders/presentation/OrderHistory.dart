import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double subtotal;
  final String imageUrl;

  OrderItem({required this.name, required this.quantity, required this.subtotal, required this.imageUrl});
}

class Order {
  final int orderId;
  final String date;
  final double total;
  final List<OrderItem> items;

  Order({required this.orderId, required this.date, required this.total, required this.items});
}

class OrderHistory extends StatefulWidget {
  final List<Order> orders;
  OrderHistory({required this.orders});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateEvent(index: 4, category: 0)),
        ),
        title: Text('Order History', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        centerTitle: false,
      ),
      body: widget.orders.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No orders yet', style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.orders.length,
              itemBuilder: (context, index) {
                final order = widget.orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF019934).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.receipt_long, color: Color(0xFF019934)),
                      ),
                      title: Text('Order #${order.orderId}', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w600)),
                      subtitle: Text(order.date, style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade500)),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('\u20B9${order.total.toStringAsFixed(0)}', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF019934))),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                          child: Text('Delivered', style: GoogleFonts.rubik(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.green.shade700)),
                        ),
                      ]),
                      children: [
                        const Divider(height: 1),
                        ...order.items.map((item) {
                          final imageUrl = item.imageUrl.isNotEmpty ? item.imageUrl : 'assets/sample.png';
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(imageUrl, width: 44, height: 44, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.name, style: GoogleFonts.rubik(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text('Qty: ${item.quantity}', style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey.shade500)),
                              ])),
                              Text('\u20B9${item.subtotal.toStringAsFixed(0)}', style: GoogleFonts.rubik(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                            ]),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
