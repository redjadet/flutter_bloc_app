# Case studies

This folder owns two evidence types:

- **Product briefs** define requirements for vertical demos.
- **Engineering decision stories** explain a bounded decision, rejected options,
  trade-offs, proof, changed default, and revisit trigger.

Implementation notes, routes, and point-in-time evidence remain in linked
feature docs and `docs/changes/` entries. The
[interview showcase](../interview_showcase.md) links these case studies instead
of duplicating their narratives.

## Product briefs

| Brief | In-app feature | Module |
| --- | --- | --- |
| [Dentists](dentists.md) — video answers to ten predefined questions | Case Study Demo | `apps/mobile/lib/features/case_study_demo/` |

**Routes:** `/case-study-demo` and nested paths (see [Feature overview](../feature_overview.md)).
**Entry:** Example hub (`/example`) and `AppRoutes` constants in
`apps/mobile/lib/app/router/app_routes.dart`.

**Implementation / migration notes:**

- [Dentist case study demo — plan](../changes/2026-04-01_dentist_case_study_demo_plan.md) — scope, routes, auth, Hive, tests
- [Dentists brief](dentists.md) — includes shipped optional Supabase private storage (bucket, RLS, signed URLs, submit)

## Engineering decision stories

| Story | Decision boundary |
| --- | --- |
| [Mobile release secret boundary](engineering/mobile_release_secret_boundary.md) | Public client configuration versus server-only authority |
| [macOS dependency compatibility](engineering/macos_dependency_compatibility.md) | Per-plugin CocoaPods fallback without abandoning SwiftPM |
| [Social Feed offline ownership](engineering/social_feed_offline_ownership.md) | Newest local intent versus stale remote/replay state |
| [Todo measurement-gated performance](engineering/todo_measurement_gated_performance.md) | Selector isolation backed by production-path measurement |

For the repo-level navigation hub, see [docs index](../README.md).
