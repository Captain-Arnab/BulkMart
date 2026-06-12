import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/config/api_config.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/wallet/wallet_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens PhonePe (or other gateway) payment page and verifies payment on return.
class WalletPaymentWebView extends StatefulWidget {
  const WalletPaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.amount,
    this.transactionId = '',
    this.onReturnVerify,
  });

  final String paymentUrl;
  final String transactionId;
  final double amount;

  /// Optional server-side verification for order/subscription payments.
  final Future<bool> Function()? onReturnVerify;

  @override
  State<WalletPaymentWebView> createState() => _WalletPaymentWebViewState();
}

class _WalletPaymentWebViewState extends State<WalletPaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _completed = false;
  bool? _verifiedResult;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            _handlePossibleReturn(request.url);
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _handlePossibleReturn(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isSiteReturnUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.toLowerCase().contains('urbunroots.com');
  }

  bool? _paymentOutcomeFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final path = uri.path.toLowerCase();
    final query = uri.query.toLowerCase();
    final haystack = '$path?$query';

    if (RegExp(r'(?:^|[?&_=-])(?:cancel(?:led)?|cancelled|failed|failure|error|abort|declined)(?:[$&=/]|$)')
        .hasMatch(haystack)) {
      return false;
    }

    if (RegExp(r'(?:^|[?&_=-])(?:success|successful|paid|completed|verified)(?:[$&=/]|$)')
        .hasMatch(haystack)) {
      return true;
    }

    if (query.contains('status=fail') ||
        query.contains('status=failed') ||
        query.contains('status=cancel') ||
        query.contains('status=cancelled')) {
      return false;
    }

    if (query.contains('status=success') ||
        query.contains('status=paid') ||
        query.contains('status=completed')) {
      return true;
    }

    return null;
  }

  bool _shouldVerifyForUrl(String url) {
    if (_completed || _isVerifying || widget.transactionId.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final host = uri.host.toLowerCase();
    if (!host.contains('urbunroots.com')) return false;

    final path = uri.path.toLowerCase();
    final query = uri.query.toLowerCase();

    return path.contains('wallet') ||
        path.contains('verify') ||
        path.contains('payment') ||
        path.contains('callback') ||
        path.contains('return') ||
        query.contains('txn') ||
        query.contains('success') ||
        query.contains('status=success');
  }

  Future<void> _handlePossibleReturn(String url) async {
    if (_completed || _isVerifying) return;

    final urlOutcome = _paymentOutcomeFromUrl(url);
    if (urlOutcome == false) {
      _finish(false);
      return;
    }

    if (widget.transactionId.isNotEmpty && _shouldVerifyForUrl(url)) {
      await _verifyWalletAndFinish(trigger: 'redirect');
      return;
    }

    if (!_isSiteReturnUrl(url)) return;

    if (widget.onReturnVerify != null) {
      await _verifyExternalAndFinish();
      return;
    }

    if (urlOutcome == true) {
      _finish(true);
    }
  }

  Future<void> _verifyWalletAndFinish({required String trigger}) async {
    if (_completed || _isVerifying) return;
    setState(() => _isVerifying = true);

    final wallet = WalletController.findOrPut();
    final verified =
        await wallet.completeTopUpVerification(widget.transactionId);

    if (!mounted) return;

    if (verified) {
      _finish(true);
      return;
    }

    setState(() => _isVerifying = false);

    if (trigger == 'manual') {
      await SweetAlert.warning(
        context,
        message:
            'Payment not confirmed yet. Complete payment on PhonePe or try again.',
      );
    }
  }

  Future<void> _verifyExternalAndFinish() async {
    if (_completed || _isVerifying || widget.onReturnVerify == null) return;
    setState(() => _isVerifying = true);

    final verified = await widget.onReturnVerify!();

    if (!mounted) return;
    _finish(verified);
  }

  void _finish(bool success) {
    if (_completed) return;
    _completed = true;
    _verifiedResult = success;
    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }

  Future<void> _onClosePressed() async {
    if (_completed) {
      Navigator.of(context).pop(_verifiedResult ?? false);
      return;
    }

    if (widget.transactionId.isNotEmpty) {
      await _verifyWalletAndFinish(trigger: 'manual');
      if (!mounted || _completed) return;
      Navigator.of(context).pop(false);
      return;
    }

    // User explicitly closed/cancelled — do not treat as payment success.
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onClosePressed();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'Complete Payment',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          actions: [
            if (_isVerifying)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _onClosePressed,
                child: Text(
                  'Cancel',
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading || _isVerifying)
              Container(
                color: Colors.white.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF019934),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isVerifying ? 'Verifying payment...' : 'Loading PhonePe...',
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Pay ₹${widget.amount.toStringAsFixed(0)} via PhonePe · ${ApiConfig.siteRoot}',
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}
