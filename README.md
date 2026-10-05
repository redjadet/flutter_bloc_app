# Flutter BLoC App

[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml)
[![Web app](https://img.shields.io/badge/Web%20app-Live-4285F4.svg?logo=googlechrome&logoColor=white)](https://redjadet.github.io/flutter_bloc_app/)
[![Google Play](https://img.shields.io/badge/Google%20Play-Available-34A853.svg?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)

Flutter / Dart engineering portfolio for **iOS, Android, web and macOS**. The
reference app demonstrates BLoC/Cubit, Clean Architecture, offline-first
synchronization, native Swift/Kotlin integration, and human-reviewed AI workflows.

[Live web demo](https://redjadet.github.io/flutter_bloc_app/) ·
[Google Play](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter) ·
[Portfolio](https://redjadet.github.io/react-web-portfolio/)

## Quick start

```bash
bash tool/workspace_pub_get.sh
dart run melos bootstrap
cd apps/mobile && flutter run -t lib/main_dev.dart
```

Backend demos may require values from [`.env.example`](.env.example); copy them
to the gitignored root `.env`. See the [new developer guide](docs/new_developer_guide.md)
for full setup.

## Reviewer path

| Review | Start here | Evidence |
| --- | --- | --- |
| Flutter state and boundaries | [Counter feature](apps/mobile/lib/features/counter/) · [Clean Architecture](docs/clean_architecture.md) | [Cubit tests](apps/mobile/test/counter_cubit_test.dart) |
| Offline-first reliability | [Counter repository](apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart) · [Adoption guide](docs/offline_first/adoption_guide.md) | [Queue replay test](apps/mobile/test/features/counter/data/background_sync_counter_flow_test.dart) |
| Native iOS and Android | [Showcase guide](apps/mobile/lib/features/native_platform_showcase/README.md) | [Platform tests](apps/mobile/test/features/native_platform_showcase/) |
| Human-reviewed AI workflow | [Collaboration workflow](docs/ai/human_ai_collaboration.md) · [Safety contracts](docs/agent_kb/agent_safety_contracts.md) | [Validation gates](docs/validation_scripts.md) |

For the full walkthrough, see the [30-minute portfolio review](docs/interview_showcase.md).
The [documentation index](docs/README.md) maps the remaining guides.

[Agent harness scorecard](docs/ai/harness_scorecard.md)
[Engineering scorecard](docs/engineering/engineering_quality_scorecard.md)
Do not conflate app proof with agent tooling.

## Scope

This is a portfolio reference app, not a claim that every integration is enabled
in the public demo. Backend-dependent flows need their documented configuration;
native bridges report unavailable states on unsupported hosts. See
[feature scope](docs/feature_overview.md) and the [testing strategy](docs/testing_overview.md)
for prerequisites and verification coverage.
