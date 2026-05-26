class DeviceTokenRegisterResult {
  const DeviceTokenRegisterResult._({
    required this.success,
    required this.message,
    this.skipped = false,
  });

  final bool success;
  final bool skipped;
  final String message;

  factory DeviceTokenRegisterResult.success([String message = 'Registered']) =>
      DeviceTokenRegisterResult._(success: true, message: message);

  factory DeviceTokenRegisterResult.failed(String message) =>
      DeviceTokenRegisterResult._(success: false, message: message);

  factory DeviceTokenRegisterResult.skipped(String message) =>
      DeviceTokenRegisterResult._(success: true, skipped: true, message: message);
}
