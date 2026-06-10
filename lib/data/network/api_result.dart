/// Sealed result wrapper for all API calls — never expose raw exceptions to UI.
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

/// Parses Urban Roots `status` / `success` fields (bool, int, or string).
class ApiStatus {
  ApiStatus._();

  static bool isSuccess(dynamic value) {
    if (value == true) return true;
    if (value is num) return value == 1;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'true' || v == '1' || v == 'success' || v == 'ok';
    }
    return false;
  }

  static bool isFailure(dynamic value) {
    if (value == false) return true;
    if (value is num) return value == 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'false' || v == '0' || v == 'fail' || v == 'error';
    }
    return false;
  }

  /// `true` = success, `false` = failure, `null` = no status field.
  static bool? fromMap(Map<String, dynamic> data) {
    for (final key in ['status', 'success']) {
      if (!data.containsKey(key)) continue;
      final value = data[key];
      if (isSuccess(value)) return true;
      if (isFailure(value)) return false;
    }
    return null;
  }
}

/// Standard success envelope from Urban Roots backend.
class ApiEnvelope {
  const ApiEnvelope({
    required this.status,
    this.message,
    this.raw = const {},
  });

  final bool status;
  final String? message;
  final Map<String, dynamic> raw;

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    return ApiEnvelope(
      status: ApiStatus.fromMap(json) ?? false,
      message: json['message'] as String?,
      raw: json,
    );
  }
}
