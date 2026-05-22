/// Demo credentials for client presentations. No real API calls.
class DemoAuth {
  static const String demoPassword = 'demo123';
  static const String demoOtp = '123456';

  static const String demoEmail = 'demo@urbanroots.com';
  static const String demoVendorEmail = 'vendor@urbanroots.com';
  static const String demoPhone = '9876543210';
  /// Vendor demo mobile (same password & OTP as customer).
  static const String demoVendorPhone = '9123456780';

  static bool isValidPassword(String password) => password == demoPassword;

  static bool isValidOtp(String otp) => otp == demoOtp;

  static bool isValidEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized == demoEmail || normalized == demoVendorEmail;
  }

  static bool isVendorEmail(String email) =>
      email.trim().toLowerCase() == demoVendorEmail;

  static bool isValidPhone(String phone) {
    final digits = _normalizePhone(phone);
    return digits == demoPhone ||
        digits == demoVendorPhone ||
        digits.endsWith(demoPhone) ||
        digits.endsWith(demoVendorPhone);
  }

  static bool isVendorPhone(String phone) {
    final digits = _normalizePhone(phone);
    return digits == demoVendorPhone || digits.endsWith(demoVendorPhone);
  }

  static String _normalizePhone(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '');

  static String maskIdentifier(String identifier, {required bool isPhone}) {
    if (isPhone) {
      final digits = identifier.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 4) {
        return '+91 ${digits.substring(0, 2)}****${digits.substring(digits.length - 2)}';
      }
    }
    final parts = identifier.split('@');
    if (parts.length == 2 && parts[0].length > 2) {
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    }
    return identifier;
  }
}
