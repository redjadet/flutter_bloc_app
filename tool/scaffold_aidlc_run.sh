#!/usr/bin/env bash
# Deterministic AIDLC Lite/full scaffold (repo-root aware, dry-run by default).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/scaffold_aidlc_run.sh --host <codex|cursor> [options]

Scaffold AIDLC Lite tracker section or T2 full run bundle.
Default mode is dry-run (prints plan only). Pass --apply to write.

Options:
  --host HOST           Required: codex or cursor
  --mode MODE           lite (default) or full
  --slug KEBAB          Required for full unless --run-id set; optional lite label
  --run-id ID           Full run id YYYYMMDD-kebab (optional; built from --slug)
  --replace-active      Supersede prior active run before creating a new active one
  --dry-run             Print plan only (default when --apply omitted)
  --apply               Write files
  -h, --help            Show help
EOF
}

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

host=""
mode="lite"
slug=""
run_id=""
replace_active=0
apply=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --host) host="${2:-}"; shift 2 ;;
    --mode) mode="${2:-}"; shift 2 ;;
    --slug) slug="${2:-}"; shift 2 ;;
    --run-id) run_id="${2:-}"; shift 2 ;;
    --replace-active) replace_active=1; shift ;;
    --dry-run) apply=0; shift ;;
    --apply) apply=1; shift ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$host" ]]; then
  echo "Missing required --host." >&2
  usage >&2
  exit 2
fi
if [[ "$host" != "codex" && "$host" != "cursor" ]]; then
  echo "Invalid --host: $host (expected codex|cursor)" >&2
  exit 2
fi
if [[ "$mode" != "lite" && "$mode" != "full" ]]; then
  echo "Invalid --mode: $mode (expected lite|full)" >&2
  exit 2
fi

slug_re='^[a-z0-9]+(-[a-z0-9]+)*$'
run_id_re='^[0-9]{8}-[a-z0-9]+(-[a-z0-9]+)*$'

if [[ "$mode" == "full" ]]; then
  if [[ -n "$run_id" ]]; then
    if [[ ! "$run_id" =~ $run_id_re ]]; then
      echo "Invalid --run-id: $run_id" >&2
      exit 2
    fi
  else
    if [[ -z "$slug" ]]; then
      echo "full mode requires --slug or --run-id" >&2
      exit 2
    fi
    if [[ ! "$slug" =~ $slug_re ]]; then
      echo "Invalid --slug: $slug" >&2
      exit 2
    fi
    run_id="$(date +%Y%m%d)-${slug}"
  fi
elif [[ -n "$slug" && ! "$slug" =~ $slug_re ]]; then
  echo "Invalid --slug: $slug" >&2
  exit 2
fi

tracker="tasks/${host}/todo.md"
bundle_dir=""
if [[ "$mode" == "full" ]]; then
  base_id="$run_id"
  candidate="$base_id"
  n=2
  while [[ -d "tasks/${host}/aidlc/${candidate}" ]]; do
    if [[ -n "$(ls -A "tasks/${host}/aidlc/${candidate}" 2>/dev/null || true)" ]]; then
      if (( replace_active == 0 )); then
        # collision: append -2, -3
        candidate="${base_id}-${n}"
        n=$((n + 1))
        continue
      fi
    fi
    break
  done
  run_id="$candidate"
  bundle_dir="tasks/${host}/aidlc/${run_id}"
fi

# Detect existing active runs
active_hits=0
if [[ -f "$tracker" ]] && grep -qF "## AIDLC" "$tracker"; then
  if grep -qE 'run_status:[[:space:]]*active' "$tracker"; then
    active_hits=$((active_hits + 1))
  fi
fi
if [[ -d "tasks/${host}/aidlc" ]]; then
  while IFS= read -r state; do
    if grep -qE 'run_status:[[:space:]]*active' "$state"; then
      active_hits=$((active_hits + 1))
    fi
  done < <(find "tasks/${host}/aidlc" -name aidlc-state.md 2>/dev/null || true)
fi

# Active-run guard applies to writes; dry-run still plans but warns.
if (( active_hits > 0 && replace_active == 0 )); then
  if (( apply == 1 )); then
    echo "scaffold_aidlc_run|error|active run exists for host ${host}; pass --replace-active" >&2
    exit 1
  fi
  echo "scaffold_aidlc_run|warn|active run exists for host ${host}; --apply needs --replace-active"
fi

if [[ "$mode" == "full" && -d "$bundle_dir" && -n "$(ls -A "$bundle_dir" 2>/dev/null || true)" && "$replace_active" -eq 0 ]]; then
  if (( apply == 1 )); then
    echo "scaffold_aidlc_run|error|non-empty target exists: $bundle_dir" >&2
    exit 1
  fi
  echo "scaffold_aidlc_run|warn|non-empty target exists: $bundle_dir"
fi

# Path escape guard
case "$tracker" in
  tasks/codex/*|tasks/cursor/*) ;;
  *) echo "path escape blocked: $tracker" >&2; exit 1 ;;
esac
if [[ -n "$bundle_dir" ]]; then
  case "$bundle_dir" in
    tasks/codex/aidlc/*|tasks/cursor/aidlc/*) ;;
    *) echo "path escape blocked: $bundle_dir" >&2; exit 1 ;;
  esac
fi

ext_block="$(cat <<'YAML'
extensions:
  user_story: { status: skipped, reason: "Fill reason." }
  architecture: { status: skipped, reason: "Fill reason." }
  testing: { status: selected, reason: "Fill reason." }
  security: { status: skipped, reason: "Fill reason." }
  resilience: { status: skipped, reason: "Fill reason." }
  ui_platform: { status: skipped, reason: "Fill reason." }
  operations: { status: skipped, reason: "Fill reason." }
  documentation: { status: selected, reason: "Fill reason." }
  property_based_testing: { status: skipped, reason: "Fill reason." }
YAML
)"

run_label_line=""
if [[ "$mode" == "lite" && -n "$slug" ]]; then
  run_label_line="run_label: ${slug}"
fi

if [[ "$mode" == "lite" ]]; then
  yaml_body="$(cat <<YAML
aidlc_schema_version: 1
mode: lite
run_status: active
${run_label_line}
task_type: docs
field: brownfield
current_stage: inception
risk: low
next_gate: inception_approval
operation: not_applicable
operation_reason: "Local work; no release/deploy."
${ext_block}
gate_events: []
YAML
)"
else
  yaml_body="$(cat <<YAML
aidlc_schema_version: 1
mode: full
run_id: ${run_id}
run_status: active
task_type: docs
field: brownfield
current_stage: inception
risk: low
next_gate: inception_approval
operation: not_applicable
operation_reason: "Local work; no release/deploy."
${ext_block}
gate_events: []
YAML
)"
fi

# drop empty run_label line if unused
yaml_body="$(printf '%s\n' "$yaml_body" | sed '/^$/d')"

aidlc_section="$(cat <<EOF
## AIDLC

\`\`\`yaml
${yaml_body}
\`\`\`
EOF
)"

echo "scaffold_aidlc_run|mode|${mode}"
echo "scaffold_aidlc_run|host|${host}"
echo "plan|tracker|${tracker}"
if [[ -n "$bundle_dir" ]]; then
  echo "plan|bundle|${bundle_dir}"
fi
if (( replace_active )); then
  echo "plan|replace-active|yes"
fi

if (( apply == 0 )); then
  echo "scaffold_aidlc_run|dry-run"
  exit 0
fi

mkdir -p "tasks/${host}"
stage_root="$(mktemp -d "${TMPDIR:-/tmp}/aidlc-scaffold.XXXXXX")"
cleanup_stage() {
  rm -rf "$stage_root"
}
trap cleanup_stage EXIT

# Stage all writes first (never mutate live active runs until promotion succeeds).
staged_tracker="${stage_root}/todo.md"
if [[ -f "$tracker" ]]; then
  cp "$tracker" "$staged_tracker"
else
  cat >"$staged_tracker" <<'EOF'
## Goal
AIDLC scaffolded task.

## Write-set
- (fill)

## Risks
- (fill)

## Validation command
- bash tool/check_aidlc_artifacts.sh

## Evidence/result
- (pending)

EOF
fi

python3 - "$staged_tracker" "$aidlc_section" <<'PY'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
section = sys.argv[2]
text = path.read_text(encoding="utf-8")
if re.search(r"^## AIDLC\s*$", text, re.M):
    text = re.sub(
        r"^## AIDLC\s*\n(?:.*\n)*?(?=^## |\Z)",
        section.rstrip() + "\n\n",
        text,
        count=1,
        flags=re.M,
    )
else:
    text = text.rstrip() + "\n\n" + section.rstrip() + "\n"
path.write_text(text)
print("scaffold_aidlc_run|staged|tracker")
PY

staged_bundle=""
if [[ "$mode" == "full" ]]; then
  staged_bundle="${stage_root}/bundle"
  mkdir -p "$staged_bundle"
  cat >"${staged_bundle}/aidlc-state.md" <<EOF
## AIDLC

\`\`\`yaml
${yaml_body}
\`\`\`
EOF
  printf '# Questions\n\n' >"${staged_bundle}/questions.md"
  cat >"${staged_bundle}/audit.md" <<EOF
# Audit

\`\`\`yaml
- id: E001
  gate: inception_approval
  action: create
  actor: implementer
  timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  reason: "Run scaffolded."
\`\`\`
EOF
  printf '# Artifacts\n\n' >"${staged_bundle}/artifacts.md"
  echo "scaffold_aidlc_run|staged|bundle"
fi

# Validate staged artifacts before touching live files.
validate_paths=("$staged_tracker")
if [[ -n "$staged_bundle" ]]; then
  validate_paths+=("$staged_bundle")
fi
if ! bash "$repo_root/tool/check_aidlc_artifacts.sh" --paths "${validate_paths[@]}"; then
  echo "scaffold_aidlc_run|error|staged validation failed; live files unchanged" >&2
  exit 1
fi

# Backup live tracker for rollback.
backup_tracker=""
if [[ -f "$tracker" ]]; then
  backup_tracker="${stage_root}/backup-todo.md"
  cp "$tracker" "$backup_tracker"
fi

# Promote: supersede prior actives (with supersede audit note), then install staged.
if (( replace_active )); then
  if [[ -f "$tracker" ]]; then
    python3 - "$tracker" <<'PY'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text2 = re.sub(r"(run_status:\s*)active", r"\1superseded", text, count=1)
if text2 != text:
    path.write_text(text2)
    print("scaffold_aidlc_run|superseded|tracker")
PY
  fi
  if [[ -d "tasks/${host}/aidlc" ]]; then
    while IFS= read -r state; do
      if grep -qE 'run_status:[[:space:]]*active' "$state"; then
        python3 - "$state" <<'PY'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
path.write_text(re.sub(r"(run_status:\s*)active", r"\1superseded", text))
# Append supersede audit event when audit.md exists.
audit = path.parent / "audit.md"
if audit.is_file():
    stamp = __import__("datetime").datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    audit.write_text(
        audit.read_text(encoding="utf-8").rstrip()
        + f"\n\n- E998 supersede (auto) actor=scaffold timestamp={stamp} reason=replaced-by-new-active\n"
    )
print("scaffold_aidlc_run|superseded|" + str(path))
PY
      fi
    done < <(find "tasks/${host}/aidlc" -name aidlc-state.md 2>/dev/null || true)
  fi
fi

if ! cp "$staged_tracker" "$tracker"; then
  echo "scaffold_aidlc_run|error|tracker promote failed" >&2
  if [[ -n "$backup_tracker" ]]; then
    cp "$backup_tracker" "$tracker" || true
  fi
  exit 1
fi
echo "scaffold_aidlc_run|wrote|${tracker}|updated"

if [[ "$mode" == "full" ]]; then
  mkdir -p "$(dirname "$bundle_dir")"
  if [[ -e "$bundle_dir" ]]; then
    echo "scaffold_aidlc_run|error|bundle already exists after staging: ${bundle_dir}" >&2
    if [[ -n "$backup_tracker" ]]; then
      cp "$backup_tracker" "$tracker" || true
    fi
    exit 1
  fi
  if ! mv "$staged_bundle" "$bundle_dir"; then
    echo "scaffold_aidlc_run|error|bundle promote failed" >&2
    if [[ -n "$backup_tracker" ]]; then
      cp "$backup_tracker" "$tracker" || true
    fi
    exit 1
  fi
  echo "scaffold_aidlc_run|wrote|${bundle_dir}"
fi

# Final live validation; restore tracker backup on failure.
if ! bash "$repo_root/tool/check_aidlc_artifacts.sh" --host "$host"; then
  echo "scaffold_aidlc_run|error|live validation failed; attempting tracker restore" >&2
  if [[ -n "$backup_tracker" ]]; then
    cp "$backup_tracker" "$tracker" || true
  fi
  exit 1
fi

echo "scaffold_aidlc_run|apply|ok"
trap - EXIT
cleanup_stage
