# Mobile–Backend Integration — Deferred Work

**Status:** Explicitly **not implemented** in the 2026-07-16 hardening program.
**Program closeout:** [`audits/mobile_backend_integration_hardening_final_2026-07-16.md`](../audits/mobile_backend_integration_hardening_final_2026-07-16.md)
**Change note:** [`changes/2026-07-16_mobile_backend_integration_hardening.md`](../changes/2026-07-16_mobile_backend_integration_hardening.md)

This page is the single list of hardening items left as **contracts / plans only**.
Do not treat Firebase Analytics on the classpath, or pagination wording in guides, as shipped product features.

## Deferred items

| Item | Why deferred | Contract / plan to follow | Unblock when |
| --- | --- | --- | --- |
| **Pagination implementation** (offset or cursor lists, refresh/load-more UI, dedupe) | No product list yet needs paging; avoid inventing a framework | [`backend/API_CONTRACT_GUIDE.md`](../backend/API_CONTRACT_GUIDE.md) § Pagination; failure mode 2 in [`architecture/MOBILE_BACKEND_BOUNDARIES.md`](../architecture/MOBILE_BACKEND_BOUNDARIES.md) | First feature with unbounded or large list + product owner sign-off |
| **Product analytics events** (taxonomy, SDK wiring, consent) | ADR-0005 doc-only posture; Firebase Analytics dep ≠ event tracking | [`plans/future_observability.md`](../plans/future_observability.md), [`adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md), [`observability.md`](../observability.md) | Real funnel/adoption questions that Crashlytics/`AppLogger` cannot answer |
| **Live-backend contract validation** (Render / HF / AI Decision e2e against real hosts) | Hardening proved offline with unit tests + fixtures | Final audit “No-live-backend limitation” | Staging credentials + intentional integration lane |
| **Broad demo DTO cast rewrite** (beyond AI Decision + GraphQL country) | Surgical scope; other demos still use direct `as` casts | Same defensive pattern as `ai_decision_json.dart` / `graphql_json.dart` | Touching those features for other reasons, or a follow-up cast-hardening slice |
| **Domain wire-leak warn-only backlog** | **Closed 2026-07-17** (`violations=0`) | `bash tool/check_domain_wire_leaks.sh`; change notes [`changes/2026-07-17_domain_purity_chat_counter_todo.md`](../changes/2026-07-17_domain_purity_chat_counter_todo.md), [`changes/2026-07-17_domain_purity_remaining_demos.md`](../changes/2026-07-17_domain_purity_remaining_demos.md) | Keep domain free of wire JSON; new models use data DTOs |
| **Maintainability simplify leftovers** (Wave C presentation splits; staff clock-out partial `flags`) | Lower seam value / pre-existing wire — not mobile-backend hardening | [`plans/2026-07-17_maintainability_simplify_deferred.md`](../plans/2026-07-17_maintainability_simplify_deferred.md) (**MS-D01**, **MS-D02**) | UI touch for MS-D01; product/sync contract for MS-D02 |

## Pagination — what exists vs what does not

**Exists (docs/review only):**

- Field shapes (offset vs cursor), refresh vs load-more, duplicate prevention, required tests when first list lands — in the API contract guide.
- PR questions under [`contributing/PR_REVIEW_CHECKLIST.md`](../contributing/PR_REVIEW_CHECKLIST.md) § Pagination.

**Does not exist:**

- Shared pagination repository/cubit helpers
- Production list screens that page
- Backend endpoints changed for paging in this program

## Product analytics — what exists vs what does not

**Exists:**

- Firebase Analytics as a dependency / Firebase bootstrap surface (not a product event system)
- Crashlytics when Firebase initializes
- Draft event taxonomy and Mixpanel/Sentry seams in [`plans/future_observability.md`](../plans/future_observability.md)

**Does not exist:**

- Shipped event emitters for product funnels
- Mixpanel / Sentry (or similar) in `pubspec.yaml`
- Consent + identify flows for analytics

## How to pick this work up later

1. Confirm product need (list size or funnel metric).
2. Implement against the linked contract/plan — do not invent a parallel doc.
3. Add focused tests listed in the contract; update this page’s status row when code lands.
4. Keep PR review checklist answers honest (`N/A` only with reason until the feature ships).

## Related

- Hardening residual risks: final audit § Residual risks
- Transport guard (shipped): `bash tool/check_adhoc_dio_construction.sh`
