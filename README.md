# Flutter BLoC App

Flutter / Dart engineering portfolio for **iOS, Android, web and macOS**. The
reference app demonstrates BLoC/Cubit, Clean Architecture, offline-first
synchronization, native Swift/Kotlin integration, and human-reviewed AI workflows.

**Hiring reviewers:** a late remote counter response must not overwrite newer
local work. The repository re-reads local state before saving the response.
Inspect [`pullRemote re-checks local before save when local advances`](https://github.com/redjadet/flutter_bloc_app/blob/5aa04771392fccf77dd3ea7fd0f11bb4a2cb6372/apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart#L455)
and its [passing app test run](https://github.com/redjadet/flutter_bloc_app/actions/runs/37902949216/job/113729610021)
and [iOS simulator smoke run](https://github.com/redjadet/flutter_bloc_app/actions/runs/37902949216/job/113730219449)
(2026-10-09, `5aa0477`). **[Verifiable evidence](docs/EVIDENCE.md)** explains the
decision and proof limits; the [30-minute showcase](docs/interview_showcase.md)
provides the full walkthrough.

**Project and toolchain**

[![Web app](https://img.shields.io/badge/Web%20app-Live-4285F4.svg?logo=googlechrome&logoColor=white)](https://redjadet.github.io/flutter_bloc_app/) [![Google Play](https://img.shields.io/badge/Google%20Play-Available-34A853.svg?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.ilkersevim.blocflutter)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-blue.svg)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS-02569B.svg)](docs/deployment.md) [![License](https://img.shields.io/badge/License-Custom-lightgrey.svg)](LICENSE)
[![style: very good analysis](https://img.shields.io/badge/Lint-very__good__analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis) [![Custom lint](https://img.shields.io/badge/Lint-analysis__server__plugin%20%7C%20mix__lint-64748B.svg)](docs/CODE_QUALITY.md) [![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

**CI and supply chain**

[![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml) [![Deploy web](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/deploy_web.yml)
[![Dependency Review](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-review.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/dependency-review.yml) [![Dep drift](https://github.com/redjadet/flutter_bloc_app/actions/workflows/drift.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/drift.yml)
[![OSV Scanner](https://github.com/redjadet/flutter_bloc_app/actions/workflows/osv-scanner-pr.yml/badge.svg)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/osv-scanner-pr.yml) [![CodeQL](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/codeql.yml)

**Architecture and quality**

[![Coverage policy](https://img.shields.io/badge/Coverage-policy%20%26%20scope-546E7A.svg)](docs/CODE_QUALITY.md) [![Delivery gate](https://img.shields.io/badge/Gate-%2Fbin%2Fchecklist-1B5E20.svg)](docs/validation_scripts.md) [![Modularity](https://img.shields.io/badge/Modularity-Leak%20guards-6B7280.svg)](docs/modularity.md) [![Code quality](https://img.shields.io/badge/Docs-CODE__QUALITY-546E7A.svg)](docs/CODE_QUALITY.md)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](docs/clean_architecture.md) [![ADRs](https://img.shields.io/badge/ADRs-Accepted%20Decisions-475569.svg)](docs/adr/README.md) [![Offline First](https://img.shields.io/badge/Data-Offline--First-16A34A.svg)](docs/offline_first/adoption_guide.md)
[![State Management](https://img.shields.io/badge/State-BLoC%2FCubit-2563EB.svg)](https://pub.dev/packages/flutter_bloc) [![Routing](https://img.shields.io/badge/Routing-GoRouter-00ADD8.svg)](https://pub.dev/packages/go_router) [![DI](https://img.shields.io/badge/DI-get__it-8E44AD.svg)](https://pub.dev/packages/get_it)
[![Persistence](https://img.shields.io/badge/Persistence-Hive-FFB300.svg)](docs/offline_first/hive_schema_migrations.md) [![Networking](https://img.shields.io/badge/Networking-Dio%20%7C%20Retrofit-0EA5E9.svg)](docs/reliability_error_handling_performance.md) [![Codegen](https://img.shields.io/badge/Codegen-Freezed%20%7C%20JSON-7C3AED.svg)](docs/architecture/freezed_usage_analysis.md)
[![Design System](https://img.shields.io/badge/Design-Material%203%20%7C%20Mix-6200EE.svg)](docs/design_system.md) [![Testing](https://img.shields.io/badge/Testing-Unit%20%7C%20Widget%20%7C%20Golden%20%7C%20Integration-2E7D32.svg)](docs/testing_overview.md)
[![Localization](https://img.shields.io/badge/Localization-6%20locales-009688.svg)](docs/engineering/localization.md) [![RTL](https://img.shields.io/badge/i18n-RTL%20%28ar%29-0D9488.svg)](docs/engineering/localization.md)

**Integrations**

[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28.svg)](docs/integrations/firebase_setup.md) [![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E.svg)](supabase/README.md) [![FastAPI](https://img.shields.io/badge/API-FastAPI-009688.svg)](docs/integrations/render_fastapi_chat_demo.md) [![GraphQL](https://img.shields.io/badge/GraphQL-Demo-E10098.svg)](docs/offline_first/graphql_demo.md)
[![AI](https://img.shields.io/badge/AI-GenUI%20%7C%20chat-8B5CF6.svg)](docs/integrations/ai_integration.md) [![Deep links](https://img.shields.io/badge/Deep%20links-app__links-0F766E.svg)](docs/universal_links/README.md) [![Observability](https://img.shields.io/badge/Observability-Crashlytics-DC2626.svg)](docs/observability.md) [![Security](https://img.shields.io/badge/Security-Secrets%20%26%20Config-111827.svg)](docs/security_and_secrets.md)

**Engineering practices**

[![Agent harness](https://img.shields.io/badge/Agents-AGENTS.md-18181B.svg)](AGENTS.md)
[![Harness score](https://img.shields.io/badge/Harness-10%2F10-brightgreen.svg)](docs/ai/harness_scorecard.md)
[![Reliability](https://img.shields.io/badge/Reliability-Errors%20%7C%20perf-0369A1.svg)](docs/reliability_error_handling_performance.md) [![Lifecycle](https://img.shields.io/badge/Lifecycle-Repo%20hygiene-334155.svg)](docs/engineering/REPOSITORY_LIFECYCLE.md)

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

The [documentation index](docs/README.md) maps the remaining guides.

[Agent harness scorecard](docs/ai/harness_scorecard.md) ·
[Engineering scorecard](docs/engineering/engineering_quality_scorecard.md)

Do not conflate app proof with agent tooling.

## My role and AI-assisted workflow

I am **İlker Sevim**, the owner of this repository. I set feature scope and
architecture direction: repository ports separate Cubits from storage, offline
state has explicit replay/reconciliation rules, and native replies become typed
results before reaching UI state. I review implementation choices, failure paths,
and regression coverage, then validate changes through targeted tests and PR CI.

AI coding agents, including Cursor and Codex, assist with implementation,
documentation, and review. I define intent and the allowed write-set, assess
proposed diffs, and own the acceptance decision. The [human–AI collaboration
workflow](docs/ai/human_ai_collaboration.md), [agent entry map](AGENTS.md), and
[AI-native SDLC kit](docs/ai-sdlc/README.md) make those review gates inspectable.
AI-assisted changes pass through those same review gates. My contribution is
design, review, and validation responsibility, with implementation assistance
acknowledged rather than sole authorship claimed for every line.

## Scope and limits

This is a **portfolio reference app**, not production software at scale. It does
not establish additional years of platform experience, employer tenure, live user
counts, or revenue. Backend-dependent flows need their documented configuration;
native bridges report unavailable states on unsupported hosts. See
[feature scope](docs/feature_overview.md), **[Verifiable evidence](docs/EVIDENCE.md)**,
and the [testing strategy](docs/testing_overview.md) for prerequisites and
verification coverage.

## Screenshots

<details>
<summary>Show all screenshots</summary>

Captured screens from the mobile demo. The live web demo shows the current build.

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

</details>
