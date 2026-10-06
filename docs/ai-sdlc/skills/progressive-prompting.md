---
name: progressive-prompting
description: Apply when scoping agent turns, plan steps, or Cursor/Codex prompts so each slice starts from green code and adds one verifiable behavior.
---

# Skill: progressive-prompting

**Owner:** [`docs/ai-sdlc/README.md`](../README.md) (Progressive prompting),
[`templates/plan.md`](../templates/plan.md).

Inspired by Chris Dunlop’s **Progressive Prompting** pattern for Cursor: small
sequenced prompts beat one-shot “build the entire feature” asks.

## Must

1. **Start from working code** — analyze and the last step’s focused tests pass before the next prompt.
2. **One verifiable behavior per turn** — maps to a single numbered plan step with named proof commands.
3. **Land the slice** — commit or PR the thin diff; next prompt references that baseline.
4. **Name proof in the plan** — each step ties to a row in the plan **Proof plan** table or [`gates.md`](../gates.md).
5. **Keep write-set narrow** — if a step touches paths outside the plan write-set, stop and revise the plan.

## Must not

- Ask the agent to implement an entire offline feature, new Cubit surface, and UI in one message.
- Start a new turn while analyze or the prior step’s tests are red (“fix forward” without scoping).
- Skip tests for “just wiring” steps that change behavior visible to users or merge logic.

## Flutter patterns (examples)

| Slice | Proof |
| --- | --- |
| Cubit event + state only | `flutter test path/to/cubit_test.dart` |
| Repository merge / pending queue | `bash tool/check_offline_first_remote_merge.sh` + repo tests |
| Widget loading/error | Widget test with mocked bloc/cubit |

See plan template examples: cancellation on cubit close; offline pending retry row.

## Proof

Plan step complete when its proof row passes and write-set matches the plan table.
