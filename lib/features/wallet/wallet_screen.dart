import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/Loader.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/repositories/wallet_repository.dart';
import 'package:urban_roots/features/wallet/wallet_controller.dart';
import 'package:urban_roots/features/wallet/wallet_payment_webview.dart';

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
        title: Text(
          'My Wallet',
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
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
                  Text(
                    'Available Balance',
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${wallet.balance.value.toStringAsFixed(0)}',
                    style: GoogleFonts.rubik(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF019934),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _openAddMoneySheet(context, wallet),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(
                            'Add Money',
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                  Text(
                    'Recent Transactions',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: wallet.transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet',
                        style: GoogleFonts.rubik(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: wallet.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = wallet.transactions[index];
                        final isCredit =
                            tx['type']?.toString().toLowerCase() == 'credit';
                        final amount =
                            double.tryParse(tx['amount']?.toString() ?? '0') ??
                                0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isCredit ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isCredit ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx['title']?.toString() ??
                                          tx['description']?.toString() ??
                                          'Transaction',
                                      style: GoogleFonts.rubik(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${tx['date'] ?? ''} • ${tx['method'] ?? ''}',
                                      style: GoogleFonts.rubik(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
                                style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isCredit
                                      ? const Color(0xFF019934)
                                      : Colors.red.shade400,
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

  Future<void> _openAddMoneySheet(
    BuildContext context,
    WalletController wallet,
  ) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMoneySheet(),
    );
    if (amount == null || amount <= 0 || !context.mounted) return;
    await _startTopUp(context, wallet, amount);
  }

  Future<void> _startTopUp(
    BuildContext context,
    WalletController wallet,
    double amount,
  ) async {
    Loader.show(context);
    final repo = ApiWalletRepository();
    final result = await repo.topUpWallet(amount);
    if (context.mounted) Loader.hide(context);

    if (result is ApiFailure<WalletTopUpResult>) {
      if (context.mounted) {
        await SweetAlert.error(context, message: result.message);
      }
      return;
    }

    final topUp = (result as ApiSuccess<WalletTopUpResult>).data;
    if (!context.mounted) return;

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPaymentWebView(
          paymentUrl: topUp.redirectUrl,
          transactionId: topUp.transactionId,
          amount: amount,
        ),
      ),
    );

    if (!context.mounted) return;

    // Payment completion happens in the redirect/webview flow — never assume
    // success just because initiateTopUp returned a redirect URL.
    if (success == true) {
      await wallet.loadBalance();
      await wallet.loadTransactions();
      await SweetAlert.success(
        context,
        message: 'Wallet topped up successfully!',
      );
    } else {
      await SweetAlert.info(
        context,
        title: 'Payment pending',
        message:
            'If you completed payment, your balance will update shortly. '
            'Pull to refresh if needed.',
      );
      await wallet.loadBalance();
    }
  }
}

class _AddMoneySheet extends StatefulWidget {
  const _AddMoneySheet();

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  static const _presets = [100.0, 200.0, 500.0, 1000.0];
  final _custom = TextEditingController();
  double? _selected = 500;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  double? get _amount {
    final custom = double.tryParse(_custom.text.trim());
    if (custom != null && custom > 0) return custom;
    return _selected;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Money',
                style: GoogleFonts.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select an amount or enter a custom value',
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presets.map((value) {
                  final selected = _selected == value && _custom.text.isEmpty;
                  return ChoiceChip(
                    label: Text('₹${value.toStringAsFixed(0)}'),
                    selected: selected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: GoogleFonts.rubik(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : Colors.black87,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selected = value;
                        _custom.clear();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _custom,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Custom amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (_) => setState(() => _selected = null),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = _amount;
                    if (amount == null || amount < 1) {
                      showAppToast(
                        context,
                        'Enter a valid amount',
                        isError: true,
                      );
                      return;
                    }
                    Navigator.pop(context, amount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Continue to Pay',
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
