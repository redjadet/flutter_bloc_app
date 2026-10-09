[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml) [![Web app](https://img.shields.io/badge/Web%20app-Live-4285F4.svg?logo=googlechrome&logoColor=white)](https://redjadet.github.io/flutter_bloc_app/) [![Google Play](https://img.shields.io/badge/Google%20Play-Available-34A853.svg?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-blue.svg)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg)](https://dart.dev) [![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS-02569B.svg)](docs/deployment.md) [![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)
[![Agent harness](https://img.shields.io/badge/Agents-AGENTS.md-18181B.svg)](AGENTS.md)
[![Harness score](https://img.shields.io/badge/Harness-10%2F10-brightgreen.svg)](docs/ai/harness_scorecard.md)

# Flutter BLoC App

Flutter / Dart engineering portfolio for **iOS, Android, web and macOS**. The
reference app demonstrates BLoC/Cubit, Clean Architecture, offline-first
synchronization, native Swift/Kotlin integration, and human-reviewed AI workflows.

Start with [verifiable evidence](docs/EVIDENCE.md) for design decisions, named
regressions, recorded test runs, and proof limits.

## Quick start

```bash
bash tool/workspace_pub_get.sh
dart run melos bootstrap
cd apps/mobile && flutter run -t lib/main_dev.dart
```

See the [new developer guide](docs/new_developer_guide.md) for toolchain setup
and backend configuration. This is a **portfolio reference app**; supported
flows and prerequisites are listed in the [feature catalog](docs/feature_overview.md).

## Reviewer path

| Review | Start here |
| --- | --- |
| Flutter state and boundaries | [Counter feature](apps/mobile/lib/features/counter/) · [Clean Architecture](docs/clean_architecture.md) · [Cubit tests](apps/mobile/test/counter_cubit_test.dart) |
| Offline-first reliability | [Adoption guide](docs/offline_first/adoption_guide.md) · [Counter evidence](docs/EVIDENCE.md#1-offline-first-counter-local-persistence-and-queue-replay) |
| Native iOS and Android | [Showcase guide](apps/mobile/lib/features/native_platform_showcase/README.md) · [Platform tests](apps/mobile/test/features/native_platform_showcase/) |
| Human-reviewed AI workflow | [Human decisions and agent contributions](docs/engineering/critical_human_skills.md#human-focus-triad-architecture-intent-edge-cases) · [Collaboration workflow](docs/ai/human_ai_collaboration.md) |

## Detailed guides

- [Technology stack](docs/tech_stack.md) · [Integrations](docs/integrations/README.md) · [Deployment](docs/deployment.md)
- [Testing strategy](docs/testing_overview.md)
- [30-minute showcase](docs/interview_showcase.md) · [Documentation index](docs/README.md)

[Engineering scorecard](docs/engineering/engineering_quality_scorecard.md)

Do not conflate app proof with agent tooling.

## My role and AI-assisted workflow

I am **İlker Sevim**. I set architecture and intent, review edge cases, and own
acceptance; Cursor and Codex assist with implementation and verification.
[Contribution and AI assistance](docs/EVIDENCE.md#contribution-and-ai-assistance)
explains the responsibilities and review gates.

## Screenshots

Captured mobile demo screens. [Full gallery: all 33 screenshots](docs/features/screenshots.md).

<!-- markdownlint-disable MD033 -->

| Offline-capable counter | GraphQL countries browser |
| --- | --- |
| <img src="apps/mobile/assets/screenshots/small/counter_home.png" alt="Counter screen with paused auto-decrement and increment controls" width="240" /> | <img src="apps/mobile/assets/screenshots/small/graphQL_countries.png" alt="GraphQL countries browser with continent filter and country details" width="240" /> |

<!-- markdownlint-enable MD033 -->
