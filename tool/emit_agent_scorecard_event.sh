#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCORECARD_ROOT="$PROJECT_ROOT/analysis/agent_scorecard"
SCORECARD_FILE="$SCORECARD_ROOT/scorecard-events.jsonl"
SCORECARD_SUMMARIES_DIR="$SCORECARD_ROOT/summaries"
SCORECARD_ARCHIVE_DIR="$SCORECARD_ROOT/archive"
SCHEMA_VERSION="v1"
HOT_RETENTION_DAYS=30

usage() {
  cat <<'EOF'
Usage:
  emit_agent_scorecard_event.sh --command <name> --status <ok|failed|cancelled|aborted|invalid> [options]

Required:
  --command <name>             Logical command name (e.g. checklist, integration_tests)
  --status <value>             Event outcome

Optional:
  --task-id <id>               Stable task id across retries
  --run-id <id>                Single attempt id
  --attempt <n>                Attempt number (default: 1)
  --started-at <iso8601>       UTC timestamp (default: now)
  --ended-at <iso8601>         UTC timestamp (default: now)
  --duration-ms <n>            Duration in milliseconds (default: 0)
  --branch <name>              Git branch name (best-effort default)
  --risk-class <value>         low|medium|high|unknown (default: unknown)
  --delegate-used <0|1>        Whether delegate was used (default: 0)
  --delegate-mode <name>       Delegate mode (ask/plan/review/etc)
  --delegate-fail-reason <s>   Delegate failure reason
  --checklist-pass <0|1|null>  Validation status
  --router-pass <0|1|null>     Validation status
  --integration-pass <0|1|null> Validation status
  --invalid-partial <0|1>      Mark artifact as invalid/partial (default: 0)
EOF
}

command_name=""
status=""
task_id="${TASK_ID:-}"
run_id="${RUN_ID:-}"
attempt="${ATTEMPT:-1}"
started_at=""
ended_at=""
duration_ms="0"
branch=""
risk_class="${RISK_CLASS:-unknown}"
delegate_used="0"
delegate_mode=""
delegate_fail_reason=""
checklist_pass="null"
router_pass="null"
integration_pass="null"
invalid_partial="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --command) command_name="${2:-}"; shift 2 ;;
    --status) status="${2:-}"; shift 2 ;;
    --task-id) task_id="${2:-}"; shift 2 ;;
    --run-id) run_id="${2:-}"; shift 2 ;;
    --attempt) attempt="${2:-}"; shift 2 ;;
    --started-at) started_at="${2:-}"; shift 2 ;;
    --ended-at) ended_at="${2:-}"; shift 2 ;;
    --duration-ms) duration_ms="${2:-}"; shift 2 ;;
    --branch) branch="${2:-}"; shift 2 ;;
    --risk-class) risk_class="${2:-}"; shift 2 ;;
    --delegate-used) delegate_used="${2:-}"; shift 2 ;;
    --delegate-mode) delegate_mode="${2:-}"; shift 2 ;;
    --delegate-fail-reason) delegate_fail_reason="${2:-}"; shift 2 ;;
    --checklist-pass) checklist_pass="${2:-}"; shift 2 ;;
    --router-pass) router_pass="${2:-}"; shift 2 ;;
    --integration-pass) integration_pass="${2:-}"; shift 2 ;;
    --invalid-partial) invalid_partial="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$command_name" || -z "$status" ]]; then
  echo "Missing required --command or --status." >&2
  usage >&2
  exit 2
fi

now_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
started_at="${started_at:-$now_iso}"
ended_at="${ended_at:-$now_iso}"
branch="${branch:-$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")}"

mkdir -p "$SCORECARD_ROOT" "$SCORECARD_SUMMARIES_DIR" "$SCORECARD_ARCHIVE_DIR"

python3 - "$SCORECARD_ROOT" "$SCORECARD_FILE" "$SCORECARD_ARCHIVE_DIR" "$HOT_RETENTION_DAYS" <<'PY'
import gzip
import shutil
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

root = Path(sys.argv[1])
current_file = Path(sys.argv[2])
archive_dir = Path(sys.argv[3])
retention_days = int(sys.argv[4])

root.mkdir(parents=True, exist_ok=True)
archive_dir.mkdir(parents=True, exist_ok=True)

today = datetime.now(timezone.utc).date()

if current_file.exists() and current_file.stat().st_size > 0:
    file_day = datetime.fromtimestamp(current_file.stat().st_mtime, timezone.utc).date()
    if file_day < today:
        dated_name = f"scorecard-events-{file_day.isoformat()}.jsonl"
        dated_file = root / dated_name
        if dated_file.exists():
            with current_file.open("r", encoding="utf-8") as src, dated_file.open("a", encoding="utf-8") as dst:
                shutil.copyfileobj(src, dst)
            current_file.unlink()
        else:
            current_file.rename(dated_file)

threshold = today - timedelta(days=retention_days)
for dated_file in root.glob("scorecard-events-*.jsonl"):
    try:
        date_part = dated_file.stem.replace("scorecard-events-", "")
        file_date = datetime.strptime(date_part, "%Y-%m-%d").date()
    except ValueError:
        continue
    if file_date <= threshold:
        gz_target = archive_dir / f"{dated_file.name}.gz"
        with dated_file.open("rb") as src, gzip.open(gz_target, "wb") as dst:
            shutil.copyfileobj(src, dst)
        dated_file.unlink()
PY

if [[ -z "$task_id" ]]; then
  task_id="$(python3 - "$command_name" "$branch" <<'PY'
import hashlib
import sys
from datetime import datetime, timezone

seed = f"{sys.argv[1]}::{sys.argv[2]}::{datetime.now(timezone.utc).date().isoformat()}"
print("tsk_" + hashlib.sha1(seed.encode("utf-8")).hexdigest()[:12])
PY
)"
fi

if [[ -z "$run_id" ]]; then
  run_id="$(python3 - <<'PY'
import uuid
print("run_" + uuid.uuid4().hex)
PY
)"
fi

python3 - "$SCORECARD_FILE" \
  "$SCHEMA_VERSION" "$task_id" "$run_id" "$command_name" "$started_at" "$ended_at" "$duration_ms" "$status" "$attempt" \
  "$branch" "$risk_class" "$delegate_used" "$delegate_mode" "$delegate_fail_reason" \
  "$checklist_pass" "$router_pass" "$integration_pass" "$invalid_partial" <<'PY'
import json
import sys
from pathlib import Path

(
    scorecard_file,
    schema_version,
    task_id,
    run_id,
    command_name,
    started_at,
    ended_at,
    duration_ms,
    status,
    attempt,
    branch,
    risk_class,
    delegate_used,
    delegate_mode,
    delegate_fail_reason,
    checklist_pass,
    router_pass,
    integration_pass,
    invalid_partial,
) = sys.argv[1:]

def parse_bool_or_null(value: str):
    value = value.strip().lower()
    if value == "1" or value == "true":
        return True
    if value == "0" or value == "false":
        return False
    return None

event = {
    "schema_version": schema_version,
    "task_id": task_id,
    "run_id": run_id,
    "command": command_name,
    "started_at": started_at,
    "ended_at": ended_at,
    "duration_ms": int(duration_ms),
    "status": status,
    "attempt": int(attempt),
    "branch": branch,
    "risk_class": risk_class,
    "delegate_used": delegate_used in ("1", "true", "True"),
    "delegate_mode": delegate_mode or None,
    "delegate_fail_reason": delegate_fail_reason or None,
    "checklist_pass": parse_bool_or_null(checklist_pass),
    "router_validate_pass": parse_bool_or_null(router_pass),
    "integration_pass": parse_bool_or_null(integration_pass),
    "invalid_partial": invalid_partial in ("1", "true", "True"),
}
event["dedupe_key"] = f"{event['task_id']}+{event['command']}+{event['attempt']}+{event['started_at']}"

Path(scorecard_file).parent.mkdir(parents=True, exist_ok=True)
with Path(scorecard_file).open("a", encoding="utf-8") as handle:
    handle.write(json.dumps(event, ensure_ascii=True) + "\n")
PY
