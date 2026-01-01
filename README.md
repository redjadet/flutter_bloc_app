# Flutter BLoC App

A production-grade Flutter app demonstrating clean architecture, offline-first
data access, and modern responsive/adaptive UI patterns. Includes AI chat via
Hugging Face, real-time updates, maps, and advanced rendering demos.

[![Flutter](https://img.shields.io/badge/Flutter-3.38.5-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.4-blue.svg)](https://dart.dev)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Coverage](https://img.shields.io/badge/Coverage-83%2E87%25-brightgreen.svg)](coverage/coverage_summary.md)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![State Management](https://img.shields.io/badge/State%20Management-BLOC%2FCubit-2196F3.svg)](https://pub.dev/packages/flutter_bloc)
[![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28.svg)](https://firebase.google.com/)
[![Architecture Pattern](https://img.shields.io/badge/Architecture-Offline--First-4CAF50.svg)](docs/offline_first/adoption_guide.md)
[![Design System](https://img.shields.io/badge/Design%20System-Material%203-6200EE.svg)](https://m3.material.io/)
[![iOS Design](https://img.shields.io/badge/iOS%20Design-Cupertino-007AFF.svg)](https://api.flutter.dev/flutter/cupertino/cupertino-library.html)
[![DRY Principles](https://img.shields.io/badge/DRY-Principles-2B7A78.svg)](docs/dry_principles.md)
[![SOLID](https://img.shields.io/badge/SOLID-Principles-6C5CE7.svg)](docs/solid_principles.md)

---

## Highlights

- Clean Architecture (domain -> data -> presentation) with DI and testable boundaries
- Offline-first repositories with background sync, retries, and cache-first reads
- Responsive/adaptive UI with platform-aware components and shared design system
- Robust quality gates: formatting, analysis, validation scripts, and coverage
- Security-minded foundations (encrypted storage, biometric gating, auth routing)

## What This App Demonstrates

- **Architecture**: repository pattern, DI composition root, and Flutter-agnostic domain
- **Offline-first**: pending sync queues, cache-first reads, and background flushing
- **UI/UX**: Material 3 + Cupertino adaptive widgets, text scaling, and safe-area handling
- **Resilience**: error mapping, retries, guarded async flows, and lifecycle safety
- **Performance**: `BlocSelector`, repaint isolation, responsive layout helpers, and [lazy loading optimizations](analysis/lazy_loading_late_review.md)

## Features (Selected)

- AI chat with Hugging Face inference, offline queueing, and cached history
- Counter with auto-decrement timer and encrypted persistence
- Search with cache-first results and background refresh
- GraphQL countries browser with caching and staleness policy
- WebSocket demo with reconnect and message states
- Maps: Google Maps + Apple Maps fallback
- Whiteboard (CustomPainter) and Markdown editor (custom RenderObject)

Full feature catalog: `docs/feature_overview.md`.

## Architecture & Documentation

- Clean architecture overview: `docs/clean_architecture.md`
- Architecture diagrams and state flow: `docs/architecture_details.md`
- Offline-first patterns: `docs/offline_first/adoption_guide.md`
- UI/UX responsive rules: `docs/ui_ux_responsive_review.md`
- Performance optimization: [`analysis/lazy_loading_late_review.md`](analysis/lazy_loading_late_review.md) (comprehensive lazy loading guide)
- Auth and security flow: `docs/authentication.md`
- SOLID and DRY reviews: `docs/solid_principles.md`, `docs/dry_principles.md`
- AI integration notes: `docs/ai_integration.md`
- Advanced rendering notes: `docs/custom_painter_and_render_object.md`
- Testing overview: `docs/testing_overview.md`
- Trade-offs and future improvements: `docs/tradeoffs_and_future.md`
- Validation scripts: `docs/validation_scripts.md`
- Developer setup and testing: `docs/new_developer_guide.md`

## Additional Resources

### Development & Setup

- Tech stack and packages: `docs/tech_stack.md`
- Security and secrets management: `docs/security_and_secrets.md`
- Localization setup: `docs/localization.md`
- Deployment guide: `docs/deployment.md`
- Contributing guidelines: `docs/contributing.md`

### Code Quality & Best Practices

- Code quality analysis: `docs/CODE_QUALITY_ANALYSIS.md`
- Flutter best practices review: `docs/flutter_best_practices_review.md`
- Shared utilities documentation: `docs/SHARED_UTILITIES.md`
- Repository lifecycle guide: `docs/REPOSITORY_LIFECYCLE.md`
- Dependency update monitoring: `docs/DEPENDENCY_UPDATES.md`

### Performance & Optimization

- [Lazy loading analysis](analysis/lazy_loading_late_review.md) - Comprehensive guide to deferred imports, lazy DI, route-level initialization, and optimization opportunities
- [Compute/isolate usage](docs/compute_isolate_review.md) - Guide to using `compute()` and isolates for JSON decoding and CPU-intensive operations
- [Startup time profiling](docs/STARTUP_TIME_PROFILING.md) - Measuring and profiling app startup time
- [Bundle size monitoring](docs/BUNDLE_SIZE_MONITORING.md) - Monitoring and optimizing app bundle size

### Reference & Support

- Frequently asked questions: `docs/FAQ.md`

## Quick Start

### Prerequisites

- Flutter 3.38.5
- Dart 3.10.4
- iOS 12+ / Android API 21+

### Installation

```bash
flutter pub get
flutter run
```

For codegen, localization, and platform-specific setup, see
`docs/new_developer_guide.md`.

## Quality Gates

Run the full checklist before commits:

```bash
./bin/checklist
```

This runs formatting, analysis, validation scripts, and coverage. See
`docs/validation_scripts.md` for details.

## Validation Scripts (Overview)

The checklist includes automated guards for architecture, UI/UX, async safety,
performance, and memory hygiene. Full documentation and suppression guidance:
`docs/validation_scripts.md`.

## Screenshots

| Counter Home | Auto Countdown | Settings |
| --- | --- | --- |
| ![Counter home screen](assets/screenshots/small/counter_home.png) | ![Counter screen with countdown](assets/screenshots/small/counter_home2.png) | ![Settings screen](assets/screenshots/small/settings.png) |

| Charts | GraphQL | AI Chat |
| --- | --- | --- |
| ![Charts page](assets/screenshots/small/chart.png) | ![GraphQL countries browser](assets/screenshots/small/graphQL_countries.png) | ![AI chat conversation](assets/screenshots/small/ai_chat.png) |

| Apple Maps Demo | Google Maps Demo | Search |
| --- | --- | --- |
| ![Apple Maps demo](assets/screenshots/apple_maps.png) | ![Google Maps demo](assets/screenshots/google_maps.png) | ![Search demo](assets/screenshots/search.png) |

| Payment Calculator | Payment Summary | Register |
| --- | --- | --- |
| ![Payment calculator screen](assets/screenshots/calculator.png) | ![Payment summary screen](assets/screenshots/paymentSummary.png) | ![Register screen](assets/screenshots/register.png) |

| Color Picker | Whiteboard | Markdown Editor |
| --- | --- | --- |
| ![Whiteboard color picker](assets/screenshots/whiteboard_color_pick.png) | ![Whiteboard](assets/screenshots/whiteboard.png) | ![Markdown Editor](assets/screenshots/markdown_editor.png) |

More screenshots are available in `assets/screenshots/`.

---

## License

This project is available for free use in public, non-commercial repositories under the terms described in [`LICENSE`](LICENSE). Any commercial or closed-source usage requires prior written permission from the copyright holder.

---

## Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers
- All package contributors
- The open-source community

---

Built with ❤️ using Flutter
