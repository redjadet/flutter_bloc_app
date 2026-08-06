#!/usr/bin/env bash
# Warn-only: public domain Map<String, dynamic> bags (AP-18).
# Theme: architecture | Severity: warn
# See docs/engineering/flutter-anti-patterns.md AP-18

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
# shellcheck disable=SC1091
source "$TOOL_DIR/check_helpers.sh"

ALLOWLIST_FILE="${DOMAIN_MAP_BAG_ALLOWLIST_FILE:-${WORKSPACE_ROOT}/tool/config/domain_map_bag_allowlist.txt}"
declare -a EXPLICIT_PATHS=()

usage() {
  cat <<'EOF'
Usage: tool/check_domain_map_bags.sh [--paths PATH...]

Warn-only scan for Map<String, dynamic> on feature domain models/contracts.
Exit 0 on findings (warn). Exit non-zero only for script/config errors.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --paths)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        EXPLICIT_PATHS+=("$1")
        shift
      done
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$ALLOWLIST_FILE" ]]; then
  echo "config-error|missing allowlist: $ALLOWLIST_FILE" >&2
  exit 2
fi

declare -A ALLOWED=()
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  IFS='|' read -r path symbol reason <<<"$line"
  path="${path#"${path%%[![:space:]]*}"}"
  path="${path%"${path##*[![:space:]]}"}"
  symbol="${symbol#"${symbol%%[![:space:]]*}"}"
  symbol="${symbol%"${symbol##*[![:space:]]}"}"
  reason="${reason#"${reason%%[![:space:]]*}"}"
  reason="${reason%"${reason##*[![:space:]]}"}"
  if [[ -z "$path" || -z "$symbol" || -z "$reason" ]]; then
    echo "config-error|malformed allowlist line: $line" >&2
    exit 2
  fi
  ALLOWED["$path|$symbol"]=1
done <"$ALLOWLIST_FILE"

declare -a SCAN_ROOTS=()
if [[ ${#EXPLICIT_PATHS[@]} -gt 0 ]]; then
  for p in "${EXPLICIT_PATHS[@]}"; do
    SCAN_ROOTS+=("$(resolve_scan_root "$p")")
  done
else
  SCAN_ROOTS+=("$APP_ROOT/lib/features")
fi

echo "🔍 Checking domain Map bags (warn-only)..."

hits=0
while IFS= read -r match; do
  [[ -z "$match" ]] && continue
  file="${match%%:*}"
  rest="${match#*:}"
  lineno="${rest%%:*}"
  content="${rest#*:}"

  # Prefer path relative to APP_ROOT (apps/mobile) for allowlist keys.
  rel="$file"
  if [[ "$file" == "$APP_ROOT/"* ]]; then
    rel="${file#"$APP_ROOT"/}"
  elif [[ "$file" == "$WORKSPACE_ROOT/"* ]]; then
    # Fixture under workspace: keep workspace-relative for display; not allowlisted.
    rel="${file#"$WORKSPACE_ROOT"/}"
  fi

  # Skip generated sources when scanning the live tree.
  case "$rel" in
    *.freezed.dart|*.g.dart) continue ;;
  esac

  symbol=""
  # Name after Map<String, dynamic> (field / ctor param / method signature),
  # else this.name. The optional ? belongs to Map itself, e.g.
  # Future<Map<String, dynamic>?> loadMessage(...).
  symbol="$(sed -n 's/.*Map[[:space:]]*<[[:space:]]*String[[:space:]]*,[[:space:]]*dynamic[[:space:]]*>[[:space:]]*[?]\{0,1\}[[:space:]]*[>]*[[:space:]]*\([A-Za-z_][A-Za-z0-9_]*\).*/\1/p' <<<"$content" | head -1)"
  if [[ -z "$symbol" && "$content" == *'this.'* ]]; then
    symbol="$(sed -n 's/.*this\.\([A-Za-z_][A-Za-z0-9_]*\).*/\1/p' <<<"$content" | head -1)"
  fi

  # This is a public API guard, not a ban on implementation locals. Domain
  # member declarations and method signatures are normally class-indented by
  # two spaces; wrapped constructor parameters can be further indented but
  # retain `required` or `this.`. Skip private symbols and ordinary locals.
  indentation="${content%%[^[:space:]]*}"
  if [[ "$symbol" == _* ]] || {
    (( ${#indentation} > 2 )) &&
      [[ "$content" != *'required '* && "$content" != *'this.'* ]]
  }; then
    continue
  fi

  key="$rel|$symbol"
  if [[ -n "$symbol" && -n "${ALLOWED[$key]:-}" ]]; then
    continue
  fi

  echo "⚠️  $rel:$lineno: domain Map bag ($symbol) — $content"
  hits=$((hits + 1))
done < <(
  for root in "${SCAN_ROOTS[@]}"; do
    if [[ -f "$root" ]]; then
      rg -n --with-filename --glob '!*.freezed.dart' --glob '!*.g.dart' \
        'Map[[:space:]]*<[[:space:]]*String[[:space:]]*,[[:space:]]*dynamic[[:space:]]*>' \
        "$root" 2>/dev/null || true
    elif [[ -d "$root" ]]; then
      rg -n --with-filename --glob '**/domain/**/*.dart' --glob '!*.freezed.dart' --glob '!*.g.dart' \
        'Map[[:space:]]*<[[:space:]]*String[[:space:]]*,[[:space:]]*dynamic[[:space:]]*>' \
        "$root" 2>/dev/null || true
    fi
  done
)

if [[ "$hits" -eq 0 ]]; then
  echo "✅ ok|domain-map-bags|violations=0"
  exit 0
fi

echo "⚠️  warn|domain-map-bags|violations=$hits"
exit 0
