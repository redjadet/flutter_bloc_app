# Flutter BLoC App

A feature-rich Flutter reference application that demonstrates clean
architecture, disciplined BLoC/Cubit state management, offline-first patterns,
and production-minded delivery workflows in a single codebase.

[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.41.6-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.4-blue.svg)](https://dart.dev)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Coverage](https://img.shields.io/badge/Coverage-77%2E84%25-brightgreen.svg)](coverage/coverage_summary.md)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![State Management](https://img.shields.io/badge/State%20Management-BLOC%2FCubit-2196F3.svg)](https://pub.dev/packages/flutter_bloc)
[![Routing](https://img.shields.io/badge/Routing-GoRouter-00ADD8.svg)](https://pub.dev/packages/go_router)
[![DI](https://img.shields.io/badge/DI-get__it-8E44AD.svg)](https://pub.dev/packages/get_it)
[![Testing](https://img.shields.io/badge/Testing-Unit%20%7C%20Widget%20%7C%20Golden%20%7C%20Integration-2E7D32.svg)](docs/testing_overview.md)
[![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28.svg)](https://firebase.google.com/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E.svg)](https://supabase.com/)
[![Architecture Pattern](https://img.shields.io/badge/Architecture-Offline--First-4CAF50.svg)](docs/offline_first/adoption_guide.md)
[![Design System](https://img.shields.io/badge/Design%20System-Material%203-6200EE.svg)](https://m3.material.io/)
[![iOS Design](https://img.shields.io/badge/iOS%20Design-Cupertino-007AFF.svg)](https://api.flutter.dev/flutter/cupertino/cupertino-library.html)
[![Type Safety](https://img.shields.io/badge/Type%20Safety-Compile--Time-0F9D58.svg)](docs/compile_time_safety.md)
[![DRY Principles](https://img.shields.io/badge/DRY-Principles-2B7A78.svg)](docs/dry_principles.md)
[![Separation of Concerns](https://img.shields.io/badge/Separation%20of%20Concerns-Applied-00796B.svg)](docs/separation_of_concerns.md)
[![SOLID](https://img.shields.io/badge/SOLID-Principles-6C5CE7.svg)](docs/solid_principles.md)

## Overview

This repository is designed as an engineering reference app, not a narrow demo.
It combines multiple product surfaces and integrations so architecture,
validation, and developer workflow can be evaluated under realistic scope.

The README stays intentionally high level. Setup detail, architecture rationale,
feature-level behavior, and operational guidance live in `docs/` and are linked
throughout this page.

## What This Codebase Covers

- Clean Architecture with a `Domain -> Data -> Presentation` feature structure
- BLoC/Cubit state management with `flutter_bloc`
- Dependency injection via `get_it`
- `GoRouter`-based navigation and multiple app entrypoints
- Firebase-backed core integrations with optional Supabase-backed features
- Offline-first repositories, pending sync, and background reconciliation
- Automated validation, coverage tracking, and CI-backed delivery checks

## Quick Start

### Android (Google Play)

You can install the published Android build from the Google Play Store:

[flutter_bloc_app on Google Play](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)

### Prerequisites

- Flutter `3.41.6`
- Dart `3.11.4`
- Platform tooling for the target you intend to run

Before local setup, review the environment and secrets guides:

- [New Developer Guide](docs/new_developer_guide.md)
- [Firebase Setup](docs/firebase_setup.md)
- [Security and Secrets](docs/security_and_secrets.md)

### Run Locally

```bash
flutter pub get
flutter run -t lib/main_dev.dart
```

Available app entrypoints:

- `lib/main_dev.dart`
- `lib/main_staging.dart`
- `lib/main_prod.dart`

Run code generation when touching Freezed, JSON serialization, Retrofit, or
other generated sources:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Validation Workflow

Use the repo commands instead of ad-hoc validation:

| Command | Purpose |
| --- | --- |
| `./bin/checklist` | Primary local quality gate: formatting, analysis, validation scripts, tests, and coverage workflow. |
| `./bin/integration_tests` | Runs the integration suite for flow-level verification. |
| `./bin/upgrade_validate_all` | Full maintenance workflow for upgrades, validation, integration tests, and coverage/doc refresh. |

Validation behavior, CI coverage, and script-level guards are documented here:

- [Validation Scripts](docs/validation_scripts.md)
- [Testing Overview](docs/testing_overview.md)
- [Contributing](docs/contributing.md)

## Documentation Map

### Start Here

- [New Developer Guide](docs/new_developer_guide.md)
- [Feature Overview](docs/feature_overview.md)
- [Tech Stack](docs/tech_stack.md)
- [FAQ](docs/FAQ.md)

### Architecture and Design

- [Clean Architecture](docs/clean_architecture.md)
- [Architecture Details](docs/architecture_details.md)
- [Modularity](docs/modularity.md)
- [Design System](docs/design_system.md)
- [Architecture Decision Records](docs/adr/)

### Setup and Operations

- [Firebase Setup](docs/firebase_setup.md)
- [Authentication](docs/authentication.md)
- [Security and Secrets](docs/security_and_secrets.md)
- [Deployment](docs/deployment.md)
- [Firebase App Distribution](docs/firebase_app_distribution.md)
- [Android Play Store Release SOP](docs/android_play_store_release_sop.md)

### Quality and Engineering References

- [Testing Overview](docs/testing_overview.md)
- [Validation Scripts](docs/validation_scripts.md)
- [Code Generation Guide](docs/code_generation_guide.md)
- [Compile-Time Safety](docs/compile_time_safety.md)
- [Offline-First Adoption Guide](docs/offline_first/adoption_guide.md)

## Representative Feature Areas

This app spans several kinds of product and platform work. Use the linked docs
for implementation detail and setup notes.

- Core app foundation: counter, settings, localization, adaptive theming, and diagnostics
- Data and sync: todo list, profile, search, chat, charts, and IoT flows with offline-first behavior
- Integrations: Firebase Auth, Remote Config, Realtime Database, FCM, Supabase-backed demos, maps, GraphQL, and WebSocket flows
- AI demos: Hugging Face chat and GenUI-generated UI experiences
- UI/system demos: whiteboard, markdown editor, calculator, library demo, in-app purchase, and platform-adaptive examples

For module entry points and capability notes, see [Feature Overview](docs/feature_overview.md).

## Quality Signals

- CI: [GitHub Actions workflow](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml)
- Coverage: [coverage/coverage_summary.md](coverage/coverage_summary.md)
- Developer workflow: [docs/new_developer_guide.md](docs/new_developer_guide.md)
- Validation guards: [docs/validation_scripts.md](docs/validation_scripts.md)

## Screenshots

<!-- markdownlint-disable MD033 -->

### Core app

| Counter | Countdown | Settings |
| --- | --- | --- |
| <img src="assets/screenshots/small/counter_home.png" alt="Counter home screen" width="240" /> | <img src="assets/screenshots/small/counter_home2.png" alt="Counter screen with countdown" width="240" /> | <img src="assets/screenshots/small/settings.png" alt="Settings screen" width="240" /> |

### Data, sync, and feature flows

| Profile | Profile 2 | IoT demo |
| --- | --- | --- |
| <img src="assets/screenshots/profile.png" alt="Profile screen" width="240" /> | <img src="assets/screenshots/profile2.png" alt="Profile screen (2)" width="240" /> | <img src="assets/screenshots/IoT.png" alt="IoT demo" width="240" /> |

| IoT demo 2 | Todo list | Swipe actions |
| --- | --- | --- |
| <img src="assets/screenshots/IoT2.png" alt="IoT demo 2" width="240" /> | <img src="assets/screenshots/todolist.png" alt="Todo List screen" width="240" /> | <img src="assets/screenshots/todolistSwipe.png" alt="Todo List swipe action" width="240" /> |

| Search | Charts | GraphQL |
| --- | --- | --- |
| <img src="assets/screenshots/search.png" alt="Search demo" width="240" /> | <img src="assets/screenshots/small/chart.png" alt="Charts page" width="240" /> | <img src="assets/screenshots/small/graphQL_countries.png" alt="GraphQL countries browser" width="240" /> |

### Integrations and demos

| AI chat | Apple Maps | Google Maps |
| --- | --- | --- |
| <img src="assets/screenshots/small/ai_chat.png" alt="AI chat conversation" width="240" /> | <img src="assets/screenshots/apple_maps.png" alt="Apple Maps demo" width="240" /> | <img src="assets/screenshots/google_maps.png" alt="Google Maps demo" width="240" /> |

| GenUI | Calculator | Summary |
| --- | --- | --- |
| <img src="assets/screenshots/gen_ui.png" alt="GenUI Demo - AI-generated dynamic UI" width="240" /> | <img src="assets/screenshots/calculator.png" alt="Payment calculator screen" width="240" /> | <img src="assets/screenshots/paymentSummary.png" alt="Payment summary screen" width="240" /> |

| Register | In-app purchase | Whiteboard colors |
| --- | --- | --- |
| <img src="assets/screenshots/register.png" alt="Register screen" width="240" /> | <img src="assets/screenshots/in_app_purchase.png" alt="In-app purchase screen" width="240" /> | <img src="assets/screenshots/whiteboard_color_pick.png" alt="Whiteboard color picker" width="240" /> |

| Whiteboard | Markdown | Camera & gallery |
| --- | --- | --- |
| <img src="assets/screenshots/whiteboard.png" alt="Whiteboard" width="240" /> | <img src="assets/screenshots/markdown_editor.png" alt="Markdown Editor" width="240" /> | <img src="assets/screenshots/camera_gallery.png" alt="Camera and gallery picker" width="240" /> |

| Example | Library demo | Library demo 2 |
| --- | --- | --- |
| <img src="assets/screenshots/example.png" alt="Example screen" width="240" /> | <img src="assets/screenshots/library_demo.png" alt="Library Demo screen" width="240" /> | <img src="assets/screenshots/library_demo2.png" alt="Library Demo 2 screen" width="240" /> |

| Learn | Chat list | iGaming |
| --- | --- | --- |
| <img src="assets/screenshots/learn.png" alt="Learn" width="240" /> | <img src="assets/screenshots/chat_list.png" alt="Chat list screen" width="240" /> | <img src="assets/screenshots/igaming.png" alt="iGaming" width="240" /> |

| Scapes |
| --- |
| <img src="assets/screenshots/scapes.png" alt="Scapes screen" width="240" /> |

<!-- markdownlint-enable MD033 -->

## License

This project is available for free use in public, non-commercial repositories
under the terms described in [LICENSE](LICENSE). Commercial or closed-source
use requires prior written permission from the copyright holder.
