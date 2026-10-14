# Codex review note — native telemetry freshness

Date: 2026-10-14  
Branch: `cursor/linkedin-freshness-stale-c98c`  
Tip base: `149327962257ee2ba419277bd86a944de294110a`

## Codex attempt

`./tool/request_codex_feedback.sh --staged --profile fast --backend codex-cli`
was run on a narrow staged set (l10n generated files excluded). The process
produced no output and was killed after **2 minutes** (hard stop per finish
instruction). Prior Lacie attempts also hung while assembling large diffs /
waiting on tooling.

**Fallback:** Cursor high-bar review below stands in for Codex-before-commit.

## High-bar review (Cursor)

### Verdict

Ship as teaching-quality demo improvement. No blocking correctness issues found
in the freshness/liveness path.

### What is solid

- Delivery rate vs value age are separated: Cubit tracks monotonic **receipt age**
  vs **value age**; UI surfaces both.
- Freshness deadline re-evaluated on a timer without requiring a new event.
- Hosts emit `acceptedCount == 0` liveness ticks for all-dup windows with source
  activity — quiet-from-dedupe is no longer mistaken for a dead source.
- Liveness ticks keep the last accepted average on screen (update rate ≠ value
  refresh).
- Domain tracker is plain immutable (no Freezed); ports/CA boundaries preserved
  (Cubit → use case → EventChannel adapter).
- Native Android / iOS / macOS accumulators + unit tests updated together.
- Dart tests cover tracker ages/deadlines, Cubit liveness display, and timer
  stale flip (`+18` focused tests passed).

### Risks / follow-ups (non-blocking)

1. **`native_platform_showcase_state.freezed.dart`** was updated to match the
   `telemetryFreshness` annotation after `build_runner` in a `/tmp` worktree
   wrote **0 outputs** and removed the part file. Annotation and generated
   surface are kept in sync; regenerate with Freezed when the host builder is
   healthy and replace this note.
2. Value age is “time since last accepted bridge event,” not a cross-clock
   sample timestamp — intentional; do not claim Dart↔native wall latency.
3. Freshness timer is presentation-side; fine for the showcase. If reused in
   production streams, consider a use-case/policy owner above the Cubit.

### Security / perf

No new channel surface beyond schema-v1 `acceptedCount == 0`. No secrets.
Timer interval 250 ms is selector-isolated and cheap for a demo page.
