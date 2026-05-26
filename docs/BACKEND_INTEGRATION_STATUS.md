# Urban Roots Mobile — Backend Integration Status

**Last updated:** May 2026  
**App:** Single Flutter binary (`user_app`) — Customer + Vendor via login role (not separate APKs).

---

## 1. Android package names

| Role | Separate Android app? | Package name (`applicationId`) |
|------|---------------------|--------------------------------|
| **User (Customer)** | No — same APK | `com.urbanroots.delivery` |
| **Vendor** | No — same APK | `com.urbanroots.delivery` |

- Firebase `google-services.json` package: **`com.urbanroots.delivery`** (aligned).
- Firebase project ID: **`urban-roots-ee10d`**
- Distinguish user vs vendor in APIs using JWT + `role` field (`user` | `vendor`), not package name.

**iOS bundle ID:** Update in Xcode / `ios/Runner.xcodeproj` when iOS Firebase app is added (`GoogleService-Info.plist` not in repo yet).

---

## 2. Firebase SDK integration

| Item | Status |
|------|--------|
| `firebase_core` + `firebase_messaging` (Flutter) | **Done** |
| Google Services Gradle plugin | **Done** |
| `google-services.json` (Android) | **Present** — `com.urbanroots.delivery` |
| `Firebase.initializeApp()` in `main.dart` | **Done** |
| FCM permission request (Android 13+ / iOS) | **Done** |
| Foreground / background / tap handlers | **Done** (basic logging; deep-link TBD) |
| iOS `GoogleService-Info.plist` | **Pending** — add from Firebase Console |

---

## 3. Firebase device token → API

| Item | Status |
|------|--------|
| Fetch FCM token after Firebase init | **Done** |
| Register token after login (user + vendor) | **Done** |
| Re-register on app resume (splash, existing session) | **Done** |
| Re-register on FCM token refresh | **Done** |
| Unregister on logout | **Done** (`DELETE` stub) |

### Expected backend contract

**Register (authenticated)**

```
POST {API_BASE_URL}/api/device-token
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "device_token": "<fcm_token>",
  "platform": "android" | "ios",
  "role": "user" | "vendor",
  "package_name": "com.urbanroots.delivery"
}
```

**Unregister (logout)**

```
DELETE {API_BASE_URL}/api/device-token
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "device_token": "<fcm_token>"
}
```

### Mobile configuration

Set API base URL at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.urbanroots.com
```

Until `API_BASE_URL` is set, the app **obtains FCM tokens** but **skips HTTP registration** (debug log only). Backend can implement endpoints and share the production URL.

---

## Reply template for backend developer

> 1. **Package names (Android):** We ship one app: `com.urbanroots.delivery` for both customer and vendor. Role is sent as `user` or `vendor` in the device-token payload and login JWT.  
> 2. **Firebase SDK:** Integrated on Android (`firebase_core`, `firebase_messaging`, Gradle plugin, `google-services.json` for `urban-roots-ee10d`). iOS plist still pending.  
> 3. **Device token API:** Client calls `POST /api/device-token` after login and on token refresh; `DELETE /api/device-token` on logout. Please confirm the contract above or share your final paths/body so we can point `API_BASE_URL` to staging/production.
