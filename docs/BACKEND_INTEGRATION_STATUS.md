# Urban Roots Mobile — Backend Integration Status

**Last updated:** May 2026  
**App:** Single Flutter binary — Customer + Vendor via login role (`user` | `vendor`).

---

## Backend confirmed

| Item | Value |
|------|--------|
| Firebase Project ID | `urban-roots-ee10d` |
| Android package | `com.urbanroots.delivery` |
| `google-services.json` | Present & aligned |
| Device Token API | **Live on backend** — supports `user` / `vendor` |
| FCM targeting | By role + stored device tokens |
| Production API URL | **Pending** — backend will share after live-server verification |

---

## 1. Package names (production)

| Role | Separate APK? | Package |
|------|---------------|---------|
| User (Customer) | No | `com.urbanroots.delivery` |
| Vendor | No | `com.urbanroots.delivery` |

Use JWT `role` field (`user` | `vendor`) for API and notification targeting.

---

## 2. Firebase SDK (mobile)

| Item | Status |
|------|--------|
| `firebase_core` + `firebase_messaging` | Done |
| Google Services Gradle plugin | Done |
| `google-services.json` | Done |
| FCM init + permissions | Done |
| Token fetch + refresh → Device Token API | Done |
| Role-aware notification routing | Done |
| Foreground / background / tap / cold start | Done |
| iOS `GoogleService-Info.plist` | Pending |

---

## 3. Device Token API (client ↔ backend)

**Auth:** `Authorization: Bearer <jwt>` (required)

**Register**

```
POST {baseUrl}/api/device-token

{
  "device_token": "<fcm_token>",
  "platform": "android" | "ios",
  "role": "user" | "vendor",
  "package_name": "com.urbanroots.delivery",
  "firebase_project_id": "urban-roots-ee10d"
}
```

**Unregister (logout)**

```
DELETE {baseUrl}/api/device-token
{ "device_token": "<fcm_token>" }
```

**When called from app:** after login, session restore, FCM token refresh; unregister on logout.

---

## 4. FCM notification payload (expected from backend)

```json
{
  "notification": {
    "title": "Order Update",
    "body": "Your order #12345 is shipped"
  },
  "data": {
    "type": "order_status",
    "role": "user",
    "order_id": "12345",
    "status": "shipped",
    "click_action": "ORDER_DETAIL"
  }
}
```

App ignores notifications when `data.role` does not match the logged-in session role.

---

## 5. API URL configuration

When backend shares URLs:

```bash
# Staging
flutter run --dart-define=STAGING_API_BASE_URL=https://staging-api.urbanroots.com

# Production (after verification)
flutter run --dart-define=PRODUCTION_API_BASE_URL=https://api.urbanroots.com
```

Legacy flag still works: `--dart-define=API_BASE_URL=...`

Until a URL is set, FCM tokens are generated locally; HTTP registration is skipped.

---

## Pending

- Production / staging API URL from backend
- iOS Firebase config
- Payment gateway live integration
- Delivery Boy app (separate package TBD)
- Notification deep-links to order screens (when order APIs are live)
