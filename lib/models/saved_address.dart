class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.pincode,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String pincode;
  final bool isDefault;

  String get fullAddress {
    final parts = [line1, if (line2 != null && line2!.isNotEmpty) line2, city, pincode];
    return parts.where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');
  }

  SavedAddress copyWith({
    String? id,
    String? label,
    String? line1,
    String? line2,
    String? city,
    String? pincode,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
