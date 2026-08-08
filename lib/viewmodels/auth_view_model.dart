import 'package:flutter/foundation.dart';

import '../models/business_type.dart';
import '../models/kyc_status.dart';
import '../models/registration_document.dart';
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
  String businessTypeId = BusinessTypes.defaultId;
  String gstNumber = '';
  String ownerName = '';
  String email = '';
  String fssaiNumber = '';
  String panNumber = '';

  String shopAddress = '';
  String deliveryAddress = '';
  bool sameAsShopAddress = true;
  String city = '';
  String state = 'Karnataka';
  String landmark = '';
  String pincode = '';
  double? geoLat;
  double? geoLng;

  final Map<String, String> documents = {};
  bool acceptedTerms = false;

  /// Legacy alias used by older screens.
  String get businessType => BusinessTypes.byId(businessTypeId).label;
  String get address =>
      deliveryAddress.isNotEmpty ? deliveryAddress : shopAddress;

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
    // Accept label or id for backwards compatibility.
    businessTypeId = BusinessTypes.byId(value).id;
    notifyListeners();
  }

  void setBusinessTypeId(String id) {
    businessTypeId = id;
    notifyListeners();
  }

  void setGstNumber(String value) => gstNumber = value;
  void setOwnerName(String value) => ownerName = value;
  void setEmail(String value) => email = value;
  void setFssaiNumber(String value) => fssaiNumber = value;
  void setPanNumber(String value) => panNumber = value;

  void setShopAddress(String value) {
    shopAddress = value;
    if (sameAsShopAddress) deliveryAddress = value;
  }

  void setDeliveryAddress(String value) => deliveryAddress = value;

  void setSameAsShopAddress(bool value) {
    sameAsShopAddress = value;
    if (value) deliveryAddress = shopAddress;
    notifyListeners();
  }

  void setCity(String value) => city = value;
  void setStateName(String value) {
    state = value;
    notifyListeners();
  }

  void setLandmark(String value) => landmark = value;
  void setPincode(String value) => pincode = value;

  void setGeo(double lat, double lng) {
    geoLat = lat;
    geoLng = lng;
    notifyListeners();
  }

  void setDocument(RegistrationDocumentType type, String path) {
    documents[type.id] = path;
    notifyListeners();
  }

  void clearDocument(RegistrationDocumentType type) {
    documents.remove(type.id);
    notifyListeners();
  }

  void setAcceptedTerms(bool value) {
    acceptedTerms = value;
    notifyListeners();
  }

  /// Kept for older call sites.
  void setAddress(String value) {
    shopAddress = value;
    if (sameAsShopAddress) deliveryAddress = value;
  }

  int get uploadedDocumentCount {
    final visible = RegistrationDocumentType.visibleTypes(
      hasGstin: gstNumber.trim().isNotEmpty,
    );
    return visible.where((t) => documents.containsKey(t.id)).length;
  }

  int get visibleDocumentCount => RegistrationDocumentType.visibleTypes(
        hasGstin: gstNumber.trim().isNotEmpty,
      ).length;

  bool get requiredDocumentsUploaded {
    for (final t in RegistrationDocumentType.values) {
      if (t.isRequired && !documents.containsKey(t.id)) return false;
    }
    return true;
  }

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

  Future<bool> verifyOtp(String otp, {bool persistSession = true}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.verifyOtp(
      mobile: mobile,
      otp: otp,
      businessName: businessName.isEmpty ? 'Bulk Buyer' : businessName,
      persistSession: persistSession,
    );

    return result.when(
      success: (u) {
        if (persistSession) {
          user = u;
          businessName = u.businessName;
        }
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

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.loginWithEmail(
      email: email,
      password: password,
    );

    return result.when(
      success: (u) {
        user = u;
        businessName = u.businessName;
        this.email = u.email ?? email;
        mobile = u.mobile;
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

  Future<bool> setLoginPassword({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.setLoginPassword(
      email: email,
      password: password,
    );

    return result.when(
      success: (u) {
        user = u;
        this.email = u.email ?? email;
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

    final effectiveDelivery =
        sameAsShopAddress ? shopAddress.trim() : deliveryAddress.trim();

    final result = await _authRepository.completeRegistration(
      mobile: mobile,
      businessName: businessName,
      businessTypeId: businessTypeId,
      businessTypeLabel: businessType,
      ownerName: ownerName,
      email: email,
      gstNumber: gstNumber,
      fssaiNumber: fssaiNumber,
      panNumber: panNumber,
      shopAddress: shopAddress,
      deliveryAddress: effectiveDelivery,
      city: city,
      state: state,
      landmark: landmark,
      pincode: pincode,
      geoLat: geoLat,
      geoLng: geoLng,
      documents: Map<String, String>.from(documents),
    );

    return result.when(
      success: (u) {
        user = u;
        businessName = u.businessName;
        businessTypeId = u.businessTypeId ?? businessTypeId;
        gstNumber = u.gstNumber ?? gstNumber;
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

  Future<bool> approveKycDemo() async {
    if (user == null) return false;
    isLoading = true;
    notifyListeners();
    final updated = user!.copyWith(
      kycStatus: KycStatus.approved,
      clearRejectionReason: true,
    );
    final result = await _authRepository.updateProfile(user: updated);
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

  bool isUploadingAvatar = false;

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

    final type = BusinessTypes.byId(businessType);
    final u = user!;
    final updated = u.copyWith(
      businessName: businessName.trim(),
      businessType: type.label,
      businessTypeId: type.id,
      gstNumber: (gstNumber == null || gstNumber.trim().isEmpty) ? null : gstNumber.trim(),
      contactPerson:
          (contactPerson == null || contactPerson.trim().isEmpty) ? null : contactPerson.trim(),
      ownerName:
          (contactPerson == null || contactPerson.trim().isEmpty) ? u.ownerName : contactPerson.trim(),
    );

    final result = await _authRepository.updateProfile(user: updated);
    return result.when(
      success: (u) {
        user = u;
        this.businessName = u.businessName;
        businessTypeId = u.businessTypeId ?? type.id;
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

  Future<bool> uploadAvatar(String localPath) async {
    isUploadingAvatar = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.uploadAvatar(localPath: localPath);
    return result.when(
      success: (u) {
        user = u;
        isUploadingAvatar = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isUploadingAvatar = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> removeAvatar() async {
    isUploadingAvatar = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.removeAvatar();
    return result.when(
      success: (u) {
        user = u;
        isUploadingAvatar = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isUploadingAvatar = false;
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
    businessTypeId = BusinessTypes.defaultId;
    gstNumber = '';
    ownerName = '';
    email = '';
    fssaiNumber = '';
    panNumber = '';
    shopAddress = '';
    deliveryAddress = '';
    sameAsShopAddress = true;
    city = '';
    state = 'Karnataka';
    landmark = '';
    pincode = '';
    geoLat = null;
    geoLng = null;
    documents.clear();
    acceptedTerms = false;
    authFlow = 'login';
    notifyListeners();
  }
}
