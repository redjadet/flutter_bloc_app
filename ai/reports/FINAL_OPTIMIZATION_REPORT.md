---
generated: 2026-05-21
scope: Phase 4 post-merge (ARCH-001, ARCH-002)
evidence: flutter test, tool/modular_metrics.sh
---

# Final optimization report (ARCH-001 / ARCH-002)

Closure report for the **post-merge** architecture refactors on branch
`refactor/arch-001-case-study-decouple`, after [PR #239](https://github.com/redjadet/flutter_bloc_app/pull/239) (AI-first Waves 1–2 + ARCH-003 barrels).

## Summary

| Item | Outcome |
| --- | --- |
| ARCH-001 | **Resolved** — decoupled `case_study_demo` from `camera_gallery` / `supabase_auth` domain types |
| ARCH-002 | **Resolved** — split monolithic cubit actions part into flow mixins (max part ~159 LOC) |
| ARCH-003 | **Resolved** on `main` (PR #239) — four feature barrels + import tests |
| Cross-feature edges | **0** involving `case_study_demo` (`modular_metrics.sh --cross-feature-only`) |
| Tests | `flutter test test/features/case_study_demo` — 33 passed (2026-05-21) |

## ARCH-001 — shared ports and media types

**Problem:** `case_study_demo` imported domain types from `camera_gallery` and `supabase_auth` (audit ARCH-001).

**Changes:**

- `lib/shared/media/media_pick_result.dart` + `media_pick_error_keys.dart` — shared pick result model.
- `lib/core/auth/remote_backend_auth_port.dart` — auth port (`isConfigured`, `currentUser`, `authStateChanges`, `signOut`).
- `SupabaseAuthRepository` implements `RemoteBackendAuthPort`; registered in DI.
- `camera_gallery` keeps typedef/shim aliases for backward compatibility.
- `case_study_demo` cubit uses `RemoteBackendAuthPort` and `MediaPickResult` only.

**Proof:** `bash tool/modular_metrics.sh --cross-feature-only` shows no `case_study_demo → *` feature imports.

## ARCH-002 — cubit action decomposition

**Problem:** `case_study_session_cubit_actions.part.dart` (~385 LOC) — agent/review hotspot (ARCH-002).

**Changes:** Replaced single actions part with:

| Part file | Mixin | LOC (approx.) |
| --- | --- | --- |
| `case_study_session_cubit_wizard.part.dart` | `_CaseStudySessionCubitWizard` | 84 |
| `case_study_session_cubit_lifecycle.part.dart` | `_CaseStudySessionCubitLifecycle` | 26 |
| `case_study_session_cubit_history.part.dart` | `_CaseStudySessionCubitHistory` | 126 |
| `case_study_session_cubit_submit.part.dart` | `_CaseStudySessionCubitSubmit` | 159 |
| `case_study_session_cubit_video.part.dart` | `_CaseStudySessionCubitVideo` | (unchanged) |

`CaseStudySessionCubit` mixin order: Wizard → Lifecycle → History → Submit (Submit `on` History for `_persistSubmissionToLocalHistory`) → Video.

**Behavior:** Wizard navigation restored to pre-split semantics (`goToReviewPhase` requires `draft.isComplete`; boundary checks on question index).

**Proof:** `flutter test test/features/case_study_demo/presentation/cubit/case_study_session_cubit_actions_test.dart` and full feature suite.

## Phase 5 — mechanical Feature Brief gate

**Added:** `tool/check_feature_brief_linked.sh` — warns when `lib/features/**/*.dart` changes without `docs/changes/*.md` in the same diff; `SKIP_FEATURE_BRIEF=1` or `FEATURE_BRIEF_CHECK_STRICT=1` documented in [`docs/validation_scripts.md`](../../docs/validation_scripts.md).

Not wired into `./bin/checklist` by default (avoid false positives on small fixes); run manually on feature PRs.

## Remaining backlog (out of this plan scope)

| ID | Note |
| --- | --- |
| ARCH-004–011 | See [`docs/audits/ai_architecture_audit.md`](../../docs/audits/ai_architecture_audit.md) |
| 32/31 full `CONTRACTS.md` bodies | Five pilots only (Wave 2) |
| REC-004 | Addressed by ARCH-002 split |

## Refresh

After merge to `main`, run:

```bash
bash tool/modular_metrics.sh
bash tool/modular_metrics.sh --cross-feature-only
```

Update [`context_hotspots.md`](context_hotspots.md) if new top-20 files appear.
