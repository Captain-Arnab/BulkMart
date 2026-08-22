import '../core/config/app_config.dart';
import '../models/saved_address.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

abstract class AddressRepository {
  factory AddressRepository({ApiClient? apiClient}) {
    if (AppConfig.kDemoMode) {
      return MockAddressRepository();
    }
    return ApiAddressRepository(apiClient: apiClient!);
  }

  Future<Result<List<SavedAddress>>> fetchAddresses();

  Future<Result<SavedAddress>> upsert(SavedAddress address);

  Future<Result<void>> setDefault(String id);

  Future<Result<void>> delete(String id);

  Future<Result<SavedAddress?>> getById(String id);
}

class MockAddressRepository implements AddressRepository {
  MockAddressRepository() {
    _addresses = [
      const SavedAddress(
        id: 'a1',
        label: 'Shop',
        line1: '12, Wholesale Market Road',
        line2: 'Near Mandi Gate',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560001',
        isDefault: true,
      ),
      const SavedAddress(
        id: 'a2',
        label: 'Warehouse',
        line1: 'Plot 44, Industrial Area Phase 2',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560058',
      ),
    ];
  }

  late List<SavedAddress> _addresses;

  @override
  Future<Result<List<SavedAddress>>> fetchAddresses() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Success(List.unmodifiable(_addresses));
  }

  @override
  Future<Result<SavedAddress>> upsert(SavedAddress address) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _addresses.indexWhere((e) => e.id == address.id);
    var next = List<SavedAddress>.from(_addresses);
    if (address.isDefault) {
      next = next.map((e) => e.copyWith(isDefault: false)).toList();
    }
    if (index >= 0) {
      next[index] = address;
    } else {
      next.add(address);
    }
    _addresses = next;
    return Success(address);
  }

  @override
  Future<Result<void>> setDefault(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!_addresses.any((e) => e.id == id)) {
      return const Failure('Address not found', statusCode: 404);
    }
    _addresses =
        _addresses.map((e) => e.copyWith(isDefault: e.id == id)).toList();
    return const Success(null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final before = _addresses.length;
    _addresses = _addresses.where((e) => e.id != id).toList();
    if (_addresses.length == before) {
      return const Failure('Address not found', statusCode: 404);
    }
    return const Success(null);
  }

  @override
  Future<Result<SavedAddress?>> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return Success(_addresses.firstWhere((e) => e.id == id));
    } catch (_) {
      return const Success(null);
    }
  }
}

class ApiAddressRepository implements AddressRepository {
  ApiAddressRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<SavedAddress>>> fetchAddresses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.addresses);
      return ApiEnvelope.parse(response, (data) {
        final raw = data is Map && data['addresses'] is List
            ? data['addresses'] as List
            : data is List
                ? data
                : const [];
        return raw
            .map(
              (e) =>
                  SavedAddress.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<SavedAddress>> upsert(SavedAddress address) async {
    try {
      final body = {
        'label': address.label,
        'line1': address.line1,
        if (address.line2 != null) 'line2': address.line2,
        'city': address.city,
        'state': address.state.isNotEmpty ? address.state : 'Karnataka',
        'pincode': address.pincode,
        if (address.landmark != null) 'landmark': address.landmark,
        if (address.geoLat != null) 'geo_lat': address.geoLat,
        if (address.geoLng != null) 'geo_lng': address.geoLng,
        'is_default': address.isDefault,
      };
      final isNew =
          address.id.isEmpty || int.tryParse(address.id) == null;
      final response = isNew
          ? await _apiClient.dio.post(ApiEndpoints.addresses, data: body)
          : await _apiClient.dio.put(
              ApiEndpoints.addressDetail(address.id),
              data: body,
            );
      return ApiEnvelope.parse(response, (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final raw = map['address'] ?? map;
        return SavedAddress.fromJson(Map<String, dynamic>.from(raw as Map));
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<void>> setDefault(String id) async {
    try {
      final response =
          await _apiClient.dio.post(ApiEndpoints.addressDefault(id));
      final parsed = ApiEnvelope.parse(response, (_) => true);
      return parsed.when(
        success: (_) => const Success(null),
        failure: (message, {statusCode, code, fields}) => Failure(
          message,
          statusCode: statusCode,
          code: code,
          fields: fields,
        ),
      );
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final response =
          await _apiClient.dio.delete(ApiEndpoints.addressDetail(id));
      final parsed = ApiEnvelope.parse(response, (_) => true);
      return parsed.when(
        success: (_) => const Success(null),
        failure: (message, {statusCode, code, fields}) => Failure(
          message,
          statusCode: statusCode,
          code: code,
          fields: fields,
        ),
      );
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<SavedAddress?>> getById(String id) async {
    final all = await fetchAddresses();
    return all.when(
      success: (list) {
        try {
          return Success(list.firstWhere((e) => e.id == id));
        } catch (_) {
          return const Success(null);
        }
      },
      failure: (message, {statusCode, code, fields}) => Failure(
        message,
        statusCode: statusCode,
        code: code,
        fields: fields,
      ),
    );
  }
}
