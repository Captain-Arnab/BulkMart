import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/repositories/wishlist_repository.dart';

/// Wishlist state (list, count, loading, error) backed by [WishlistRepository].
class WishlistController extends GetxController {
  WishlistController({WishlistRepository? repository})
      : _repo = repository ?? ApiWishlistRepository();

  final WishlistRepository _repo;

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxInt count = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Local optimistic membership keyed by product_id.
  final RxMap<String, bool> membership = <String, bool>{}.obs;
  final Set<String> _toggling = <String>{};

  bool _membershipSynced = false;
  Future<void>? _membershipSyncFuture;

  Future<void> loadWishlist() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _repo.getWishlist();
    isLoading(false);

    if (result is ApiFailure<List<Map<String, dynamic>>>) {
      errorMessage.value = result.message;
      items.clear();
      return;
    }

    final list =
        (result as ApiSuccess<List<Map<String, dynamic>>>).data;
    items.assignAll(list);

    for (final item in list) {
      final productId = _productIdOf(item);
      if (productId.isNotEmpty) {
        membership[productId] = true;
      }
    }
    _membershipSynced = true;
    membership.refresh();
    await refreshCount();
  }

  /// One list fetch for all hearts — avoids N× `/wishlist/check.php` on home.
  Future<void> syncMembershipFromServer() {
    if (_membershipSynced) return Future.value();
    return _membershipSyncFuture ??= () async {
      try {
        await loadWishlist();
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('[Wishlist] membership sync failed: $e\n$st');
        }
      } finally {
        _membershipSyncFuture = null;
      }
    }();
  }

  Future<void> refreshCount() async {
    final result = await _repo.getWishlistCount();
    if (result is ApiSuccess<int>) {
      count.value = result.data;
    }
  }

  /// Uses cached membership only. Unknown products are treated as not
  /// wishlisted; [syncMembershipFromServer] fills the cache in one request.
  Future<bool> isInWishlist(String productId) async {
    final id = productId.trim();
    if (id.isEmpty) return false;

    if (membership.containsKey(id)) {
      return membership[id]!;
    }

    // Fire-and-forget single list sync — never N+1 check.php per product card.
    unawaited(syncMembershipFromServer());
    return false;
  }

  bool isKnownInWishlist(String productId) =>
      membership[productId.trim()] == true;

  bool isToggling(String productId) => _toggling.contains(productId.trim());

  /// Optimistic add/remove. Reverts membership on API failure.
  Future<bool> toggle(String productId, {bool? add}) async {
    final id = productId.trim();
    if (id.isEmpty) return false;
    if (_toggling.contains(id)) return false;

    final currentlyIn = membership[id] ?? false;
    final shouldAdd = add ?? !currentlyIn;

    _toggling.add(id);
    membership[id] = shouldAdd;
    if (shouldAdd) {
      count.value = count.value + 1;
    } else if (count.value > 0) {
      count.value = count.value - 1;
      items.removeWhere((e) => _productIdOf(e) == id);
    }
    membership.refresh();

    final result = shouldAdd
        ? await _repo.addToWishlist(id)
        : await _repo.removeFromWishlist(id);

    _toggling.remove(id);

    if (result is ApiFailure<void>) {
      errorMessage.value = result.message;
      membership[id] = currentlyIn;
      if (shouldAdd) {
        if (count.value > 0) count.value = count.value - 1;
      } else {
        count.value = count.value + 1;
      }
      membership.refresh();
      return false;
    }

    // Sync list/count in background after a successful mutation.
    if (shouldAdd) {
      await refreshCount();
    } else {
      await Future.wait([loadWishlist(), refreshCount()]);
    }
    return true;
  }

  String _productIdOf(Map<String, dynamic> item) =>
      item['product_id']?.toString() ??
      item['pd_id']?.toString() ??
      item['id']?.toString() ??
      '';

  static WishlistController findOrPut() {
    if (Get.isRegistered<WishlistController>()) {
      return Get.find<WishlistController>();
    }
    return Get.put(WishlistController());
  }

  @override
  void onInit() {
    super.onInit();
    refreshCount();
    unawaited(syncMembershipFromServer());
  }
}
