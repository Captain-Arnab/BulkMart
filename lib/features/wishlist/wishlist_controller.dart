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
  final Set<String> _cachedProductIds = <String>{};
  bool _cacheLoaded = false;

  Future<void> _refreshProductIdCache() async {
    final result = await _api.wishlist.list();
    _cachedProductIds.clear();
    if (result is ApiSuccess<Map<String, dynamic>>) {
      for (final item in extractList(result.data).whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final productId = map['product_id']?.toString() ??
            map['pd_id']?.toString() ??
            map['id']?.toString() ??
            '';
        if (productId.isNotEmpty) {
          _cachedProductIds.add(productId);
        }
      }
    }
    _cacheLoaded = true;
  }

  Future<void> loadWishlist() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.wishlist.list();
    isLoading(false);
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      items.clear();
      _cachedProductIds.clear();
      _cacheLoaded = false;
      return;
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    items.assignAll(
      extractList(data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
    await _refreshProductIdCache();
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
    if (add) {
      _cachedProductIds.add(productId);
    } else {
      _cachedProductIds.remove(productId);
    }
    _cacheLoaded = true;
    await loadWishlist();
    return true;
  }

  Future<bool> isInWishlist(String productId) async {
    if (productId.trim().isEmpty) return false;

    if (!_cacheLoaded) {
      await _refreshProductIdCache();
    }

    // Backend wishlist/check.php currently throws SQL errors — use list cache.
    return _cachedProductIds.contains(productId.trim());
  }

  static WishlistController findOrPut() {
    if (Get.isRegistered<WishlistController>()) {
      return Get.find<WishlistController>();
    }
    return Get.put(WishlistController());
  }
}
