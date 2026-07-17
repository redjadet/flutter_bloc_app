# Case studies (product briefs)

This folder holds **product-style requirements** for vertical demos implemented
in the app. Each brief is independent of the code; implementation notes,
routes, and engineering plans live in the linked feature module and
`docs/changes/` entries.

## Index

| Brief | In-app feature | Module |
| --- | --- | --- |
| [Dentists](dentists.md) — video answers to ten predefined questions | Case Study Demo | `apps/mobile/lib/features/case_study_demo/` |

**Routes:** `/case-study-demo` and nested paths (see [Feature overview](../feature_overview.md)).
**Entry:** Example hub (`/example`) and `AppRoutes` constants in
`apps/mobile/lib/app/router/app_routes.dart`.

**Implementation / migration notes:**

- [Dentist case study demo — plan](../changes/2026-04-01_dentist_case_study_demo_plan.md) — scope, routes, auth, Hive, tests
- [Dentists brief](dentists.md) — includes shipped optional Supabase private storage (bucket, RLS, signed URLs, submit)

For the repo-level navigation hub, see [docs index](../README.md).
