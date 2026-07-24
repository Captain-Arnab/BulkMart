import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/data/repositories/subscription_repository.dart';
import 'package:urban_roots/features/subscription/presentation/subscription_success_screen.dart';
import 'package:urban_roots/features/subscription/subscribe_view_model.dart';
import 'package:urban_roots/features/wallet/wallet_payment_webview.dart';

/// Post-create payment UX: brief charge confirmation → PhonePe WebView →
/// check-status → success, or a distinct failure + Retry Payment.
///
/// Retry Payment re-calls create.php (server dedupes pending / issues fresh URL).
class SubscriptionPaymentFlowScreen extends StatefulWidget {
  const SubscriptionPaymentFlowScreen({
    super.key,
    required this.viewModel,
  });

  final SubscribeViewModel viewModel;

  @override
  State<SubscriptionPaymentFlowScreen> createState() =>
      _SubscriptionPaymentFlowScreenState();
}

enum _PaymentPhase { confirming, opening, failed, verifying }

class _SubscriptionPaymentFlowScreenState
    extends State<SubscriptionPaymentFlowScreen> {
  _PaymentPhase _phase = _PaymentPhase.confirming;
  bool _started = false;

  SubscribeViewModel get _vm => widget.viewModel;

  SubscriptionCreateData? get _data => _vm.pendingPayment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started && mounted) {
        _started = true;
        _runConfirmThenPay();
      }
    });
  }

  Future<void> _runConfirmThenPay() async {
    final data = _data;
    if (data == null || !data.requiresPayment) {
      if (!mounted) return;
      _goToSuccess();
      return;
    }

    setState(() => _phase = _PaymentPhase.confirming);

    // Brief transitional state so the user sees the authoritative amount
    // from create.php before PhonePe opens.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    await _openPaymentWebView();
  }

  Future<void> _openPaymentWebView() async {
    final data = _data;
    if (data == null) return;

    final url = data.paymentUrl?.trim() ?? '';
    if (url.isEmpty) {
      setState(() => _phase = _PaymentPhase.failed);
      return;
    }

    setState(() => _phase = _PaymentPhase.opening);

    final amount = data.amount ?? 0;
    final txn = data.paymentReferenceId;
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WalletPaymentWebView(
          paymentUrl: url,
          amount: amount,
          transactionId: '',
          onReturnVerify: txn.isEmpty ? null : () => _vm.verifyPendingPayment(),
        ),
      ),
    );

    if (!mounted) return;

    if (paid == true) {
      setState(() => _phase = _PaymentPhase.verifying);
      final verified = await _vm.verifyPendingPayment();
      if (!mounted) return;
      if (verified) {
        _goToSuccess();
        return;
      }
      // WebView reported success but check-status did not — treat as unpaid.
      setState(() => _phase = _PaymentPhase.failed);
      return;
    }

    setState(() => _phase = _PaymentPhase.failed);
  }

  void _goToSuccess() {
    final data = _data;
    if (data == null) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SubscriptionSuccessScreen(
          data: data,
          productName: _vm.pendingProductName,
          planName: _vm.pendingPlanName,
        ),
      ),
    );
  }

  Future<void> _retryPayment() async {
    // Re-call create.php — backend returns same pending URL or a fresh one.
    setState(() => _phase = _PaymentPhase.confirming);
    final data = await _vm.retryCreate();
    if (!mounted) return;

    if (data == null || !data.requiresPayment) {
      if (data != null && !data.requiresPayment) {
        _goToSuccess();
        return;
      }
      setState(() => _phase = _PaymentPhase.failed);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _openPaymentWebView();
  }

  /// TEMPORARY: PhonePe is rejecting all attempts account-wide — use these
  /// debug actions to exercise success/failure UI without a real gateway return.
  Future<void> _debugSimulateSuccess() async {
    setState(() => _phase = _PaymentPhase.verifying);
    // Skip live check-status in the stub path so UI can be reviewed offline.
    if (!mounted) return;
    _goToSuccess();
  }

  void _debugSimulateFailure() {
    setState(() => _phase = _PaymentPhase.failed);
  }

  String _confirmingMessage(SubscriptionCreateData data) {
    final amount = data.amount;
    final deliveries = data.totalDeliveries.trim();
    final amountPart = amount != null && amount > 0
        ? '₹${amount.toStringAsFixed(0)}'
        : 'the listed amount';
    final deliveryPart = deliveries.isNotEmpty
        ? '$deliveries deliveries'
        : 'your plan deliveries';
    return 'Confirming your subscription — $amountPart for $deliveryPart';
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _phase == _PaymentPhase.failed
              ? 'Payment incomplete'
              : 'Subscription payment',
          style: GoogleFonts.rubik(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: data == null
              ? Center(
                  child: Text(
                    'No pending subscription payment.',
                    style: GoogleFonts.rubik(color: Colors.grey.shade600),
                  ),
                )
              : _phase == _PaymentPhase.failed
                  ? _FailureBody(
                      data: data,
                      productName: _vm.pendingProductName,
                      planName: _vm.pendingPlanName,
                      canRetry: _vm.canRetryPayment,
                      isRetrying: _vm.isCreating,
                      onRetry: _retryPayment,
                      onClose: () => Navigator.of(context).pop(),
                    )
                  : _BusyBody(
                      message: _phase == _PaymentPhase.verifying
                          ? 'Verifying payment…'
                          : _phase == _PaymentPhase.opening
                              ? 'Opening PhonePe…'
                              : _confirmingMessage(data),
                      subtitle: _phase == _PaymentPhase.confirming
                          ? 'You’ll be charged this amount for the full term.'
                          : null,
                    ),
        ),
      ),
      // TEMPORARY stub controls — remove once PhonePe account payments work.
      bottomNavigationBar: kDebugMode && data != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TEMP debug stubs (PhonePe account blocked)',
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _debugSimulateFailure,
                            child: const Text('Simulate fail'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _debugSimulateSuccess,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Simulate success'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _BusyBody extends StatelessWidget {
  const _BusyBody({required this.message, this.subtitle});

  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({
    required this.data,
    required this.productName,
    required this.planName,
    required this.canRetry,
    required this.isRetrying,
    required this.onRetry,
    required this.onClose,
  });

  final SubscriptionCreateData data;
  final String productName;
  final String planName;
  final bool canRetry;
  final bool isRetrying;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(
          Icons.payment_outlined,
          size: 72,
          color: Colors.orange.shade700,
        ),
        const SizedBox(height: 16),
        Text(
          'Payment couldn’t be completed',
          textAlign: TextAlign.center,
          style: GoogleFonts.rubik(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Payment couldn’t be completed — please try again in a moment. '
          'Your subscription is saved and waiting for payment; this is not a new signup.',
          textAlign: TextAlign.center,
          style: GoogleFonts.rubik(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        if (productName.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            productName,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        if (planName.isNotEmpty)
          Text(
            planName,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        if (data.subscriptionId.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Subscription ID: ${data.subscriptionId}',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
        if (data.amount != null && data.amount! > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Amount: ₹${data.amount!.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
        const Spacer(),
        if (canRetry)
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isRetrying ? null : onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isRetrying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Retry Payment',
                      style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: isRetrying ? null : onClose,
          child: Text(
            'Close',
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
