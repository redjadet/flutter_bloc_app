# Human–AI developer work loop

**Date:** 2026-09-24

**Scope:** Human-facing documentation only.

## Why

The [Stackademic article](https://blog.stackademic.com/ai-writes-my-code-now-heres-what-i-actually-do-with-my-time-a7387fd82e75)
argues that developers spend more time defining problems, reviewing generated
code, supplying user context, owning architecture, and testing unexpected paths.
This repository already documents those skills, but the human guide lacked a
short sequence and request card a developer could use during one agent task.

## Decision

- Add a five-stage human–AI work loop and a reusable request card to the
  existing human-skills owner. Human developers define expected behavior before
  generated code, spend agent run time on counterexamples, then review and
  verify the full change.
- Clarify that a prompt starts a task but does not replace a durable feature
  brief, change note, or owner document. Point onboarding and the AI work-area
  guide at the loop instead of duplicating its instructions.
- Use the existing offline-sync contract as a concrete example of paired
  counterexamples. This documents a proof obligation; it changes no behavior.

## Must remain true

Human developers own product decisions, architecture direction, risk
acceptance, and final approval. Expected results come from a user or domain
contract independent of generated implementation and tests. Teammates can find
the rationale and recovery path without the original AI conversation.

## Failure modes

- A detailed prompt contains an unstated or wrong assumption: compare it with
  current code, user context, and independently written acceptance examples;
  settle conflicting product interpretations before accepting the patch.
- Generated code and tests agree on a flawed happy path: inspect every changed
  file and test, trace callers, and add a counterexample that can fail for the
  intended defect.
- A passing local check is presented as complete proof: record exact commands,
  skipped lanes, relevant runtime observations, and residual risk.

## Rejected alternatives

- A new AI policy document: it would duplicate the existing human-skills,
  review, and validation owners and make guidance harder to maintain.
- Treating the prompt or agent summary as the only specification: neither is a
  durable repository artifact or independent expected-result source.
- Mandating a fixed test list for every change: risk and contract determine the
  relevant proof through validation routing.
