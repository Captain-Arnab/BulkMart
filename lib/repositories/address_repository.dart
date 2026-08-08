import '../core/config/app_config.dart';
import '../models/saved_address.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/result.dart';

/// Address repository. Demo vs live is controlled by [AppConfig.kDemoMode].
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

/// Demo implementation — in-memory list (seeded for walkthrough).
class MockAddressRepository implements AddressRepository {
  MockAddressRepository() {
    _addresses = [
      const SavedAddress(
        id: 'a1',
        label: 'Shop',
        line1: '12, Wholesale Market Road',
        line2: 'Near Mandi Gate',
        city: 'Bengaluru',
        pincode: '560001',
        isDefault: true,
      ),
      const SavedAddress(
        id: 'a2',
        label: 'Warehouse',
        line1: 'Plot 44, Industrial Area Phase 2',
        city: 'Bengaluru',
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
    _addresses = _addresses.map((e) => e.copyWith(isDefault: e.id == id)).toList();
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

/// Live API stub — wire when backend `/addresses` is ready.
class ApiAddressRepository implements AddressRepository {
  ApiAddressRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<SavedAddress>>> fetchAddresses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.addresses);
      final raw =
          response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      final list =
          raw.map((e) => SavedAddress.fromJson(e as Map<String, dynamic>)).toList();
      return Success(list);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<SavedAddress>> upsert(SavedAddress address) async {
    // TODO: Wire to POST/PUT /addresses when backend is ready.
    throw UnimplementedError('ApiAddressRepository.upsert');
  }

  @override
  Future<Result<void>> setDefault(String id) async {
    // TODO: Wire to PATCH /addresses/{id}/default when backend is ready.
    throw UnimplementedError('ApiAddressRepository.setDefault');
  }

  @override
  Future<Result<void>> delete(String id) async {
    // TODO: Wire to DELETE /addresses/{id} when backend is ready.
    throw UnimplementedError('ApiAddressRepository.delete');
  }

  @override
  Future<Result<SavedAddress?>> getById(String id) async {
    // TODO: Wire to GET /addresses/{id} when backend is ready.
    throw UnimplementedError('ApiAddressRepository.getById');
  }
}
