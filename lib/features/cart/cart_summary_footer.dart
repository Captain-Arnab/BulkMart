import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/checkout/checkout_summary.dart';

/// Compact price breakdown for the cart screen footer.
class CartSummaryFooter extends StatelessWidget {
  const CartSummaryFooter({
    super.key,
    required this.summary,
    required this.onCheckout,
    this.isLoading = false,
  });

  final CheckoutSummary summary;
  final VoidCallback onCheckout;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row('Items (${summary.lines.length})', summary.itemsTotal),
            if (summary.totalGst > 0)
              _row('GST (included)', summary.totalGst, muted: true),
            if (summary.deliveryFee > 0) _row('Delivery', summary.deliveryFee),
            if (summary.discount > 0)
              _row(
                'Discount',
                -summary.discount,
                valueColor: AppColors.primary,
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total payable',
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '₹${summary.grandTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.rubik(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Proceed to Checkout',
              isLoading: isLoading,
              onPressed: onCheckout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    double amount, {
    bool muted = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: muted ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
          Text(
            '${amount < 0 ? '-' : ''}₹${amount.abs().toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}',
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
