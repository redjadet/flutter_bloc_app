# Senior quality hotspot audit (2026-05-12)

## Why

Churn- and seed-script-driven review of the agreed hotspot set was needed to
classify risk without speculative refactors. The owning artifact is the audit
under `docs/audits/`, not this note.

## Decision

- **SAFE_TO_FIX_NOW:** only low-risk, proof-backed fixes (here: library-level
  documentation + `library;` on `lib/core/config/secret_config.dart` for
  `dangling_library_doc_comments`).
- **NEEDS_TEST_FIRST:** no items applied in this pass; anything with possible
  behavior, l10n, UI, storage, or async-order impact stays out of the patch
  until a narrow proof exists.
- **BACKLOG_ONLY:** large `.part.dart` splits, injector/router growth, and
  similar items stay deferred with explicit proof requirements.

## Scope

- Canonical write-up: [`../audits/senior_quality_hotspots_2026-05-12.md`](../audits/senior_quality_hotspots_2026-05-12.md).
- Machine log: [`../audits/_senior_quality_hotspots_seed_2026-05-12.log`](../audits/_senior_quality_hotspots_seed_2026-05-12.log).
- Local Cursor plan outside the repo is closed with all todos completed.
- Operator / continual-learning map detail lives in
  [`../agent_knowledge_base.md#operator-preferences-durable`](../agent_knowledge_base.md#operator-preferences-durable);
  [`AGENTS.md`](../../AGENTS.md) stays a lean link map.

## Changed files

- `lib/core/config/secret_config.dart`
- [`../audits/README.md`](../audits/README.md)
- [`../audits/senior_quality_hotspots_2026-05-12.md`](../audits/senior_quality_hotspots_2026-05-12.md)
- [`../audits/_senior_quality_hotspots_seed_2026-05-12.log`](../audits/_senior_quality_hotspots_seed_2026-05-12.log)
- [`README.md`](README.md)
- [`../agent_knowledge_base.md`](../agent_knowledge_base.md)
- [`../../AGENTS.md`](../../AGENTS.md)

## Validation

Full delivery gate after `lib/core/config` touch:
`CHECKLIST_RUN_COVERAGE=0 ./bin/checklist --explain` (includes `flutter analyze`,
`normalize_doc_links`, and the checklist’s regression subset). `./bin/checklist-fast`
remains intentionally unavailable while `lib/**` is part of the same change set
(see `tool/delivery_checklist.sh` fast-path rules).
