import 'package:flutter/material.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/features/payments/domain/PhonePeService.dart';
import 'package:urban_roots/Payment.dart';

class PhonePePaymentScreen extends StatefulWidget {
  final double amount;
  final String title;
  final String subtitle;
  final VoidCallback? onSuccess;
  final bool showSuccessScreen;

  const PhonePePaymentScreen({
    super.key,
    required this.amount,
    required this.title,
    required this.subtitle,
    this.onSuccess,
    this.showSuccessScreen = true,
  });

  @override
  State<PhonePePaymentScreen> createState() => _PhonePePaymentScreenState();
}

class _PhonePePaymentScreenState extends State<PhonePePaymentScreen> {
  static const Color _phonePePurple = Color(0xFF5F259F);

  String _selectedMethod = 'UPI';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        backgroundColor: _phonePePurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PhonePe',
                style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w800, color: _phonePePurple),
              ),
            ),
            const SizedBox(width: 8),
            Text('Secure Pay', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            color: _phonePePurple,
            child: Column(
              children: [
                Text('Amount to pay', style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.rubik(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(widget.title, style: GoogleFonts.rubik(fontSize: 14, color: Colors.white)),
                Text(widget.subtitle, style: GoogleFonts.rubik(fontSize: 12, color: Colors.white60), textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Pay using', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _methodTile('UPI', 'Pay via UPI apps', Icons.account_balance_wallet_outlined),
                _methodTile('PhonePe Wallet', 'Urban Roots linked wallet', Icons.wallet_outlined),
                _methodTile('Card', 'Debit / Credit Card', Icons.credit_card_outlined),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _phonePePurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isProcessing ? null : _pay,
                child: _isProcessing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Pay ₹${widget.amount.toStringAsFixed(0)}', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodTile(String method, String subtitle, IconData icon) {
    final selected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _phonePePurple : Colors.grey.shade200, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _phonePePurple : Colors.grey.shade600),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method, style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _phonePePurple : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _isProcessing = true);

    final result = await PhonePeService.initiatePayment(
      amountInRupees: widget.amount,
      orderTitle: widget.title,
      method: _selectedMethod,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (!result.success) {
      await SweetAlert.error(context, message: 'Payment failed. Please try again.');
      return;
    }

    widget.onSuccess?.call();

    if (widget.showSuccessScreen && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PaymentScreen(transactionId: result.transactionId, amount: widget.amount)),
      );
    } else if (mounted) {
      Navigator.pop(context, result);
    }
  }
}
