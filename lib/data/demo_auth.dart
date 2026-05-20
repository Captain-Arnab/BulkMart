/// Demo credentials for client presentations. No real API calls.
class DemoAuth {
  static const String demoPassword = 'demo123';
  static const String demoOtp = '123456';

  static const String demoEmail = 'demo@urbanroots.com';
  static const String demoPhone = '9876543210';

  static bool isValidPassword(String password) => password == demoPassword;

  static bool isValidOtp(String otp) => otp == demoOtp;

  static bool isValidEmail(String email) =>
      email.trim().toLowerCase() == demoEmail;

  static bool isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits == demoPhone || digits.endsWith(demoPhone);
  }

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
