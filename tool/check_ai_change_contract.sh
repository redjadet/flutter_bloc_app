#!/usr/bin/env bash
# Diff-scoped AI change contract for feature/app/package edits.
# Usage: bash tool/check_ai_change_contract.sh [--base <git-ref>]

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

usage() {
  cat <<'EOF'
Usage: bash tool/check_ai_change_contract.sh [--base <git-ref>] [--self-test]

When diffs touch apps/mobile/lib/features, apps/mobile/lib/app, or packages:
- delegates to feature brief, folder contract, and clean-architecture guards
- requires a test path under apps/mobile/test/ or explicit Tests: N/A in a
  linked docs/changes note for changed features

Docs-only diffs (no apps/mobile or packages paths) exit 0.

Options:
  --self-test  Run built-in fixture cases (harness)
EOF
}

validate_feature_test_coverage() {
  local -n _changed_ref=$1
  local -n _changed_features_ref=$2
  local -n _change_docs_ref=$3

  for feature in "${!_changed_features_ref[@]}"; do
    local barrel="apps/mobile/lib/features/${feature}/${feature}.dart"
    local alt_barrel="apps/mobile/lib/features/${feature}/features.dart"
    if [[ ! -f "$barrel" && ! -f "$alt_barrel" ]]; then
      if ! find "apps/mobile/lib/features/${feature}" -maxdepth 2 -name '*.dart' | grep -q .; then
        fail "changed feature missing dart entrypoints: $feature"
      fi
    fi

    local has_test=false
    local f
    for f in "${_changed_ref[@]}"; do
      if [[ "$f" == apps/mobile/test/features/${feature}/* ]]; then
        has_test=true
        break
      fi
    done

    if [[ "$has_test" == false ]]; then
      local tests_na=false
      local doc
      for doc in "${_change_docs_ref[@]}"; do
        if grep -qiE 'Tests:[[:space:]]*N/A' "$doc"; then
          tests_na=true
          break
        fi
      done
      if [[ "$tests_na" == false ]]; then
        fail "feature '$feature' changed without test path or Tests: N/A in docs/changes"
      fi
    fi
  done
}

run_self_test() {
  local failures=0
  fail_local() {
    echo "❌ self-test: $*" >&2
    failures=1
  }

  local -a docs_only=( "docs/feature_overview.md" )
  local docs_only_flag=true
  local f
  for f in "${docs_only[@]}"; do
    case "$f" in
      apps/mobile/*|packages/*) docs_only_flag=false ;;
    esac
  done
  if [[ "$docs_only_flag" != true ]]; then
    fail_local "docs-only fixture misconfigured"
  fi

  local -a feature_changed=(
    "apps/mobile/lib/features/counter/presentation/pages/counter_page.dart"
  )
  declare -A feature_map=([counter]=1)
  local -a empty_docs=()
  failures=0
  fail() { fail_local "$*"; }
  validate_feature_test_coverage feature_changed feature_map empty_docs
  if [[ "$failures" -eq 0 ]]; then
    fail_local "expected missing-test fixture to fail"
  else
    failures=0
  fi

  local -a with_test=(
    "apps/mobile/lib/features/counter/presentation/pages/counter_page.dart"
    "apps/mobile/test/features/counter/presentation/pages/counter_page_test.dart"
  )
  declare -A with_test_map=([counter]=1)
  validate_feature_test_coverage with_test with_test_map empty_docs
  if [[ "$failures" -ne 0 ]]; then
    exit 1
  fi

  echo "✅ AI change contract self-test passed."
  exit 0
}

base_ref=""
self_test=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --self-test)
      self_test=true
      shift
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

if [[ "$self_test" == true ]]; then
  run_self_test
fi

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

if [[ "${#changed[@]}" -eq 0 ]]; then
  echo "✅ AI change contract: no changed files."
  exit 0
fi

has_code_paths=false
docs_only=true
declare -A changed_features=()

for f in "${changed[@]}"; do
  [[ -z "$f" ]] && continue
  case "$f" in
    apps/mobile/lib/features/*|apps/mobile/lib/app/*|packages/*)
      has_code_paths=true
      docs_only=false
      ;;
    docs/*)
      ;;
    *)
      docs_only=false
      ;;
  esac

  if [[ "$f" =~ ^apps/mobile/lib/features/([^/]+)/ ]]; then
    changed_features["${BASH_REMATCH[1]}"]=1
  fi
done

if [[ "$docs_only" == true ]]; then
  echo "✅ AI change contract: docs-only diff."
  exit 0
fi

if [[ "$has_code_paths" != true ]]; then
  echo "✅ AI change contract: no feature/app/package paths."
  exit 0
fi

failures=0
fail() {
  echo "❌ $*" >&2
  failures=1
}

declare -a changed_dart=()
for f in "${changed[@]}"; do
  [[ "$f" == *.dart ]] || continue
  case "$f" in
    apps/mobile/lib/features/*|apps/mobile/lib/app/*|packages/*)
      case "$f" in
        *.g.dart|*.freezed.dart|*.gr.dart) continue ;;
      esac
      changed_dart+=("$f")
      ;;
  esac
done

if [[ ${#changed_dart[@]} -gt 0 ]]; then
  if ! bash tool/check_feature_brief_linked.sh --base "$base_ref"; then
    fail "feature brief link check failed"
  fi
  if ! bash tool/check_feature_folder_contract.sh --paths "${changed_dart[@]}"; then
    fail "feature folder contract failed"
  fi
  if ! bash tool/check_clean_architecture_imports.sh --paths "${changed_dart[@]}"; then
    fail "clean architecture imports failed"
  fi
fi

declare -a change_docs=()
for f in "${changed[@]}"; do
  case "$f" in
    docs/changes/*.md) change_docs+=("$f") ;;
  esac
done

validate_feature_test_coverage changed changed_features change_docs

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "✅ AI change contract checks passed."
