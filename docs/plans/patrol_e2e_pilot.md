# Patrol E2E pilot (plan only)

**Status:** Not implemented. No `patrol` dependency in `pubspec.yaml`.

## Objective

Evaluate [Patrol](https://patrol.leancode.co/) for native-aware E2E (permissions, notifications) on the **counter persistence** journey — complementing existing `integration_test` harness.

## Scope (pilot)

| In scope | Out of scope |
| --- | --- |
| Counter offline increment + restart | Full spine (7 flows) in Patrol |
| Single macOS or Android device target | Linux CI runner |
| Compare flake rate vs `registerCounterPersistenceIntegrationFlow` | Replacing all integration tests |

## Dependencies (if proceeding)

- `patrol` + `patrol_cli` dev dependencies
- Native test runner config per platform
- CI job time budget (see [validation_scripts.md](../validation_scripts.md))

## Comparison to current harness

| Aspect | `integration_test` today | Patrol pilot |
| --- | --- | --- |
| Entry | `./bin/integration_tests <target>` | `patrol test` |
| PR smoke | `pr_smoke_flows_test.dart` | Not default until proven stable |
| Native dialogs | Limited | Stronger |
| Maintenance | In-repo flow registrars | Additional codegen / config |

## Success criteria for adoption

1. Counter persistence scenario passes 3 consecutive local runs
2. Runtime ≤ 2× current counter persistence test median
3. Documented skip path when simulator unavailable (same as today)

## Next steps (human gate)

1. Approve CI minutes and `pubspec.yaml` change
2. Scaffold `patrol_test/` with one test mirroring counter persistence
3. Update [interview_showcase.md](../interview_showcase.md) only after green runs
