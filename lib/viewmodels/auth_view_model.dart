import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool isLoading = false;
  String? error;
  User? user;

  String mobile = '';
  String businessName = '';
  String businessType = 'Wholesaler';
  String gstNumber = '';
  String address = '';
  String pincode = '';

  /// `login` | `register`
  String authFlow = 'login';

  void setMobile(String value) {
    mobile = value;
    error = null;
    notifyListeners();
  }

  void setBusinessName(String value) {
    businessName = value;
    error = null;
  }

  void setBusinessType(String value) {
    businessType = value;
    notifyListeners();
  }

  void setGstNumber(String value) => gstNumber = value;

  void setAddress(String value) => address = value;

  void setPincode(String value) => pincode = value;

  void startLoginFlow() {
    authFlow = 'login';
    error = null;
  }

  void startRegisterFlow() {
    authFlow = 'register';
    error = null;
  }

  Future<bool> bootstrapSession() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final loggedIn = await _authRepository.isLoggedIn();
      if (loggedIn) {
        user = await _authRepository.currentUser();
        isLoading = false;
        notifyListeners();
        return user != null;
      }
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtp() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.sendOtp(
      mobile: mobile,
      businessName: businessName,
    );

    return result.when(
      success: (_) {
        isLoading = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.verifyOtp(
      mobile: mobile,
      otp: otp,
      businessName: businessName.isEmpty ? 'Bulk Buyer' : businessName,
    );

    return result.when(
      success: (u) {
        user = u;
        isLoading = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> completeRegistration() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.completeRegistration(
      mobile: mobile,
      businessName: businessName,
      businessType: businessType,
      address: address,
      pincode: pincode,
      gstNumber: gstNumber,
    );

    return result.when(
      success: (u) {
        user = u;
        isLoading = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> updateProfile({
    required String businessName,
    required String businessType,
    String? gstNumber,
    String? contactPerson,
  }) async {
    if (user == null) return false;
    isLoading = true;
    error = null;
    notifyListeners();

    final u = user!;
    final updated = User(
      id: u.id,
      mobile: u.mobile,
      businessName: businessName.trim(),
      address: u.address,
      email: u.email,
      businessType: businessType,
      gstNumber: (gstNumber == null || gstNumber.trim().isEmpty) ? null : gstNumber.trim(),
      contactPerson:
          (contactPerson == null || contactPerson.trim().isEmpty) ? null : contactPerson.trim(),
    );

    final result = await _authRepository.updateProfile(user: updated);
    return result.when(
      success: (u) {
        user = u;
        this.businessName = u.businessName;
        this.businessType = u.businessType ?? businessType;
        this.gstNumber = u.gstNumber ?? '';
        isLoading = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user = null;
    mobile = '';
    businessName = '';
    businessType = 'Wholesaler';
    gstNumber = '';
    address = '';
    pincode = '';
    authFlow = 'login';
    notifyListeners();
  }
}
