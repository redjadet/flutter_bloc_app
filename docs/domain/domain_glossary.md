# Domain glossary (source of truth)

Curated ubiquitous language for this app. Findings inventory: [`docs/audits/ai_domain_language_report_v1.md`](../audits/ai_domain_language_report_v1.md).

| Term | Definition | Bounded context |
| --- | --- | --- |
| Feature module | Vertical slice under `lib/features/<name>/` | Engineering |
| Presentation layer | Pages, widgets, Cubits | Clean Architecture |
| Domain layer | Contracts, models; pure Dart | Clean Architecture |
| Data layer | Repository implementations, DTOs | Clean Architecture |
| Offline-first repository | Writes locally; enqueues remote sync | Sync |
| Pending sync | Outbound mutation queue | `lib/shared/sync/` |
| Counter | Home persisted count feature | `counter` |
| Feature Brief | Pre-work doc from [`FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md) | Process |
| ARCH-### | Ranked architecture issue | Audits |
| REC-### | Prioritized recommendation | `ai/reports/ai_recommendations.md` |
| Demo feature | Showcase route; may use fake backends | `*_demo` modules |
| Auth-gated route | Requires Firebase session | `auth`, router redirect |

## Naming rules (new code)

1. Prefix types with feature (`ChatRepository`, not `Repository`).
2. Suffix Cubit states with feature when ambiguous (`ChatListState`).
3. Do not rename Hive types without migration doc.
4. Prefer `Failure` / `Exception` suffixes per existing feature conventions.

## Maintenance

Update this table when product language changes or Wave 2+ audits find new collisions.
