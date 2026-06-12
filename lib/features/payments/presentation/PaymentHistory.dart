import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';
import 'package:urban_roots/features/payments/domain/payment_history_controller.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  IconData _methodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.language;
    }
  }

  String _formatAmount(Map<String, dynamic> payment) {
    final raw = payment['amount'];
    if (raw is num) {
      return raw.toDouble().toStringAsFixed(0);
    }
    return '0';
  }

  String _formatDate(Map<String, dynamic> payment) {
    final createdAt = payment['created_at'];
    if (createdAt is int && createdAt > 0) {
      final dt = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    }
    if (createdAt is String && createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = PaymentHistoryController.findOrPut();

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
          'Payment History',
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
            controller.payments.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.error,
            errorMessage: controller.errorMessage.value,
            onRetry: controller.loadPayments,
            child: const SizedBox(),
          );
        }
        if (controller.payments.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.empty,
            emptyMessage: 'No payments yet',
            child: const SizedBox(),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF019934),
          onRefresh: controller.loadPayments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.payments.length,
            itemBuilder: (context, index) {
              final payment = controller.payments[index];
              final formattedDate = _formatDate(payment);
              final amount = _formatAmount(payment);
              final method = payment['method']?.toString() ?? 'N/A';
              final status =
                  payment['status']?.toString().toLowerCase() ?? 'success';
              final isSuccess = status.contains('success') ||
                  status.contains('complete') ||
                  status.contains('paid');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF019934).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _methodIcon(method),
                        color: const Color(0xFF019934),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment['description']?.toString() ?? '',
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (formattedDate.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSuccess
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isSuccess ? 'Success' : status,
                                  style: GoogleFonts.rubik(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: isSuccess
                                        ? Colors.green.shade700
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                              if ((payment['gateway'] ?? '').toString() ==
                                  'PhonePe') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5F259F)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PhonePe',
                                    style: GoogleFonts.rubik(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF5F259F),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Text(
                                method,
                                style: GoogleFonts.rubik(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\u20B9$amount',
                      style: GoogleFonts.rubik(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF019934),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
