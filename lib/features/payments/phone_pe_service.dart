import 'dart:math';

/// Demo PhonePe payment simulation for client presentations.
/// Production: integrate PhonePe PG SDK with merchantId, saltKey, and redirect URLs.
class PhonePeService {
  static String generateTransactionId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'PP$ts$rand';
  }

  /// Simulates PhonePe payment processing (1.5–2.5s).
  static Future<PhonePePaymentResult> initiatePayment({
    required double amountInRupees,
    required String orderTitle,
    String method = 'UPI',
  }) async {
    await Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(1000)));
    return PhonePePaymentResult(
      success: true,
      transactionId: generateTransactionId(),
      amountInPaise: (amountInRupees * 100).round(),
      method: method,
      gateway: 'PhonePe',
    );
  }
}

class PhonePePaymentResult {
  final bool success;
  final String transactionId;
  final int amountInPaise;
  final String method;
  final String gateway;

  PhonePePaymentResult({
    required this.success,
    required this.transactionId,
    required this.amountInPaise,
    required this.method,
    required this.gateway,
  });
}
