#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/validate_task_trackers.sh [--paths <file>...] [--base <git-ref>]

Validate that `tasks/*/todo.md` trackers follow the canonical contract.
With no args, validates existing tracker files and passes when none exist.

Contract:
- required headings:
  - "## Goal"
  - "## Write-set"
  - "## Risks"
  - "## Validation command"
  - "## Evidence/result"
- "Write-set" must not be empty
- "Validation command" must not be empty

Exit codes:
  0 pass
  1 fail
  2 usage error

Environment:
  HARNESS_SKIP_TRACKER_VALIDATE=1  -> prints skipped-by-policy and exits 0
EOF
}

if [[ "${HARNESS_SKIP_TRACKER_VALIDATE:-0}" == "1" ]]; then
  echo "skipped-by-policy|tracker-validate|HARNESS_SKIP_TRACKER_VALIDATE=1"
  exit 0
fi

base_ref=""
declare -a explicit_paths=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --base)
      base_ref="${2:-}"
      if [[ -z "$base_ref" ]]; then
        echo "usage-error|--base requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --paths)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        explicit_paths+=("$1")
        shift
      done
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

declare -a targets=()

add_tracker_target_if_in_scope() {
  local p="$1"
  if [[ "$p" == /* ]]; then
    p="${p#$repo_root/}"
  fi
  case "$p" in
    tasks/*/todo.md)
      targets+=("$p")
      ;;
  esac
}

if [[ "${#explicit_paths[@]}" -gt 0 ]]; then
  for p in "${explicit_paths[@]}"; do
    add_tracker_target_if_in_scope "$p"
  done
  if [[ "${#targets[@]}" -eq 0 ]]; then
    echo "✅ Task trackers validated (no tracker paths provided)."
    exit 0
  fi
elif [[ -n "$base_ref" ]]; then
  if ! git rev-parse "$base_ref" >/dev/null 2>&1; then
    echo "usage-error|invalid base ref: $base_ref" >&2
    exit 2
  fi
  while IFS= read -r p; do
    [[ -n "$p" ]] && add_tracker_target_if_in_scope "$p"
  done < <(git diff --name-only "$base_ref...HEAD" --diff-filter=ACMRTUXB | sed '/^$/d')
  if [[ "${#targets[@]}" -eq 0 ]]; then
    echo "✅ Task trackers validated (no changed tracker paths)."
    exit 0
  fi
else
  shopt -s nullglob
  targets+=(tasks/*/todo.md)
  shopt -u nullglob
  if [[ "${#targets[@]}" -eq 0 ]]; then
    echo "✅ Task trackers validated (no tracker files present)."
    exit 0
  fi
fi

failures=0

fail() {
  echo "❌ $*" >&2
  failures=1
}

require_heading() {
  local file="$1"
  local heading="$2"
  if ! grep -qF "$heading" "$file"; then
    fail "$file missing required heading: $heading"
  fi
}

section_non_empty() {
  local file="$1"
  local heading="$2"
  # Grab lines until next '## ' heading. Allow blank lines at start, but require at least one non-blank content line.
  local content
  content="$(awk -v h="$heading" '
    $0 == h { inside=1; next }
    inside && $0 ~ /^## / { exit }
    inside { print }
  ' "$file" | sed 's/[[:space:]]//g' | sed '/^$/d' | head -n 1 || true)"
  if [[ -z "$content" ]]; then
    fail "$file section empty: $heading"
  fi
}

for file in "${targets[@]}"; do
  if [[ ! -f "$file" ]]; then
    fail "missing tracker: $file"
    continue
  fi

  require_heading "$file" "## Goal"
  require_heading "$file" "## Write-set"
  require_heading "$file" "## Risks"
  require_heading "$file" "## Validation command"
  require_heading "$file" "## Evidence/result"

  section_non_empty "$file" "## Write-set"
  section_non_empty "$file" "## Validation command"
done

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "✅ Task trackers validated."
