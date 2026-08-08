# VeggiiCart (user_app) — Data & Structure Audit

> **Generated from a full code pass (Step 17).** Reflects what is built in `/lib` right now — not a proposed schema.
>
> **App branding in code:** `VeggiiCart` (logo assets on Splash / About). Package: `veggiicart`. Config: `AppConfig.kDemoMode = true`.
>
> **Routing:** Imperative `Navigator` + `AppPageRoute` only. No GoRouter / named routes table.
>
> **DI / state:** `provider` (`MultiProvider`, `ChangeNotifierProvider`, `Provider`).

---

## 0. Architecture snapshot

| Layer | Path | Role |
|-------|------|------|
| Config | `lib/core/config/app_config.dart` | `kDemoMode`, `appName`, company slug |
| Storage | `lib/core/storage/secure_storage_service.dart` | Token + user JSON (auth session) |
| API | `lib/services/api/` | Dio `ApiClient`, `Result`, `ApiEndpoints` |
| Models | `lib/models/` | Domain types + JSON helpers |
| Mock data | `lib/data/mock/` | Products, orders, offers, notifications |
| Repositories | `lib/repositories/` | Abstract factory → Mock\* / Api\* (except Auth always demo) |
| ViewModels | `lib/viewmodels/` | `ChangeNotifier`s |
| Screens | `lib/views/screens/` | Feature UI |
| Widgets | `lib/views/widgets/` | Shared UI (ProductCard, MoqBadge, etc.) |
| Theme | `lib/theme/` | `AppColors`, `AppTextStyles`, `AppTheme`, radii/shadows |

**Providers registered in `lib/main.dart`:** storage, apiClient, Auth / Product / Order / Address / Support / Wishlist / Notification / Offer repositories, `ShellController`, `AuthViewModel`, `HomeViewModel`, `CartViewModel`, `AddressViewModel`, `WishlistViewModel`, `NotificationViewModel` (`..load()`), `OfferViewModel` (`..load()`).

**Demo OTP:** `1234` (AuthRepository).

**API base (placeholder):** `https://api.veggiicart.example/v1`.

---

## 1. Screen inventory

### 1.1 Splash — `splash/splash_screen.dart`

- Bootstraps `AuthViewModel.bootstrapSession()`; min delay ~500ms.
- Routes: logged-in + KYC approved → `MainShell`; logged-in + pending/rejected → `VerificationStatusScreen`; else → `LoginScreen`.
- Brand: `veggiicart_icon_mark.png` in circle + “VeggiiCart” wordmark; forest→green gradient.

### 1.2 Auth

| Screen | File | Notes |
|--------|------|-------|
| Login | `auth/login_screen.dart` | Tabs: **Mobile Number** \| **Email & Password**; register link; Forgot Password stub |
| OTP | `auth/otp_screen.dart` | 4 boxes; demo `1234`; register path can resume registration without full session |
| Registration | `auth/registration_screen.dart` | 5 steps: Mobile → Business → Address → Documents → Review |
| Verification status | `auth/verification_status_screen.dart` | Pending / approved / rejected; demo `approveKycDemo` when pending |
| Forgot password | `auth/forgot_password_screen.dart` | UI stub only |
| Registration success | `auth/registration_success_screen.dart` | **Defined but unused** — flow goes to verification status |

**Registration fields (high level):** mobile; business name, owner, email, GST, FSSAI, PAN, business type (+ Other free text); shop/delivery address, city, state, pincode, landmark, geo; documents (9 types; required Aadhaar + Shop Front; GST cert if GSTIN present).

**Login email:** any valid email + password ≥ 6 chars in demo; password opt-in on Profile via `setLoginPassword`.

### 1.3 Shell / Home

| Screen | File | Notes |
|--------|------|-------|
| Main shell | `home/main_shell.dart` | `IndexedStack`: Home \| Cart \| Orders \| Account; floating pill nav; sticky cart bar |
| Home | `home/home_screen.dart` | Greeting, location, **Saved** (wishlist), **Alerts** (notifications + unread badge), search → browse, offer carousel from `OfferViewModel.featured`, “View all offers →”, category chips, product rows (capped) |

### 1.4 Catalog / Product

| Screen | File | Notes |
|--------|------|-------|
| Category browse | `catalog/category_browse_screen.dart` | Search + filters; optional `initialCategoryId` (offers deep-link) |
| Product detail | `product/product_detail_screen.dart` | Image, wishlist heart, **MoqBadge**, stock chip, **description section**, MOQ qty + add to cart |

**ProductCard** (`widgets/product_card.dart`): MOQ pill + wishlist heart; used on Home, browse, wishlist.

### 1.5 Cart / Orders

| Screen | File | Notes |
|--------|------|-------|
| Cart | `cart/cart_screen.dart` | Lines + MOQ steppers; delivery via `AddressViewModel.defaultAddress`; tap → `showLocationPickerSheet`; place order with `addressId: delivery.id` (no hardcoded demo id); COD-only copy |
| Orders list | `orders/orders_screen.dart` | Filters; payment via `order.paymentMethod.paymentMethodLabel` |
| Order detail | `orders/order_detail_screen.dart` | Timeline; payment label helper; **Cancel** when status `placed` or `confirmed` |
| Order confirmation | `orders/order_confirmation_screen.dart` | Success after place |

### 1.6 Account

| Screen | File | Notes |
|--------|------|-------|
| Account hub | `account/account_screen.dart` | Profile, addresses, support, about, logout |
| Profile details | `account/profile_details_screen.dart` | Parity with registration fields + inline documents + password opt-in |
| Addresses | `account/addresses_screen.dart` | CRUD via AddressViewModel |
| Support | `account/support_screen.dart` | FAQ + ticket form + **My Tickets** list |
| About | `account/about_screen.dart` | Brand + COD policy copy |

### 1.7 Wishlist / Notifications / Offers (Step 17 Part B)

| Screen | File | Entry points | Behavior |
|--------|------|--------------|----------|
| Wishlist | `wishlist/wishlist_screen.dart` | Home “Saved”; hearts on card/detail | Grid of saved products; **To Cart** (`addProduct` at MOQ) + **Remove**; empty → Browse Catalog |
| Notifications | `notifications/notifications_screen.dart` | Home bell + unread badge | Read/unread rows; tap → order detail or offers; **Mark all read** |
| Offers | `offers/offers_screen.dart` | Home carousel + “View all offers →”; notification offer taps | Cards from same `MockOffers` / `OfferRepository` as Home; category tap → browse |

---

## 2. Models (`lib/models/`)

| Model | Key fields |
|-------|------------|
| `User` | id, mobile, businessName, address, gst/email/owner/contact, businessType + businessTypeId, FSSAI/PAN, shop/delivery/city/state/landmark/pincode/geo, documents map, kycStatus + rejection reason, hasPassword, avatarPath |
| `Product` | id, name, category/categoryId, unit, moq, price?, stock?, imageUrl?, description?, batchNo?, itemCode?, inStock |
| `ProductCategory` | id, name |
| `CartItem` | product, quantity; lineTotal |
| `Order` | id, items, status, subtotal/deliveryFee/total, placedAt, estimatedDeliveryDate?, deliveryAddress?, paymentMethod (default `'COD'`) |
| `OrderStatus` | placed, confirmed, deliveryDateSet, outForDelivery, delivered, cancelled |
| `SavedAddress` | id, label, line1, line2?, city, pincode, isDefault |
| `SupportTicket` | id, subject, description, relatedOrderId?, createdAt, status |
| `Offer` | id, title, subtitle, discountLabel, validUntil, gradientColors, categoryId?, minQty?, textColor?, featured |
| `AppNotification` | id, title, body, createdAt, kind (order/offer/kyc/general), read, orderId?, offerId? |
| `BusinessTypes` / options | 12 B2B types including Other; IndianStates list |
| `KycStatus` | pending, approved, rejected |
| `RegistrationDocumentType` | 9 document types + required rules |
| `payment_method.dart` | `String` extension `paymentMethodLabel` → human label for COD / etc. |

---

## 3. Repositories & persistence

| Repository | Demo implementation | Survives navigation? | Survives app restart? |
|------------|---------------------|----------------------|------------------------|
| `AuthRepository` | Always demo (no Api twin) | Yes | **Yes** (secure storage) |
| `ProductRepository` | `MockProducts` (~33 SKUs; descriptions via `_descriptionFor`) | N/A (static) | Static mock |
| `OrderRepository` | Mutates `MockOrders.orders` | Yes | **No** (static reseeds) |
| `AddressRepository` | In-memory seed | Yes | **No** |
| `SupportRepository` | In-memory `_tickets` | Yes | **No** |
| `WishlistRepository` | In-memory product id set | Yes | **No** (session-scoped) |
| `NotificationRepository` | Seeded list; mark-read mutates | Yes | **No** (re-seeds unread) |
| `OfferRepository` | `MockOffers.all` | N/A | Static mock |

**Api\* stubs:** most list/mutation methods `throw UnimplementedError` until live backend exists. Partial wiring exists on some Product/Address/Order GET/POST paths.

`ApiEndpoints` covers auth, products, categories, cart, orders, addresses — **not** wishlist / notifications / offers / support.

---

## 4. ViewModels

| VM | Responsibility |
|----|----------------|
| `AuthViewModel` | Login/register draft, OTP, email login, `completeRegistration` (passes `businessType` / `businessTypeId`), KYC demo approve, profile/docs/avatar, password, session |
| `HomeViewModel` | Categories + products for home |
| `CartViewModel` | In-memory cart; MOQ-aware add/qty |
| `AddressViewModel` | Load/upsert/default/delete; seeds from registration |
| `CategoryBrowseViewModel` | Screen-scoped browse/search |
| `WishlistViewModel` | Toggle/remove; resolves `Product`s via ProductRepository |
| `NotificationViewModel` | Load, mark read / all; unreadCount |
| `OfferViewModel` | Load all + featured |
| `ShellController` | Tab index + fly-to-cart overlay |

---

## 5. Critical flows (verified)

### 5.1 Place order + address

1. Cart requires `AddressViewModel.defaultAddress`.
2. If missing: UI shows “Select a delivery address” → `showLocationPickerSheet`.
3. `placeOrder(..., addressId: delivery.id, deliveryAddress: delivery.fullAddress)`.
4. **Grep:** `addr_demo_1` — **zero matches** in `lib/`.

### 5.2 Payment labels

- Orders UI uses `order.paymentMethod.paymentMethodLabel`.
- **Grep:** literal `'Cash on Delivery'` — **absent** under `lib/views/screens/orders/`; remaining hits are About/cart policy copy or the shared helper in `payment_method.dart`.

### 5.3 Product description

- Mock: `MockProducts.all` applies `_descriptionFor` per product.
- PDP: dedicated section when `description` non-empty.

### 5.4 Cancel order

- `OrderDetailScreen`: visible when status is `placed` or `confirmed`; calls `OrderRepository.cancelOrder`.

### 5.5 Support tickets

- Model `SupportTicket` + `SupportRepository` / `MockSupportRepository`.
- Support screen: submit + **My Tickets** list (session memory).

### 5.6 MoqBadge

- Used on `ProductDetailScreen` (not dead code). ProductCard uses its own MOQ pill.

### 5.7 Registration `businessType`

- `AuthRepository.completeRegistration` builds `User(businessType: businessTypeLabel, businessTypeId: businessTypeId, ...)`.

### 5.8 Wishlist / Notifications / Offers

- Wired in `main.dart`; Home entry points present; mock-backed repos; offers share `MockOffers` with Home carousel.

---

## 6. Design tokens

**File:** `lib/theme/colors.dart`

| Token | Role |
|-------|------|
| `green` `#12833B` | Primary / CTAs |
| `forest` `#0B5C27` | Emphasis / headers |
| `accent` `#F5A623` | MOQ / offer accents |
| `ink` `#1E1F22` | Body text |
| `section` `#F4FAF6` | Screen backgrounds |
| `violet` | Alias → green |
| `mustard` | Alias → accent |

Typography: Plus Jakarta Sans (display) + Inter (body) via `AppTextStyles`. Motion: `flutter_animate` + `AppMotion` / `PressableScale`.

---

## 7. Gaps (actual remaining only)

These are **still true** after Step 17. Items previously listed as gaps that are now implemented (wishlist UI, notifications, offers screen, description, cancel, support tickets, MoqBadge wiring, cart address id, payment label helper, registration businessType) are **not** listed here.

1. **`AppConfig.kDemoMode = true`** — normal runs never exercise live APIs.
2. **Live API incomplete** — many `Api*` methods `UnimplementedError`; Auth has no live implementation; placeholder base URL `api.veggiicart.example`.
3. **`ApiEndpoints` missing** wishlist, notifications, offers, support paths.
4. **Auth is demo-only** — OTP fixed `1234`; no SMS; email password not a real credential store (flag only); forgot-password is a stub.
5. **Cart not persisted** across process kill (`CartViewModel` memory).
6. **Wishlist / notifications read-state / addresses / support tickets / newly placed or cancelled orders** — session (or static mock) only; restart restores seeds / empty lists as applicable.
7. **Offers are display-only** — no discount applied to cart totals or checkout math.
8. **Catalog price/stock** — mock placeholders, not live B2B pricing/inventory.
9. **`RegistrationSuccessScreen` unused** — dead screen file.
10. **Flipping `kDemoMode` alone is unsafe** — home/browse would hit unimplemented product list/search until ApiProductRepository is finished.

---

## 8. Step 17 verification checklist

| # | Item | Verified how | Status |
|---|------|--------------|--------|
| A1 | Cart uses selected/default address id | Grep `addr_demo_1` empty; `cart_screen` uses `delivery.id` + picker | Fixed |
| A2 | Payment label from order | Orders screens use `paymentMethodLabel`; no COD literal in orders/ | Fixed |
| A3 | Product description shown | PDP section + `MockProducts._descriptionFor` | Fixed |
| A4 | Cancel order | `_canCancel` + `cancelOrder` on detail | Fixed |
| A5 | Support tickets persist in session | `SupportTicket` + Mock repo + My Tickets UI | Fixed |
| A6 | MoqBadge used | Import/use on ProductDetailScreen | Fixed (wired, not deleted) |
| A7 | businessType after registration | `User(..., businessType: businessTypeLabel, ...)` in AuthRepository | Fixed |
| B1 | Wishlist | Screen + repo + Home/card/detail hearts | Built |
| B2 | Notifications | Screen + repo + Home badge + mark all read | Built |
| B3 | Offers | Screen + shared MockOffers + Home carousel/link | Built |

---

*End of audit.*
