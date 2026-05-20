# Flutter BLoC App

Production-style Flutter reference app: Clean Architecture, offline-first sync, Cubit/BLoC, GoRouter, and a broad demo surface for integrations, AI, and release discipline.

[![Flutter](https://img.shields.io/badge/Flutter-3.44.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.0-blue.svg)](https://dart.dev)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/badge/Coverage-71%2E18%25-brightgreen.svg)](coverage/coverage_summary.md)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)

[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![Offline First](https://img.shields.io/badge/Data-Offline--First-16A34A.svg)](docs/offline_first/adoption_guide.md)
[![Testing](https://img.shields.io/badge/Testing-Unit%20%7C%20Widget%20%7C%20Integration-2E7D32.svg)](docs/testing_overview.md)
[![ADRs](https://img.shields.io/badge/ADRs-Accepted%20Decisions-475569.svg)](docs/adr/README.md)

## Quick start

```bash
flutter pub get
flutter run -t lib/main_dev.dart
```

Setup, flavors, and credentials: [docs/new_developer_guide.md](docs/new_developer_guide.md).

## Documentation

| Topic | Doc |
| --- | --- |
| Index | [docs/README.md](docs/README.md) |
| Features | [docs/feature_overview.md](docs/feature_overview.md) |
| Architecture | [docs/clean_architecture.md](docs/clean_architecture.md), [docs/architecture_details.md](docs/architecture_details.md) |
| ADRs | [docs/adr/README.md](docs/adr/README.md) |
| Design | [DESIGN.md](DESIGN.md), [docs/design_system.md](docs/design_system.md) |
| Validation | [docs/validation_scripts.md](docs/validation_scripts.md), [docs/testing_overview.md](docs/testing_overview.md) |
| Offline-first | [docs/offline_first/adoption_guide.md](docs/offline_first/adoption_guide.md) |
| Security | [docs/SECURITY.md](docs/SECURITY.md), [docs/security_and_secrets.md](docs/security_and_secrets.md) |
| Deploy / lifecycle | [docs/deployment.md](docs/deployment.md), [docs/REPOSITORY_LIFECYCLE.md](docs/REPOSITORY_LIFECYCLE.md) |
| Interview walk (~30 min) | [docs/interview_showcase.md](docs/interview_showcase.md) |
| AI agents | [AGENTS.md](AGENTS.md) → [docs/agent_knowledge_base.md](docs/agent_knowledge_base.md) |

## Screenshots

<!-- markdownlint-disable MD033 -->

| Counter | Todo | Chat | Settings |
| --- | --- | --- | --- |
| <img src="assets/screenshots/small/counter_home.png" alt="Counter" width="200" /> | <img src="assets/screenshots/todolist.png" alt="Todo list" width="200" /> | <img src="assets/screenshots/chat_list.png" alt="Chat list" width="200" /> | <img src="assets/screenshots/small/settings.png" alt="Settings" width="200" /> |

More UI samples: `assets/screenshots/`.

<!-- markdownlint-enable MD033 -->

## Scope

This file is the repo entrypoint only. Behavior, commands, and deep dives live in [docs/README.md](docs/README.md).
