#!/usr/bin/env bash
# Jank triage entry for humans and agents.
# Prints the measure-first cause map and optionally analyzes a perf report.
#
# Usage:
#   bash tool/triage_jank.sh
#   bash tool/triage_jank.sh artifacts/perf/perf_report_data_<stamp>.json
#   bash tool/triage_jank.sh --latest
#   bash tool/triage_jank.sh --help
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="docs/performance/finding_jank_cause.md"
ANALYZER="$ROOT/tool/analyze_perf_trace.py"

usage() {
  cat <<EOF
Usage: bash tool/triage_jank.sh [--latest | <perf_report_data_*.json>]

Jank is a symptom. Find which work delayed the frame before changing code.
Canon: $DOC

Without a report path, prints the triage map only.
With --latest, analyzes the newest artifacts/perf/perf_report_data_*.json.
EOF
}

print_map() {
  cat <<EOF
[triage_jank] Finding the real cause of jank
Canon: $ROOT/$DOC

1. Reproduce in profile mode (debug frame times lie).
   Interactive:  cd apps/mobile && flutter run --profile
   Automated:    CHECKLIST_INTEGRATION_DEVICE=<udid> bash tool/capture_perf_trace.sh
                 python3 tool/analyze_perf_trace.py artifacts/perf/perf_report_data_<stamp>.json

2. Follow the slow side in DevTools Performance (select a red frame).
   High UI time  → BUILD/LAYOUT/PAINT timeline + CPU Profiler
                   tool/check_perf_unnecessary_rebuilds.sh
                   tool/check_perf_nonbuilder_lists.sh
                   tool/check_perf_shrinkwrap_lists.sh
   High Raster   → clips, opacity, shadows, saveLayer, offscreen layers
                   tool/check_perf_missing_repaint_boundary.sh

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
  # Prefer nullglob-safe find over bare globs.
  latest="$(
    find "$ROOT/artifacts/perf" -maxdepth 1 -type f -name 'perf_report_data_*.json' \
      2>/dev/null | sort | tail -n 1 || true
  )"
  if [[ -z "$latest" ]]; then
    echo "[triage_jank] No artifacts/perf/perf_report_data_*.json found." >&2
    echo "[triage_jank] Capture first:" >&2
    echo "[triage_jank]   CHECKLIST_INTEGRATION_DEVICE=<udid> bash tool/capture_perf_trace.sh" >&2
    exit 3
  fi
  printf '%s\n' "$latest"
}

REPORT=""
case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  --latest)
    REPORT="$(resolve_latest)"
    ;;
  "")
    ;;
  *)
    REPORT="$1"
    if [[ "$REPORT" != /* ]]; then
      REPORT="$ROOT/$REPORT"
    fi
    if [[ ! -f "$REPORT" ]]; then
      echo "[triage_jank] Report not found: $REPORT" >&2
      exit 2
    fi
    ;;
esac

print_map
echo

if [[ -n "$REPORT" ]]; then
  echo "[triage_jank] Analyzing: $REPORT"
  echo
  python3 "$ANALYZER" "$REPORT" --triage
fi
