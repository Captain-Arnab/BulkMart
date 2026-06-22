class TrackingCoordinate {
  const TrackingCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  bool get isValid =>
      latitude.abs() > 0.000001 && longitude.abs() > 0.000001;
}

class OrderTrackingStep {
  const OrderTrackingStep({
    required this.label,
    this.timestamp = '',
    this.completed = false,
    this.isCurrent = false,
  });

  final String label;
  final String timestamp;
  final bool completed;
  final bool isCurrent;

  OrderTrackingStep copyWith({
    String? label,
    String? timestamp,
    bool? completed,
    bool? isCurrent,
  }) {
    return OrderTrackingStep(
      label: label ?? this.label,
      timestamp: timestamp ?? this.timestamp,
      completed: completed ?? this.completed,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

class OrderTrackingData {
  const OrderTrackingData({
    this.status = '',
    this.statusCode = '',
    this.steps = const [],
    this.destination,
    this.agentName = '',
    this.agentPhone = '',
    this.eta = '',
  });

  final String status;
  final String statusCode;
  final List<OrderTrackingStep> steps;
  final TrackingCoordinate? destination;
  final String agentName;
  final String agentPhone;
  final String eta;
}

class OrderLiveTrackingData {
  const OrderLiveTrackingData({
    this.destination,
    this.agent,
    this.agentName = '',
    this.agentPhone = '',
    this.eta = '',
    this.status = '',
    this.statusCode = '',
  });

  final TrackingCoordinate? destination;
  final TrackingCoordinate? agent;
  final String agentName;
  final String agentPhone;
  final String eta;
  final String status;
  final String statusCode;
}

bool _isNumericStatus(String value) =>
    RegExp(r'^\d+$').hasMatch(value.trim());

/// Higher rank = further along delivery (used to reconcile APIs).
int trackingStatusRank(String status) {
  final lower = status.trim().toLowerCase();
  if (lower.isEmpty) return -1;
  if (lower.contains('cancel') || lower.contains('reject')) return 100;
  if (lower.contains('complete') || lower.contains('delivered')) return 30;
  if (lower.contains('ship') || lower.contains('out for')) return 20;
  if (lower.contains('process') ||
      lower.contains('confirm') ||
      lower.contains('placed') ||
      lower.contains('pending')) {
    return 10;
  }
  return -1;
}

int? _statusCodeForRank(int rank, List<OrderTrackingStep> steps) {
  if (rank < 0) return null;

  if (steps.isNotEmpty) {
    for (var i = 0; i < steps.length; i++) {
      final label = steps[i].label.toLowerCase();
      if (rank >= 100 && label.contains('cancel')) return i + 1;
      if (rank >= 30 &&
          (label.contains('complete') || label.contains('delivered'))) {
        return i + 1;
      }
      if (rank >= 20 && label.contains('ship')) return i + 1;
      if (rank >= 10 && label.contains('process')) return i + 1;
    }
  }

  const fallback = {10: 1, 20: 2, 30: 3, 100: 4};
  return fallback[rank];
}

/// Prefer order-detail status when it is ahead of stale tracking API codes.
String reconcileStatusCode({
  String? apiCode,
  required String orderStatus,
  required List<OrderTrackingStep> steps,
}) {
  final apiInt = int.tryParse(apiCode?.trim() ?? '');
  final orderRank = trackingStatusRank(orderStatus);
  final orderInt = _statusCodeForRank(orderRank, steps);

  if (orderInt != null && apiInt != null) {
    return (orderInt > apiInt ? orderInt : apiInt).toString();
  }
  if (orderInt != null) return orderInt.toString();
  if (apiInt != null) return apiInt.toString();
  return apiCode?.trim() ?? '';
}

bool _isTerminalStatusCode(int code, List<OrderTrackingStep> steps) {
  if (code < 1 || code > steps.length) return false;
  final label = steps[code - 1].label.toLowerCase();
  return label.contains('complete') ||
      label.contains('delivered') ||
      label.contains('cancel');
}

/// Returns false for API flags/codes like 0, 1, 2 — not customer-facing labels.
bool isMeaningfulTrackingStatus(String? value) {
  if (value == null) return false;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  if (_isNumericStatus(trimmed)) return false;
  final lower = trimmed.toLowerCase();
  if (lower == 'true' || lower == 'false') return false;
  return true;
}

String? _labelFromNumericStatusCode(int code, List<OrderTrackingStep> steps) {
  if (steps.isNotEmpty && code >= 1 && code <= steps.length) {
    return steps[code - 1].label.trim();
  }

  const fallbackLabels = {
    1: 'Processing',
    2: 'Shipping',
    3: 'Completed',
    4: 'Cancelled',
  };
  return fallbackLabels[code];
}

String resolveTrackingDisplayStatus({
  required String rawStatus,
  required List<OrderTrackingStep> steps,
  String orderStatusFallback = '',
}) {
  final orderFallback = orderStatusFallback.trim();
  final orderRank = trackingStatusRank(orderFallback);

  final trimmed = rawStatus.trim();
  String? fromApi;
  if (_isNumericStatus(trimmed)) {
    final code = int.tryParse(trimmed);
    if (code != null) {
      fromApi = _labelFromNumericStatusCode(code, steps);
    }
  } else if (isMeaningfulTrackingStatus(trimmed)) {
    fromApi = trimmed;
  }

  if (orderRank >= 0 && isMeaningfulTrackingStatus(orderFallback)) {
    final apiRank = fromApi != null ? trackingStatusRank(fromApi) : -1;
    if (apiRank < 0 || orderRank > apiRank) {
      return orderFallback;
    }
  }

  if (fromApi != null && fromApi.isNotEmpty) return fromApi;

  for (final step in steps) {
    if (step.isCurrent && step.label.trim().isNotEmpty) {
      return step.label.trim();
    }
  }

  for (final step in steps.reversed) {
    if (step.completed && step.label.trim().isNotEmpty) {
      return step.label.trim();
    }
  }

  OrderTrackingStep? latestWithTime;
  for (final step in steps) {
    if (step.timestamp.trim().isNotEmpty) {
      latestWithTime = step;
    }
  }
  if (latestWithTime != null && latestWithTime.label.trim().isNotEmpty) {
    return latestWithTime.label.trim();
  }

  if (isMeaningfulTrackingStatus(orderStatusFallback)) {
    return orderStatusFallback.trim();
  }

  return 'Processing';
}

List<OrderTrackingStep> normalizeTrackingSteps({
  required List<OrderTrackingStep> steps,
  String? statusCode,
  String orderStatus = '',
}) {
  if (steps.isEmpty) return steps;

  final reconciled = reconcileStatusCode(
    apiCode: statusCode,
    orderStatus: orderStatus,
    steps: steps,
  );
  final code = int.tryParse(reconciled);
  if (code == null || code < 1) {
    return _inferStepProgress(steps);
  }

  final activeIndex = code - 1;
  final terminal = _isTerminalStatusCode(code, steps);

  return steps.asMap().entries.map((entry) {
    final index = entry.key;
    final step = entry.value;
    final label = step.label.toLowerCase();

    if (label.contains('cancel')) {
      return step.copyWith(
        completed: code >= steps.length && label.contains('cancel'),
        isCurrent: false,
      );
    }

    if (terminal) {
      return step.copyWith(
        completed: index <= activeIndex,
        isCurrent: false,
      );
    }

    return step.copyWith(
      completed: index < activeIndex,
      isCurrent: index == activeIndex,
    );
  }).toList();
}

List<OrderTrackingStep> _inferStepProgress(List<OrderTrackingStep> steps) {
  var lastCompletedIndex = -1;
  var currentIndex = -1;

  for (var i = 0; i < steps.length; i++) {
    if (steps[i].isCurrent) currentIndex = i;
    if (steps[i].completed) lastCompletedIndex = i;
  }

  if (currentIndex >= 0) {
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return step.copyWith(
        completed: index < currentIndex,
        isCurrent: index == currentIndex,
      );
    }).toList();
  }

  if (lastCompletedIndex >= 0) {
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return step.copyWith(
        completed: index <= lastCompletedIndex,
        isCurrent: index == lastCompletedIndex,
      );
    }).toList();
  }

  return steps;
}

List<OrderTrackingStep> buildFallbackTrackingSteps(String status) {
  final lower = status.toLowerCase();
  final confirmed = lower.contains('confirm') ||
      lower.contains('process') ||
      lower.contains('ship') ||
      lower.contains('deliver') ||
      lower.contains('complete');
  final outForDelivery = lower.contains('out') ||
      lower.contains('ship') ||
      lower.contains('deliver') ||
      lower.contains('complete');
  final delivered =
      lower.contains('deliver') || lower.contains('complete');

  return [
    const OrderTrackingStep(label: 'Placed', completed: true),
    OrderTrackingStep(
      label: 'Confirmed',
      completed: confirmed,
      isCurrent: !confirmed && !lower.contains('cancel'),
    ),
    OrderTrackingStep(
      label: 'Out for Delivery',
      completed: outForDelivery,
      isCurrent: confirmed && !outForDelivery && !lower.contains('cancel'),
    ),
    OrderTrackingStep(
      label: 'Delivered',
      completed: delivered,
      isCurrent: outForDelivery && !delivered && !lower.contains('cancel'),
    ),
  ];
}
