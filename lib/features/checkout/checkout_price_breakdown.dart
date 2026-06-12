import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/checkout/checkout_summary.dart';

class CheckoutPriceBreakdown extends StatelessWidget {
  const CheckoutPriceBreakdown({super.key, required this.summary});

  final CheckoutSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.softCard(radius: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...summary.lines.map(_lineRow),
          const Divider(height: 24),
          _amountRow('Items total', summary.itemsTotal),
          if (summary.totalGst > 0)
            _amountRow('GST (included)', summary.totalGst, muted: true),
          if (summary.deliveryFee > 0)
            _amountRow('Delivery fee', summary.deliveryFee),
          if (summary.discount > 0)
            _amountRow(
              'Coupon / discount',
              -summary.discount,
              valueColor: AppColors.primary,
            ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total payable',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹${summary.grandTotal.toStringAsFixed(0)}',
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineRow(CheckoutLineItem line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  '₹${line.unitPrice.toStringAsFixed(0)} × ${line.quantity}',
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                '₹${line.lineTotal.toStringAsFixed(0)}',
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (line.gstPercent > 0) ...[
            const SizedBox(height: 2),
            Text(
              'GST ${line.gstPercent.toStringAsFixed(0)}% (₹${line.gstAmount.toStringAsFixed(2)} incl.)',
              style: GoogleFonts.rubik(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _amountRow(
    String label,
    double amount, {
    bool muted = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
