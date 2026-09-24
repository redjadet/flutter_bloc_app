# Flutter BLoC App

[![Flutter](https://img.shields.io/badge/Flutter-3.47.5-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.4-blue.svg)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-02569B.svg)](docs/deployment.md)
[![style: very good analysis](https://img.shields.io/badge/Lint-very__good__analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)
[![Google Play](https://img.shields.io/badge/Google%20Play-Available-34A853.svg?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
[![Web app](https://img.shields.io/badge/Web%20app-Live-4285F4.svg?logo=googlechrome&logoColor=white)](https://redjadet.github.io/flutter_bloc_app/)

[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml)
[![Deploy web](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml)
[![CodeQL](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml)
[![Coverage](https://img.shields.io/badge/Coverage-86%2E80%25-brightgreen.svg)](docs/CODE_QUALITY.md)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![Offline First](https://img.shields.io/badge/Data-Offline--First-16A34A.svg)](docs/offline_first/adoption_guide.md)
[![State Management](https://img.shields.io/badge/State-BLoC%2FCubit-2563EB.svg)](https://pub.dev/packages/flutter_bloc)
[![Engineering score](https://img.shields.io/badge/Engineering-10%2F10-brightgreen.svg)](docs/engineering/engineering_quality_scorecard.md)

Production-style Flutter portfolio reference: Clean Architecture, Cubit/BLoC,
offline-first sync, native iOS/Android interop, and human-in-the-loop (HITL)
agent workflows. Details live in `docs/` — this README is navigation only.

## Quick start

```bash
bash tool/workspace_pub_get.sh
dart run melos bootstrap
cd apps/mobile && flutter run -t lib/main_dev.dart
```

With `tool/direnv/bin` first in `PATH` (via `.envrc` or
`export PATH="$PWD/tool/direnv/bin:$PATH"`) and an optional gitignored `.env` at
the repo root (see [`.env.example`](.env.example)), `flutter run` from the repo
root routes to `apps/mobile`.

- Agents: [docs/quick_start.md](docs/quick_start.md)
- Full setup: [docs/new_developer_guide.md](docs/new_developer_guide.md)

## Four pillars

Equal pillars — do not collapse to Flutter-only demos:

1. **Flutter / Cubit / Clean Architecture** —
   [feature overview](docs/feature_overview.md),
   [architecture tour](docs/architecture_tour.md)
2. **Offline-first / reliability** —
   [adoption guide](docs/offline_first/adoption_guide.md),
   [offline-first docs](docs/offline_first/README.md)
3. **Native iOS & Android interop** —
   [platforms pack](docs/platforms/README.md),
   [native showcase](apps/mobile/lib/features/native_platform_showcase/README.md)
4. **Human–AI HITL** —
   [collaboration map](docs/ai/human_ai_collaboration.md),
   [AGENTS.md](AGENTS.md)

Evidence and change notes: [docs/changes/](docs/changes/README.md).
Interview walk: [interview showcase](docs/interview_showcase.md).

| Goal | Start here |
| --- | --- |
| Architecture (≤15 min) | [Architecture tour](docs/architecture_tour.md) |
| Code / docs map | [CODEMAP.md](CODEMAP.md), [docs/README.md](docs/README.md) |
| Contribute | [Contributing](docs/contributing/contributing.md) |
| Work with an agent | [AGENTS.md](AGENTS.md), [HITL map](docs/ai/human_ai_collaboration.md) |

## Live app

- [Google Play Store](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
- [Latest web build](https://redjadet.github.io/flutter_bloc_app/)

## Native Android and iOS engineering

Runnable MethodChannel / EventChannel / PlatformView / FFI showcase behind Clean
Architecture ports — not a claim that every host API is wrapped.

- Teaching pack: [docs/platforms/README.md](docs/platforms/README.md)
- Feature: [native_platform_showcase](apps/mobile/lib/features/native_platform_showcase/README.md)
- Host entrypoints: [Android MainActivity](apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/MainActivity.kt),
  [iOS AppDelegate](apps/mobile/ios/Runner/AppDelegate.swift)

```bash
cd apps/mobile && flutter test test/features/native_platform_showcase
```

## Documentation

Index and hubs — open these instead of expanding this file:

- [Documentation index](docs/README.md)
- [Architecture](docs/architecture.md) · [Testing](docs/testing.md) ·
  [Engineering decisions](docs/engineering-decisions.md) ·
  [AI workflow](docs/ai-workflow.md)
- [Design](DESIGN.md) · [ADRs](docs/adr/README.md) ·
  [Validation scripts](docs/validation_scripts.md) ·
  [Security](docs/SECURITY.md) · [Deployment](docs/deployment.md)

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

| Scapes | Social feed |
| --- | --- |
| <img src="apps/mobile/assets/screenshots/scapes.png" alt="Scapes screen" width="240" /> | <img src="apps/mobile/assets/screenshots/social_feed.png" alt="Social feed demo" width="240" /> |

<!-- markdownlint-enable MD033 -->
