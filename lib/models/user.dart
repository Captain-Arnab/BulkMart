class User {
  const User({
    required this.id,
    required this.mobile,
    required this.businessName,
    this.address,
    this.gstNumber,
    this.email,
    this.contactPerson,
    this.businessType,
    this.avatarPath,
  });

  final String id;
  final String mobile;
  final String businessName;
  final String? address;
  final String? gstNumber;
  final String? email;
  final String? contactPerson;
  final String? businessType;

  /// Local file path (demo) or remote URL for profile photo.
  final String? avatarPath;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      businessName:
          json['business_name']?.toString() ?? json['businessName']?.toString() ?? '',
      address: json['address']?.toString(),
      gstNumber: json['gst_number']?.toString() ?? json['gstNumber']?.toString(),
      email: json['email']?.toString(),
      contactPerson:
          json['contact_person']?.toString() ?? json['contactPerson']?.toString(),
      businessType:
          json['business_type']?.toString() ?? json['businessType']?.toString(),
      avatarPath:
          json['avatar_path']?.toString() ??
          json['avatarPath']?.toString() ??
          json['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mobile': mobile,
        'business_name': businessName,
        if (address != null) 'address': address,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (email != null) 'email': email,
        if (contactPerson != null) 'contact_person': contactPerson,
        if (businessType != null) 'business_type': businessType,
        if (avatarPath != null) 'avatar_path': avatarPath,
      };

  User copyWith({
    String? id,
    String? mobile,
    String? businessName,
    String? address,
    String? gstNumber,
    String? email,
    String? contactPerson,
    String? businessType,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return User(
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      email: email ?? this.email,
      contactPerson: contactPerson ?? this.contactPerson,
      businessType: businessType ?? this.businessType,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
    );
  }

  /// Initials from business name (up to 2 letters).
  String get initials {
    final parts = businessName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return 'B';
    final list = parts.toList();
    if (list.length == 1) {
      final s = list.first;
      return (s.length >= 2 ? s.substring(0, 2) : s).toUpperCase();
    }
    return ('${list[0][0]}${list[1][0]}').toUpperCase();
  }
}
