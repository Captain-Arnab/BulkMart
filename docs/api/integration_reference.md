# VeggiiCart API — Flutter Integration Reference

**Generated:** 2026-08-13  
**Purpose:** Exact wiring facts for the Flutter app — traced from routing/auth code, not from memory.  
**Read-only discovery** (no code changes).

---

## 1. BASE URL DISCOVERY

### How requests reach the API (confirmed chain)

| Step | File | What happens |
|------|------|----------------|
| 1 | Repo-root [`.htaccess`](../../.htaccess) L1–2 | `RewriteRule ^(.*)$ public/$1 [L]` — if the vhost document root is the **project root**, every URL is internally rewritten into `/public/…`. |
| 2 | Root [`index.php`](../../index.php) L1–20 | Convenience bounce into `/public/` if someone hits the project root without rewrite. Comment L4: *“Prefer pointing the vhost/document root at `/public` in production.”* |
| 3 | [`public/.htaccess`](../../public/.htaccess) L3–9 | Non-file requests → front controller `index.php`. |
| 4 | [`public/index.php`](../../public/index.php) L34–40, L55–121 | Strips `app_base_url()` prefix from `REQUEST_URI`, then matches routes registered as `/api/v1/...`. |
| 5 | [`app/core/Router.php`](../../app/core/Router.php) L47–68 | Same base-strip + match; 404 JSON for unknown `/api/*`. |

Route paths are registered **including** the `/api/v1` prefix (e.g. `public/index.php` L55: `'/api/v1/auth/send-otp'`). There is **no** separate `routes/api.php`.

`app_base_url()` ([`app/config/app.php`](../../app/config/app.php) L75–96): when `app.base_url` is empty (current `config.local.php` L17), it auto-detects as `dirname(SCRIPT_NAME)` — e.g. `/VGS/veggiicart/public` on XAMPP, or `''` when the document root **is** `public/`.

### Confirmed base URLs

| Environment | API base URL (no trailing slash) | Why |
|-------------|----------------------------------|-----|
| **PRODUCTION (intended)** | `https://veggiicart.com/api/v1` | With docroot = `public/` **or** project-root + root `.htaccess` rewrite, the **external** path is `/api/v1/...` (the `/public` segment is not part of the client-facing URL). |
| **LOCAL (XAMPP, this repo)** | `http://localhost/VGS/veggiicart/public/api/v1` | Confirmed in [`docs/api/README.md`](README.md) L3 and live smoke/`verify_api.php` default. Htdocs is the Apache docroot; the app lives under `/VGS/veggiicart/public`. |

**Do not use** `https://veggiicart.com/public/api/v1` as the primary Flutter prod base unless production hosting is misconfigured to expose `/public` in the browser URL. The rewrite + front-controller design makes the clean path `/api/v1`.

**Sanity check after deploy:**  
`GET https://veggiicart.com/api/v1/categories` → JSON `{ "success": true, "data": { "categories": [...] }, "error": null }`

---

## 2. DIRECTORY STRUCTURE (API-relevant)

```
veggiicart/
├── .htaccess                    # rewrite → public/ (if docroot = project root)
├── index.php                    # redirect helper into /public
├── public/                      # ★ ACTUAL WEB ROOT (point domain / vhost here)
│   ├── .htaccess                # front-controller → index.php
│   ├── index.php                # registers ALL /api/v1 routes + admin routes
│   ├── assets/                  # admin UI static (not API)
│   └── uploads/                 # uploaded avatars/KYC/docs (web-accessible URLs)
├── app/                         # internal PHP (not directly URL-mapped)
│   ├── config/
│   │   ├── app.php              # app_base_url(), app_config()
│   │   ├── config.sample.php    # jwt/cors/sms defaults
│   │   ├── config.local.php     # gitignored live secrets/TTLs
│   │   └── db.php               # PDO
│   ├── core/
│   │   ├── Router.php           # method/path matcher + middleware
│   │   ├── Controller.php
│   │   └── Model.php
│   ├── middleware/
│   │   └── api_auth.php         # CORS + require_api_auth (JWT Bearer)
│   ├── controllers/api/         # one controller per resource area
│   │   ├── ApiController.php    # JSON envelope helpers
│   │   ├── AuthApiController.php
│   │   ├── BusinessApiController.php
│   │   ├── ProfileApiController.php
│   │   ├── AddressApiController.php
│   │   ├── CatalogApiController.php
│   │   ├── CartApiController.php
│   │   ├── WishlistApiController.php
│   │   ├── NotificationApiController.php
│   │   ├── SupportApiController.php
│   │   └── OrderApiController.php
│   ├── models/                  # shared with admin; API uses Customer, Product, Cart, …
│   └── services/                # JwtService, OtpService, SmsService, CheckoutService, …
├── scripts/verify_api.php       # HTTP matrix smoke test
└── docs/api/                    # this folder
```

| Path | Role |
|------|------|
| `public/` | **Public web root** — only this tree should be served by the domain. |
| `public/index.php` | Front controller; **sole** route table for `/api/v1/*` (L55–121). |
| `app/controllers/api/` | API handlers; dispatched by Router. |
| `app/middleware/api_auth.php` | CORS for `/api/*` + JWT gate. |
| `app/models/`, `app/services/` | DB + business logic reused by API (and admin). |
| `app/`, `database/`, `scripts/`, `docs/` | **Internal-only** — not meant as direct URL targets (except via `public/uploads`). |

---

## 3. FULL ENDPOINT LIST (ground truth)

**Source:** [`public/index.php`](../../public/index.php) L53–121.  
**Auth column:** `JWT` = middleware `require_api_auth` (`$apiAuth`).  
**Path below** is relative to the API base (prepend base URL from §1).

### Auth — `AuthApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| POST | `/auth/send-otp` | `sendOtp` | Public |
| POST | `/auth/resend-otp` | `resendOtp` | Public |
| POST | `/auth/verify-otp` | `verifyOtp` | Public |
| POST | `/auth/email-login` | `emailLogin` | Public |
| POST | `/auth/refresh-token` | `refreshToken` | Public |
| POST | `/auth/logout` | `logout` | Optional Bearer (body `refresh_token`) |

### Business / KYC — `BusinessApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/business-types` | `businessTypes` | Public |
| POST | `/business/register` | `register` | JWT |
| POST | `/business/documents` | `uploadDocument` | JWT |
| GET | `/business/documents` | `listDocuments` | JWT |
| POST | `/business/resubmit` | `resubmit` | JWT |
| GET | `/business/verification-status` | `verificationStatus` | JWT |

### Profile — `ProfileApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/profile` | `show` | JWT |
| PUT | `/profile` | `update` | JWT |
| POST | `/profile` | `update` | JWT (PUT fallback) |
| POST | `/profile/avatar` | `uploadAvatar` | JWT |
| DELETE | `/profile/avatar` | `removeAvatar` | JWT |

### Addresses — `AddressApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/addresses` | `index` | JWT |
| POST | `/addresses` | `store` | JWT |
| PUT | `/addresses/{id}` | `update` | JWT |
| POST | `/addresses/{id}` | `update` | JWT (PUT fallback) |
| DELETE | `/addresses/{id}` | `destroy` | JWT |
| POST | `/addresses/{id}/default` | `setDefault` | JWT |

### Catalog — `CatalogApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/categories` | `categories` | Public |
| GET | `/categories/{id}` | `categoryDetail` | Public |
| GET | `/products` | `products` | Public |
| GET | `/products/search` | `search` | Public |
| GET | `/products/market-prices` | `marketPrices` | Public |
| GET | `/products/{id}/similar` | `similar` | Public |
| GET | `/products/{id}/frequently-bought-together` | `frequentlyBought` | Public |
| GET | `/products/{id}` | `productDetail` | Public |
| GET | `/banners` | `banners` | Public |
| GET | `/offers` | `offers` | Public |

### Cart — `CartApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/cart` | `show` | JWT |
| POST | `/cart/items` | `addItem` | JWT |
| PUT | `/cart/items/{id}` | `updateItem` | JWT |
| POST | `/cart/items/{id}` | `updateItem` | JWT (PUT fallback) |
| DELETE | `/cart/items/{id}` | `removeItem` | JWT |
| POST | `/cart/coupon` | `applyCoupon` | JWT |
| DELETE | `/cart/coupon` | `removeCoupon` | JWT |

### Wishlist — `WishlistApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/wishlist` | `index` | JWT |
| POST | `/wishlist` | `add` | JWT |
| DELETE | `/wishlist/{id}` | `remove` | JWT |
| POST | `/wishlist/{id}/move-to-cart` | `moveToCart` | JWT |

### Notifications — `NotificationApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/notifications` | `index` | JWT |
| POST | `/notifications/read-all` | `markAllRead` | JWT |
| POST | `/notifications/{id}/read` | `markRead` | JWT |

### Support — `SupportApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/support/faqs` | `faqs` | Public |
| POST | `/support/tickets` | `createTicket` | JWT |
| GET | `/support/tickets` | `myTickets` | JWT |
| GET | `/support/tickets/{id}` | `ticketDetail` | JWT |

### Orders / checkout — `OrderApiController`

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| GET | `/delivery-slots` | `deliverySlots` | JWT |
| POST | `/orders` | `place` | JWT |
| GET | `/orders` | `index` | JWT |
| GET | `/orders/{id}/invoice` | `invoice` | JWT |
| POST | `/orders/{id}/reorder` | `reorder` | JWT |
| POST | `/orders/{id}/cancel` | `cancel` | JWT |
| GET | `/orders/{id}` | `show` | JWT |

**Registered route count:** **58** (including POST aliases for PUT).

### vs `verify_api.php` coverage

| Status | Routes |
|--------|--------|
| **Hit in current `scripts/verify_api.php`** | Auth (all 6), business-types/register/documents GET+POST/resubmit, profile PUT+POST+avatar, addresses POST/PUT/DELETE/default, products/search + products/{id}, cart add/update/delete/coupon, wishlist add/delete/move-to-cart, orders place/invoice/cancel/reorder, notifications read + read-all, support tickets POST + GET/{id} |
| **Registered but not in current `verify_api.php` HTTP matrix** (were probed in earlier audit smokes / are read-only GETs) | `GET /profile`, `GET /addresses`, `GET /categories`, `GET /categories/{id}`, `GET /products`, `GET /products/market-prices`, `GET /products/{id}/similar`, `GET /products/{id}/frequently-bought-together`, `GET /banners`, `GET /offers`, `GET /cart`, `GET /wishlist`, `GET /notifications`, `GET /support/faqs`, `GET /support/tickets`, `GET /delivery-slots`, `GET /orders`, `GET /orders/{id}`, `GET /business/verification-status`, POST aliases `POST /addresses/{id}`, `POST /cart/items/{id}`, invoice `?format=html` |
| **In verify but not a separate route** | N/A |

---

## 4. AUTH INTEGRATION DETAILS

### Header format

Confirmed in [`app/middleware/api_auth.php`](../../app/middleware/api_auth.php) L42–55:

```http
Authorization: Bearer <access_token>
```

- Case-insensitive `Bearer` + whitespace + token (`preg_match('/^Bearer\s+(\S+)$/i'`).
- Also checks `REDIRECT_HTTP_AUTHORIZATION` and `apache_request_headers()` if CGI strips the header (L42–51).

### Token TTLs

| Token | Duration | Source |
|-------|----------|--------|
| **Access JWT** | **3600 s (1 hour)** | `config.local.php` `jwt.access_ttl` L22; mirrored in `app_settings.jwt_access_ttl_seconds`; used in `JwtService::issueAccessToken` L10 and returned as `expires_in` |
| **Refresh token** | **2592000 s (30 days)** | `config.local.php` `jwt.refresh_ttl` L23; `RefreshToken::store` uses this TTL (`AuthApiController::issueTokens` L184) |

Access token payload (`JwtService` L12–17): `sub` (customer id), `type: "access"`, `iat`, `exp`.

Refresh token is an **opaque** 64-char hex string (`bin2hex(random_bytes(32))`), **not** a JWT — stored hashed in `refresh_tokens`.

### `POST /auth/verify-otp`

**Request** (`AuthApiController::verifyOtp` L53–55):

```json
{ "mobile": "9876500001", "otp": "123456" }
```

**Success response** (`issueTokens` L193–200 → envelope):

```json
{
  "success": true,
  "data": {
    "access_token": "<jwt>",
    "refresh_token": "<64-hex>",
    "token_type": "Bearer",
    "expires_in": 3600,
    "is_new_user": true,
    "customer": {
      "id": 1,
      "mobile": "9876500001",
      "email": null,
      "business_name": "...",
      "owner_name": "...",
      "business_type": "...",
      "gst_number": null,
      "fssai_number": null,
      "pan_number": null,
      "avatar_url": null,
      "kyc_status": "pending",
      "kyc_rejection_reason": null,
      "is_blocked": false,
      "registration_complete": false
    }
  },
  "error": null
}
```

Customer fields from `Customer::publicProfile` ([`app/models/Customer.php`](../../app/models/Customer.php) L137–155).

### `POST /auth/refresh-token`

**Request** (L129–132):

```json
{ "refresh_token": "<current refresh>" }
```

**Success:** same shape as verify-otp `data` via `issueTokens` (new access + **rotated** refresh; old refresh revoked).  
**Failure:** HTTP **401**, `error.code = "UNAUTHORIZED"` (L137, L142).

### Expired / invalid access token (Dio interceptor)

From `require_api_auth` ([`api_auth.php`](../../app/middleware/api_auth.php) L53–74) via `ApiController::abort`:

| Situation | HTTP | `error.code` | `error.message` |
|-----------|------|--------------|-----------------|
| Missing/malformed `Authorization` | **401** | `UNAUTHORIZED` | `Missing or invalid Authorization header.` |
| Bad signature / wrong type / **expired JWT** | **401** | `UNAUTHORIZED` | `Invalid or expired access token.` |
| Valid JWT but `sub` missing/0 | **401** | `UNAUTHORIZED` | `Invalid or expired access token.` |
| Customer row gone | **401** | `UNAUTHORIZED` | `Customer not found.` |
| Customer blocked | **403** | `FORBIDDEN` | `Your account has been blocked. Contact support.` |

**Interceptor rule:** treat **401 + `error.code == "UNAUTHORIZED"`** as “refresh or re-login”. Do **not** treat **403 FORBIDDEN** as token expiry (account blocked). Validation failures are **422** with `VALIDATION_ERROR` / other codes — unrelated to auth refresh.

Body shape on auth abort (L32–36 of `ApiController.php`):

```json
{
  "success": false,
  "data": null,
  "error": { "code": "UNAUTHORIZED", "message": "Invalid or expired access token." }
}
```

---

## 5. RESPONSE ENVELOPE

**Standard** — all JSON API responses go through `ApiController::envelope` ([`ApiController.php`](../../app/controllers/api/ApiController.php) L40–49):

```json
{
  "success": true|false,
  "data": { ... } | null,
  "error": null | { "code": "...", "message": "...", "fields"?: { ... } }
}
```

- Success: `error` is JSON `null`.
- Failure: `data` is `null`; optional `error.fields` on validation (`validationError` L22–26).
- `Content-Type: application/json; charset=utf-8`.

**Known deviation**

| Endpoint | Behavior |
|----------|----------|
| `GET /orders/{id}/invoice?format=html` (or `pdf`) | Returns **raw HTML** (`Content-Type: text/html`), **not** the JSON envelope — `OrderApiController::renderInvoiceHtml` L333. Default (no query / `format=json`) stays JSON: `{ success, data: { invoice: {...} }, error }`. |

Router 404 for unknown API paths also uses the same envelope (`Router.php` L103–109, code `NOT_FOUND`).

CORS preflight `OPTIONS` returns **204** empty body (`api_auth.php` L31–34) — not the envelope.

---

## 6. CORS / NETWORK NOTES

### CORS (current)

[`api_apply_cors`](../../app/middleware/api_auth.php) L6–34 + [`config.local.php`](../../app/config/config.local.php) L36–38 / sample L38–44:

- **Current:** `cors.allowed_origins = ['*']` — reflects request `Origin` when present, else `*`.
- Allows methods: `GET, POST, PUT, PATCH, DELETE, OPTIONS`.
- Allows headers: `Authorization, Content-Type, Accept, X-Requested-With`.
- Sets `Access-Control-Allow-Credentials: true`.

**Production flag:** sample config says replace `*` before production. Once tightened to explicit origins, Flutter **web** and any website origins (e.g. `https://app.veggiicart.com`, `https://veggiicart.com`) **must** be listed or browsers will block. Native iOS/Android Dio calls are unaffected by CORS.

### Content-Type expectations

| Call type | Expectation |
|-----------|-------------|
| Most JSON writes | `Content-Type: application/json` + JSON body (`ApiController::jsonBody` L53–63). |
| Multipart uploads | **Do not** force JSON. Use `multipart/form-data`: |
| → Avatar | field name `avatar` **or** `file` (`ProfileApiController` L47–51) |
| → KYC document | fields `document_type` + `file` (`BusinessApiController` L94–99); images/PDF ≤ 5MB |
| Method overrides | Router accepts `X-HTTP-Method-Override` or `_method` on POST (`Router.php` L50–56) for PUT/DELETE if needed |

### Other

- OTP DEV MODE may return `dev_otp` / `dev_mode` in `send-otp` data until SMS is live — strip/ignore in production builds.
- Absolute media URLs are built from request host (`ApiController::absoluteMedia` L101–112).

---

## 7. QUICK COPY-PASTE BLOCK (Flutter)

```dart
/// VeggiiCart API — from docs/api/integration_reference.md (do not guess).
const String kApiBaseUrlProd = 'https://veggiicart.com/api/v1';
const String kApiBaseUrlLocal = 'http://localhost/VGS/veggiicart/public/api/v1';

/// Prefix only — full header value is '$kAuthHeaderPrefix$accessToken'
const String kAuthHeaderPrefix = 'Bearer ';

/// Access JWT lifetime from server config (seconds).
const int kAccessTokenTtlSeconds = 3600;

/// Refresh token lifetime from server config (seconds).
const int kRefreshTokenTtlSeconds = 2592000;
```

**Dio interceptor tip:** on response `statusCode == 401` and `data['error']['code'] == 'UNAUTHORIZED'`, call `POST /auth/refresh-token` with `{ "refresh_token": ... }`, then retry; if refresh also 401, force logout/OTP again.

### Sanity-check summary

- **Total registered `/api/v1` routes:** **58**
- **Auth required (JWT Bearer):** **40**
- **Public (no JWT middleware):** **18** (includes logout with optional Bearer; includes all catalog + FAQs + auth OTP/login/refresh)

---

### Cite checklist (double-check these if anything looks off)

| Fact | Citation |
|------|----------|
| Route table | `public/index.php` L55–121 |
| Root rewrite to public | `.htaccess` L1–2 |
| Front controller | `public/.htaccess` L8–9 |
| Prefer docroot = public | root `index.php` L4 |
| JWT header parse | `app/middleware/api_auth.php` L53–60 |
| Envelope | `app/controllers/api/ApiController.php` L40–49 |
| Token issue shape | `AuthApiController.php` L193–200 |
| Access/refresh TTL | `config.local.php` L21–23; `JwtService.php` L10 |
| Invoice HTML deviation | `OrderApiController.php` L279–283, L333 |
| Local base URL docs | `docs/api/README.md` L3 |
