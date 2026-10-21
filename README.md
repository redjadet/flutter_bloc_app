# Flutter BLoC App

[![Web app](https://img.shields.io/badge/Web%20app-Live-4285F4.svg?logo=googlechrome&logoColor=white)](https://redjadet.github.io/flutter_bloc_app/)
[![Google Play](https://img.shields.io/badge/Google%20Play-Available-34A853.svg?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS-02569B.svg)](docs/deployment.md)

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

## Stack and checks

Stack badges link to implementation and setup guides; workflow badges link to
GitHub runs. See the scorecard for validation scope and coverage policy.

[Engineering scorecard](docs/engineering/engineering_quality_scorecard.md)

**Toolchain**

[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg)](https://dart.dev)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)
[![Codegen](https://img.shields.io/badge/Codegen-Freezed%20%7C%20JSON-7C3AED.svg)](docs/architecture/freezed_usage_analysis.md)
[![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)

**Architecture and state**

[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md)
[![ADRs](https://img.shields.io/badge/ADRs-Accepted%20Decisions-475569.svg)](docs/adr/README.md)
[![State Management](https://img.shields.io/badge/State-BLoC%2FCubit-2563EB.svg)](https://pub.dev/packages/flutter_bloc)
[![DI](https://img.shields.io/badge/DI-get__it-8E44AD.svg)](https://pub.dev/packages/get_it)
[![Routing](https://img.shields.io/badge/Routing-GoRouter-00ADD8.svg)](https://pub.dev/packages/go_router)

**Data and sync**

[![Offline First](https://img.shields.io/badge/Data-Offline--First-16A34A.svg)](docs/offline_first/adoption_guide.md)
[![Persistence](https://img.shields.io/badge/Persistence-Hive-FFB300.svg)](docs/offline_first/hive_schema_migrations.md)
[![Networking](https://img.shields.io/badge/Networking-Dio%20%7C%20Retrofit-0EA5E9.svg)](docs/reliability_error_handling_performance.md)

**UI and localization**

[![Design System](https://img.shields.io/badge/Design-Material%203%20%7C%20Mix-6200EE.svg)](docs/design_system.md)
[![Localization](https://img.shields.io/badge/Localization-6%20locales-009688.svg)](docs/engineering/localization.md)
[![RTL](https://img.shields.io/badge/i18n-RTL%20%28ar%29-0D9488.svg)](docs/engineering/localization.md)

**Integrations**

[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28.svg)](docs/integrations/firebase_setup.md)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E.svg)](supabase/README.md)
[![FastAPI](https://img.shields.io/badge/API-FastAPI-009688.svg)](docs/integrations/render_fastapi_chat_demo.md)
[![GraphQL](https://img.shields.io/badge/GraphQL-Demo-E10098.svg)](docs/offline_first/graphql_demo.md)
[![AI](https://img.shields.io/badge/AI-GenUI%20%7C%20chat-8B5CF6.svg)](docs/integrations/ai_integration.md)
[![Deep links](https://img.shields.io/badge/Deep%20links-app__links-0F766E.svg)](docs/universal_links/README.md)

**Quality and delivery**

[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml)
[![Deploy web](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml)
[![Testing](https://img.shields.io/badge/Testing-Unit%20%7C%20Widget%20%7C%20Golden%20%7C%20Integration-2E7D32.svg)](docs/testing_overview.md)
[![Coverage policy](https://img.shields.io/badge/Coverage-policy%20%26%20scope-546E7A.svg)](docs/CODE_QUALITY.md)
[![Delivery gate](https://img.shields.io/badge/Gate-%2Fbin%2Fchecklist-1B5E20.svg)](docs/validation_scripts.md)
[![Code quality](https://img.shields.io/badge/Docs-CODE__QUALITY-546E7A.svg)](docs/CODE_QUALITY.md)
[![style: very good analysis](https://img.shields.io/badge/Lint-very__good__analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Custom lint](https://img.shields.io/badge/Lint-analysis__server__plugin%20%7C%20mix__lint-64748B.svg)](docs/CODE_QUALITY.md)
[![Modularity](https://img.shields.io/badge/Modularity-Leak%20guards-6B7280.svg)](docs/modularity.md)

**Reliability and security**

[![Reliability](https://img.shields.io/badge/Reliability-Errors%20%7C%20perf-0369A1.svg)](docs/reliability_error_handling_performance.md)
[![Observability](https://img.shields.io/badge/Observability-Crashlytics-DC2626.svg)](docs/observability.md)
[![Security](https://img.shields.io/badge/Security-Secrets%20%26%20Config-111827.svg)](docs/security_and_secrets.md)
[![Dependency Review](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-review.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-review.yml)
[![Dep drift](https://github.com/redjadet/flutter_bloc_app/actions/workflows/drift.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/drift.yml)
[![OSV Scanner](https://github.com/redjadet/flutter_bloc_app/actions/workflows/osv-scanner-pr.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/osv-scanner-pr.yml)
[![CodeQL](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml)

**Agent tooling and repository maintenance**

Do not conflate app proof with agent tooling. App and runtime evidence is recorded
in [EVIDENCE.md](docs/EVIDENCE.md); the harness score describes agent tooling.

[![Agent harness](https://img.shields.io/badge/Agents-AGENTS.md-18181B.svg)](AGENTS.md)
[![Harness score](https://img.shields.io/badge/Harness-10%2F10-brightgreen.svg)](docs/ai/harness_scorecard.md)
[![Lifecycle](https://img.shields.io/badge/Lifecycle-Repo%20hygiene-334155.svg)](docs/engineering/REPOSITORY_LIFECYCLE.md)

## My role and AI-assisted workflow

I am **İlker Sevim**. I set architecture and intent, review edge cases, and own
acceptance; Cursor and Codex assist with implementation and verification.
[Contribution and AI assistance](docs/EVIDENCE.md#contribution-and-ai-assistance)
explains the responsibilities and review gates.

## Screenshots

All 33 captured mobile screens are included below, grouped by feature. These
images document captured states; the [live web demo](https://redjadet.github.io/flutter_bloc_app/)
shows the current web build. A [standalone gallery](docs/features/screenshots.md)
is also available.

<!-- markdownlint-disable MD033 -->

### Counter and countries

| Offline-capable counter | GraphQL countries browser |
| --- | --- |
| <img src="apps/mobile/assets/screenshots/small/counter_home.png" alt="Counter screen with paused auto-decrement and increment controls" width="240" /> | <img src="apps/mobile/assets/screenshots/small/graphQL_countries.png" alt="GraphQL countries browser with continent filter and country details" width="240" /> |

### Core app

| Countdown | Settings | Country code picker |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/small/counter_home2.png" alt="Counter screen with countdown" width="240" /> | <img src="apps/mobile/assets/screenshots/small/settings.png" alt="Settings screen" width="240" /> | <img src="apps/mobile/assets/screenshots/country_code.png" alt="Country code picker" width="240" /> |

### Data, sync, and feature flows

| Profile | Profile 2 | IoT demo |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/profile.png" alt="Profile screen" width="240" /> | <img src="apps/mobile/assets/screenshots/profile2.png" alt="Profile screen (2)" width="240" /> | <img src="apps/mobile/assets/screenshots/IoT.png" alt="IoT demo" width="240" /> |

| IoT demo 2 | Todo list | Swipe actions |
| --- | --- | --- |
| <img src="apps/mobile/assets/screenshots/IoT2.png" alt="IoT demo 2" width="240" /> | <img src="apps/mobile/assets/screenshots/todolist.png" alt="Todo List screen" width="240" /> | <img src="apps/mobile/assets/screenshots/todolistSwipe.png" alt="Todo List swipe action" width="240" /> |

| Search | Charts |
| --- | --- |
| <img src="apps/mobile/assets/screenshots/search.png" alt="Search demo" width="240" /> | <img src="apps/mobile/assets/screenshots/small/chart.png" alt="Charts page" width="240" /> |

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
