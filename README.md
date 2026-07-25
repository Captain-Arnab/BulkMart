# BulkMart — B2B Bulk Ordering App

Flutter Android app for **wholesale / restaurant / bulk buyers**. Cash on Delivery only.

## Stack

| Area | Choice |
|------|--------|
| Framework | Flutter (Material 3) |
| Architecture | MVVM + Repository |
| State | Provider (`ChangeNotifier`) |
| Networking | Dio + `Result<T>` |
| Auth storage | `flutter_secure_storage` |
| Fonts | Roboto Slab · Inter · Space Mono |

## Session 1 status

- [x] Project scaffold + theme tokens
- [x] Splash → Login → OTP → Home
- [x] Catalog grid with dummy wholesale products
- [x] Shared widgets (`ProductCard`, `MoqBadge`, `StepperQty`, `StatusTimeline`, `PrimaryButton`)
- [ ] Wire real auth / catalog APIs (pending endpoint tracker)
- [ ] Product detail polish, full checkout, order tracking

## Run

```bash
flutter pub get
flutter run
```

**Demo OTP:** `1234`

## Layout

```
lib/
├── models/
├── repositories/
├── services/api/
├── viewmodels/
├── views/screens/   # splash, auth, home, product, cart, orders, account
├── views/widgets/
├── theme/
└── data/dummy/
```
