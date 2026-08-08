import 'business_type.dart';
import 'kyc_status.dart';

class User {
  const User({
    required this.id,
    required this.mobile,
    required this.businessName,
    this.address,
    this.gstNumber,
    this.email,
    this.contactPerson,
    this.ownerName,
    this.businessType,
    this.businessTypeId,
    this.avatarPath,
    this.fssaiNumber,
    this.panNumber,
    this.shopAddress,
    this.deliveryAddress,
    this.city,
    this.state,
    this.landmark,
    this.pincode,
    this.geoLat,
    this.geoLng,
    this.documents = const {},
    this.kycStatus = KycStatus.approved,
    this.kycRejectionReason,
    this.hasPassword = false,
  });

  final String id;
  final String mobile;
  final String businessName;
  final String? address;
  final String? gstNumber;
  final String? email;
  final String? contactPerson;
  final String? ownerName;
  final String? businessType;
  final String? businessTypeId;
  final String? avatarPath;
  final String? fssaiNumber;
  final String? panNumber;
  final String? shopAddress;
  final String? deliveryAddress;
  final String? city;
  final String? state;
  final String? landmark;
  final String? pincode;
  final double? geoLat;
  final double? geoLng;

  /// Document type id → local file path (demo) or remote URL.
  final Map<String, String> documents;
  final KycStatus kycStatus;
  final String? kycRejectionReason;

  /// Opt-in email+password login (set from Profile after mobile registration).
  final bool hasPassword;

  String get displayOwnerName =>
      (ownerName != null && ownerName!.trim().isNotEmpty)
          ? ownerName!.trim()
          : (contactPerson ?? '');

  String get businessTypeLabel {
    if (BusinessTypes.isOther(businessTypeId)) {
      final custom = businessType?.trim();
      if (custom != null && custom.isNotEmpty && custom.toLowerCase() != 'other') {
        return custom;
      }
      return 'Other';
    }
    if (businessTypeId != null) return BusinessTypes.byId(businessTypeId).label;
    return businessType ?? BusinessTypes.byId(BusinessTypes.defaultId).label;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['documents'];
    final docs = <String, String>{};
    if (rawDocs is Map) {
      rawDocs.forEach((k, v) {
        if (v != null) docs[k.toString()] = v.toString();
      });
    }

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
      ownerName: json['owner_name']?.toString() ??
          json['ownerName']?.toString() ??
          json['contact_person']?.toString() ??
          json['contactPerson']?.toString(),
      businessType:
          json['business_type']?.toString() ?? json['businessType']?.toString(),
      businessTypeId: json['business_type_id']?.toString() ??
          json['businessTypeId']?.toString(),
      avatarPath: json['avatar_path']?.toString() ??
          json['avatarPath']?.toString() ??
          json['avatar_url']?.toString(),
      fssaiNumber: json['fssai_number']?.toString() ?? json['fssaiNumber']?.toString(),
      panNumber: json['pan_number']?.toString() ?? json['panNumber']?.toString(),
      shopAddress: json['shop_address']?.toString() ?? json['shopAddress']?.toString(),
      deliveryAddress:
          json['delivery_address']?.toString() ?? json['deliveryAddress']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      landmark: json['landmark']?.toString(),
      pincode: json['pincode']?.toString() ?? json['pin_code']?.toString(),
      geoLat: (json['geo_lat'] as num?)?.toDouble() ??
          (json['geoLat'] as num?)?.toDouble(),
      geoLng: (json['geo_lng'] as num?)?.toDouble() ??
          (json['geoLng'] as num?)?.toDouble(),
      documents: docs,
      kycStatus: KycStatus.fromApi(json['kyc_status']?.toString() ?? json['kycStatus']?.toString()),
      kycRejectionReason: json['kyc_rejection_reason']?.toString() ??
          json['kycRejectionReason']?.toString(),
      hasPassword: json['has_password'] == true || json['hasPassword'] == true,
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
        if (ownerName != null) 'owner_name': ownerName,
        if (businessType != null) 'business_type': businessType,
        if (businessTypeId != null) 'business_type_id': businessTypeId,
        if (avatarPath != null) 'avatar_path': avatarPath,
        if (fssaiNumber != null) 'fssai_number': fssaiNumber,
        if (panNumber != null) 'pan_number': panNumber,
        if (shopAddress != null) 'shop_address': shopAddress,
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (landmark != null) 'landmark': landmark,
        if (pincode != null) 'pincode': pincode,
        if (geoLat != null) 'geo_lat': geoLat,
        if (geoLng != null) 'geo_lng': geoLng,
        if (documents.isNotEmpty) 'documents': documents,
        'kyc_status': kycStatus.toApi(),
        if (kycRejectionReason != null) 'kyc_rejection_reason': kycRejectionReason,
        'has_password': hasPassword,
      };

  User copyWith({
    String? id,
    String? mobile,
    String? businessName,
    String? address,
    String? gstNumber,
    String? email,
    String? contactPerson,
    String? ownerName,
    String? businessType,
    String? businessTypeId,
    String? avatarPath,
    String? fssaiNumber,
    String? panNumber,
    String? shopAddress,
    String? deliveryAddress,
    String? city,
    String? state,
    String? landmark,
    String? pincode,
    double? geoLat,
    double? geoLng,
    Map<String, String>? documents,
    KycStatus? kycStatus,
    String? kycRejectionReason,
    bool? hasPassword,
    bool clearAvatar = false,
    bool clearRejectionReason = false,
    bool clearGst = false,
    bool clearEmail = false,
    bool clearContactPerson = false,
    bool clearOwnerName = false,
    bool clearFssai = false,
    bool clearPan = false,
  }) {
    return User(
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      gstNumber: clearGst ? null : (gstNumber ?? this.gstNumber),
      email: clearEmail ? null : (email ?? this.email),
      contactPerson:
          clearContactPerson ? null : (contactPerson ?? this.contactPerson),
      ownerName: clearOwnerName ? null : (ownerName ?? this.ownerName),
      businessType: businessType ?? this.businessType,
      businessTypeId: businessTypeId ?? this.businessTypeId,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      fssaiNumber: clearFssai ? null : (fssaiNumber ?? this.fssaiNumber),
      panNumber: clearPan ? null : (panNumber ?? this.panNumber),
      shopAddress: shopAddress ?? this.shopAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      geoLat: geoLat ?? this.geoLat,
      geoLng: geoLng ?? this.geoLng,
      documents: documents ?? this.documents,
      kycStatus: kycStatus ?? this.kycStatus,
      kycRejectionReason: clearRejectionReason
          ? null
          : (kycRejectionReason ?? this.kycRejectionReason),
      hasPassword: hasPassword ?? this.hasPassword,
    );
  }

  String get initials {
    final parts = businessName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return 'V';
    final list = parts.toList();
    if (list.length == 1) {
      final s = list.first;
      return (s.length >= 2 ? s.substring(0, 2) : s).toUpperCase();
    }
    return ('${list[0][0]}${list[1][0]}').toUpperCase();
  }
}
