/// Firebase project constants — aligned with backend & google-services.json.
class FirebaseConfig {
  FirebaseConfig._();

  static const String projectId = 'urban-roots-ee10d';
  static const String androidPackageName = 'com.urbanroots.delivery';

  /// Role values accepted by Device Token API and FCM targeting.
  static const String roleUser = 'user';
  static const String roleVendor = 'vendor';
}
