/// Response from POST /delivery_boy_api/clock.php
class ClockResponse {
  const ClockResponse({required this.action, required this.time});

  /// "clock_in" or "clock_out"
  final String action;
  final String time;

  bool get isClockIn => action.toLowerCase() == 'clock_in';

  factory ClockResponse.fromJson(Map<String, dynamic> json) {
    return ClockResponse(
      action: json['action']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

/// A single daily work-log entry.
class WorkLogEntry {
  const WorkLogEntry({
    required this.logId,
    required this.date,
    required this.clockIn,
    required this.clockOut,
    required this.totalHours,
  });

  final String logId;
  final String date;
  final String clockIn;
  final String clockOut;
  final String totalHours;

  /// Active session = clocked in but not yet clocked out.
  bool get isActive => clockIn.isNotEmpty && clockOut.isEmpty;

  factory WorkLogEntry.fromJson(Map<String, dynamic> json) {
    final out = json['clock_out'];
    return WorkLogEntry(
      logId: json['log_id']?.toString() ?? json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      clockIn: json['clock_in']?.toString() ?? '',
      clockOut: (out == null || out.toString().toLowerCase() == 'null')
          ? ''
          : out.toString(),
      totalHours: json['total_hours']?.toString() ?? '',
    );
  }
}
