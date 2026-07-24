import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/payments/cards_controller.dart';
import 'package:urban_roots/features/payments/models/saved_card.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens PhonePe CARD-only tokenization checkout, then confirms via cards/confirm.php.
Future<SavedCard?> startSaveCardFlow(BuildContext context) async {
  final cards = CardsController.findOrPut();
  final sessionResult = await cards.startSaveCard();

  if (!context.mounted) return null;

  if (sessionResult is ApiFailure<CardSaveSession>) {
    await SweetAlert.error(context, message: sessionResult.message);
    return null;
  }

  final session = (sessionResult as ApiSuccess<CardSaveSession>).data;

  final txnId = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => _CardSaveWebView(
        paymentUrl: session.redirectUrl,
        knownTransactionId: session.transactionId,
      ),
    ),
  );

  if (!context.mounted) return null;
  if (txnId == null || txnId.isEmpty) {
    await SweetAlert.warning(
      context,
      message: 'Card save was cancelled or incomplete.',
    );
    return null;
  }

  final confirmResult = await cards.confirmSave(transactionId: txnId);
  if (!context.mounted) return null;

  if (confirmResult is ApiFailure<SavedCard>) {
    await SweetAlert.error(context, message: confirmResult.message);
    return null;
  }

  final card = (confirmResult as ApiSuccess<SavedCard>).data;
  await SweetAlert.success(
    context,
    message: card.maskedNumber.isNotEmpty
        ? 'Card ${card.maskedNumber} saved'
        : 'Card saved successfully',
  );
  return card;
}

class _CardSaveWebView extends StatefulWidget {
  const _CardSaveWebView({
    required this.paymentUrl,
    this.knownTransactionId = '',
  });

  final String paymentUrl;
  final String knownTransactionId;

  @override
  State<_CardSaveWebView> createState() => _CardSaveWebViewState();
}

class _CardSaveWebViewState extends State<_CardSaveWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _completed = false;

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

  String? _txnIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    for (final key in [
      'transaction_id',
      'transactionId',
      'txn_id',
      'txnId',
      'merchantTransactionId',
      'merchant_transaction_id',
    ]) {
      final value = uri.queryParameters[key];
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  bool _isSiteReturn(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.toLowerCase().contains('urbunroots.com');
  }

  bool _isFailureUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('cancel') ||
        lower.contains('failed') ||
        lower.contains('failure') ||
        lower.contains('status=fail');
  }

  void _handlePossibleReturn(String url) {
    if (_completed) return;
    if (_isFailureUrl(url) && _isSiteReturn(url)) {
      _finish(null);
      return;
    }
    if (!_isSiteReturn(url)) return;

    final txn = _txnIdFromUrl(url) ??
        (widget.knownTransactionId.isNotEmpty
            ? widget.knownTransactionId
            : null);
    if (txn != null && txn.isNotEmpty) {
      _finish(txn);
    }
  }

  void _finish(String? txnId) {
    if (_completed) return;
    _completed = true;
    if (mounted) Navigator.of(context).pop(txnId);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _finish(null);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'Save Card',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _finish(null),
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
            if (_isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.85),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              '₹1 card verification via PhonePe · card details stay on PhonePe',
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared brand icon for Visa / Mastercard / RuPay / Amex / default.
IconData cardNetworkIcon(String network) {
  final value = network.toLowerCase();
  if (value.contains('visa')) return Icons.credit_card;
  if (value.contains('master')) return Icons.credit_card;
  if (value.contains('rupay') || value.contains('ru pay')) {
    return Icons.credit_card;
  }
  if (value.contains('amex') || value.contains('american')) {
    return Icons.credit_card;
  }
  return Icons.credit_card_outlined;
}

Color cardNetworkColor(String network) {
  final value = network.toLowerCase();
  if (value.contains('visa')) return const Color(0xFF1A1F71);
  if (value.contains('master')) return const Color(0xFFEB001B);
  if (value.contains('rupay')) return const Color(0xFF097B3D);
  if (value.contains('amex')) return const Color(0xFF2E77BB);
  return AppColors.primary;
}
