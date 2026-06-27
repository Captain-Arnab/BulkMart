import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';

/// Centered loading spinner used while a screen is fetching data.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (label != null) ...[
            const SizedBox(height: 14),
            Text(label!, style: GoogleFonts.rubik(color: AppColors.hint)),
          ],
        ],
      ),
    );
  }
}

/// Heuristic: does this error mean the endpoint isn't live on the backend yet?
/// New screens hit endpoints that may 404 / return an HTML error page until the
/// backend ships them. We show a friendly placeholder instead of a scary error.
bool looksLikeUnavailableEndpoint(String message) {
  final e = message.toLowerCase();
  return e.contains('non-json') ||
      e.contains('http 404') ||
      e.contains('not found') ||
      e.contains('404') ||
      e.contains('<') ||
      e.contains('empty response');
}

/// Friendly placeholder for a feature whose backend endpoint isn't live yet.
/// Keeps a Retry button so it starts working the moment the API ships.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    this.message = 'Not available yet',
    this.subtitle = 'This will be ready once the server is updated.',
    required this.onRetry,
  });

  final String message;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_empty_rounded,
                      size: 56, color: AppColors.hint),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.rubik(fontSize: 13, color: AppColors.hint),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Picks a friendly "coming soon" placeholder for not-yet-live endpoints, or a
/// normal error+retry view for genuine failures.
class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (looksLikeUnavailableEndpoint(message)) {
      return ComingSoonView(onRetry: onRetry);
    }
    return ErrorRetryView(message: message, onRetry: onRetry);
  }
}

/// Error state with a Retry button. Scrollable so it can be used inside a
/// [RefreshIndicator].
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 56, color: AppColors.hint),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Friendly empty state. Scrollable so it works inside a [RefreshIndicator].
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.subtitle,
  });

  final String message;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56, color: AppColors.hint),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                          fontSize: 13, color: AppColors.hint),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill that color-codes a status word.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  /// Maps common status words to a color following the spec.
  factory StatusBadge.forStatus(String status) {
    final s = status.trim().toLowerCase();
    Color color;
    if (s == 'paid' || s == 'resolved' || s == 'delivered' || s == 'active') {
      color = AppColors.primary;
    } else if (s == 'open') {
      color = const Color(0xFFD32F2F);
    } else if (s == 'pending' || s == 'in progress' || s == 'accepted') {
      color = const Color(0xFFE08600);
    } else if (s == 'cancelled' || s == 'inactive' || s == 'absent') {
      color = Colors.grey;
    } else {
      color = AppColors.hint;
    }
    final display = status.isEmpty
        ? 'Unknown'
        : status[0].toUpperCase() + status.substring(1);
    return StatusBadge(label: display, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.rubik(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Placeholder shown inside a chart card when there is no data.
class ChartEmpty extends StatelessWidget {
  const ChartEmpty({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.hint),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: GoogleFonts.rubik(color: AppColors.hint, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
