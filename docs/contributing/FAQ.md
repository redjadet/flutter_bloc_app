# ❓ FAQ

## 📌 What is this repository for?

This is a reference Flutter application that demonstrates clean architecture, offline-first data access, and production-minded tooling. It is intended for technical evaluation and as a starting point for new features, not as a turnkey product.

## 👥 Who should review this codebase?

- Developers looking for architecture and testing patterns
- Teams that want an offline-first template with BLoC/Cubit

## ⚡ Quick answers

- Architecture overview: [`clean_architecture.md`](../clean_architecture.md), [`architecture_details.md`](../architecture_details.md)
- Offline-first architecture case study: [`engineering/offline_first_flutter_architecture_with_conflict_resolution.md`](../engineering/offline_first_flutter_architecture_with_conflict_resolution.md)
- Performance and lazy loading: [`performance/performance_bottlenecks.md`](../performance/performance_bottlenecks.md), [`performance/lazy_loading_review.md`](../performance/lazy_loading_review.md)
- Compute/isolate JSON guidance: [`performance/compute_isolate_review.md`](../performance/compute_isolate_review.md)
- Testing strategy and examples: [`testing_overview.md`](../testing_overview.md), `test/shared/common_bugs_prevention_test.dart`
- Responsive UI patterns: [`ui_ux_responsive_review.md`](../review/ui_ux_responsive_review.md)
- Localization workflow: [`localization.md`](../engineering/localization.md), [`new_developer_guide.md`](../new_developer_guide.md)
- Offline-first patterns: [`offline_first/adoption_guide.md`](../offline_first/adoption_guide.md)
- Validation scripts: [`validation_scripts.md`](../validation_scripts.md)
- Cursor Runlayer hooks / “Config version must be a number”: `tool/fix_runlayer_cursor_hooks.py`, [runlayer/plugins#6](https://github.com/runlayer/plugins/pull/6)
- Migrations (type-safe BLoC, Freezed, sealed, Cupertino): [`compile_time_safety.md`](../architecture/compile_time_safety.md), [`freezed_usage_analysis.md`](../architecture/freezed_usage_analysis.md), [`design_system.md`](../design_system.md)

## 🔍 What should I review first?

Start with these entry points:

- [`clean_architecture.md`](../clean_architecture.md) and [`architecture_details.md`](../architecture_details.md)
- `apps/mobile/lib/main_bootstrap.dart` and `apps/mobile/lib/main_dev.dart`
- `apps/mobile/lib/app.dart` and `apps/mobile/lib/app/`
- `apps/mobile/lib/app/composition/` (dependency injection)
- `apps/mobile/lib/app/router/` (navigation)
- `apps/mobile/lib/features/counter/` (core example feature)
- `apps/mobile/lib/app/` (cross-cutting utilities)

## 🧭 Why BLoC/Cubit over Riverpod or Provider?

This codebase emphasizes explicit state transitions, testable business logic, and predictable rebuilds. Cubits keep UI lean and enable focused unit/bloc tests without widget pumps.

See [State Management Choice](../architecture/state_management_choice.md) for the full rationale.

## 🚀 How do I run the app?

```bash
bash tool/workspace_pub_get.sh
cd apps/mobile && flutter run -t lib/main_dev.dart
```

For platform setup and configuration, see [Developer Guide](../new_developer_guide.md) and [Security & Secrets](../security_and_secrets.md).

## 🔐 Which features need API keys or services?

- Firebase (Auth, Remote Config, etc.)
- Google Maps (Android/iOS keys)
- Hugging Face Inference API

See [Security & Secrets](../security_and_secrets.md) for setup details.

## 📱 Are there platform-specific dependencies?

Yes. Some packages only work on certain platforms:

- **`apple_maps_flutter`** – iOS-only; app uses `google_maps_flutter` on Android
- **`window_manager`** – Desktop-only; no-op on mobile
- **`local_auth`** – Both platforms; uses fingerprint on Android, Face ID/Touch ID on iOS

The app handles this automatically (e.g., maps switch based on platform). See [Tech Stack](../tech_stack.md#platform-specific-dependencies) for the full list.

## 🛠️ Cursor reports Runlayer plugin hooks error (“Config version must be a number”)

Cursor expects plugin `hooks/hooks.json` to include a numeric top-level `version` (usually `1`). If the Runlayer marketplace cache is older than upstream, you may see validation errors until the bundle is refreshed.

- **Upstream fix:** [runlayer/plugins#6](https://github.com/runlayer/plugins/pull/6) adds `"version": 1` to `cursor-plugin/hooks/hooks.json`.
- **Local repair (idempotent):** run `python3 tool/fix_runlayer_cursor_hooks.py` after plugin installs or cache updates. Use `--dry-run` to see what would change.

## ✅ How is testing handled?

The project uses unit, bloc, widget, and golden tests. Common pitfalls are captured in `test/shared/common_bugs_prevention_test.dart`.

See [Testing Overview](../testing_overview.md) for details.

## 📱 How do I keep UI responsive and adaptive?

Use the shared responsive extensions and platform-adaptive widgets instead of raw Material buttons or hard-coded spacing. The base layout components handle safe areas and keyboard insets.

See [UI/UX Guidelines](../review/ui_ux_responsive_review.md).
