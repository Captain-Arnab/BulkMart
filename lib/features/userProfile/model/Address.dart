class Address {
  String addressLine1;
  String? addressLine2; // Optional field
  String state;
  String city;
  String pincode;
  String category; // Home, Work, Others
  String? deliveryInstructions; // Optional field

  Address({
    required this.addressLine1,
    this.addressLine2,
    required this.state,
    required this.city,
    required this.pincode,
    required this.category,
    this.deliveryInstructions,
  });

  // Optionally, you can add methods for JSON serialization/deserialization
  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'state': state,
      'city': city,
      'pincode': pincode,
      'category': category,
      'deliveryInstructions': deliveryInstructions,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      category: json['category'],
      deliveryInstructions: json['deliveryInstructions'],
    );
  }
}
