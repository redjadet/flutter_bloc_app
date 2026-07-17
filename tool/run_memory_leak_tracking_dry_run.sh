#!/usr/bin/env bash
# Wave B0: report-only full-suite leak_tracker dry-run.
# Enables MEMORY_LEAK_TRACKING_DRY_RUN for apps/mobile tests, captures logs,
# writes a summary under tmp/, and ALWAYS exits 0 (non-blocking lane).
# Do NOT wire into delivery_checklist / CI gates.
set -uo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"

STAMP="${MEMORY_LEAK_DRY_RUN_STAMP:-$(date -u +%Y%m%dT%H%M%SZ)}"
OUT_DIR="${MEMORY_LEAK_DRY_RUN_OUT:-$WORKSPACE_ROOT/tmp/memory_leak_dry_run/$STAMP}"
mkdir -p "$OUT_DIR"

RAW_LOG="$OUT_DIR/flutter_test_raw.log"
SUMMARY_JSON="$OUT_DIR/summary.json"
SUMMARY_MD="$OUT_DIR/summary.md"
META="$OUT_DIR/meta.txt"

{
  echo "stamp=$STAMP"
  echo "started_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "cwd=$APP_ROOT"
  echo "dart_define=MEMORY_LEAK_TRACKING_DRY_RUN=true"
  echo "command=flutter test --dart-define=MEMORY_LEAK_TRACKING_DRY_RUN=true ${MEMORY_LEAK_DRY_RUN_ARGS:-}"
} >"$META"

echo "🧪 Memory leak tracking dry-run (report-only)"
echo "   output: $OUT_DIR"
echo "   NOTE: default suite still uses withIgnoredAll(); this lane only."

cd "$APP_ROOT"
set +e
# shellcheck disable=SC2086
flutter test \
  --dart-define=MEMORY_LEAK_TRACKING_DRY_RUN=true \
  ${MEMORY_LEAK_DRY_RUN_ARGS:-} \
  2>&1 | tee "$RAW_LOG"
flutter_status=${PIPESTATUS[0]}
set -e

{
  echo "finished_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "flutter_test_exit=$flutter_status"
} >>"$META"

python3 "$WORKSPACE_ROOT/tool/summarize_memory_leak_dry_run.py" \
  --log "$RAW_LOG" \
  --meta "$META" \
  --json-out "$SUMMARY_JSON" \
  --md-out "$SUMMARY_MD" || {
  echo "⚠️  summarizer failed; raw log still at $RAW_LOG"
}

echo
echo "📄 Dry-run artifacts:"
echo "   $RAW_LOG"
echo "   $SUMMARY_MD"
echo "   $SUMMARY_JSON"
echo "✅ Dry-run lane finished (report-only; exit 0 regardless of flutter_test=$flutter_status)."
exit 0
