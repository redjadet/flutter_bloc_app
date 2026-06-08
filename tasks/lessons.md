# Lessons

**Versioned in git** — commit new entries with the change that learned the lesson.
Local per-host trackers stay under `tasks/codex/` and `tasks/cursor/` (gitignored).

Record patterns from user corrections or notable misses so they can be avoided
next time.

Agents must answer **"What did you get wrong, and how did you fix it?"** before filing
here: what went wrong, what fixed it, and what rule prevents recurrence.
Operator pref: [`docs/agent_kb/operator_preferences_durable.md`](../docs/agent_kb/operator_preferences_durable.md)
§ Workflow.

## Template

### YYYY-MM-DD - Short title

- What went wrong:
- How it was fixed:
- Pattern:
- Preventive rule:
- Evidence or affected files:

### 2026-04-02 - Isolate.run from video tile captured non-sendable Flutter state

- Correction:
  Replaced `Isolate.run(() => File(path).existsSync())` in `CaseStudyVideoTile`
  with `compute(_caseStudyLocalVideoExists, localPath)` using a top-level helper.
- Pattern:
  `Isolate.run` serializes the closure’s captures; instance-method closures can
  pull in `WidgetsFlutterBinding` / async zones and fail at runtime with
  *illegal argument in isolate message*.
- Preventive rule:
  In presentation code, use `compute` + top-level/static callback only; repo
  checklist includes `tool/check_no_isolate_run_in_presentation.sh`.
- Evidence or affected files:
  `lib/features/case_study_demo/presentation/widgets/case_study_video_tile.dart`
  `.cursor/rules/flutter-isolate-presentation.mdc`
  `tool/check_no_isolate_run_in_presentation.sh`

### 2026-04-17 - Caveman-lite is the default when suitable

- Correction:
  Do not treat caveman mode as opt-in for this repo's normal agent replies.
  Routine commentary and concise summaries should already use caveman-lite when
  it preserves clarity.
- Pattern:
  I answered as if caveman mode had to be manually activated, ignoring the repo
  canon that already sets compressed communication as the default behavior.
- Preventive rule:
  For this repo, assume caveman-lite is on by default for routine updates and
  straightforward answers. Switch back to normal concise prose only when
  precision, ambiguity, or tone makes compression risky.
- Evidence or affected files:
  `AGENTS.md`
  `tasks/lessons.md`

### 2026-03-30 - Do not self-invoke Codex review helper from Codex

- Correction:
  Do not call `./tool/request_codex_feedback.sh` from Codex itself. That helper
  is meant for Cursor or explicit cross-host second-opinion flows.
- Pattern:
  I treated a repo review helper as a generic validation step without checking
  whether the current host was the same system the helper delegates to.
- Preventive rule:
  Before invoking a cross-host or second-opinion helper, confirm whether the
  current host is already that reviewer. If it is, only use the helper when the
  user explicitly asks for a second opinion or cross-host review.
- Evidence or affected files:
  `AGENTS.md`
  `docs/agents_quick_reference.md`
  `docs/ai_code_review_protocol.md`
  `~/.codex/skills/flutter-bloc-app-quick-reference/SKILL.md`
  `~/.codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md`
  `~/.codex/skills/flutter-bloc-app-cross-host-review/SKILL.md`
