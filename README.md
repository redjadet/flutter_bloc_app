# Flutter BLoC App

Production-style Flutter reference app for a mobile engineering portfolio:
feature-based Clean Architecture, offline-first sync, Cubit/BLoC, GoRouter,
CI-backed validation, and a broad set of integration demos. The repo is
intentionally proof-oriented: claims in the README link to source, docs, or
commands instead of relying on generic architecture statements.

## Platform and toolchain

[![Flutter](https://img.shields.io/badge/Flutter-3.44.6-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-blue.svg)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-02569B.svg)](docs/deployment.md)
[![style: very good analysis](https://img.shields.io/badge/Lint-very__good__analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Custom lint](https://img.shields.io/badge/Lint-custom__lint%20%7C%20mix__lint-64748B.svg)](docs/CODE_QUALITY.md)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)
[![Google Play](https://img.shields.io/badge/Google%20Play-Available-34A853.svg?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
[![Web app](https://img.shields.io/badge/Web%20app-Live-4285F4.svg?logo=googlechrome&logoColor=white)](https://redjadet.github.io/flutter_bloc_app/)

## CI, quality, and supply chain

[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml)
[![Deploy web](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml)
[![Dependency Review](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-review.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-review.yml)
[![Dependency Updates](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-updates.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-updates.yml)
[![Drift](https://github.com/redjadet/flutter_bloc_app/actions/workflows/drift.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/drift.yml)
[![OSV Scanner](https://github.com/redjadet/flutter_bloc_app/actions/workflows/osv-scanner-pr.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/osv-scanner-pr.yml)
[![CodeQL](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml)
[![Coverage](https://img.shields.io/badge/Coverage-86%2E29%25-brightgreen.svg)](docs/CODE_QUALITY.md)
[![Delivery gate](https://img.shields.io/badge/Gate-%2Fbin%2Fchecklist-1B5E20.svg)](docs/validation_scripts.md)
[![Modularity](https://img.shields.io/badge/Modularity-Leak%20guards-6B7280.svg)](docs/modularity.md)
[![Code quality](https://img.shields.io/badge/Docs-CODE__QUALITY-546E7A.svg)](docs/CODE_QUALITY.md)

## Architecture and app stack

[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![ADRs](https://img.shields.io/badge/ADRs-Accepted%20Decisions-475569.svg)](docs/adr/README.md)
[![Offline First](https://img.shields.io/badge/Data-Offline--First-16A34A.svg)](docs/offline_first/adoption_guide.md)
[![State Management](https://img.shields.io/badge/State-BLoC%2FCubit-2563EB.svg)](https://pub.dev/packages/flutter_bloc)
[![Routing](https://img.shields.io/badge/Routing-GoRouter-00ADD8.svg)](https://pub.dev/packages/go_router)
[![DI](https://img.shields.io/badge/DI-get__it-8E44AD.svg)](https://pub.dev/packages/get_it)
[![Persistence](https://img.shields.io/badge/Persistence-Hive-FFB300.svg)](docs/offline_first/hive_schema_migrations.md)
[![Networking](https://img.shields.io/badge/Networking-Dio%20%7C%20Retrofit-0EA5E9.svg)](docs/plans/dio_retrofit_integration_plan.md)
[![Codegen](https://img.shields.io/badge/Codegen-Freezed%20%7C%20JSON-7C3AED.svg)](docs/architecture/freezed_usage_analysis.md)
[![Design System](https://img.shields.io/badge/Design-Material%203%20%7C%20Mix-6200EE.svg)](docs/design_system.md)
[![Testing](https://img.shields.io/badge/Testing-Unit%20%7C%20Widget%20%7C%20Golden%20%7C%20Integration-2E7D32.svg)](docs/testing_overview.md)
[![Localization](https://img.shields.io/badge/Localization-6%20locales-009688.svg)](docs/engineering/localization.md)
[![RTL](https://img.shields.io/badge/i18n-RTL%20%28ar%29-0D9488.svg)](docs/engineering/localization.md)

## Integrations and platform services

[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28.svg)](docs/integrations/firebase_setup.md)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E.svg)](supabase/README.md)
[![FastAPI](https://img.shields.io/badge/API-FastAPI-009688.svg)](docs/integrations/render_fastapi_chat_demo.md)
[![GraphQL](https://img.shields.io/badge/GraphQL-Demo-E10098.svg)](docs/offline_first/graphql_demo.md)
[![AI](https://img.shields.io/badge/AI-GenUI%20%7C%20chat-8B5CF6.svg)](docs/integrations/ai_integration.md)
[![Deep links](https://img.shields.io/badge/Deep%20links-app__links-0F766E.svg)](docs/universal_links/README.md)
[![Observability](https://img.shields.io/badge/Observability-Crashlytics%20%7C%20plan-DC2626.svg)](docs/observability.md)
[![Security](https://img.shields.io/badge/Security-Secrets%20%26%20Config-111827.svg)](docs/security_and_secrets.md)

## Engineering practices

[![Agent harness](https://img.shields.io/badge/Agents-AGENTS.md-18181B.svg)](AGENTS.md)
[![Engineering score](https://img.shields.io/badge/Engineering-10%2F10-brightgreen.svg)](docs/engineering/engineering_quality_scorecard.md)
[![Harness score](https://img.shields.io/badge/Harness-10%2F10-brightgreen.svg)](docs/ai/harness_scorecard.md)
[![Reliability](https://img.shields.io/badge/Reliability-Errors%20%7C%20perf-0369A1.svg)](docs/reliability_error_handling_performance.md)
[![Lifecycle](https://img.shields.io/badge/Lifecycle-Repo%20hygiene-334155.svg)](docs/engineering/REPOSITORY_LIFECYCLE.md)

Harness = agent tooling wiring. Engineering = app/portfolio proof. Do not conflate.

## Live app

- [Google Play Store](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
- [Latest web build](https://redjadet.github.io/flutter_bloc_app/)

## Native Android and iOS engineering

The native showcase is a runnable feature, not a platform-API claim. It keeps
Flutter-facing contracts behind Clean Architecture ports while exercising
Android and iOS implementation details directly.

| Area | Android evidence | iOS evidence | Flutter boundary |
| --- | --- | --- | --- |
| Host-language calls | [Kotlin `MethodChannel`](apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/MainActivity.kt) | [Swift `MethodChannel`](apps/mobile/ios/Runner/AppDelegate.swift) | [host-language service](apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service.dart) |
| High-rate native telemetry | [HandlerThread aggregation and cancellation](apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/NativeShowcaseTelemetryStreamHandler.kt) | [DispatchQueue timers and cancellation](apps/mobile/ios/Runner/NativeShowcaseTelemetryStreamHandler.swift) | [bounded `EventChannel` adapter](apps/mobile/lib/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart) |
| C/C++ interop | [CMake native library wiring](apps/mobile/android/app/src/main/cpp/CMakeLists.txt) | [exported Swift FFI symbols](apps/mobile/ios/Runner/NativeShowcaseBridge.swift) | [FFI adapter](apps/mobile/lib/features/native_platform_showcase/data/ffi_native_showcase_native_code_service.dart) |
| Native UI and system actions | [Android platform-view factory](apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/NativeShowcaseBannerPlatformView.kt) | [UIKit platform view, haptic, and share sheet](apps/mobile/ios/Runner/NativeShowcaseBannerPlatformView.swift) | [showcase feature](apps/mobile/lib/features/native_platform_showcase/) |

The telemetry example samples at 60 Hz, aggregates off the UI thread, emits at
4 Hz, and tears down native work when Flutter cancels the stream. Focused
contract, Cubit, and widget coverage lives in
[`apps/mobile/test/features/native_platform_showcase/`](apps/mobile/test/features/native_platform_showcase/).

```bash
cd apps/mobile
flutter test test/features/native_platform_showcase
flutter build apk --debug --no-pub
flutter build ios --simulator --debug --no-pub
```

## Why this repo differs

Most Flutter repositories document the app. This one also documents how an AI
agent should safely change it. Agents can locate feature ownership, architecture
boundaries, conventions, and proof commands with minimal task-specific guidance.
The workflow stays model-agnostic: Codex, Cursor, Claude Code, Gemini, other AI models (including self-hostable open-weight models), and human contributors can use the same repository-owned files, commands, tools, and scripts.

| Need | Repository mechanism |
| --- | --- |
| Fast, canonical orientation | [`AGENTS.md`](AGENTS.md), [context ladder](docs/ai/context_loading.md), [`CODEMAP.md`](CODEMAP.md), and [feature catalog](docs/feature_overview.md) |
| Right tool and validation lane | `./bin/agent-maintain preflight`, `./bin/agent-maintain tools --intent "<goal>" --paths <files>`, and [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md) |
| Compact repository context | [Repomix profiles](docs/ai/repomix_profiles.md) via `bash tool/repomix_pack.sh onboarding` or `feature <name>` |
| Current AI discovery maps | `bash tool/refresh_ai_reports.sh` plus `bash tool/check_ai_snapshot_freshness.sh` |
| Safe incremental delivery | task trackers, `bash tool/check_ai_change_contract.sh`, focused checks, then `./bin/agent-maintain closeout` |

Start an agent task with [`AGENTS.md`](AGENTS.md). Use Dart MCP when available
for live analysis and runtime inspection; repository scripts remain the
deterministic fallback and CI contract.

## Quick start

```bash
bash tool/workspace_pub_get.sh
dart run melos bootstrap
cd apps/mobile && flutter run -t lib/main_dev.dart
```

With `.envrc` / `tool/direnv/bin` first in `PATH`, `flutter run` also works
from the repo root and is routed to `apps/mobile`.

Agent-oriented bootstrap and validation: [docs/quick_start.md](docs/quick_start.md). Full setup, flavors, and credentials: [docs/new_developer_guide.md](docs/new_developer_guide.md).

## Portfolio reading path

For a fast technical review, read these first:

1. [Interview showcase](docs/interview_showcase.md) — 30-minute walkthrough with
   honest shipped-vs-planned boundaries.
2. [System design showcase](docs/features/system_design_showcase.md) — architecture,
   operations, security, and proof paths.
3. [Architecture](docs/architecture.md) and [Modularity](docs/modularity.md) —
   boundary rules and enforcement scripts.
4. [Testing overview](docs/testing_overview.md) and
   [Validation scripts](docs/validation_scripts.md) — how changes are verified.

## Documentation

| Topic | Doc |
| --- | --- |
| Index | [docs/README.md](docs/README.md) |
| Entry hubs | [docs/architecture.md](docs/architecture.md), [docs/testing.md](docs/testing.md), [docs/engineering-decisions.md](docs/engineering-decisions.md), [docs/ai-workflow.md](docs/ai-workflow.md) |
| Quick start (agents) | [docs/quick_start.md](docs/quick_start.md) |
| Features | [docs/feature_overview.md](docs/feature_overview.md) |
| Architecture | [docs/architecture.md](docs/architecture.md) → [docs/clean_architecture.md](docs/clean_architecture.md), [docs/architecture_details.md](docs/architecture_details.md) |
| Plugin failures & storage | [docs/engineering/plugin_failure_mode_strategy.md](docs/engineering/plugin_failure_mode_strategy.md), [docs/security/storage_rules.md](docs/security/storage_rules.md) |
| ADRs | [docs/adr/README.md](docs/adr/README.md) |
| Design | [DESIGN.md](DESIGN.md), [docs/design_system.md](docs/design_system.md) |
| Validation | [docs/validation_scripts.md](docs/validation_scripts.md), [docs/testing_overview.md](docs/testing_overview.md) |
| Offline-first | [docs/offline_first/adoption_guide.md](docs/offline_first/adoption_guide.md) |
| Security | [docs/SECURITY.md](docs/SECURITY.md), [docs/security_and_secrets.md](docs/security_and_secrets.md) |
| Deploy / lifecycle | [docs/deployment.md](docs/deployment.md), [docs/engineering/REPOSITORY_LIFECYCLE.md](docs/engineering/REPOSITORY_LIFECYCLE.md) |
| Interview walk (~30 min) | [docs/interview_showcase.md](docs/interview_showcase.md) |
| AI agents | [AGENTS.md](AGENTS.md) → [docs/agent_knowledge_base.md](docs/agent_knowledge_base.md) |

## Scope

This file is the repo entrypoint only. Behavior, commands, and deep dives live in [docs/README.md](docs/README.md).

## Screenshots

<!-- markdownlint-disable MD033 -->

### Core app

| Counter | Countdown | Settings |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/small/counter_home.png" alt="Counter home screen" width="240" /> | <img src="apps/mobile/assets/screenshots/small/counter_home2.png" alt="Counter screen with countdown" width="240" /> | <img src="apps/mobile/assets/screenshots/small/settings.png" alt="Settings screen" width="240" /> |

### Data, sync, and feature flows

| Profile | Profile 2 | IoT demo |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/profile.png" alt="Profile screen" width="240" /> | <img src="apps/mobile/assets/screenshots/profile2.png" alt="Profile screen (2)" width="240" /> | <img src="apps/mobile/assets/screenshots/IoT.png" alt="IoT demo" width="240" /> |

| IoT demo 2 | Todo list | Swipe actions |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/IoT2.png" alt="IoT demo 2" width="240" /> | <img src="apps/mobile/assets/screenshots/todolist.png" alt="Todo List screen" width="240" /> | <img src="apps/mobile/assets/screenshots/todolistSwipe.png" alt="Todo List swipe action" width="240" /> |

| Search | Charts | GraphQL |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/search.png" alt="Search demo" width="240" /> | <img src="apps/mobile/assets/screenshots/small/chart.png" alt="Charts page" width="240" /> | <img src="apps/mobile/assets/screenshots/small/graphQL_countries.png" alt="GraphQL countries browser" width="240" /> |

### Integrations and demos

| AI chat | Apple Maps | Google Maps |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/small/ai_chat.png" alt="AI chat conversation" width="240" /> | <img src="apps/mobile/assets/screenshots/apple_maps.png" alt="Apple Maps demo" width="240" /> | <img src="apps/mobile/assets/screenshots/google_maps.png" alt="Google Maps demo" width="240" /> |

| GenUI | Calculator | Summary |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/gen_ui.png" alt="GenUI Demo - AI-generated dynamic UI" width="240" /> | <img src="apps/mobile/assets/screenshots/calculator.png" alt="Payment calculator screen" width="240" /> | <img src="apps/mobile/assets/screenshots/paymentSummary.png" alt="Payment summary screen" width="240" /> |

| Register | In-app purchase | Whiteboard colors |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/register.png" alt="Register screen" width="240" /> | <img src="apps/mobile/assets/screenshots/in_app_purchase.png" alt="In-app purchase screen" width="240" /> | <img src="apps/mobile/assets/screenshots/whiteboard_color_pick.png" alt="Whiteboard color picker" width="240" /> |

| Whiteboard | Markdown | Camera and gallery |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/whiteboard.png" alt="Whiteboard" width="240" /> | <img src="apps/mobile/assets/screenshots/markdown_editor.png" alt="Markdown Editor" width="240" /> | <img src="apps/mobile/assets/screenshots/camera_gallery.png" alt="Camera and gallery picker" width="240" /> |

| Example | Library demo | Library demo 2 |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/example.png" alt="Example screen" width="240" /> | <img src="apps/mobile/assets/screenshots/library_demo.png" alt="Library Demo screen" width="240" /> | <img src="apps/mobile/assets/screenshots/library_demo2.png" alt="Library Demo 2 screen" width="240" /> |

| Learn | Chat list | iGaming |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/learn.png" alt="Learn" width="240" /> | <img src="apps/mobile/assets/screenshots/chat_list.png" alt="Chat list screen" width="240" /> | <img src="apps/mobile/assets/screenshots/igaming.png" alt="iGaming" width="240" /> |

| Scapes |
| --- |
| <img src="apps/mobile/assets/screenshots/scapes.png" alt="Scapes screen" width="240" /> |

<!-- markdownlint-enable MD033 -->
