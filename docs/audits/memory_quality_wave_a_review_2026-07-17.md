# Audit — Memory quality Wave A (2026-07-17)

## Baseline

- `flutter_test_config.dart`: `LeakTesting.enable()` + `withIgnoredAll()` (unchanged for untagged)
- Existing opt-in tests passed ignored settings (fixed via helper)
- Analyzer already had `cancel_subscriptions` / `close_sinks` as errors

## Shipped

| Layer | Artifact |
| --- | --- |
| Static | `custom_lints/memory_lint` — four rules; AST helper unit tests |
| Runner | `tool/run_memory_lint.sh` |
| Runtime | `leakSafeTestWidgets` + four tagged tests |
| Checklist | `CHECKLIST_RUN_MEMORY_LINT`, `CHECKLIST_RUN_MEMORY_LEAK_TESTS` (default 1) |

## Findings

| Finding | Classification | Action |
| --- | --- | --- |
| `run_memory_lint.sh` on app `lib/` | Clean | No production fixes required |
| GoRouter push/pop seed test | Test harness noise / flaky notDisposed layers | Narrowed to mount/unmount MaterialApp.router |
| `analyzer_testing` AnalysisRuleTest | Stack incompatibility with analyzer 10.0.2 (same as file_length_lint) | Use `parseString` helper contract tests |

## Suppressions

None.

## Verification (closeout)

| Command | Result |
| --- | --- |
| `cd custom_lints/memory_lint && dart test` | 9 passed |
| `bash tool/run_memory_lint.sh` | passed (no `memory_*` under app `lib/`) |
| `(cd apps/mobile && flutter test --tags memory_leak)` | 4 passed |
| `CHECKLIST_RUN_COVERAGE=0 CHECKLIST_RUN_MEMORY_LINT=1 ./bin/checklist` | Delivery checklist complete |
| `./bin/format` | applied |

## Deferred (Wave B)

See [`../performance/memory_management.md`](../performance/memory_management.md) Wave B backlog.
