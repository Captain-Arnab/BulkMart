// Smoke test for backend-fixed endpoints.
// Run: dart run tool/api_smoke_test.dart
//
// Optional env:
//   TEST_PHONE=9876543210
//   TEST_OTP=123456
//   TEST_BEARER_TOKEN=eyJ...

import 'dart:convert';
import 'dart:io';

const _base = 'https://urbunroots.com/api/user';
const _apiKey = 'URBANROOTS_API_2026';

Future<void> main() async {
  final phone = Platform.environment['TEST_PHONE'] ?? '9876543210';
  final otpOverride = Platform.environment['TEST_OTP'];
  final bearer = Platform.environment['TEST_BEARER_TOKEN'];

  print('=== Urban Roots API smoke test ===\n');

  final sendResult = await _testSendLoginOtp(phone);
  final otpFromSend = sendResult.json?['otp']?.toString();
  final otp = otpOverride ?? otpFromSend;

  String? loginToken;
  if (otp != null && otp.isNotEmpty) {
    final loginResult = await _testOtpLogin(phone, otp);
    loginToken = loginResult.json?['token'] as String?;
  } else {
    print('\n[SKIP] otp-login — no OTP available');
  }

  final deviceBearer = bearer ?? loginToken;
  if (deviceBearer != null && deviceBearer.isNotEmpty) {
    await _testRegisterDevice(deviceBearer, 'test_fcm_token_smoke');
  } else {
    print('\n[SKIP] register-device — no bearer token available');
  }

  print('\n=== Done ===');
}

Future<_SmokeResult> _testSendLoginOtp(String phone) async {
  print('--- POST send-login-otp.php ---');
  final result = await _post('/send-login-otp.php', {'phone': phone});
  _printResult(result);
  return result;
}

Future<_SmokeResult> _testOtpLogin(String phone, String otp) async {
  print('\n--- POST otp-login.php ---');
  final result = await _post('/otp-login.php', {'phone': phone, 'otp': otp});
  _printResult(result);
  if (result.json?['token'] != null) {
    print('  token present: yes');
  }
  final data = result.json?['data'];
  if (data is Map && data['id'] != null) {
    print('  user_id (data.id): ${data['id']}');
  }
  return result;
}

Future<void> _testRegisterDevice(String bearer, String fcmToken) async {
  print('\n--- POST notifications/register-device.php ---');
  final result = await _post(
    '/notifications/register-device.php',
    {'fcm_token': fcmToken, 'platform': 'android'},
    bearer: bearer,
  );
  _printResult(result);
}

Future<_SmokeResult> _post(
  String path,
  Map<String, dynamic> body, {
  String? bearer,
}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('$_base$path'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('x-api-key', _apiKey);
    if (bearer != null) {
      request.headers.set('Authorization', 'Bearer $bearer');
    }
    request.write(jsonEncode(body));

    final response = await request.close();
    final raw = await response.transform(utf8.decoder).join();
    final trimmed = raw.trim();

    if (trimmed.startsWith('<')) {
      print('[API_ERROR] HTML response (${response.statusCode})');
      print('  ${trimmed.length > 300 ? '${trimmed.substring(0, 300)}...' : trimmed}');
      return _SmokeResult(
        statusCode: response.statusCode,
        isJson: false,
        raw: raw,
      );
    }

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        json = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      print('[API_ERROR] Non-JSON response (${response.statusCode})');
      print('  ${trimmed.length > 300 ? '${trimmed.substring(0, 300)}...' : trimmed}');
      return _SmokeResult(
        statusCode: response.statusCode,
        isJson: false,
        raw: raw,
      );
    }

    return _SmokeResult(
      statusCode: response.statusCode,
      isJson: true,
      json: json,
      raw: raw,
    );
  } finally {
    client.close();
  }
}

void _printResult(_SmokeResult result) {
  print('  HTTP ${result.statusCode}');
  print('  JSON: ${result.isJson}');
  if (result.json != null) {
    print('  body: ${jsonEncode(result.json)}');
  }
}

class _SmokeResult {
  _SmokeResult({
    required this.statusCode,
    required this.isJson,
    this.json,
    this.raw,
  });

  final int statusCode;
  final bool isJson;
  final Map<String, dynamic>? json;
  final String? raw;
}
