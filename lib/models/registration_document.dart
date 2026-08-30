enum RegistrationDocumentType {
  gstCertificate,
  fssaiLicense,
  shopRegistration,
  msmeCertificate,
  tradeLicense,
  panCard,
  aadhaarCard,
  shopFrontPhoto,
  visitingCard;

  String get id => name;

  String get label {
    switch (this) {
      case RegistrationDocumentType.gstCertificate:
        return 'GST Certificate';
      case RegistrationDocumentType.fssaiLicense:
        return 'FSSAI License';
      case RegistrationDocumentType.shopRegistration:
        return 'Shop Registration';
      case RegistrationDocumentType.msmeCertificate:
        return 'MSME Certificate';
      case RegistrationDocumentType.tradeLicense:
        return 'Trade License';
      case RegistrationDocumentType.panCard:
        return 'PAN Card';
      case RegistrationDocumentType.aadhaarCard:
        return 'Aadhaar Card';
      case RegistrationDocumentType.shopFrontPhoto:
        return 'Shop Front Photo';
      case RegistrationDocumentType.visitingCard:
        return 'Business Visiting Card';
    }
  }

  // All document types are optional for now — nothing gates the Continue
  // button on Step 4. Re-introduce a real required-set here (ideally driven
  // by a remote/app setting rather than hardcoded) before production launch.
  bool get isRequired => false;

  /// GST cert only relevant when GSTIN was provided.
  bool visibleWhen({required bool hasGstin}) {
    if (this == RegistrationDocumentType.gstCertificate) return hasGstin;
    return true;
  }

  static RegistrationDocumentType? fromId(String? id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return null;
  }

  static List<RegistrationDocumentType> visibleTypes({required bool hasGstin}) {
    return values.where((t) => t.visibleWhen(hasGstin: hasGstin)).toList();
  }
}
