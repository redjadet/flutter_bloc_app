---
name: agents-create-cubit
description: Scaffold or add a feature Cubit with Freezed state, tests, and repo-standard placement under presentation/cubit/.
---

# Create Cubit

Use when adding a new Cubit to an existing feature or during feature delivery.

Read in order:

1. `docs/bloc/cubit_file_template.md`
2. `docs/bloc_standards.md`
3. `docs/review/bloc_checklist.md`

Rules:

- Default `Cubit`; do not add `Bloc` unless event-queue complexity is documented.
- New code uses `apps/mobile/lib/features/<feature>/presentation/cubit/` (singular).
- State uses Freezed; domain models only — no DTOs in state.
- Cubit depends on domain contracts, not data implementations.
- Register in `apps/mobile/lib/app/composition/` with existing idempotent helpers.
- Add cubit tests: initial, loading, success, error, stale-async guard.

Proof: `flutter test test/features/<feature>/presentation/` + `./tool/analyze.sh`.
