import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/data/repositories/subscription_repository.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';

/// Confirmation screen after a successful single-product subscription create.
/// Same visual pattern as [OrderSuccessScreen].
class SubscriptionSuccessScreen extends StatelessWidget {
  const SubscriptionSuccessScreen({
    super.key,
    required this.data,
    this.productName = '',
    this.planName = '',
    this.paymentPending = false,
  });

  final SubscriptionCreateData data;
  final String productName;
  final String planName;
  final bool paymentPending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                paymentPending ? 'Subscription created' : 'Subscribed!',
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (paymentPending) ...[
                const SizedBox(height: 8),
                Text(
                  'Payment was not completed. You can finish payment from Profile → Subscriptions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
              if (productName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  productName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              if (planName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  planName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (data.subscriptionId.isNotEmpty)
                _DetailRow(
                  label: 'Subscription ID',
                  value: data.subscriptionId,
                ),
              if (data.startDate.isNotEmpty)
                _DetailRow(label: 'Start date', value: data.startDate),
              if (data.endDate.isNotEmpty)
                _DetailRow(label: 'End date', value: data.endDate),
              if (data.totalDeliveries.isNotEmpty)
                _DetailRow(
                  label: 'Total deliveries',
                  value: data.totalDeliveries,
                ),
              if (data.message.isNotEmpty &&
                  data.subscriptionId.isEmpty &&
                  data.startDate.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  data.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(fontSize: 14),
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continue Shopping',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                  Future.microtask(() {
                    DashboardController.findOrPut().goToTab(4);
                  });
                },
                child: Text(
                  'Go to Profile',
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.rubik(fontSize: 15, color: Colors.grey.shade800),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
