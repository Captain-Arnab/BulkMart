import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/data/demo_auth.dart';
import 'package:urban_roots/data/models/login_response.dart';

/// Auth repository — swap mock with Retrofit/Dio when backend is ready.
abstract class AuthRepository {
  Future<LoginResponse> login({
    required String identifier,
    AuthRole? selectedRole,
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<LoginResponse> login({
    required String identifier,
    AuthRole? selectedRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final isVendorAccount = identifier.trim().toLowerCase() == DemoAuth.demoVendorEmail ||
        DemoAuth.isVendorPhone(identifier);
    final role = selectedRole ??
        (isVendorAccount ? AuthRole.vendor : AuthRole.user);

    if (role == AuthRole.vendor) {
      return const LoginResponse(
        token: 'mock_vendor_jwt_token',
        role: AuthRole.vendor,
        vendorId: 'VND001',
        name: 'Urban Roots Vendor',
      );
    }

    return const LoginResponse(
      token: 'mock_user_jwt_token',
      role: AuthRole.user,
      name: 'Urban Roots Customer',
    );
  }
}
