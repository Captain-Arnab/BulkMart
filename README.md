# Urban Roots — User App

Flutter mobile app for **grocery shopping**: browse products, manage a cart, check out, view orders, and maintain profile details (addresses, payments, and related settings).

---

## Features

- **Authentication** — registration and login (email / phone with OTP).
- **Catalog** — categories and products; search and filters.
- **Cart & checkout** — add items, choose delivery address and payment method.
- **Payments** — cash on delivery (COD) and online gateways (e.g. Razorpay / Paytm / Stripe) where integrated.
- **Promotions** — coupons and discounts.
- **Orders** — history, reorder, and order status / tracking when connected to the backend.
- **Notifications** — push updates for orders and offers (e.g. Firebase).
- **Profile** — addresses, preferences, and account-related screens.

### In-app flow (customer)

1. Browse or search products.  
2. Add items to the cart and open checkout.  
3. Set delivery address and payment method.  
4. Place the order.  
5. View order history and track status from the app.

---

## Tech stack

| Area | Choice |
|------|--------|
| Framework | [Flutter](https://flutter.dev/) (Dart SDK `>=3.2.3 <4.0.0`) |
| Navigation / DI | [GetX](https://pub.dev/packages/get) |
| State management | [flutter_bloc](https://pub.dev/packages/flutter_bloc) (and GetX controllers where used) |
| Typography | [google_fonts](https://pub.dev/packages/google_fonts) |
| UI | carousel_slider, smooth_page_indicator, flutter_animate, flutter_rating_stars, flutter_html, svg_flutter |
| Utilities | intl, fluttertoast |

Backend integration is expected via **REST APIs**; push, maps, and payments can be added as the app is wired to live services.

---

## Repository notes

- **Package name:** `urban_roots` (`pubspec.yaml`).  
- **App title:** Urban Roots (`lib/main.dart`).  
- **APIs:** `lib/Utils/APIClass.dart` uses placeholder endpoints; **`lib/data/dummy_data.dart`** supports demo flows until a real API base URL and routes are configured.

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable, compatible with the Dart SDK range above).  
- Android Studio or VS Code with Flutter tooling.  
- An Android emulator or a device with USB debugging enabled.

### Commands

```bash
cd user_app
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

Launcher icons: `flutter_launcher_icons` in `pubspec.yaml` (source image: `assets/logo_new.png`).

---

## Project layout

```
lib/
├── main.dart
├── data/                     # Local / demo data
├── features/
│   ├── dashboard/
│   ├── login/, registration/
│   ├── orders/, payments/
│   ├── products/
│   ├── userProfile/
│   └── splash/
└── Utils/
```

---

## Connecting APIs

1. Set `APIClass._baseUrl` and endpoint constants in `lib/Utils/APIClass.dart`.  
2. Swap dummy data for real HTTP calls and models as endpoints go live.  
3. Add Firebase, maps, and payment keys per environment using your preferred secrets approach (for example `--dart-define` or CI-injected values; avoid committing secrets).

---

## License

Private / unpublished (`publish_to: 'none'` in `pubspec.yaml`). Distribution is governed by your organization’s policies.
