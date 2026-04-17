# Flutter BLoC App

A Flutter reference application for Clean Architecture, `flutter_bloc`,
offline-first data flows, and integration-heavy product demos.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.5-blue.svg)](https://dart.dev)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Coverage](https://img.shields.io/badge/Coverage-74%2E72%25-brightgreen.svg)](coverage/coverage_summary.md)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)

[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![Architecture Pattern](https://img.shields.io/badge/Architecture-Offline--First-4CAF50.svg)](docs/offline_first/adoption_guide.md)
[![State Management](https://img.shields.io/badge/State%20Management-BLOC%2FCubit-2196F3.svg)](https://pub.dev/packages/flutter_bloc)
[![Routing](https://img.shields.io/badge/Routing-GoRouter-00ADD8.svg)](https://pub.dev/packages/go_router)
[![DI](https://img.shields.io/badge/DI-get__it-8E44AD.svg)](https://pub.dev/packages/get_it)
[![Testing](https://img.shields.io/badge/Testing-Unit%20%7C%20Widget%20%7C%20Golden%20%7C%20Integration-2E7D32.svg)](docs/testing_overview.md)

[![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28.svg)](https://firebase.google.com/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E.svg)](https://supabase.com/)
[![FastAPI](https://img.shields.io/badge/FastAPI-Chat%20demo-009688.svg)](docs/integrations/render_fastapi_chat_demo.md)
[![Render](https://img.shields.io/badge/Render-Hosting-46E3B7.svg)](https://render.com/)
[![FastAPI Cloud](https://img.shields.io/badge/FastAPI%20Cloud-Hosting-0B5FFF.svg)](https://fastapicloud.com/)
[![AI Chat](https://img.shields.io/badge/AI-Chat%20Flows-0EA5E9.svg)](docs/ai_integration.md)

[![Staff Demo](https://img.shields.io/badge/Demo-Staff%20App-2563EB.svg)](docs/staff_app_demo_walkthrough.md)
[![Case Studies](https://img.shields.io/badge/Product-Case%20Studies-8B5CF6.svg)](docs/case_studies/README.md)
[![Design System](https://img.shields.io/badge/Design%20System-Material%203-6200EE.svg)](https://m3.material.io/)
[![iOS Design](https://img.shields.io/badge/iOS%20Design-Cupertino-007AFF.svg)](https://api.flutter.dev/flutter/cupertino/cupertino-library.html)
[![Type Safety](https://img.shields.io/badge/Type%20Safety-Compile--Time-0F9D58.svg)](docs/compile_time_safety.md)
[![DRY Principles](https://img.shields.io/badge/DRY-Principles-2B7A78.svg)](docs/dry_principles.md)
[![Separation of Concerns](https://img.shields.io/badge/Separation%20of%20Concerns-Applied-00796B.svg)](docs/separation_of_concerns.md)
[![SOLID](https://img.shields.io/badge/SOLID-Principles-6C5CE7.svg)](docs/solid_principles.md)

## Overview

This repository is an engineering reference app rather than a single-purpose
demo. It combines shared app infrastructure, offline-first patterns, backend
integrations, AI/chat transports, and multiple product-style feature surfaces
so architecture, validation, and delivery workflows can be exercised under
realistic scope.

## Start Here

- Full docs index: [docs/README.md](docs/README.md)
- Local setup and first run: [docs/new_developer_guide.md](docs/new_developer_guide.md)
- Feature and route catalog: [docs/feature_overview.md](docs/feature_overview.md)
- Validation and test lanes: [docs/testing_overview.md](docs/testing_overview.md),
  [docs/validation_scripts.md](docs/validation_scripts.md)
- Architecture and repo shape: [docs/clean_architecture.md](docs/clean_architecture.md),
  [docs/architecture_details.md](docs/architecture_details.md)
- Security and secret injection: [docs/security_and_secrets.md](docs/security_and_secrets.md),
  [docs/SECURITY.md](docs/SECURITY.md)
- Deployment and release: [docs/deployment.md](docs/deployment.md)

## Current Surfaces

- AI chat overview: [docs/ai_integration.md](docs/ai_integration.md)
- FastAPI Cloud chat orchestration: [docs/integrations/render_fastapi_chat_demo.md](docs/integrations/render_fastapi_chat_demo.md)
- Staff app demo walkthrough: [docs/staff_app_demo_walkthrough.md](docs/staff_app_demo_walkthrough.md)
- Case-study briefs and demo context: [docs/case_studies/README.md](docs/case_studies/README.md)

## Repo Snapshot

- Toolchain: Flutter `3.41.7`, Dart `3.11.5`
- Entry points: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`
- Architecture shape: `Presentation -> Domain <- Data`
- Core infra: `flutter_bloc`, `get_it`, `GoRouter`, offline-first sync under `lib/shared/sync/`
- Validation entrypoints: `./tool/delivery_checklist.sh`, `./bin/router_feature_validate`, `./bin/integration_tests`, `./bin/upgrade_validate_all`

Use [docs/README.md](docs/README.md) as the source-of-truth navigation page for everything else.

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
