import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart' show parseList;

/// Admin API facade — https://urbunroots.com/api/admin (no auth token).
class AdminApiService {
  AdminApiService({ApiClient? client}) : _client = client ?? ApiClient.admin;

  static final AdminApiService instance = AdminApiService();

  final ApiClient _client;

  Future<({List<VendorPayoutReportItem> report, String? error})>
      vendorPayoutReport({String? vendorId}) async {
    final result = await _client.get(
      APIClass.adminVendorPayoutReport,
      token: TokenMode.none,
      queryParameters:
          (vendorId != null && vendorId.isNotEmpty) ? {'vendor_id': vendorId} : null,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (report: <VendorPayoutReportItem>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (
      report: parseList(data, 'report', VendorPayoutReportItem.fromJson),
      error: null,
    );
  }

  Future<({List<VendorSalesSummaryItem> summary, String? error})>
      vendorSalesSummary() async {
    final result = await _client.get(
      APIClass.adminVendorSalesSummary,
      token: TokenMode.none,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (summary: <VendorSalesSummaryItem>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (
      summary: parseList(data, 'summary', VendorSalesSummaryItem.fromJson),
      error: null,
    );
  }

  Future<({List<DeliveryMonitorItem> boys, String? error})> deliveryMonitoring({
    String? date,
  }) async {
    final result = await _client.get(
      APIClass.adminDeliveryMonitoring,
      token: TokenMode.none,
      queryParameters: date != null ? {'date': date} : null,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (boys: <DeliveryMonitorItem>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (
      boys: parseList(data, 'delivery_boys', DeliveryMonitorItem.fromJson),
      error: null,
    );
  }

  Future<({AttendanceReport? data, String? error})> deliveryAttendance({
    required String deliveryBoyId,
    String? from,
    String? to,
  }) async {
    final result = await _client.get(
      APIClass.adminDeliveryAttendance,
      token: TokenMode.none,
      queryParameters: {
        'delivery_boy_id': deliveryBoyId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (data: null, error: result.message);
    }
    return (
      data: AttendanceReport.fromJson((result as ApiSuccess).data),
      error: null,
    );
  }
}
