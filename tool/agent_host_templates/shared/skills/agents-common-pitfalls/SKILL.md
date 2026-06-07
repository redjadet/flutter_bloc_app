---
name: agents-common-pitfalls
description: Pre-flight checklist of frequent agent mistakes. Use before writing or reviewing code.
---

# Common pitfalls

Pre-flight scan before first edit on non-trivial work. Owner register:
[`docs/ai/ai_failure_risks.md`](../../../../../docs/ai/ai_failure_risks.md).

**Full rules:** `agents-canonical-rules` (+ matching `agents-canonical-rules-*`).
**Table:** [`docs/CODE_QUALITY.md`](../../../../../docs/CODE_QUALITY.md).

## Pitfall → risk ID

| Pitfall | Risk ID | Prevention |
| --- | --- | --- |
| Flutter/UI imports in `domain/` | `RISK-ARCH-LAYER` | `agents-feature-delivery`; `check_clean_architecture_imports.sh` |
| Copy legacy cubit layout (`cubits/`, root cubits) | `RISK-ARCH-LAYER` | [`reference_features.md`](../../../../../docs/architecture/reference_features.md); `presentation/cubit/` |
| `context.read` / `BlocProvider.of` | `RISK-BLOC-DIVERGENCE` | `type-safe-bloc-access`; `context.cubit<T>()` |
| Emit after `close()` or leaked subscriptions | `RISK-ASYNC-LIFECYCLE` | `agents-canonical-rules-async`; cancel in `close()` |
| `context` after `await` without `mounted` | `RISK-ASYNC-LIFECYCLE` | Guard `mounted`; keep side effects in Cubit |
| Remote fetch overwrites offline-pending local | `RISK-OFFLINE-OVERWRITE` | `agents-shared-patterns`; offline adoption guide |
| Skip DI / routes / l10n / codegen | `RISK-INTEGRATION-SEAM` | `agents-feature-delivery` wire-DI rule |
| Start feature without brief/tests | `RISK-FEATURE-BRIEF-SKIP` | `scaffold_feature_contract.sh`; feature brief |
| Claim done without focused tests | `RISK-TEST-GAP` | testing matrix; `flutter test <paths>` |
| Auth/PII/payments without security pass | `RISK-SECURITY-GAP` | `review/security_checklist.md` |
| Commit or print secrets | `RISK-SECRET-LEAK` | `check_tracked_secret_literals.sh` |
| `rm`, deploy, or external mutation without ask | `RISK-DESTRUCTIVE-SIDE-EFFECT` | List affected items; current-turn confirm |
| Reuse stale checklist / partial proof | `RISK-VALIDATION-SHORTCUT` | `--no-reuse`; scorecard gates |
| Direct `Hive.openBox` / ad-hoc Dio | `RISK-ARCH-LAYER` | DI entrypoints; `agents-canonical-rules-platform` |
| `print` instead of `AppLogger` | `RISK-UI-REGRESSION` | logging standards |
| Hardcoded colors/strings | `RISK-UI-REGRESSION` | `DESIGN.md`; `AppTheme` / l10n |

After scan: map task to Minimum proof by task in `ai_failure_risks.md`.
