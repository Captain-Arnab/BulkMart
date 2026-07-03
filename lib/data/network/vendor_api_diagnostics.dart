import 'package:urban_roots/core/config/api_config.dart';

/// Captures the last vendor API call for sharing with the backend team.
class VendorApiDiagnostics {
  VendorApiDiagnostics._();
  static final VendorApiDiagnostics instance = VendorApiDiagnostics._();

  String? lastMethod;
  String? lastUrl;
  int? lastStatusCode;
  String? lastRequestHeaders;
  String? lastResponseHeaders;
  String? lastResponseBody;
  String? lastError;
  DateTime? lastTimestamp;

  void record({
    required String method,
    required String url,
    int? statusCode,
    Map<String, dynamic>? requestHeaders,
    Map<String, dynamic>? responseHeaders,
    String? responseBody,
    String? error,
  }) {
    lastMethod = method;
    lastUrl = url;
    lastStatusCode = statusCode;
    lastRequestHeaders = _formatHeaders(requestHeaders);
    lastResponseHeaders = _formatHeaders(responseHeaders);
    lastResponseBody = responseBody;
    lastError = error;
    lastTimestamp = DateTime.now();
  }

  String formatForSharing() {
    final buf = StringBuffer()
      ..writeln('=== Urban Roots Vendor API Diagnostics ===')
      ..writeln('Environment: ${ApiConfig.environmentLabel}')
      ..writeln('Site root: ${ApiConfig.siteRoot}')
      ..writeln('Vendor base: ${ApiConfig.vendorBaseUrl}')
      ..writeln('Captured: ${lastTimestamp?.toIso8601String() ?? 'n/a'}')
      ..writeln('Method: ${lastMethod ?? 'n/a'}')
      ..writeln('URL: ${lastUrl ?? 'n/a'}')
      ..writeln('HTTP Status: ${lastStatusCode ?? 'n/a'}')
      ..writeln()
      ..writeln('--- Request Headers ---')
      ..writeln(lastRequestHeaders ?? 'n/a')
      ..writeln()
      ..writeln('--- Response Headers ---')
      ..writeln(lastResponseHeaders ?? 'n/a')
      ..writeln()
      ..writeln('--- Response Body ---')
      ..writeln(lastResponseBody ?? '(empty)')
      ..writeln();
    if (lastError != null && lastError!.isNotEmpty) {
      buf
        ..writeln('--- Client Error ---')
        ..writeln(lastError);
    }
    return buf.toString();
  }

  String _formatHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return '(none)';
    final lines = <String>[];
    headers.forEach((key, value) {
      final k = key.toString().toLowerCase();
      if (k == 'authorization' && value is String) {
        lines.add('$key: ${_maskToken(value)}');
      } else {
        lines.add('$key: $value');
      }
    });
    return lines.join('\n');
  }

  String _maskToken(String header) {
    const prefix = 'Bearer ';
    if (!header.startsWith(prefix)) return '***';
    final token = header.substring(prefix.length);
    if (token.length <= 12) return '$prefix***';
    return '$prefix${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
