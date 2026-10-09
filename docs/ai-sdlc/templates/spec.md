# Spec template

Copy to `docs/ai-sdlc/features/<slug>/spec.md` after intent is **accepted**.
Compress requirements + design. Apply institutional skills from
[`../skills/`](../skills/README.md).

```yaml
status: draft  # draft | accepted | rejected
slug: <kebab-slug>
intent: ./intent.md
skills_applied:
  - offline-first
  - # platform-channel-safety | cancellation-disposables | theme-tokens
```

## Behavior contract

Derive expected results from accepted intent or an existing owner contract;
cite that source. Add the risk-relevant cases below; mark an irrelevant case N/A
with a reason. An agent can propose missing cases, but unresolved expected
behavior remains a human decision.

| Case | Input | Expected |
| --- | --- | --- |
| Happy | … | … |
| Boundary | … | … |
| Failure | … | … |
| Repeated / concurrent | … | … |
| Interrupted / stale | … | … |
| Recovery / retry | … | … |

## Layers / seams

- [ ] domain
- [ ] data (repos, DTO, Hive)
- [ ] presentation (Cubit/BLoC, pages)
- [ ] DI / routes / l10n
- [ ] platform channels / FFI (if any)

## Architecture notes

Link reference feature grade:
[`docs/architecture/reference_features.md`](../../architecture/reference_features.md).
Do not bypass Clean Architecture.

- State/data source of truth and owner of each side effect:
- Lifecycle/trust boundaries and partial-failure recovery (where relevant):
- Consequential decision, chosen option, rejected simpler option, and human owner;
  link an ADR if required. Routine choices reuse accepted architecture.

## Tests (RED first)

Mirror [`docs/engineering/FEATURE_TEMPLATE.md`](../../engineering/FEATURE_TEMPLATE.md):

- Behaviour (widget/cubit):
- Unit (domain/data) + adversarial:
- Integration journey (if cross-screen):
- Proof command: `cd apps/mobile && flutter test <paths>`

Map each important behavior case to a named test or explicit manual proof and
limitation. Review assertions against the contract, not the generated control
flow; agent-written tests are drafts too.

## Non-goals

Explicit outs so agents do not scope-creep.

## Risks

Offline overwrite, emit-after-close, channel threading, theme hardcoding, …

---

### Example — BLoC + offline todo merge

**Behavior:** Local edit while offline → remote fetch returns older row → local
row retained. Pending state remains visible through the existing feature or
sync-diagnostics surface, according to the feature contract.

**Layers:** data (todo repository merge) + presentation (Cubit status) + tests.

**Skills:** `offline-first`, `cancellation-disposables`.

**Proof:** focused repository + cubit tests; offline merge script.

### Example — platform channel ping

**Behavior:** MethodChannel `demo/ping` returns typed success/failure; web stub
returns `unsupported` without throwing into UI.

**Skills:** `platform-channel-safety`.

**Proof:** unit tests for host stub + widget test for error chip; see
[`docs/platforms/reviewer_guide.md`](../../platforms/reviewer_guide.md).
