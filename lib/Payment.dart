import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/Dashboard.dart';

class PaymentScreen extends StatelessWidget {
  final String? transactionId;
  final double? amount;

  const PaymentScreen({super.key, this.transactionId, this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F259F).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Color(0xFF5F259F), size: 72),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Successful!',
                  style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paid via PhonePe',
                  style: GoogleFonts.rubik(fontSize: 15, color: const Color(0xFF5F259F), fontWeight: FontWeight.w600),
                ),
                if (amount != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '₹${amount!.toStringAsFixed(0)}',
                    style: GoogleFonts.rubik(fontSize: 32, fontWeight: FontWeight.w700, color: const Color(0xFF019934)),
                  ),
                ],
                if (transactionId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Txn ID: $transactionId',
                      style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed successfully.',
                  style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF019934),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const Dashboard()),
                        (_) => false,
                      );
                    },
                    child: Text('Back to Home', style: GoogleFonts.rubik(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
