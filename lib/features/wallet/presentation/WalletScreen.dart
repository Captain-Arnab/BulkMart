import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/payments/presentation/PhonePePaymentScreen.dart';
import 'package:urban_roots/features/wallet/domain/WalletController.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Get.put(WalletController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('My Wallet', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
      ),
      body: Obx(
        () => Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF019934), Color(0xFF01752A)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF019934).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Balance', style: GoogleFonts.rubik(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '₹${wallet.balance.value.toStringAsFixed(0)}',
                    style: GoogleFonts.rubik(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF019934),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _topUp(context, wallet),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text('Add Money', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Recent Transactions', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: wallet.transactions.length,
                itemBuilder: (context, index) {
                  final tx = wallet.transactions[index];
                  final isCredit = tx['type'] == 'credit';
                  final amount = (tx['amount'] as num).toDouble();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isCredit ? Colors.green : Colors.red).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isCredit ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx['title'] ?? '', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                '${tx['date']} • ${tx['method']}',
                                style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
                          style: GoogleFonts.rubik(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isCredit ? const Color(0xFF019934) : Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _topUp(BuildContext context, WalletController wallet) async {
    final result = await wallet.initiateTopUp(500);
    if (result is ApiFailure) {
      if (context.mounted) {
        await SweetAlert.error(context, message: (result as ApiFailure).message);
      }
      return;
    }
    final data = (result as ApiSuccess).data;
    final redirect = data['data']?['redirect_url']?.toString();
    if (redirect != null && context.mounted) {
      await SweetAlert.info(context, message: 'Complete payment at: $redirect');
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhonePePaymentScreen(
          amount: 500,
          title: 'Wallet Top-up',
          subtitle: 'Add ₹500 to Urban Roots Wallet',
          showSuccessScreen: false,
          onSuccess: () async {
            await wallet.loadBalance();
            await wallet.loadTransactions();
            if (context.mounted) {
              await SweetAlert.success(context, message: 'Wallet updated');
            }
          },
        ),
      ),
    );
  }
}
