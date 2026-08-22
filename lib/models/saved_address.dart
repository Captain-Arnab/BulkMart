class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    this.state = '',
    required this.pincode,
    this.landmark,
    this.geoLat,
    this.geoLng,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final double? geoLat;
  final double? geoLng;
  final bool isDefault;

  String get fullAddress {
    final parts = [
      line1,
      if (line2 != null && line2!.isNotEmpty) line2,
      city,
      if (state.isNotEmpty) state,
      pincode,
    ];
    return parts
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Shop',
      line1: json['line1']?.toString() ?? json['line_1']?.toString() ?? '',
      line2: json['line2']?.toString() ?? json['line_2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? json['pin_code']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      geoLat: (json['geo_lat'] as num?)?.toDouble(),
      geoLng: (json['geo_lng'] as num?)?.toDouble(),
      isDefault: json['is_default'] == true ||
          json['isDefault'] == true ||
          json['is_default']?.toString() == 'true' ||
          json['is_default']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'line1': line1,
        if (line2 != null) 'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        if (landmark != null) 'landmark': landmark,
        if (geoLat != null) 'geo_lat': geoLat,
        if (geoLng != null) 'geo_lng': geoLng,
        'is_default': isDefault,
      };

  SavedAddress copyWith({
    String? id,
    String? label,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    double? geoLat,
    double? geoLng,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      geoLat: geoLat ?? this.geoLat,
      geoLng: geoLng ?? this.geoLng,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
