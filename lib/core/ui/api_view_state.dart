import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'sweet_alert_util.dart' show showApiSnackBar;

enum ApiViewStatus { idle, loading, success, error, empty }

/// Reusable loading / error / empty UI for API-driven screens.
class ApiStateView extends StatelessWidget {
  const ApiStateView({
    super.key,
    required this.status,
    required this.child,
    this.errorMessage,
    this.emptyMessage = 'Nothing here yet',
    this.onRetry,
  });

  final ApiViewStatus status;
  final Widget child;
  final String? errorMessage;
  final String emptyMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ApiViewStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF019934)),
        );
      case ApiViewStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text(
                  errorMessage ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(fontSize: 14, color: Colors.black54),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ],
            ),
          ),
        );
      case ApiViewStatus.empty:
        return Center(
          child: Text(
            emptyMessage,
            style: GoogleFonts.rubik(fontSize: 14, color: Colors.black45),
          ),
        );
      case ApiViewStatus.idle:
      case ApiViewStatus.success:
        return child;
    }
  }
}
