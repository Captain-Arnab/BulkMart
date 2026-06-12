import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/payments/payment_history_controller.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late final PaymentHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentHistoryController.findOrPut();
    _controller.loadPayments();
  }

  IconData _methodIcon(String method) {
    final value = method.toLowerCase();
    if (value.contains('wallet')) return Icons.account_balance_wallet_outlined;
    if (value.contains('cod') || value.contains('cash')) {
      return Icons.payments_outlined;
    }
    if (value.contains('upi') || value.contains('phonepe')) {
      return Icons.account_balance;
    }
    if (value.contains('card')) return Icons.credit_card;
    return Icons.language;
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

  ({String label, Color bg, Color fg}) _statusStyle(String status) {
    final value = status.toLowerCase();
    if (value.contains('cancel')) {
      return (
        label: 'Cancelled',
        bg: Colors.red.shade50,
        fg: Colors.red.shade700,
      );
    }
    if (value.contains('fail') ||
        value.contains('declined') ||
        value.contains('refund')) {
      return (
        label: 'Failed',
        bg: Colors.red.shade50,
        fg: Colors.red.shade700,
      );
    }
    if (value.contains('pending') ||
        value.contains('unpaid') ||
        value.contains('initiated')) {
      return (
        label: 'Pending',
        bg: Colors.orange.shade50,
        fg: Colors.orange.shade800,
      );
    }
    return (
      label: 'Completed',
      bg: Colors.green.shade50,
      fg: Colors.green.shade700,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => DashboardController.findOrPut().backToProfile(),
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
        if (_controller.isLoading.value && _controller.payments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.payments.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.error,
            errorMessage: _controller.errorMessage.value,
            onRetry: _controller.loadPayments,
            child: const SizedBox(),
          );
        }
        if (_controller.payments.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.empty,
            emptyMessage: 'No payments yet',
            child: const SizedBox(),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _controller.loadPayments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.payments.length,
            itemBuilder: (context, index) {
              final payment = _controller.payments[index];
              final formattedDate = _formatDate(payment);
              final amount = _formatAmount(payment);
              final method = payment['method']?.toString() ?? 'N/A';
              final gateway = payment['gateway']?.toString() ?? '';
              final status =
                  payment['status']?.toString().toLowerCase() ?? 'pending';
              final statusStyle = _statusStyle(status);
              final isNegative = status.contains('cancel') ||
                  status.contains('fail') ||
                  status.contains('refund');

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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _methodIcon(method),
                        color: AppColors.primary,
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
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusStyle.bg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusStyle.label,
                                  style: GoogleFonts.rubik(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: statusStyle.fg,
                                  ),
                                ),
                              ),
                              if (gateway.isNotEmpty &&
                                  gateway.toLowerCase() != method.toLowerCase())
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gateway.toLowerCase() == 'phonepe'
                                        ? const Color(0xFF5F259F)
                                            .withValues(alpha: 0.12)
                                        : AppColors.surfaceMint,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    gateway,
                                    style: GoogleFonts.rubik(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: gateway.toLowerCase() == 'phonepe'
                                          ? const Color(0xFF5F259F)
                                          : AppColors.primaryDark,
                                    ),
                                  ),
                                ),
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
                      '₹$amount',
                      style: GoogleFonts.rubik(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isNegative
                            ? Colors.grey.shade600
                            : AppColors.primary,
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
