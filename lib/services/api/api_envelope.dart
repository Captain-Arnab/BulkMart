import 'package:dio/dio.dart';

import 'result.dart';

/// Parses the standard VeggiiCart JSON envelope and maps Dio errors → [Failure].
class ApiEnvelope {
  ApiEnvelope._();

  static Result<T> parse<T>(
    Response response,
    T Function(dynamic data) map,
  ) {
    final status = response.statusCode;
    final body = response.data;

    if (body is! Map) {
      return Failure('Unexpected response from server', statusCode: status);
    }

    final mapBody = Map<String, dynamic>.from(body);
    final success = mapBody['success'] == true;
    if (success) {
      try {
        return Success(map(mapBody['data']));
      } catch (e) {
        return Failure('Failed to parse response: $e', statusCode: status);
      }
    }

    return _failureFromError(mapBody['error'], status);
  }

  static Failure<T> fromDio<T>(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map) {
        final err = data['error'];
        if (err != null) {
          return _failureFromError(err, status);
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Failure(
            'Connection timed out. Check your network and try again.',
            statusCode: status,
            code: 'TIMEOUT',
          );
        case DioExceptionType.connectionError:
          return const Failure(
            'No internet connection. Please check your network and retry.',
            code: 'NETWORK',
          );
        case DioExceptionType.badResponse:
          if (status == 404) {
            return Failure(
              'Not found.',
              statusCode: 404,
              code: 'NOT_FOUND',
            );
          }
          return Failure(
            error.message ?? 'Request failed',
            statusCode: status,
          );
        case DioExceptionType.cancel:
          return const Failure('Request cancelled', code: 'CANCELLED');
        default:
          return Failure(
            error.message ?? 'Something went wrong',
            statusCode: status,
          );
      }
    }
    return Failure(error.toString());
  }

  static Failure<T> _failureFromError<T>(dynamic err, int? status) {
    if (err is Map) {
      final code = err['code']?.toString();
      final message =
          err['message']?.toString() ?? 'Request failed';
      Map<String, String>? fields;
      final rawFields = err['fields'];
      if (rawFields is Map) {
        fields = rawFields.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
      return Failure(
        message,
        statusCode: status,
        code: code,
        fields: fields,
      );
    }
    return Failure('Request failed', statusCode: status);
  }
}
