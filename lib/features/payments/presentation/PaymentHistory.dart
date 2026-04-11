import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';

class PaymentHistoryScreen extends StatefulWidget {
  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<dynamic> _paymentHistory = [];

  @override
  void initState() {
    super.initState();
    _paymentHistory = DummyData.samplePayments;
  }

  IconData _methodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi': return Icons.account_balance;
      case 'card': return Icons.credit_card;
      default: return Icons.language;
    }
  }

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
        title: Text('Payment History', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        centerTitle: false,
      ),
      body: _paymentHistory.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.payment_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No payments yet', style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _paymentHistory.length,
              itemBuilder: (context, index) {
                final payment = _paymentHistory[index];
                final createdAt = DateTime.fromMillisecondsSinceEpoch(payment['created_at'] * 1000);
                final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
                final amount = (payment['amount'] / 100).toStringAsFixed(0);
                final method = payment['method'] ?? 'N/A';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF019934).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_methodIcon(method), color: const Color(0xFF019934), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(payment['description'] ?? '', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(formattedDate, style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey.shade500)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Text('Success', style: GoogleFonts.rubik(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.green.shade700)),
                            ),
                            const SizedBox(width: 8),
                            Text(method, style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey.shade500)),
                          ]),
                        ]),
                      ),
                      Text('\u20B9$amount', style: GoogleFonts.rubik(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF019934))),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
