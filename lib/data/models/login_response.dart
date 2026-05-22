import 'package:urban_roots/core/auth/auth_role.dart';

class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.role,
    this.vendorId,
    this.name,
  });

  final String token;
  final AuthRole role;
  final String? vendorId;
  final String? name;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final role = AuthRole.fromApi(json['role'] as String?) ?? AuthRole.user;
    return LoginResponse(
      token: json['token'] as String? ?? '',
      role: role,
      vendorId: json['vendor_id'] as String?,
      name: json['name'] as String?,
    );
  }
}
