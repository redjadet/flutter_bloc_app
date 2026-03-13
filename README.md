# Flutter BLoC App

A reference Flutter application built to demonstrate disciplined product
engineering: clear architecture, robust state management, strong validation, and
production-minded development workflow.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.4-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.1-blue.svg)](https://dart.dev)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Coverage](https://img.shields.io/badge/Coverage-75%2E86%25-brightgreen.svg)](coverage/coverage_summary.md)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![State Management](https://img.shields.io/badge/State%20Management-BLOC%2FCubit-2196F3.svg)](https://pub.dev/packages/flutter_bloc)
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

This repository is intended as a serious engineering sample rather than a
single-purpose demo. It brings together multiple product surfaces in one codebase
and uses that breadth to show how architecture, testing, and developer workflow
can stay coherent as scope grows.

The emphasis is on maintainability, correctness, and clarity. For implementation
details, feature-level behavior, and internal standards, use the documentation
linked below rather than this README.

## Quick Start

### Prerequisites

- Flutter 3.41.4
- Dart 3.11.1
- iOS 12+ / Android API 21+

```bash
flutter pub get
flutter run -t lib/main_dev.dart
./bin/checklist
```

Run the integration suite separately when needed:

```bash
./bin/integration_tests
```

## Documentation

Start here:

- [Developer Guide](docs/new_developer_guide.md)
- [Feature Overview](docs/feature_overview.md)
- [Architecture Details](docs/architecture_details.md)
- [Testing Overview](docs/testing_overview.md)

Setup and operations:

- [Firebase Setup](docs/firebase_setup.md)
- [Security and Secrets](docs/security_and_secrets.md)
- [Deployment](docs/deployment.md)

Engineering references:

- [Clean Architecture](docs/clean_architecture.md)
- [Validation Scripts](docs/validation_scripts.md)
- [Tech Stack](docs/tech_stack.md)
- [Architecture Decisions](docs/adr/)
- Feature and integration guides: [Feature Overview](docs/feature_overview.md) (catalog and deep-dive links; see also FCM, Todo List, Google Maps, GenUI in `docs/`)

## Quality Signals

- Validation workflow: `./bin/checklist`
- Integration test suite: `./bin/integration_tests`
- Coverage tracking: [coverage/coverage_summary.md](coverage/coverage_summary.md)
- Additional validation guidance: [docs/testing_overview.md](docs/testing_overview.md)

## Screenshots

| Counter Home | Auto Countdown | Settings |
| --- | --- | --- |
| ![Counter home screen](assets/screenshots/small/counter_home.png) | ![Counter screen with countdown](assets/screenshots/small/counter_home2.png) | ![Settings screen](assets/screenshots/small/settings.png) |

| Charts | GraphQL | AI Chat |
| --- | --- | --- |
| ![Charts page](assets/screenshots/small/chart.png) | ![GraphQL countries browser](assets/screenshots/small/graphQL_countries.png) | ![AI chat conversation](assets/screenshots/small/ai_chat.png) |

| GenUI Demo |
| --- |
<!-- markdownlint-disable-next-line MD033 -->
| <img src="assets/screenshots/gen_ui.png" alt="GenUI Demo - AI-generated dynamic UI" width="240" /> |

| Apple Maps Demo | Google Maps Demo | Search |
| --- | --- | --- |
| ![Apple Maps demo](assets/screenshots/apple_maps.png) | ![Google Maps demo](assets/screenshots/google_maps.png) | ![Search demo](assets/screenshots/search.png) |

| Payment Calculator | Payment Summary | Register |
| --- | --- | --- |
| ![Payment calculator screen](assets/screenshots/calculator.png) | ![Payment summary screen](assets/screenshots/paymentSummary.png) | ![Register screen](assets/screenshots/register.png) |

| Color Picker | Whiteboard | Markdown Editor |
| --- | --- | --- |
| ![Whiteboard color picker](assets/screenshots/whiteboard_color_pick.png) | ![Whiteboard](assets/screenshots/whiteboard.png) | ![Markdown Editor](assets/screenshots/markdown_editor.png) |

| Todo List | Todo List Swipe Action |
| --- | --- |
| ![Todo List screen](assets/screenshots/todolist.png) | ![Todo List swipe action](assets/screenshots/todolistSwipe.png) |

| Library Demo | Library Demo 2 |
| --- | --- |
| ![Library Demo screen](assets/screenshots/library_demo.png) | ![Library Demo 2 screen](assets/screenshots/library_demo2.png) |

## License

This project is available for free use in public, non-commercial repositories
under the terms described in [LICENSE](LICENSE). Commercial or closed-source use
requires prior written permission from the copyright holder.
