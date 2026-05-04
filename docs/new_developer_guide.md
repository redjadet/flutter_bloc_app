# Flutter BLoC App — New Developer Guide

This guide is the fastest path to running the app locally, understanding the
repo shape, and shipping changes safely. It is intentionally onboarding-focused.
Deeper architecture, testing, deployment, and feature detail live in the
linked source-of-truth documents.

For the complete docs index, see [docs index](README.md).

## Quickstart (first 30 minutes)

### Toolchain

- Flutter `3.41.9`
- Dart `3.11.5`
- Xcode + CocoaPods for iOS work
- Android Studio + Android SDK for Android work

The pinned Flutter version comes from [README](../README.md) and
[`.github/workflows/ci.yml`](../.github/workflows/ci.yml).

### Environment setup

Before running the app, review:

- [Firebase Setup](firebase_setup.md)
- [Security and Secrets](security_and_secrets.md)
- [Tech Stack](tech_stack.md)

**Optional — automatic secret injection in the terminal:** install [direnv](https://direnv.net/), copy [`docs/envrc.example`](envrc.example) to `.envrc` in the repo root, add your keys, run `direnv allow`, then let the PATH-based `flutter` wrapper inject `--dart-define` values automatically (or use `flutter run $(./tool/flutter_dart_defines_from_env.sh)`). Plain `flutter run` then passes the same `--dart-define` values to iOS and Android. Only variables listed in [`tool/flutter_dart_defines_from_env.sh`](../tool/flutter_dart_defines_from_env.sh) are forwarded; optional FastAPI Cloud / legacy Render chat orchestration keys (`CHAT_FASTAPICLOUD_*` / `CHAT_RENDER_*`) are included there—see [`docs/integrations/render_fastapi_chat_demo.md`](integrations/render_fastapi_chat_demo.md). For Play Store release builds, the same keys can live in `.env.android.release` (see [`.env.android.release.example`](../.env.android.release.example) and [Android Play Store release SOP](android_play_store_release_sop.md)).

**Optional — Codex code graph for repo exploration:** if you use Codex heavily in this repo, you can install a local `code-review-graph` MCP server and build a persistent graph cache under `.code-review-graph/`. Setup and caveats live in [Code Review Graph for Codex](code_review_graph.md).

### Install dependencies and run

```bash
flutter pub get
flutter run -t lib/main_dev.dart
```

Other entrypoints:

- `lib/main_staging.dart`
- `lib/main_prod.dart`

### Run the local quality gate

```bash
./tool/delivery_checklist.sh
# same pipeline when present: ./bin/checklist
# local-only sanity shortcut for clean trees or narrow docs/tooling work: ./bin/checklist-fast
```

### Run code generation when needed

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 1. Mental model

- The repo follows `Presentation -> Domain <- Data` (Clean Architecture).
- Features live under `lib/features/<feature>/`.
- App-wide composition lives in `lib/app/`, `lib/core/`, and `lib/shared/`.
- `flutter_bloc` drives state transitions.
- `get_it` is the composition root and dependency container.
- Firebase powers core app integrations; Supabase is used where a feature is
  explicitly configured for it.
- Offline-first behavior is implemented through cache-first repositories,
  pending sync storage, and background reconciliation.

For deeper rationale, see:

- [Clean Architecture](clean_architecture.md)
- [Architecture Details](architecture_details.md)
- [State Management Choice](state_management_choice.md)
- [Offline-First Adoption Guide](offline_first/adoption_guide.md)

## 2. Repository layout highlights

| Path | Purpose |
| --- | --- |
| `lib/app.dart` | Top-level app widget and router creation. |
| `lib/main_*.dart` | Flavor-specific entrypoints. |
| `lib/main_bootstrap.dart` | Shared flavor bootstrap path. |
| `lib/app/` | App shell, router composition, and app scope. |
| `lib/core/` | DI, bootstrap, config, theme, routing constants, and core services. |
| `lib/features/<feature>/` | Feature modules with domain, data, and presentation layers. |
| `lib/shared/` | Cross-cutting widgets, services, sync, HTTP, storage, and utilities. |
| `lib/l10n/` | Localization ARB files and generated localizations. |
| `test/` | Unit, bloc, widget, and golden tests. |
| `integration_test/` | End-to-end and flow-based integration coverage. |
| `tool/` and `bin/` | Repo automation, validation, release, and maintenance scripts. |

For feature-by-feature entry points, see [Feature Overview](feature_overview.md).

**Case studies:** product briefs live under [Case studies](case_studies/README.md); the **Case Study Demo** (`/case-study-demo`) implements the [dentists brief](case_studies/dentists.md) and is reachable from the Example hub.

## 3. Application flow

1. `lib/main_dev.dart`, `lib/main_staging.dart`, or `lib/main_prod.dart`
   selects a `Flavor` and calls `runAppWithFlavor()`.
2. `lib/main_bootstrap.dart` initializes Flutter bindings, registers the FCM
   background handler, and delegates startup to `BootstrapCoordinator`.
3. `lib/app.dart` creates `MyApp`, configures `GoRouter`, and attaches auth
   refresh behavior through `GoRouterRefreshStream` when Firebase Auth is
   available.
4. `lib/app/app_scope.dart` wires app-wide cubits and listeners such as locale,
   theme, deep links, retry notifications, and sync status.
5. `lib/core/app_config.dart` builds `MaterialApp.router`, theme, localization,
   and app overlays.
6. Route files under `lib/app/router/` compose the app route tree:
   `routes_core.dart`, `routes_demos.dart`, and `route_groups.dart`.
7. Most feature cubits are created at route scope, and heavy screens such as
   charts, maps, markdown editor, and WebSocket are deferred-loaded.

## 4. Change workflow

When adding or changing a feature:

1. Reuse existing patterns in `lib/shared/`, `lib/core/`, and adjacent
   features before creating new abstractions.
2. Keep logic in the proper layer:
   domain contracts and models in `domain/`, implementations in `data/`,
   cubits/pages/widgets in `presentation/`.
3. Register dependencies under `lib/core/di/`.
4. Wire navigation through `lib/core/router/app_routes.dart` and
   `lib/app/router/`.
5. Update localization, code generation, docs, and tests when the change
   affects them.

Use these docs while implementing:

- [Feature Delivery Guide](feature_implementation_guide.md)
- [Validation Scripts](validation_scripts.md)
- [Testing Overview](testing_overview.md)
- [Code Generation Guide](code_generation_guide.md)

## 5. Development workflow

Use repo commands instead of ad-hoc validation:

| Command | Purpose |
| --- | --- |
| `flutter pub get` | Refresh dependencies. |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate code after model/API annotation changes. |
| `./tool/check_pyright_python.sh` | Pyright on `demos/render_chat_api` and `tool/` Python (run when editing the Render FastAPI demo or repo shell tooling; also runs inside the full delivery gate). |
| `./tool/delivery_checklist.sh` / `./bin/checklist` | Primary local quality gate. Broad/pre-ship runs still take the full sweep; some narrow local docs/tooling edits can use built-in fast paths while CI keeps the full checklist bar (`delivery_checklist.sh` is canonical). |
| `./bin/checklist-fast` | Local-only sanity shortcut for clean trees or narrow docs/tooling work. Refuses CI and broader app/runtime diffs instead of weakening the full gate. |
| `./bin/integration_tests` | Run integration flows on a supported device. |
| `./bin/upgrade_validate_all` | Full maintenance and upgrade validation flow. |

Optional local Codex tooling:

- [Code Review Graph for Codex](code_review_graph.md) — install, build, update, and verify the local MCP-backed code graph

Docs-only changes can stay lightweight, but feature, routing, DI, and behavior
changes should always go through the correct validation scope.

## 6. Testing strategy

The repo uses layered validation:

- Unit and bloc tests for logic and state transitions
- Widget and golden tests for UI behavior and regressions
- Integration flows for cross-feature journeys and persistence
- Shell validators for architecture, lifecycle, async safety, and UI guardrails

Testing detail lives in:

- [Testing Overview](testing_overview.md)
- [Integration Flow Guide](testing_integration_flows.md)
- [Validation Scripts](validation_scripts.md)

## Common Troubleshooting

| Problem | What to check |
| --- | --- |
| Firebase features are disabled | Confirm `flutterfire configure` was run and platform config files are present. See [Firebase Setup](firebase_setup.md). |
| Supabase-backed flows show "not configured" | Confirm `SUPABASE_URL` and `SUPABASE_ANON_KEY` are available through the configured secrets path. See [Security and Secrets](security_and_secrets.md). |
| Generated code is stale | Run `dart run build_runner build --delete-conflicting-outputs`. |
| iOS build fails after dependency or Firebase changes | Run `flutter clean`, `flutter pub get`, `cd ios && pod install && cd ..`, then retry. |
| Integration tests choose the wrong device | Set `CHECKLIST_INTEGRATION_DEVICE=<deviceId>` before running `./bin/integration_tests`. |
| Routes or auth behavior changed unexpectedly | Verify `lib/app.dart`, `lib/app/router/auth_redirect.dart`, and the route groups under `lib/app/router/`. |

## What to read next

- [Case studies](case_studies/README.md)
- [Feature Overview](feature_overview.md)
- [Architecture Details](architecture_details.md)
- [Tech Stack](tech_stack.md)
- [Testing Overview](testing_overview.md)
- [Deployment](deployment.md)
- [Contributing](contributing.md)
