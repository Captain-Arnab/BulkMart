class SavedCard {
  const SavedCard({
    required this.cardTokenId,
    required this.maskedNumber,
    required this.expiryDisplay,
    required this.cardNetwork,
  });

  final String cardTokenId;
  final String maskedNumber;
  final String expiryDisplay;
  final String cardNetwork;

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      cardTokenId: json['card_token_id']?.toString() ??
          json['token_id']?.toString() ??
          json['id']?.toString() ??
          '',
      maskedNumber: json['masked_number']?.toString() ??
          json['masked_card']?.toString() ??
          json['card_number']?.toString() ??
          '••••',
      expiryDisplay: json['expiry_display']?.toString() ??
          json['expiry']?.toString() ??
          json['exp']?.toString() ??
          '',
      cardNetwork: json['card_network']?.toString() ??
          json['network']?.toString() ??
          json['brand']?.toString() ??
          '',
    );
  }
}

class CardSaveSession {
  const CardSaveSession({
    required this.redirectUrl,
    this.transactionId = '',
  });

  final String redirectUrl;
  final String transactionId;
}
