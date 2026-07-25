class User {
  const User({
    required this.id,
    required this.mobile,
    required this.businessName,
    this.address,
    this.gstNumber,
    this.email,
  });

  final String id;
  final String mobile;
  final String businessName;
  final String? address;
  final String? gstNumber;
  final String? email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      businessName:
          json['business_name']?.toString() ?? json['businessName']?.toString() ?? '',
      address: json['address']?.toString(),
      gstNumber: json['gst_number']?.toString() ?? json['gstNumber']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mobile': mobile,
        'business_name': businessName,
        if (address != null) 'address': address,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (email != null) 'email': email,
      };

  User copyWith({
    String? id,
    String? mobile,
    String? businessName,
    String? address,
    String? gstNumber,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      email: email ?? this.email,
    );
  }
}
