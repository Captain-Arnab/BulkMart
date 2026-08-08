# VeggiiCart — B2B Bulk Ordering App

Flutter Android app for **wholesale / restaurant / bulk buyers**. Cash on Delivery only.

## Stack

| Area | Choice |
|------|--------|
| Framework | Flutter (Material 3) |
| Architecture | MVVM + Repository |
| State | Provider (`ChangeNotifier`) |
| Networking | Dio + `Result<T>` |
| Auth storage | `flutter_secure_storage` |
| Images | `cached_network_image` |
| Fonts | Plus Jakarta Sans · Inter |

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
| App name | VeggiiCart |
| Android applicationId | `com.virtuousglobal.veggiicart` |
| iOS bundle id | `com.virtuousglobal.veggiicart` |

## Layout

```
lib/
├── core/config/          # kDemoMode
├── data/mock/            # Demo catalog & orders
├── models/
├── repositories/
├── services/api/
├── theme/
├── viewmodels/
└── views/
```
