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
| MVVM outside presentation (`viewmodels/`, repo in ViewModel folder) | `RISK-ARCH-LAYER` | [`clean_architecture.md`](../../../../../docs/clean_architecture.md) § Architecture skeleton; [`feature_structure_contract.md`](../../../../../docs/architecture/feature_structure_contract.md) |
| `context.read` / `BlocProvider.of` | `RISK-BLOC-DIVERGENCE` | `type-safe-bloc-access`; `context.cubit<T>()` |
| Emit after `close()` or leaked subscriptions | `RISK-ASYNC-LIFECYCLE` | `agents-canonical-rules-async`; cancel in `close()` |
| `context` after `await` without `mounted` | `RISK-ASYNC-LIFECYCLE` | Guard `mounted`; keep side effects in Cubit |
| Remote fetch overwrites offline-pending local | `RISK-OFFLINE-OVERWRITE` | `agents-shared-patterns`; offline adoption guide |
| Skip DI / routes / l10n / codegen | `RISK-INTEGRATION-SEAM` | `agents-feature-delivery` wire-DI rule |
| Start feature without brief/tests | `RISK-FEATURE-BRIEF-SKIP` | `scaffold_feature_contract.sh`; feature brief |
| Claim done without focused tests | `RISK-TEST-GAP` | testing matrix; `flutter test <paths>` |
| Auth/PII/payments without security pass | `RISK-SECURITY-GAP` | `review/security_checklist.md` |
| Commit or print secrets | `RISK-SECRET-LEAK` | `check_tracked_secret_literals.sh` |
| Patch Flutter/Dart SDK or core framework files | `RISK-FLUTTER-SDK-MUTATION` | Treat `/Users/ilkersevim/Flutter_SDK/flutter/**` as read-only; fix repo code or upgrade toolchain via docs |
| `rm`, deploy, or external mutation without ask | `RISK-DESTRUCTIVE-SIDE-EFFECT` | [`agent_safety_contracts.md`](../../../../../docs/agent_kb/agent_safety_contracts.md) `SAFETY-02`; same-turn approval |
| Expand beyond write-set or unrelated cleanup | `RISK-SCOPE-CREEP` | [`agent_safety_contracts.md`](../../../../../docs/agent_kb/agent_safety_contracts.md) `SAFETY-01` |
| Guess missing path/branch/env/resource | `RISK-MISSING-TARGET` | [`agent_safety_contracts.md`](../../../../../docs/agent_kb/agent_safety_contracts.md) `SAFETY-01`; stop and ask |
| Commit/push/PR/merge/stash without request | `RISK-UNAPPROVED-GIT` | [`agent_safety_contracts.md`](../../../../../docs/agent_kb/agent_safety_contracts.md) `SAFETY-03` |
| Reuse stale checklist / partial proof | `RISK-VALIDATION-SHORTCUT` | `--no-reuse`; scorecard gates; `SAFETY-REPORT` |
| Direct `Hive.openBox` / ad-hoc Dio | `RISK-ARCH-LAYER` | DI entrypoints; `agents-canonical-rules-platform` |
| `print` instead of `AppLogger` | `RISK-UI-REGRESSION` | logging standards |
| Hardcoded colors/strings | `RISK-UI-REGRESSION` | `DESIGN.md`; `AppTheme` / l10n |
| Page-only UI (no extractable leaf widget for preview/test) | `RISK-UI-REGRESSION` | [`design_system.md`](../../../../../docs/design_system.md) § Reusable widgets; `word_card_test.dart` pattern |
| Fixed width/height on reflowable UI (skip LayoutBuilder/MediaQuery/responsive helpers) | `RISK-UI-REGRESSION` | [`design_system.md`](../../../../../docs/design_system.md) § Responsive layout; [`ui_ux_responsive_review.md`](../../../../../docs/ui_ux_responsive_review.md) |
| UI change only tested on one platform/host | `RISK-PLATFORM-SCOPE` | [`tech_stack.md`](../../../../../docs/tech_stack.md) § Supported platforms; [`design_system.md`](../../../../../docs/design_system.md) § Cross-platform form factors; `flutter-cross-platform-modern` |
| Widget works on debug device only (tablet/web/desktop not considered) | `RISK-PLATFORM-SCOPE` | Mobile + wide widget tests; `ui_ux_responsive_review.md` § Cross-platform form factors |
| Guess pub API from model memory | `RISK-STALE-API` | [`package_docs_mcp.md`](../../../../../docs/agent_kb/package_docs_mcp.md); Context7 + `read_package_uris` |

After scan: map task to Minimum proof by task in `ai_failure_risks.md`.
