/// Discriminated success / failure wrapper for repository & ViewModel layers.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final message) => message,
      };

  Map<String, String>? get fieldErrorsOrNull => switch (this) {
        Success() => null,
        Failure(:final fields) => fields,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(
      String message, {
      int? statusCode,
      String? code,
      Map<String, String>? fields,
    }) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failure(
        :final message,
        :final statusCode,
        :final code,
        :final fields,
      ) =>
        failure(message, statusCode: statusCode, code: code, fields: fields),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(
    this.message, {
    this.statusCode,
    this.code,
    this.fields,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, String>? fields;
}
