import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

class AddressController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.address.listAddresses();
    isLoading(false);

    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      addresses.clear();
      return;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    addresses.assignAll(parseAddresses(data));
  }

  Future<bool> saveAddress(Address address) async {
    isSaving(true);
    errorMessage.value = '';

    final ApiResult<Map<String, dynamic>> result;
    if (address.id.isNotEmpty) {
      result = await _api.address.editAddress(
        addressId: address.id,
        fullName: address.fullName,
        phone: address.phone,
        pincode: address.pincode,
        address: address.addressLine1,
        landmark: address.addressLine2 ?? '',
        city: address.city,
        state: address.state,
        addDefault: address.isDefault,
      );
    } else {
      result = await _api.address.addAddress(
        fullName: address.fullName,
        phone: address.phone,
        pincode: address.pincode,
        address: address.addressLine1,
        landmark: address.addressLine2 ?? '',
        city: address.city,
        state: address.state,
        addDefault: address.isDefault,
      );
    }

    isSaving(false);

    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      return false;
    }

    await loadAddresses();
    return true;
  }

  Future<bool> deleteAddress(String addressId) async {
    final result = await _api.address.deleteAddress(addressId: addressId);
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      return false;
    }
    await loadAddresses();
    return true;
  }

  Future<bool> setDefault(String addressId) async {
    final result = await _api.address.setDefaultAddress(id: addressId);
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      return false;
    }
    await loadAddresses();
    return true;
  }

  static AddressController findOrPut() {
    if (Get.isRegistered<AddressController>()) {
      return Get.find<AddressController>();
    }
    return Get.put(AddressController());
  }
}
