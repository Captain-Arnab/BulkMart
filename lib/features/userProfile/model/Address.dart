class Address {
  String id;
  String fullName;
  String phone;
  String addressLine1;
  String? addressLine2;
  String state;
  String city;
  String pincode;
  String category;
  String? deliveryInstructions;
  bool isDefault;

  Address({
    this.id = '',
    this.fullName = '',
    this.phone = '',
    required this.addressLine1,
    this.addressLine2,
    required this.state,
    required this.city,
    required this.pincode,
    required this.category,
    this.deliveryInstructions,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'state': state,
      'city': city,
      'pincode': pincode,
      'category': category,
      'deliveryInstructions': deliveryInstructions,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString(),
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Home',
      deliveryInstructions: json['deliveryInstructions']?.toString(),
      isDefault: json['isDefault'] == true,
    );
  }
}
