enum AuthRole {
  user,
  vendor;

  static AuthRole? fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'vendor':
        return AuthRole.vendor;
      case 'user':
        return AuthRole.user;
      default:
        return null;
    }
  }

  String get apiValue => name;
}
