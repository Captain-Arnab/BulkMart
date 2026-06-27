class VendorPayoutReportItem {
  const VendorPayoutReportItem({
    required this.vendorId,
    required this.vendorName,
    required this.totalSalesAmount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.payableAmount,
    required this.payoutStatus,
  });

  final String vendorId;
  final String vendorName;
  final String totalSalesAmount;
  final String commissionRate;
  final String commissionAmount;
  final String payableAmount;
  final String payoutStatus;

  double get payableValue => double.tryParse(payableAmount) ?? 0;

  factory VendorPayoutReportItem.fromJson(Map<String, dynamic> json) {
    return VendorPayoutReportItem(
      vendorId: json['vendor_id']?.toString() ?? '',
      vendorName: json['vendor_name']?.toString() ?? 'Vendor',
      totalSalesAmount: json['total_sales_amount']?.toString() ?? '0',
      // Commission rate comes from the server (fixed 5%); never computed here.
      commissionRate: json['commission_rate']?.toString() ?? '5',
      commissionAmount: json['commission_amount']?.toString() ?? '0',
      payableAmount: json['payable_amount']?.toString() ?? '0',
      payoutStatus: json['payout_status']?.toString() ?? '',
    );
  }
}

class VendorSalesSummaryItem {
  const VendorSalesSummaryItem({
    required this.vendorId,
    required this.vendorName,
    required this.totalProductsSold,
    required this.totalIncomingOrders,
    required this.totalCompletedOrders,
  });

  final String vendorId;
  final String vendorName;
  final String totalProductsSold;
  final String totalIncomingOrders;
  final String totalCompletedOrders;

  double get productsSoldValue => double.tryParse(totalProductsSold) ?? 0;

  factory VendorSalesSummaryItem.fromJson(Map<String, dynamic> json) {
    return VendorSalesSummaryItem(
      vendorId: json['vendor_id']?.toString() ?? '',
      vendorName: json['vendor_name']?.toString() ?? 'Vendor',
      totalProductsSold: json['total_products_sold']?.toString() ?? '0',
      totalIncomingOrders: json['total_incoming_orders']?.toString() ?? '0',
      totalCompletedOrders: json['total_completed_orders']?.toString() ?? '0',
    );
  }
}

class DeliveryMonitorItem {
  const DeliveryMonitorItem({
    required this.deliveryBoyId,
    required this.name,
    required this.status,
    required this.clockIn,
    required this.clockOut,
    required this.totalHours,
    required this.date,
  });

  final String deliveryBoyId;
  final String name;
  final String status;
  final String clockIn;
  final String clockOut;
  final String totalHours;
  final String date;

  bool get isActive => status.trim().toLowerCase() == 'active';

  /// Currently working = active and no clock-out recorded yet.
  bool get isCurrentlyWorking => isActive && clockOut.isEmpty;

  factory DeliveryMonitorItem.fromJson(Map<String, dynamic> json) {
    final out = json['clock_out'];
    return DeliveryMonitorItem(
      deliveryBoyId:
          json['delivery_boy_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Delivery Boy',
      status: json['status']?.toString() ?? '',
      clockIn: json['clock_in']?.toString() ?? '',
      clockOut: (out == null || out.toString().toLowerCase() == 'null')
          ? ''
          : out.toString(),
      totalHours: json['total_hours']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}

class AttendanceEntry {
  const AttendanceEntry({
    required this.date,
    required this.clockIn,
    required this.clockOut,
    required this.totalHours,
  });

  final String date;
  final String clockIn;
  final String clockOut;
  final String totalHours;

  bool get isAbsent => clockIn.isEmpty;

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      date: json['date']?.toString() ?? '',
      clockIn: json['clock_in']?.toString() ?? '',
      clockOut: json['clock_out']?.toString() ?? '',
      totalHours: json['total_hours']?.toString() ?? '',
    );
  }
}

class AttendanceReport {
  const AttendanceReport({
    this.deliveryBoyName = '',
    this.attendance = const [],
    this.totalDaysWorked = '0',
    this.totalHoursWorked = '0',
  });

  final String deliveryBoyName;
  final List<AttendanceEntry> attendance;
  final String totalDaysWorked;
  final String totalHoursWorked;

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    final raw = json['attendance'];
    final entries = <AttendanceEntry>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          entries.add(AttendanceEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return AttendanceReport(
      deliveryBoyName: json['delivery_boy_name']?.toString() ?? '',
      attendance: entries,
      totalDaysWorked: json['total_days_worked']?.toString() ?? '0',
      totalHoursWorked: json['total_hours_worked']?.toString() ?? '0',
    );
  }
}
