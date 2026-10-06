# Focus and keyboard input docs

**Date:** 2026-10-06

## Summary

- Added [`docs/engineering/focus_and_keyboard_input.md`](../engineering/focus_and_keyboard_input.md):
  focus tree vs pointer hit-test, `FocusNode` / `FocusScope` / `FocusManager`,
  key-event chain, TextInput vs focus, Shortcuts/Actions/`CallbackShortcuts`,
  ownership rules, Todo Next + dispose anchors.
- Linked from fundamentals (fourth sparse tree), engineering README,
  design-system form-factor matrix, UI/UX review, memory management.
- Fixed leftover `#984`/`#985` merge conflict markers in
  [`docs/changes/README.md`](README.md) (both change-index rows retained).
- Triggered by Medium fludev focus/keyboard article fact-check against
  [official focus](https://docs.flutter.dev/ui/interactivity/focus) and
  [actions/shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts)
  docs; closes the gap where Todo/`FocusNode` practice and desktop checklist
  rows existed without living framework teaching.

## Verification

Docs-only. Relative links checked against existing engineering / review /
performance owners. No product code changes.
