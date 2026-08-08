enum KycStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.approved:
        return 'Approved';
      case KycStatus.rejected:
        return 'Rejected';
    }
  }

  static KycStatus fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'approved':
        return KycStatus.approved;
      case 'rejected':
        return KycStatus.rejected;
      case 'pending':
      default:
        return KycStatus.pending;
    }
  }

  String toApi() => name;
}
