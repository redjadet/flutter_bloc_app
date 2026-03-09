# Feature Overview

This document lists feature modules with entry points and notes. It is intended for reviewers who want quick navigation into real code, not a marketing overview.

## Quick Links

- [Architecture Details](architecture_details.md)
- [Testing Overview](testing_overview.md)
- [UI/UX Guidelines](ui_ux_responsive_review.md)
- [Developer Guide](new_developer_guide.md)
- [Code Quality](CODE_QUALITY.md)
- [WalletConnect Auth Status](walletconnect_auth_status.md) – Demo feature status and Firebase setup
- [Firebase UI Auth overflow fix](firebase_ui_auth_overflow_fix.md) – Profile screen display name overflow (e.g. after linking wallet)

## Feature Catalog

| Feature | Entry points | Notes |
| --- | --- | --- |
| Counter | `lib/features/counter/` | Core demo feature with offline storage and timer service. |
| Chat | `lib/features/chat/` | Offline-first chat with Hugging Face inference and sync queue. |
| GenUI Demo | `lib/features/genui_demo/` | AI-generated dynamic UI using GenUI SDK with Google Gemini. |
| Search | `lib/features/search/` | Cache-first repository with background refresh. |
| Settings | `lib/features/settings/` | Theme, locale, app info, diagnostics. |
| Profile | `lib/features/profile/` | Offline-first profile cache. |
| Todo List | `lib/features/todo_list/` | Realtime database + offline-first implementation. |
| Charts | `lib/features/chart/` | Data visualization with isolated rebuilds. |
| WebSocket | `lib/features/websocket/` | Reconnect logic and message streaming. |
| Maps | `lib/features/google_maps/` | Google Maps with Apple Maps fallback. |
| Calculator | `lib/features/calculator/` | Custom keypad and summary flow. |
| Library Demo | `lib/features/library_demo/` | Figma-inspired UI showcase. |
| Markdown Editor | `lib/app/router/deferred_pages/markdown_editor_page.dart` | Deferred feature with preview/rendering. |
| Whiteboard | `lib/features/example/` | CustomPainter drawing demo. |
| IoT Demo | `lib/features/iot_demo/` | Offline-first IoT device list + commands. Uses Supabase as a backend (RLS + migrations) for per-user device data. |
| Supabase Auth | Settings → Integrations → Supabase Auth; route `/supabase-auth`. Code: `lib/features/supabase_auth/` | Optional email/password auth on a separate page. Does not replace Firebase for app-wide auth. Requires `SUPABASE_URL` and `SUPABASE_ANON_KEY` in secrets. See [Authentication](authentication.md#supabase-auth-optional-separate-page). |
| WalletConnect Auth | **Example page** → “WalletConnect Auth (Demo)” button; route `/walletconnect-auth`. Code: `lib/features/walletconnect_auth/` | Demo: connect wallet (mock), link to Firebase Auth. Firestore: one doc per user at `users/{uid}` (linkage + profile). See [WalletConnect Auth Status](walletconnect_auth_status.md) for Firebase setup. |

## Cross-Cutting Modules

- **Dependency injection**: `lib/core/di/`
- **Routing**: `lib/app/router/`
- **Responsive utilities**: `lib/shared/extensions/responsive.dart`
- **Platform-adaptive UI**: `lib/shared/utils/platform_adaptive.dart`
- **Offline-first helpers**: `lib/shared/sync/`

## Configuration Notes

Some modules require platform keys or API access:

- **Firebase** features require `google-services.json`, `GoogleService-Info.plist`, and `lib/firebase_options.dart` (all gitignored). See [Firebase Setup](firebase_setup.md) for full setup; the app runs without them with Firebase features disabled.
- **Supabase** (IoT demo backend + optional Auth page) requires `SUPABASE_URL` and `SUPABASE_ANON_KEY` in secrets (e.g. `assets/config/secrets.json` or `--dart-define`). When missing, the Supabase auth page shows "not configured" and Supabase-backed features are disabled.
- Chat requires a Hugging Face API key.
- GenUI Demo requires a Google Gemini API key (`GEMINI_API_KEY`).
- Maps require Google Maps API keys (Android/iOS).
- WalletConnect Auth requires a WalletConnect project ID (configured in `WalletConnectService`).

See [Security & Secrets](security_and_secrets.md) for API keys; see [Firebase Setup](firebase_setup.md) for Firebase configuration.
