import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    this.txnId,
  });

  final String orderId;
  final String? txnId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF019934), size: 80),
              const SizedBox(height: 16),
              Text(
                'Order Placed!',
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (orderId.isNotEmpty)
                Text(
                  'Order ID: $orderId',
                  style: GoogleFonts.rubik(fontSize: 16),
                ),
              if (txnId != null && txnId!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Transaction ID: $txnId',
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
