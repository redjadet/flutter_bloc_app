#!/usr/bin/env bash
# Remind agents/PRs to link a Feature Brief when lib/features/ changes.
# Phase 5 (AI-first plan): fail by default; warning mode is explicit.
#
# Satisfied when any of:
#   - docs/changes/*.md touched in the same diff
#   - SKIP_FEATURE_BRIEF=1
#
# Usage:
#   bash tool/check_feature_brief_linked.sh
#   bash tool/check_feature_brief_linked.sh --base origin/main
#
# Environment:
#   SKIP_FEATURE_BRIEF=1              -> skip (exit 0)
#   FEATURE_BRIEF_CHECK_STRICT=0      -> warn on violation (else fail, exit 1)

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_feature_brief_linked.sh [--base <git-ref>]

When Dart under apps/mobile/lib/features/ changes, require a docs/changes/*.md note in the
same diff (Feature Brief / change log). Fails by default; set
FEATURE_BRIEF_CHECK_STRICT=0 to warn only.
EOF
}

if [[ "${SKIP_FEATURE_BRIEF:-0}" == "1" ]]; then
  echo "skipped-by-policy|feature-brief|SKIP_FEATURE_BRIEF=1"
  exit 0
fi

base_ref=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --base)
      base_ref="${2:-}"
      [[ -n "$base_ref" ]] || {
        echo "usage-error|--base requires a value" >&2
        exit 2
      }
      shift 2
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if [[ -z "$base_ref" ]]; then
  if git rev-parse --verify origin/main &>/dev/null; then
    base_ref="$(git merge-base HEAD origin/main 2>/dev/null || echo origin/main)"
  else
    base_ref="HEAD~1"
  fi
fi

mapfile -t changed < <(
  {
    git diff --name-only "$base_ref"...HEAD 2>/dev/null || true
    git diff --name-only "$base_ref" 2>/dev/null || true
    git diff --name-only --cached 2>/dev/null || true
    git diff --name-only 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | awk 'NF' | sort -u
)

feature_dart=()
change_docs=()
for f in "${changed[@]}"; do
  [[ -z "$f" ]] && continue
  if [[ "$f" == apps/mobile/lib/features/* ]] && [[ "$f" == *.dart ]]; then
    case "$f" in
      *.g.dart|*.freezed.dart|*.gr.dart) continue ;;
    esac
    feature_dart+=("$f")
    continue
  fi
  if [[ "$f" == lib/features/* ]] && [[ "$f" == *.dart ]]; then
    case "$f" in
      *.g.dart|*.freezed.dart|*.gr.dart) continue ;;
    esac
    feature_dart+=("$f")
    continue
  fi
  case "$f" in
    docs/changes/*.md)
      change_docs+=("$f")
      ;;
  esac
done

if [[ ${#feature_dart[@]} -eq 0 ]]; then
  exit 0
fi

if [[ ${#change_docs[@]} -gt 0 ]]; then
  echo "ok|feature-brief|docs/changes touched: ${change_docs[*]}"
  exit 0
fi

msg=$'feature-brief-missing|apps/mobile/lib/features/*.dart changed without docs/changes/*.md\n'
msg+="Changed feature files (${#feature_dart[@]}): ${feature_dart[*]:0:5}"
if [[ ${#feature_dart[@]} -gt 5 ]]; then
  msg+=" ..."
fi
msg+=$'\nAdd a note under docs/changes/ (see docs/engineering/FEATURE_TEMPLATE.md) or set SKIP_FEATURE_BRIEF=1 for trivial fixes.'

if [[ "${FEATURE_BRIEF_CHECK_STRICT:-1}" == "0" ]]; then
  echo "warn|$msg" >&2
  exit 0
fi

echo "$msg" >&2
exit 1
