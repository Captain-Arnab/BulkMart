import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:geolocator/geolocator.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/data/repositories/home_repository.dart';
import 'package:urban_roots/data/repositories/offers_repository.dart';
import 'package:urban_roots/features/home/delivery_location_controller.dart';
import 'package:urban_roots/features/home/models/home_models.dart';
import 'package:urban_roots/features/offers/models/offer_model.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart'
    show Category;
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

class HomeLocationCoords {
  const HomeLocationCoords({
    required this.lat,
    required this.lng,
    this.label = '',
    this.source = HomeLocationSource.none,
  });

  final double lat;
  final double lng;
  final String label;
  final HomeLocationSource source;
}

enum HomeLocationSource { none, device, address }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    HomeRepository? repository,
    OffersRepository? offersRepository,
    UrbanRootsApi? api,
  })  : _repository = repository ?? ApiHomeRepository(),
        _offersRepository = offersRepository ?? ApiOffersRepository(),
        _api = api ?? UrbanRootsApi.instance;

  final HomeRepository _repository;
  final OffersRepository _offersRepository;
  final UrbanRootsApi _api;

  static const int _featuredLimit = 6;
  static const int _maxHomeSections = 8;
  static const int _perCategoryLimit = 10;
  static const double _defaultRadiusKm = 10;

  /// Hard cap so GPS never holds the first home paint.
  static const Duration _locationBudget = Duration(milliseconds: 1500);

  UiState<HomeUiData> state = const UiLoading();

  bool _disposed = false;
  int _loadGeneration = 0;
  bool _forceClearLocation = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void _publish({
    required List<Category> categories,
    required List<Product> featured,
    required List<CategorySection> sections,
    required List<OfferModel> offers,
    bool sectionsLoading = false,
    bool locationFilterActive = false,
    String locationLabel = '',
  }) {
    if (_disposed) return;
    state = UiSuccess(
      HomeUiData(
        categories: categories,
        featuredProducts: featured,
        categorySections: sections,
        offers: offers,
        sectionsLoading: sectionsLoading,
        locationFilterActive: locationFilterActive,
        locationLabel: locationLabel,
      ),
    );
    _safeNotify();
  }

  /// Clears location filtering and reloads the unfiltered product list.
  Future<void> clearLocationFilter() async {
    _forceClearLocation = true;
    await load();
  }

  Future<void> load() async {
    if (_disposed) return;
    final generation = ++_loadGeneration;

    state = const UiLoading();
    _safeNotify();

    final skipLocation = _forceClearLocation;
    _forceClearLocation = false;

    List<Category> categories = [];
    List<OfferModel> offers = [];
    var categoriesOk = false;
    HomeProductsResult? homeProducts;
    HomeLocationCoords? coords;

    // Location runs in parallel with a tight budget — never blocks first paint
    // behind permission dialogs or a 12s GPS wait.
    final locationFuture = skipLocation
        ? Future<HomeLocationCoords?>.value(null)
        : _resolveLocationFast();

    // Phase 1 — paint categories + offers ASAP (same as before location work).
    await Future.wait([
      _repository.fetchCategories().then((value) {
        categories = value;
        categoriesOk = true;
      }).catchError((_) {}),
      _offersRepository
          .fetchOffers()
          .then((value) => offers = value)
          .catchError((_) => offers = <OfferModel>[]),
    ]);

    if (_disposed || generation != _loadGeneration) return;

    if (!categoriesOk) {
      state = const UiError(
        'Unable to load home content. Please check your connection and try again.',
      );
      _safeNotify();
      return;
    }

    _publish(
      categories: categories,
      featured: const [],
      sections: const [],
      offers: offers,
      sectionsLoading: true,
    );

    // Take whatever location we got within the budget; otherwise load unfiltered.
    try {
      coords = await locationFuture.timeout(_locationBudget);
    } on TimeoutException {
      coords = null;
    } catch (_) {
      coords = null;
    }

    if (_disposed || generation != _loadGeneration) return;

    try {
      homeProducts = await _repository.fetchHomeProducts(
        lat: coords?.lat,
        lng: coords?.lng,
        radiusKm: coords != null ? _defaultRadiusKm : null,
      );
    } catch (_) {
      homeProducts = null;
    }

    if (_disposed || generation != _loadGeneration) return;

    final products = homeProducts?.products ?? const <Product>[];
    final locationActive =
        homeProducts?.locationFilter == true && coords != null;
    final locationLabel = _locationLabel(coords);

    if (products.isNotEmpty) {
      final featured = products.take(_featuredLimit).toList();
      final sections = _buildSectionsFromProducts(
        products: products,
        categories: categories,
      );
      _publish(
        categories: categories,
        featured: featured,
        sections: sections,
        offers: offers,
        sectionsLoading: false,
        locationFilterActive: locationActive,
        locationLabel: locationLabel,
      );
      return;
    }

    // Fallback: category-batch approach if home/products is empty/unavailable.
    await _loadCategoryBatches(
      generation: generation,
      categories: categories,
      offers: offers,
      locationActive: locationActive,
      locationLabel: locationLabel,
    );
  }

  Future<void> _loadCategoryBatches({
    required int generation,
    required List<Category> categories,
    required List<OfferModel> offers,
    required bool locationActive,
    required String locationLabel,
  }) async {
    final sections = <CategorySection>[];
    var featured = <Product>[];
    final toLoad = categories.take(_maxHomeSections).toList();

    for (var i = 0; i < toLoad.length; i += 3) {
      if (_disposed || generation != _loadGeneration) return;

      final batch = toLoad.skip(i).take(3).toList();
      final batchResults = await Future.wait(
        batch.map((category) async {
          try {
            final products = await _repository.fetchProductsByCategory(
              categoryId: category.id,
              limit: _perCategoryLimit,
              page: 1,
            );
            if (products.isEmpty) return null;
            return CategorySection(category: category, products: products);
          } catch (_) {
            return null;
          }
        }),
      );

      if (_disposed || generation != _loadGeneration) return;

      for (final section in batchResults.whereType<CategorySection>()) {
        sections.add(section);
        if (featured.isEmpty) {
          featured = section.products.take(_featuredLimit).toList();
        }
      }

      final moreRemaining = i + 3 < toLoad.length;
      _publish(
        categories: categories,
        featured: featured,
        sections: List<CategorySection>.from(sections),
        offers: offers,
        sectionsLoading: moreRemaining,
        locationFilterActive: locationActive,
        locationLabel: locationLabel,
      );
      await Future<void>.delayed(Duration.zero);
    }

    if (_disposed || generation != _loadGeneration) return;

    _publish(
      categories: categories,
      featured: featured,
      sections: sections,
      offers: offers,
      sectionsLoading: false,
      locationFilterActive: locationActive,
      locationLabel: locationLabel,
    );
  }

  List<CategorySection> _buildSectionsFromProducts({
    required List<Product> products,
    required List<Category> categories,
  }) {
    final byCategory = <String, List<Product>>{};
    for (final product in products) {
      final catId = product.rawJson['category']?.toString() ??
          product.rawJson['category_id']?.toString() ??
          product.rawJson['categ_id']?.toString() ??
          '';
      if (catId.isEmpty) continue;
      byCategory.putIfAbsent(catId, () => []).add(product);
    }

    final categoryById = {
      for (final c in categories) c.id: c,
    };

    final sections = <CategorySection>[];
    for (final entry in byCategory.entries) {
      if (sections.length >= _maxHomeSections) break;
      final category = categoryById[entry.key] ??
          Category(id: entry.key, name: 'Category', image: '', status: '');
      sections.add(
        CategorySection(
          category: category,
          products: entry.value.take(_perCategoryLimit).toList(),
        ),
      );
    }
    return sections;
  }

  String _locationLabel(HomeLocationCoords? coords) {
    if (coords == null) return '';
    if (coords.label.trim().isNotEmpty) return coords.label.trim();
    try {
      final delivery = DeliveryLocationController.findOrPut();
      final city = delivery.city.value.trim();
      if (city.isNotEmpty) return city;
    } catch (_) {}
    return 'you';
  }

  /// Fast path only — never shows a permission dialog, never reverse-geocodes,
  /// never waits on a long GPS fix.
  Future<HomeLocationCoords?> _resolveLocationFast() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return HomeLocationCoords(
            lat: last.latitude,
            lng: last.longitude,
            label: _cityFromDeliveryHeader(),
            source: HomeLocationSource.device,
          );
        }

        // Quick low-accuracy fix if we already have permission.
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 2),
            ),
          );
          return HomeLocationCoords(
            lat: position.latitude,
            lng: position.longitude,
            label: _cityFromDeliveryHeader(),
            source: HomeLocationSource.device,
          );
        } catch (_) {}
      }
    } catch (_) {}

    // Address coords fallback (no geocoding — only if API already has lat/lng).
    try {
      if (await AuthSession.instance.isLoggedIn()) {
        final fromAddress = await _coordsFromSavedAddress();
        if (fromAddress != null) return fromAddress;
      }
    } catch (_) {}

    return null;
  }

  String _cityFromDeliveryHeader() {
    try {
      final city = DeliveryLocationController.findOrPut().city.value.trim();
      return city;
    } catch (_) {
      return '';
    }
  }

  Future<HomeLocationCoords?> _coordsFromSavedAddress() async {
    final result = await _api.address.listAddresses();
    if (result is! ApiSuccess<Map<String, dynamic>>) return null;

    final addresses = parseAddresses(result.data);
    if (addresses.isEmpty) return null;

    Address? preferred;
    for (final address in addresses) {
      if (address.isDefault && address.hasCoordinates) {
        preferred = address;
        break;
      }
    }
    preferred ??= addresses.where((a) => a.hasCoordinates).firstOrNull;

    if (preferred == null || !preferred.hasCoordinates) return null;

    return HomeLocationCoords(
      lat: preferred.latitude!,
      lng: preferred.longitude!,
      label: preferred.city.isNotEmpty ? preferred.city : preferred.pincode,
      source: HomeLocationSource.address,
    );
  }
}
