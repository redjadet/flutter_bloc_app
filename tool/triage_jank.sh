#!/usr/bin/env bash
# Jank triage entry for humans and agents.
# Prints the measure-first cause map and optionally analyzes a perf report.
#
# Usage:
#   bash tool/triage_jank.sh
#   bash tool/triage_jank.sh artifacts/perf/perf_report_data_<stamp>.json
#   bash tool/triage_jank.sh --latest
#   bash tool/triage_jank.sh --help
#
# Exit codes:
#   0  map-only, or analyzer gate pass / report_only
#   1  analyzer gate fail (budget pressure in the report)
#   2  report path missing / not a file
#   3  --latest requested but no artifacts/perf/perf_report_data_*.json
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="docs/performance/finding_jank_cause.md"
ANALYZER="$ROOT/tool/analyze_perf_trace.py"

usage() {
  cat <<EOF
Usage: bash tool/triage_jank.sh [--latest | <perf_report_data_*.json>]

Jank is a symptom. Find which work delayed the frame before changing code.
Canon: $DOC

Without a report path, prints the triage map only (exit 0).
With --latest, analyzes the newest artifacts/perf/perf_report_data_*.json.
With a report path, prints the map then runs analyze_perf_trace.py --triage.

Exit codes: 0 ok / map-only; 1 gate fail; 2 bad path; 3 no --latest artifact.
EOF
}

print_map() {
  cat <<EOF
[triage_jank] Finding the real cause of jank
Canon: $ROOT/$DOC

1. Reproduce in profile mode (debug frame times lie).
   Interactive:  cd apps/mobile && flutter run --profile
                 (iOS Simulator often cannot run --profile; physical device for final accept)
   Automated:    CHECKLIST_INTEGRATION_DEVICE=<udid> bash tool/capture_perf_trace.sh
                 python3 tool/analyze_perf_trace.py artifacts/perf/perf_report_data_<stamp>.json --triage
   Budgets:      tool/perf_budgets.json (p90≤8.3ms, p99≤16.7ms) — UI vs Raster still needs DevTools

2. Follow the slow side in DevTools Performance (select a red frame).
   High UI time  → BUILD/LAYOUT/PAINT timeline + CPU Profiler
                   bash tool/check_perf_unnecessary_rebuilds.sh
                   bash tool/check_perf_nonbuilder_lists.sh
                   bash tool/check_perf_shrinkwrap_lists.sh
                   bash tool/check_side_effects_build.sh
   High Raster   → clips, opacity, shadows, saveLayer, offscreen layers
                   bash tool/check_perf_missing_repaint_boundary.sh

3. Related symptoms (separate investigations):
   Growing memory     → docs/performance/dart_memory_under_the_hood.md
   Slow first paint   → DevTools Network + startup profiling
   Main-isolate CPU   → docs/performance/compute_isolate_review.md (after measurement)

Takeaway: one targeted change, then remeasure the same interaction.
Frame budget: ~16.7ms @ 60Hz, ~8.3ms @ 120Hz.
EOF
}

resolve_latest() {
  local latest=""
  latest="$(
    find "$ROOT/artifacts/perf" -maxdepth 1 -type f -name 'perf_report_data_*.json' \
      2>/dev/null | sort | tail -n 1 || true
  )"
  if [[ -z "$latest" ]]; then
    echo "[triage_jank] No artifacts/perf/perf_report_data_*.json found." >&2
    echo "[triage_jank] Capture first:" >&2
    echo "[triage_jank]   CHECKLIST_INTEGRATION_DEVICE=<udid> bash tool/capture_perf_trace.sh" >&2
    return 3
  fi
  printf '%s\n' "$latest"
  return 0
}

REPORT=""
case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  --latest)
    # Always print the map first so agents still get guidance when artifacts are missing.
    print_map
    echo
    set +e
    REPORT="$(resolve_latest)"
    resolve_rc=$?
    set -e
    if [[ "$resolve_rc" -ne 0 ]]; then
      exit "$resolve_rc"
    fi
    ;;
  "")
    print_map
    exit 0
    ;;
  *)
    REPORT="$1"
    if [[ "$REPORT" != /* ]]; then
      REPORT="$ROOT/$REPORT"
    fi
    if [[ ! -f "$REPORT" ]]; then
      print_map
      echo
      echo "[triage_jank] Report not found: $REPORT" >&2
      exit 2
    fi
    print_map
    echo
    ;;
esac

if [[ -n "$REPORT" ]]; then
  echo "[triage_jank] Analyzing: $REPORT"
  echo
  python3 "$ANALYZER" "$REPORT" --triage
fi
