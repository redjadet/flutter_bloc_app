# Flutter BLoC App

A production-grade Flutter application demonstrating enterprise-level architecture, modern UI/UX patterns, and best practices. Built with clean architecture principles, offline-first data access, and comprehensive testing coverage.

[![Flutter](https://img.shields.io/badge/Flutter-3.38.6-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.7-blue.svg)](https://dart.dev)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Coverage](https://img.shields.io/badge/Coverage-75%2E46%25-brightgreen.svg)](coverage/coverage_summary.md)
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

## 🎯 Project Overview

This application showcases advanced Flutter development skills including:

- **Clean Architecture** with clear separation of concerns (Domain → Data → Presentation)
- **Offline-First Architecture** with intelligent caching and background synchronization
- **Responsive & Adaptive UI** supporting iOS, Android, and multiple screen sizes
- **Comprehensive Testing** with 75.46% code coverage across unit, widget, and integration tests
- **Production-Ready Features** including authentication, real-time updates, maps, AI integration, and more

## ✨ Key Features

- **AI Chat Integration** - Hugging Face inference with offline queueing
- **Real-Time Updates** - WebSocket connections with reconnection handling
- **Maps Integration** - Google Maps with Apple Maps fallback
- **GraphQL Client** - Efficient data fetching with caching strategies
- **Advanced UI Components** - Custom painters, markdown editor, charts, and more
- **Secure Authentication** - Firebase Auth with biometric support
- **Offline Support** - Cache-first reads with background sync queues

For a complete feature catalog, see [Feature Overview](docs/feature_overview.md).

## 🏗️ Architecture & Design

This project follows industry best practices:

- **Clean Architecture** - Domain-driven design with dependency inversion
- **SOLID Principles** - Maintainable, testable, and extensible codebase
- **Repository Pattern** - Abstracted data access with offline-first support
- **Dependency Injection** - Lazy singleton pattern with `get_it`
- **State Management** - BLoC/Cubit pattern for predictable state flows

📖 **Documentation**: [Architecture Details](docs/architecture_details.md) | [Clean Architecture Guide](docs/clean_architecture.md) | [SOLID Principles](docs/solid_principles.md)

## 🛠️ Tech Stack

### Core Framework

- Flutter 3.38.6 (Dart 3.10.7)
- Material 3 Design System
- Cupertino widgets for iOS-native experience

### Key Libraries

- State Management: `flutter_bloc`
- Storage: `hive` (encrypted), `flutter_secure_storage`
- Networking: `http`, `web_socket_channel`, GraphQL
- Firebase: Auth, Analytics, Crashlytics, Remote Config
- UI: Responsive framework, cached images, charts, markdown editor

📖 **Complete Tech Stack**: [Tech Stack Documentation](docs/tech_stack.md)

## 📱 Screenshots

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

| Todo List | Todo List Swipe Action |
| --- | --- |
| ![Todo List screen](assets/screenshots/todolist.png) | ![Todo List swipe action](assets/screenshots/todolistSwipe.png) |

| Library Demo | Library Demo 2 |
| --- | --- |
| ![Library Demo screen](assets/screenshots/library_demo.png) | ![Library Demo 2 screen](assets/screenshots/library_demo2.png) |

## 🚀 Quick Start

### Prerequisites

- Flutter 3.38.6
- Dart 3.10.7
- iOS 12+ / Android API 21+

### Installation

```bash
flutter pub get
flutter run
```

📖 **Detailed Setup**: [Developer Guide](docs/new_developer_guide.md)

## 📚 Documentation

This project includes comprehensive documentation covering all aspects of development:

### Architecture & Design

- [Clean Architecture](docs/clean_architecture.md) - Architecture overview and principles
- [Architecture Details](docs/architecture_details.md) - Detailed diagrams and state flows
- [State Management Choice](docs/state_management_choice.md) - Why BLoC/Cubit over Riverpod
- [SOLID Principles](docs/solid_principles.md) - SOLID implementation guide
- [DRY Principles](docs/dry_principles.md) - Code reusability patterns

### Features & Implementation

- [Feature Overview](docs/feature_overview.md) - Complete feature catalog
- [Offline-First Guide](docs/offline_first/adoption_guide.md) - Offline architecture patterns
- [AI Integration](docs/ai_integration.md) - Hugging Face integration details
- [Authentication](docs/authentication.md) - Auth flow and security

### UI/UX & Design

- [UI/UX Responsive Review](docs/ui_ux_responsive_review.md) - Responsive design patterns
- [Custom Painter & RenderObject](docs/custom_painter_and_render_object.md) - Advanced rendering

### Performance & Optimization

- [Lazy Loading Analysis](analysis/lazy_loading_late_review.md) - Deferred imports and optimization
- [Compute/Isolate Usage](docs/compute_isolate_review.md) - Isolate patterns for performance
- [Startup Time Profiling](docs/STARTUP_TIME_PROFILING.md) - Performance measurement
- [Bundle Size Monitoring](docs/BUNDLE_SIZE_MONITORING.md) - Bundle optimization

### Quality & Testing

- [Testing Overview](docs/testing_overview.md) - Testing strategies and patterns
- [Code Quality Analysis](docs/CODE_QUALITY_ANALYSIS.md) - Quality metrics and practices
- [Validation Scripts](docs/validation_scripts.md) - Automated quality gates
- [Flutter Best Practices](docs/flutter_best_practices_review.md) - Best practices guide
- [Compile-Time Safety Usage](docs/compile_time_safety_usage.md) - Type-safe BLoC/Cubit usage guide
- [Compile-Time Safety Quick Reference](docs/compile_time_safety_quick_reference.md) - Quick lookup for type-safe patterns
- [Migration Guide](docs/migration_to_type_safe_bloc.md) - Migrating to type-safe BLoC patterns
- [Improvements Analysis](docs/compile_time_safety_improvements_analysis.md) - Recent optimizations and improvements
- [Remaining Tasks Plan](docs/remaining_tasks_plan.md) - Plan for completing remaining compile-time safety tasks
- [Equatable to Freezed Guide](docs/equatable_to_freezed_conversion.md) - Converting Equatable states to Freezed
- [Sealed Classes Migration](docs/sealed_classes_migration.md) - Converting to sealed classes
- [Code Generation Guide](docs/code_generation_guide.md) - Setting up custom code generators for BLoC
- [Custom Lint Rules Guide](docs/custom_lint_rules_guide.md) - Creating custom analyzer plugins

### Development & Operations

- [Developer Guide](docs/new_developer_guide.md) - Setup and development workflow
- [Tech Stack](docs/tech_stack.md) - Complete technology list
- [Security & Secrets](docs/security_and_secrets.md) - Security practices
- [Localization](docs/localization.md) - i18n setup and usage
- [Deployment](docs/deployment.md) - Deployment guide
- [Contributing](docs/contributing.md) - Contribution guidelines

### Reference

- [Shared Utilities](docs/SHARED_UTILITIES.md) - Reusable utilities documentation
- [Repository Lifecycle](docs/REPOSITORY_LIFECYCLE.md) - Repository patterns
- [Dependency Updates](docs/DEPENDENCY_UPDATES.md) - Dependency management
- [FAQ](docs/FAQ.md) - Frequently asked questions
- [Trade-offs & Future](docs/tradeoffs_and_future.md) - Design decisions and roadmap

## ✅ Quality Assurance

The project maintains high quality standards through:

- **Automated Validation** - Pre-commit checks via `./bin/checklist`
- **Code Coverage** - 75.46% test coverage with comprehensive test suites
- **Static Analysis** - Very Good Analysis rules with custom lints
- **Architecture Guards** - Automated checks for architecture compliance

📖 **Quality Details**: [Validation Scripts](docs/validation_scripts.md) | [Testing Overview](docs/testing_overview.md)

## 📄 License

This project is available for free use in public, non-commercial repositories under the terms described in [LICENSE](LICENSE). Any commercial or closed-source usage requires prior written permission from the copyright holder.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers
- All package contributors
- The open-source community

---

Built with ❤️ using Flutter
