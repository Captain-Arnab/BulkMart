import 'dart:async';
import 'dart:io';

/// Serialises vendor API calls so only one TLS handshake is in flight at a
/// time. The hosting server aborts concurrent handshakes from the emulator
/// with TLSV1_ALERT_INTERNAL_ERROR.
class VendorRequestGate {
  VendorRequestGate._();
  static final VendorRequestGate instance = VendorRequestGate._();

  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}

/// One shared [HttpClient] per process — avoids duplicate TLS sessions to the
/// same host from separate Dio adapters.
class SharedHttpClient {
  SharedHttpClient._();
  static final SharedHttpClient instance = SharedHttpClient._();

  HttpClient? _client;

  HttpClient get client {
    return _client ??= () {
      final c = HttpClient();
      c.maxConnectionsPerHost = 1;
      c.idleTimeout = const Duration(seconds: 30);
      return c;
    }();
  }
}
