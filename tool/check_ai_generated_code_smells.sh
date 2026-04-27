#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_ai_generated_code_smells.sh [--paths <file>...] [--base <git-ref>]

High-signal scan for common AI-generated-code risk patterns.
Not a full linter. Goal: catch obvious foot-guns early with low noise.

Checks (heuristic, best-effort):
- secret-looking literals (e.g. sk-..., AKIA..., private key blocks)
- swallowed/broad exceptions (empty catch / except Exception: pass)
- obvious SQL string interpolation (SELECT/INSERT/UPDATE/DELETE + concatenation/interpolation)
- risky auth flags in server code (e.g. verify_jwt = false)

Limitations (intentional):
- `verify_jwt = false` is only enforced via TOML sections (e.g. `supabase/config.toml` `[functions.<name>]`).
  It does not detect equivalent behavior in deploy CLI flags, scripts, docs, or MCP payloads unless those
  surfaces are added explicitly.

Allowlist:
  Add `check-ignore: <reason>` on same line or the line above.
  Reason required (non-empty).

Exit codes:
  0 pass (or only ignored findings)
  1 findings
  2 usage error
EOF
}

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

add_target_if_exists() {
  local p="$1"
  if [[ "$p" == /* ]]; then
    p="${p#$repo_root/}"
  fi
  if [[ -f "$p" ]]; then
    targets+=("$p")
  fi
}

is_scannable() {
  case "$1" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.dart|*.toml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

should_auto_include_path() {
  local p="$1"

  # Skip fixtures by default; fixture harness passes explicit --paths.
  case "$p" in
    tool/fixtures/*)
      return 1
      ;;
  esac

  # Always allow the Supabase function config surface.
  if [[ "$p" == "supabase/config.toml" ]]; then
    return 0
  fi

  return 0
}

collect_changed_files_default() {
  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  {
    git diff --name-only --diff-filter=ACMRTUXB
    git diff --cached --name-only --diff-filter=ACMRTUXB
    git ls-files --others --exclude-standard
  } | sort -u | sed '/^$/d'
}

if [[ "${#explicit_paths[@]}" -gt 0 ]]; then
  for p in "${explicit_paths[@]}"; do
    add_target_if_exists "$p"
  done
elif [[ -n "$base_ref" ]]; then
  if ! git rev-parse "$base_ref" >/dev/null 2>&1; then
    echo "usage-error|invalid base ref: $base_ref" >&2
    exit 2
  fi
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    if is_scannable "$p"; then
      add_target_if_exists "$p"
    fi
  done < <(git diff --name-only "$base_ref...HEAD" --diff-filter=ACMRTUXB | sed '/^$/d')
else
  # Default: scan changed files (unstaged + staged + untracked), but keep scope tight.
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    if ! should_auto_include_path "$p"; then
      continue
    fi
    if is_scannable "$p"; then
      add_target_if_exists "$p"
    fi
  done < <(collect_changed_files_default)
fi

if [[ "${#targets[@]}" -eq 0 ]]; then
  echo "ai-smells|no-targets"
  exit 0
fi

# shellcheck disable=SC1091
source "$repo_root/tool/check_helpers.sh"

findings=""

emit_finding() {
  local file="$1"
  local line="$2"
  local rule="$3"
  local msg="$4"
  findings+="${file}:${line}:${rule}:${msg}"$'\n'
}

scan_file() {
  local file="$1"

  if [[ "$file" == *.toml ]]; then
    scan_supabase_config_toml "$file"
    return 0
  fi

  local line_no=0
  local prev=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))

    # Secret-looking literals.
    if [[ "$line" =~ sk-[A-Za-z0-9_=-]{20,} ]] || [[ "$line" =~ AKIA[0-9A-Z]{16} ]] || [[ "$line" =~ ASIA[0-9A-Z]{16} ]] || [[ "$line" =~ -----BEGIN[[:space:]]PRIVATE[[:space:]]KEY----- ]]; then
      emit_finding "$file" "$line_no" "secret_literal" "secret-looking literal"
    fi

    # Swallowed exceptions (very obvious). Broad catches that handle/log/return
    # intentionally are left to review gate; this helper should stay low-noise.
    if [[ "$file" == *.py ]]; then
      if [[ "$prev" =~ ^[[:space:]]*except[[:space:]]+Exception[[:space:]]*:([[:space:]]*)$ ]] && [[ "$line" =~ ^[[:space:]]*pass([[:space:]]*#.*)?$ ]]; then
        emit_finding "$file" "$line_no" "swallowed_exception" "except Exception: pass"
      fi
    fi

    if [[ "$file" == *.ts || "$file" == *.js || "$file" == *.tsx || "$file" == *.jsx ]]; then
      if [[ "$line" =~ catch[[:space:]]*\(.*\)[[:space:]]*\{[[:space:]]*\} ]]; then
        emit_finding "$file" "$line_no" "swallowed_exception" "empty catch block"
      fi
    fi

    # Obvious SQL string concatenation/interpolation.
    if [[ "$line" =~ (SELECT|INSERT|UPDATE|DELETE) ]]; then
      if [[ "$line" == *'${'* ]] || [[ "$line" == *"'"*"+"* ]] || [[ "$line" == *'"'*"+"* ]]; then
        emit_finding "$file" "$line_no" "sql_string_interp" "SQL string interpolation/concatenation"
      fi
    fi

    # Risky auth flags.
    if [[ "$line" =~ verify_jwt[[:space:]]*=[[:space:]]*false ]]; then
      emit_finding "$file" "$line_no" "verify_jwt_false" "verify_jwt disabled"
    fi

    prev="$line"
  done <"$file"
}

scan_supabase_config_toml() {
  local file="$1"
  local line_no=0
  local current_function=""

  # Allowed public sync functions that intentionally run with verify_jwt=false.
  # Keep list small and explicit.
  local -r allowed_public_verify_jwt_false_csv="sync-graphql-countries,sync-chart-trending"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))

    if [[ "$line" =~ ^[[:space:]]*\[functions\.([a-zA-Z0-9_-]+)\][[:space:]]*$ ]]; then
      current_function="${BASH_REMATCH[1]}"
      continue
    fi

    # Only consider verify_jwt inside a function section.
    if [[ -z "$current_function" ]]; then
      continue
    fi

    if [[ "$line" =~ ^[[:space:]]*verify_jwt[[:space:]]*=[[:space:]]*false[[:space:]]*$ ]]; then
      case ",$allowed_public_verify_jwt_false_csv," in
        *",$current_function,"*)
          # allowed (public sync surfaces); rely on RLS / table policy
          ;;
        *)
          emit_finding "$file" "$line_no" "verify_jwt_false" "verify_jwt disabled for functions.$current_function"
          ;;
      esac
    fi
  done <"$file"
}

for f in "${targets[@]}"; do
  scan_file "$f"
done

if [[ -z "$findings" ]]; then
  echo "ai-smells|ok"
  exit 0
fi

filtered="$(filter_ignored "$findings")"
if [[ -n "${IGNORED:-}" ]]; then
  if [[ "$IGNORED" == *"reason: no reason provided"* ]]; then
    echo "violation|tool/check_helpers.sh:0:ignore_reason_required:check-ignore requires a non-empty reason" >&2
    exit 1
  fi
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    echo "ignored|$line"
  done <<< "${IGNORED%$'\n'}"
fi

if [[ -z "$filtered" ]]; then
  echo "ai-smells|ok|ignored-only"
  exit 0
fi

while IFS= read -r line; do
  [[ -n "$line" ]] || continue
  echo "violation|$line"
done <<< "${filtered%$'\n'}"

exit 1
