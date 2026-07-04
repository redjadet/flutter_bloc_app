# Architecture review — Build Readiness program (2026-06)

Single audit artifact for the Architecture Standardization Program. Findings
from the planning pass; §8 records what landed in the repo during execution.

**Related:** [`docs/architecture/reference_features.md`](../architecture/reference_features.md),
[`docs/architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md),
[`docs/quick_start.md`](../quick_start.md).

---

## 1. Architecture review

**Score:** ~8/10 — Clean Architecture is real in newer features; legacy layout drift
is localized and shrinking.

| Area | Finding | Verdict |
| --- | --- | --- |
| Layering | Domain stays pure; presentation depends on abstractions | Good |
| Feature folders | Gold references (`remote_config`, `case_study_demo`, …) match contract | Good |
| Legacy drift | `check_feature_folder_contract.sh` now reports 20 legacy root cubit/state warnings plus `settings/presentation/cubits/` (down from 24 root warnings before the counter + deeplink pilot) | Improving |
| Cross-feature imports | Guarded by `check_feature_modularity_leaks.sh` | Good |
| Auth / roles | Route guards deferred to future architecture work | Documented gap |

**Program outcome:** Counter and deeplink cubits moved under `presentation/cubit/`.
Remaining legacy features stay on the migration playbook (§7); no batch move in
this program.

---

## 2. Dependency injection review

**Score:** ~7.5/10 → **~8.5/10** after Phase B.

| Check | Before | After |
| --- | --- | --- |
| `getIt` in `apps/mobile/lib/features/**/presentation/pages/**` | `EventBusDemoPage`, `CaseStudyDemoHomePage` | **Zero** (route factories inject deps) |
| `CounterCubit` timer fallback | `DefaultTimerService()` in constructor | **Required** `TimerService` from DI / tests |
| Route-owned cubits | Mostly correct | Unchanged; counter route passes `getIt<TimerService>()` |

**Verify:** `rg 'getIt<' apps/mobile/lib/features --glob '**/presentation/pages/**'` → no matches.

---

## 3. BLoC / Cubit review

**Score:** ~8/10.

| Item | Action | Status |
| --- | --- | --- |
| `online_therapy_demo` (6 cubits) | Standardize on `CubitExceptionHandler` / `executeAsync*` | Done |
| `CubitErrorHandler` (unused duplicate) | Remove | Done |
| `chat_cubit` auth transport subscriptions | `CubitSubscriptionMixin` | Done (Phase E) |
| Therapy Freezed / `ViewStatus` migration | Out of scope | Not started (by design) |

Therapy cubits keep Equatable state shapes (`isBusy`, `errorMessage`); only async
error handling paths were unified.

---

## 4. Test coverage

**Score:** ~7.5/10.

| Gap | Risk | Action | Status |
| --- | --- | --- | --- |
| `FirebaseAuthRepository` | High | Unit tests with fakes | `test/features/auth/data/firebase_auth_repository_test.dart` |
| `CallCubit`, `TherapistHomeCubit` | Medium | Cubit tests per matrix | Added under `test/features/online_therapy_demo/` |
| `online_therapy_demo` integration map | Medium | Optional smoke entry | Deferred |
| Counter tests at repo root vs `test/features/counter/` | Low | Widget/data tests under feature dir; cubit unit test at `test/counter_cubit_test.dart` | Documented; full consolidate optional |

**Verify:** targeted therapy + auth + counter + deeplink + event_bus tests green
after each phase.

---

## 5. Performance

**Score:** ~8/10 — no critical hotspots introduced.

| Check | Finding | Verdict |
| --- | --- | --- |
| `BlocSelector` / `context.selectState` | Widespread | Good |
| Type-safe bloc access | `type_safe_bloc_access.dart` | Good |
| `todo_list_page` wide rebuild | Known; deferred | Info |
| `chat_cubit` subscriptions | Mixin auto-cancel on close | Improved |

No standalone performance PR in this program.

---

## 6. Onboarding / quick start

**Agents:** ~8/10 (`AGENTS.md`, `CODEMAP.md`, `docs/ai/context_loading.md`).

**Humans:** improved from ~6/10 with **`docs/quick_start.md`** (~15 min path) and
README link. Full onboarding remains [`docs/new_developer_guide.md`](../new_developer_guide.md).

---

## 7. Legacy migration playbook

When touching a legacy feature that warns on folder contract:

1. Move cubit + state (and `.freezed.dart` / part files) to `presentation/cubit/`.
2. Update barrel exports, routes, and tests in the **same commit**.
3. Run `dart analyze` + `flutter test test/features/<feature>/`.
4. Run `bash tool/check_feature_folder_contract.sh` — expect one fewer file warning for each moved cubit/state file.
5. Update [`docs/architecture/reference_features.md`](../architecture/reference_features.md)
   when a feature graduates from "Do not copy".

**Pilot completed (2026-06):** `counter`, `deeplink`.

**Still legacy (examples):** `chat`, `scapes`, `settings/presentation/cubits/`,
`staff_app_demo` flow subfolders, `playlearn`, `graphql_demo`.

**Strict gate for new code:** `bash tool/check_feature_folder_contract.sh --strict`.

---

## 8. Before / after examples

### DI — page-level `getIt` removed

**Before** (`EventBusDemoPage`):

```dart
final eventBus = getIt<EventBus>();
```

**After** — route provides dependency:

```dart
// routes_demos.part.dart
builder: (context, state) => EventBusDemoPage(eventBus: getIt<EventBus>()),

// event_bus_demo_page.dart
const EventBusDemoPage({required this.eventBus, super.key});
final EventBus eventBus;
```

### DI — `CounterCubit` timer service

**Before:**

```dart
CounterCubit({required this.repository, TimerService? timerService})
  : _timerService = timerService ?? DefaultTimerService();
```

**After:**

```dart
CounterCubit({required this.repository, required this.timerService});
// routes_core.dart: timerService: getIt<TimerService>()
// tests: FakeTimerService()
```

### Therapy — standardized exception handling

**Before:**

```dart
} catch (e, st) {
  AppLogger.error('ClientBookingCubit.load', e, st);
  emit(state.copyWith(errorMessage: e.toString(), isBusy: false));
}
```

**After:**

```dart
await CubitExceptionHandler.executeAsync(
  operation: () => _repository.fetchSlots(),
  onSuccess: (slots) => emit(state.copyWith(slots: slots, isBusy: false)),
  onError: (message) => emit(state.copyWith(errorMessage: message, isBusy: false)),
  logContext: 'ClientBookingCubit.loadSlots',
  isAlive: () => !isClosed,
);
```

### Folder layout — counter

**Before:** `apps/mobile/lib/features/counter/presentation/counter_cubit.dart`

**After:** `apps/mobile/lib/features/counter/presentation/cubit/counter_cubit.dart` (+ parts/state)

---

## Success criteria (program closeout)

| # | Criterion | Met |
| --- | --- | --- |
| 1 | This audit published with six core sections + §7–§8 | Yes |
| 2 | Zero `getIt` in feature presentation pages | Yes |
| 3 | `CounterCubit` requires injected `TimerService` | Yes |
| 4 | Therapy six cubits use `CubitExceptionHandler` | Yes |
| 5 | Counter + deeplink under `presentation/cubit/`; contract root warnings drop from 24 to 20 | Yes |
| 6 | `CubitErrorHandler` removed; `chat_cubit` uses subscription mixin | Yes |
| 7 | FirebaseAuthRepository + CallCubit + TherapistHomeCubit tests | Yes |
| 8 | `docs/quick_start.md` + README link | Yes |
| 9 | `./bin/checklist` green on clean tree for final closeout | Run at ship time |

**Proof commands (narrow lane):**

```bash
flutter analyze
flutter test test/counter_cubit_test.dart test/features/deeplink test/features/event_bus_demo test/features/auth/data/firebase_auth_repository_test.dart test/features/online_therapy_demo
bash tool/check_feature_folder_contract.sh
rg 'getIt<' apps/mobile/lib/features --glob '**/presentation/pages/**'
```
