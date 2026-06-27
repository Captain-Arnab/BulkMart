import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/delivery/models/delivery_models.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart' show parseList;

/// Delivery boy API facade — https://urbunroots.com/delivery_boy_api
class DeliveryApiService {
  DeliveryApiService({ApiClient? client}) : _client = client ?? ApiClient.delivery;

  static final DeliveryApiService instance = DeliveryApiService();

  final ApiClient _client;

  Future<({ClockResponse? data, String? error})> clock(String action) async {
    final result = await _client.post(
      APIClass.deliveryClock,
      token: TokenMode.delivery,
      body: {'action': action},
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (data: null, error: result.message);
    }
    return (
      data: ClockResponse.fromJson((result as ApiSuccess).data),
      error: null,
    );
  }

  Future<({List<WorkLogEntry> logs, String? error})> workLog({
    String? date,
  }) async {
    final result = await _client.get(
      APIClass.deliveryWorkLog,
      token: TokenMode.delivery,
      queryParameters: date != null ? {'date': date} : null,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (logs: <WorkLogEntry>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (logs: parseList(data, 'logs', WorkLogEntry.fromJson), error: null);
  }
}
