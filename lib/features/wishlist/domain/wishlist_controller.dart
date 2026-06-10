import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class WishlistController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxInt count = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> loadWishlist() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.wishlist.list();
    isLoading(false);
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      items.clear();
      return;
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    items.assignAll(
      extractList(data).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
    );
    await refreshCount();
  }

  Future<void> refreshCount() async {
    final result = await _api.wishlist.count();
    if (result is ApiSuccess<Map<String, dynamic>>) {
      count.value = int.tryParse(result.data['count']?.toString() ?? '0') ?? 0;
    }
  }

  Future<bool> toggle(String productId, {required bool add}) async {
    final result = add
        ? await _api.wishlist.add(productId: productId)
        : await _api.wishlist.remove(productId: productId);
    if (result is ApiFailure) {
      errorMessage.value = (result as ApiFailure).message;
      return false;
    }
    await loadWishlist();
    return true;
  }

  Future<bool> isInWishlist(String productId) async {
    final result = await _api.wishlist.check(productId: productId);
    if (result is ApiSuccess<Map<String, dynamic>>) {
      return result.data['in_wishlist'] == true;
    }
    return false;
  }
}
