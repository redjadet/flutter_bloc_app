# Feature Overview

This document lists feature modules with entry points and notes. It is intended for reviewers who want quick navigation into real code, not a marketing overview.

## Quick Links

- [Architecture Details](architecture_details.md)
- [Testing Overview](testing_overview.md)
- [UI/UX Guidelines](ui_ux_responsive_review.md)
- [Developer Guide](new_developer_guide.md)
- [Code Quality](CODE_QUALITY.md)

## Feature Catalog

| Feature | Entry points | Notes |
| --- | --- | --- |
| Counter | `lib/features/counter/` | Core demo feature with offline storage and timer service. |
| Chat | `lib/features/chat/` | Offline-first chat with Hugging Face inference and sync queue. |
| GenUI Demo | `lib/features/genui_demo/` | AI-generated dynamic UI using GenUI SDK with Google Gemini. |
| Search | `lib/features/search/` | Cache-first repository with background refresh. |
| Settings | `lib/features/settings/` | Theme, locale, app info, diagnostics. |
| Profile | `lib/features/profile/` | Offline-first profile cache with sync banner. |
| Todo List | `lib/features/todo_list/` | Realtime database + offline-first implementation. |
| Charts | `lib/features/chart/` | Data visualization with isolated rebuilds. |
| WebSocket | `lib/features/websocket/` | Reconnect logic and message streaming. |
| Maps | `lib/features/google_maps/` | Google Maps with Apple Maps fallback. |
| Calculator | `lib/features/calculator/` | Custom keypad and summary flow. |
| Library Demo | `lib/features/library_demo/` | Figma-inspired UI showcase. |
| Markdown Editor | `lib/app/router/deferred_pages/markdown_editor_page.dart` | Deferred feature with preview/rendering. |
| Whiteboard | `lib/features/example/` | CustomPainter drawing demo. |

## Cross-Cutting Modules

- **Dependency injection**: `lib/core/di/`
- **Routing**: `lib/app/router/`
- **Responsive utilities**: `lib/shared/extensions/responsive.dart`
- **Platform-adaptive UI**: `lib/shared/utils/platform_adaptive.dart`
- **Offline-first helpers**: `lib/shared/sync/`

## Configuration Notes

Some modules require platform keys or API access:

- Firebase features require `google-services.json` / `GoogleService-Info.plist`.
- Chat requires a Hugging Face API key.
- GenUI Demo requires a Google Gemini API key (`GEMINI_API_KEY`).
- Maps require Google Maps API keys (Android/iOS).

See [Security & Secrets](security_and_secrets.md) for setup details.
