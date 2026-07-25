# BulkMart — B2B Bulk Ordering App

Flutter Android app for **wholesale / restaurant / bulk buyers**. Cash on Delivery only.

> Working name: **BulkMart** (final brand TBD).

## Stack

| Area | Choice |
|------|--------|
| Framework | Flutter (Material 3) |
| Architecture | MVVM + Repository |
| State | Provider (`ChangeNotifier`) |
| Networking | Dio + `Result<T>` |
| Auth storage | `flutter_secure_storage` |
| Images | `cached_network_image` |
| Fonts | Roboto Slab · Inter · Space Mono |

## Demo mode

`lib/core/config/app_config.dart`:

```dart
static const bool kDemoMode = true;
```

With `kDemoMode = true`, product/order repositories return mock data (no backend). Flip to `false` when live APIs are ready.

**Demo OTP:** `1234`

## Run

```bash
flutter pub get
flutter run
```

## Identity

| Key | Value |
|-----|--------|
| App name | BulkMart |
| Android applicationId | `com.virtuousglobal.bulkmart` |
| iOS bundle id | `com.virtuousglobal.bulkmart` |

## Layout

```
lib/
├── core/config/          # kDemoMode
├── data/mock/            # mock_products, mock_orders
├── models/
├── repositories/
├── services/api/
├── viewmodels/
├── views/screens/
├── views/widgets/
└── theme/
```
