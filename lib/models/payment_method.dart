/// Display helpers for [Order.paymentMethod] codes.
extension PaymentMethodLabel on String {
  /// Maps API/storage codes to a buyer-facing label.
  String get paymentMethodLabel {
    switch (trim().toUpperCase()) {
      case 'COD':
      case 'CASH_ON_DELIVERY':
      case 'CASH ON DELIVERY':
        return 'Cash on Delivery';
      default:
        return trim().isEmpty ? 'Cash on Delivery' : trim();
    }
  }
}
