# Maintainability simplify — intentionally deferred (2026-07-17)

**Status:** Deferred on purpose after Waves A/B (DI composition + domain wire
purity) landed on `main` (`dcd14766` … `95730e5e`).
**Do not** open standalone PRs for these unless the unblock criteria fire.

Related shipped notes:

- [`../changes/2026-07-17_di_composition_simplify.md`](../changes/2026-07-17_di_composition_simplify.md)
- [`../changes/2026-07-17_domain_purity_chat_counter_todo.md`](../changes/2026-07-17_domain_purity_chat_counter_todo.md)
- [`../changes/2026-07-17_domain_purity_remaining_demos.md`](../changes/2026-07-17_domain_purity_remaining_demos.md)

## Deferred items

| ID | Item | Why left | Owner / evidence | Unblock when |
| --- | --- | --- | --- | --- |
| **MS-D01** | **Wave C — presentation `part` / file splits** | Lower seam value than DI + domain purity; standalone churn risks format/review noise without behavior gain | Original simplify ranking: A DI → B domain → C presentation last; operator: “C deferred; split only when next UI change touches them” | Next real UI/behavior edit already touching that presentation file (cubit/page/widget). Split only the files in the write-set — no drive-by presentation refactors |
| **MS-D02** | **Staff demo clock-out `flags` payload stays partial** | Pre-existing wire shape: clock-out enqueue sends only `locationInsufficient` under `flags`, not full `StaffDemoTimeEntryFlagsDto.toJson()`. Expanding keys would change sync/Firestore payload without a product ask | `offline_first_staff_demo_timeclock_repository_sync.part.dart` (`clockOutImpl`); contrast clock-in full DTO in `offline_first_staff_demo_timeclock_repository.dart` | Product/backend contract requires full flag map on clock-out, or a staff timeclock sync hardening slice that owns both client + consumer |

## Explicitly not deferred (closed)

| Item | Status |
| --- | --- |
| Domain wire-leak warn backlog | **Closed** — `bash tool/check_domain_wire_leaks.sh` → `violations=0` |
| DI group thinning / feature data fallbacks | **Shipped** Wave A |
| Chat / counter / todo / remaining demo domain JSON → DTOs | **Shipped** Wave B + remaining slices |

## Agent rules

- Prefer opportunistic MS-D01 only inside an existing UI change’s surgical diff.
- Do not “normalize” MS-D02 to full flags “for consistency” without a contract
  change note and consumer verification.
- When closing either item, update this table’s status and link a `docs/changes/`
  note; leave a one-line pointer from the related 2026-07-17 change notes.
