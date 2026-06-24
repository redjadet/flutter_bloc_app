---
name: agents-regression-capture
description: >-
  Turns fixed unique bugs into regression tests, static guards, checklist wiring,
  and lessons so the same failure class is caught early. Auto-use immediately
  after resolving a non-trivial bug, race, lifecycle issue, flaky test, or
  one-off production failure that could recur; also when the user asks to
  harden a fix or prevent recurrence.
---

# Regression capture (post-fix hardening)

**Mandatory closeout** after any non-trivial bug fix in this repo — same turn as
the fix, before claiming done. Implements the Missing Capability Loop in
[`docs/agent_knowledge_base.md`](../../../../../docs/agent_knowledge_base.md).

Pair with `systematic-debugging` during investigation and
`agents-validation-testing` when wiring guards.

**Do not duplicate:** validation chooser and guard catalog →
`agents-validation-testing`; this skill owns capture ladder + durable memory.

## Auto-trigger

Invoke when **any** apply:

- Root cause found and code fix landed (or user confirms fix verified)
- Race, lifecycle, async supersession, stale sync, layout overflow, initState
  InheritedWidget, or offline-first merge bug class
- Flaky test fixed by behavior change (not only test timing tweak)
- User says: prevent recurrence, add regression, harden, guard, capture lesson

## Skip (record reason in report)

- Docs/format/rename only
- Obvious typo with no behavioral contract
- Bug class already covered by existing test + guard on touched paths
- External-only outage with no repo contract change

## Workflow

Answer **"What went wrong, how was it fixed, what stops recurrence?"** then run
the ladder below. Smallest durable artifact that encodes the **class**, not the
single line.

```text
Progress:
- [ ] 1. Name the bug class (one sentence)
- [ ] 2. Pick capture lane(s)
- [ ] 3. Implement smallest guard(s)
- [ ] 4. Wire into checklist / regression routing
- [ ] 5. File durable memory
- [ ] 6. Verify guards fail before fix / pass after
- [ ] 7. Report capture proof
```

### 1. Name the bug class

Template:

- **Symptom:** what the user saw
- **Root cause:** why it happened (mechanism, not blame)
- **Fix:** what changed
- **Class:** generalized pattern (e.g. "mutation success treated as failure after RequestIdGuard supersession")

### 2. Pick capture lane(s)

Use the **first** lane that can catch recurrence cheaply; add others only when
needed.

| If the class is… | Prefer | Also consider |
| --- | --- | --- |
| Wrong outcome for given inputs/state | Focused unit/cubit/widget test | Extend anchor in [`docs/testing_overview.md`](../../../../../docs/testing_overview.md) § Regression test anchors |
| Repeatable anti-pattern in code shape | `tool/check_<topic>.sh` static guard + `tool/fixtures/` bad/good samples | `.cursor/rules/*.mdc` only when agents/humans need prose |
| Path-dependent integration behavior | Widget/integration test; register in `tool/check_regression_guards.sh` | `tool/integration_selective_map.json` when journey-specific |
| Offline-first / stale remote / TOCTOU | Repository test per [`docs/offline_first/dont_overwrite_guide.md`](../../../../../docs/offline_first/dont_overwrite_guide.md) | `tool/check_offline_first_remote_merge.sh` inventory |
| UI layout / overflow | `*_regression_test.dart` + area script (`tool/check_row_action_overflow.sh`, etc.) | `docs/design_system.md` if shared component contract |

**Extend existing anchors** before adding parallel tests — see
[`docs/testing_overview.md`](../../../../../docs/testing_overview.md) § Repo
testing conventions.

### 3. Implement guards

#### Regression test

- Name: `*_regression_test.dart` or focused test with explicit bug-class name
- Must fail on pre-fix behavior (revert locally to confirm when practical)
- Cover the failure path, not only happy path

#### Static guard (syntactic/structural)

- Script: `tool/check_<short_name>.sh`
- Fixtures: `tool/fixtures/<short_name>/bad_*`, `good_*`
- Document in [`docs/validation_scripts/catalog.md`](../../../../../docs/validation_scripts/catalog.md)

### 4. Wire automation

Minimum wiring checklist:

- [ ] `tool/check_regression_guards.sh` — add to `ALL_TESTS`; add `case` path
      triggers in `select_regression_guard_tests` when area-scoped
- [ ] `tool/delivery_checklist.sh` — run static guard when relevant paths change
- [ ] Optional local pre-commit: `githooks/pre-commit` pattern (see
      [`docs/changes/2026-06-15_mutation-success-guard.md`](../../../../../docs/changes/2026-06-15_mutation-success-guard.md))
- [ ] Review checklist row if human review should catch it:
      `docs/review/bloc_checklist.md`, `security_checklist.md`, `performance_checklist.md`

Run validation doc sync when catalog/checklist touched:

```bash
bash tool/fix_validation_docs.sh && bash tool/validate_validation_docs.sh
```

### 5. File durable memory

| Audience | Where |
| --- | --- |
| Agent + humans, reusable pattern | [`tasks/lessons.md`](../../../../../tasks/lessons.md) — use template (what went wrong / fix / pattern / preventive rule / evidence) |
| Why this PR hardened the repo | `docs/changes/YYYY-MM-DD_<slug>.md` — summary, bug class, verification commands |
| Index | one line in [`docs/changes/README.md`](../../../../../docs/changes/README.md) when change note added |
| Regression anchor table | [`docs/testing_overview.md`](../../../../../docs/testing_overview.md) when new anchor area |

Do **not** add `## Learned` bullets to `AGENTS.md`; file in `tasks/lessons.md`
or owning doc per operator prefs.

### 6. Verify

```bash
# Focused new/edited test
flutter test <path> [--name "<case>"]

# Static guard (expect fail on bad fixture, pass on good)
bash tool/check_<name>.sh --paths tool/fixtures/<name>/bad_*.dart
bash tool/check_<name>.sh --paths tool/fixtures/<name>/good_*.dart

# Regression routing (narrow lane)
CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths <touched-path>

# Broader when shared/core touched
./bin/checklist-fast   # or ./bin/checklist per validation routing
```

### 7. Report capture proof

Include in task closeout (with fix proof):

```markdown
## Regression capture
- Bug class: …
- Tests: …
- Static guard: … (or N/A)
- Checklist wiring: …
- Lessons/changes: …
- Verified: commands run + outcome
```

## Examples (repo)

| Bug class | Capture |
| --- | --- |
| RequestIdGuard supersession → false failure UI | `tool/check_mutation_success_after_guard.sh`, therapy/chat regression tests, `docs/changes/2026-06-15_mutation-success-guard.md` |
| initState `context.cubit<` | Guard regex update, `test/shared/inherited_widget_lifecycle_regression_test.dart` |
| Stale remote overwrites local | `offline_first_*_repository_test.dart`, `tool/check_offline_first_remote_merge.sh` |
| Row/action overflow | `test/shared/widgets/row_overflow_regression_test.dart`, `tool/check_row_action_overflow.sh` |

## Related

- Missing Capability Loop: [`docs/agent_knowledge_base.md`](../../../../../docs/agent_knowledge_base.md)
- Test matrix: [`docs/testing/matrix_required_by_change.md`](../../../../../docs/testing/matrix_required_by_change.md)
- Validation chooser: [`docs/agents_quick_reference.md`](../../../../../docs/agents_quick_reference.md)
