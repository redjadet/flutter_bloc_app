#!/usr/bin/env bash
# Static + measured gate for Engineering scorecard claims.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_engineering_quality_scorecard_gate.sh [--skip-coverage-proof]

Validate that the Engineering Quality scorecard owners, proof gates, and high-use
agent docs stay wired together. When Coverage is scored 10/10, also enforce
filtered ≥85% and app-shell ≥75% against coverage/lcov.info (if present).

Options:
  --skip-coverage-proof  Skip measured coverage proofs (docs/wiring only).
EOF
}

skip_coverage_proof=0
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--skip-coverage-proof" ]]; then
  skip_coverage_proof=1
  shift
fi

if (($# > 0)); then
  usage >&2
  exit 2
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

missing=()

require_file() {
  local path="$1"
  [[ -f "$path" ]] || missing+=("missing file: $path")
}

require_contains() {
  local path="$1"
  local needle="$2"
  if [[ ! -f "$path" ]]; then
    missing+=("missing file: $path")
    return
  fi
  if ! grep -qF -- "$needle" "$path"; then
    missing+=("$path missing: $needle")
  fi
}

forbid_contains() {
  local path="$1"
  local needle="$2"
  if [[ -f "$path" ]] && grep -qF -- "$needle" "$path"; then
    missing+=("$path still contains stale claim: $needle")
  fi
}

area_score() {
  local area="$1"
  local line
  line="$(
    grep -E "^\|[[:space:]]*${area}[[:space:]]*\|[[:space:]]*[0-9]+[[:space:]]*/[[:space:]]*10[[:space:]]*\|" \
      "docs/engineering/engineering_quality_scorecard.md" \
      | head -n 1 || true
  )"
  if [[ -z "$line" ]]; then
    echo ""
    return
  fi
  echo "$line" | sed -E 's/^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([0-9]+)[[:space:]]*\/[[:space:]]*10[[:space:]]*\|.*/\1/'
}

require_file "docs/engineering/engineering_quality_scorecard.md"
require_file "tool/update_engineering_quality_badge.sh"
require_file "tool/check_engineering_core_coverage.sh"
require_file "tool/check_engineering_quality_scorecard_gate.sh"

require_contains "AGENTS.md" "docs/engineering/engineering_quality_scorecard.md"
require_contains "README.md" "Engineering score"
require_contains "README.md" "docs/engineering/engineering_quality_scorecard.md"
require_contains "README.md" "Do not conflate"
require_contains "docs/CODE_QUALITY.md" "engineering_quality_scorecard"
require_contains "docs/ai/context_loading.md" "engineering_quality_scorecard"
require_contains "docs/ai/ai_failure_risks.md" "RISK-ENGINEERING-SCORE-DROP"
require_contains "tool/agent_maintain.sh" "engineering-maintain"
require_contains "tool/agent_maintain.sh" "scope_has_engineering_edits"
require_contains "tool/delivery_checklist.sh" "check_engineering_quality_scorecard_gate.sh"
require_contains "docs/agents_quick_reference.md" "Engineering max-score claim"

require_contains "docs/engineering/engineering_quality_scorecard.md" "## Scoring rule"
require_contains "docs/engineering/engineering_quality_scorecard.md" "## Areas"
require_contains "docs/engineering/engineering_quality_scorecard.md" "## Exceptions"
require_contains "docs/engineering/engineering_quality_scorecard.md" "## Claim Gate"
require_contains "docs/engineering/engineering_quality_scorecard.md" "## Proof Commands"
require_contains "docs/engineering/engineering_quality_scorecard.md" "## Out of Scope"

forbid_contains "docs/interview_showcase.md" "~399 tests"
forbid_contains "docs/interview_showcase.md" "60% gate"
forbid_contains "docs/CODE_QUALITY.md" "aggregate ~65% coverage"

deferred_doc="docs/engineering/checklist_quality_gates_deferred.md"
if [[ -f "$deferred_doc" ]]; then
  if grep -E '\|[[:space:]]*defer[[:space:]]*\|' "$deferred_doc" | grep -q 'QG-D'; then
    missing+=("$deferred_doc has bare defer decision rows (use promoted/reject/ADR-deferred)")
  fi
else
  missing+=("missing file: $deferred_doc")
fi

require_file "tool/check_context_read_watch.sh"
if ((${#missing[@]} > 0)); then
  echo "❌ Engineering scorecard gate failed:" >&2
  printf '  - %s\n' "${missing[@]}" >&2
  exit 1
fi

bash "$repo_root/tool/update_engineering_quality_badge.sh" --check >/dev/null

coverage_score="$(area_score "Coverage")"
if [[ "$skip_coverage_proof" -eq 0 && "$coverage_score" == "10" ]]; then
  if [[ ! -f "coverage/lcov.info" ]]; then
    echo "❌ Engineering Coverage is 10/10 but coverage/lcov.info is missing." >&2
    echo "   Run bash tool/test_coverage.sh (or ./bin/checklist) before claiming Coverage." >&2
    exit 1
  fi
  echo "Engineering Coverage=10/10 → enforcing filtered ≥85% + app-shell ≥75%..."
  COVERAGE_THRESHOLD=85 dart run tool/update_coverage_summary.dart --enforce-threshold
  bash "$repo_root/tool/check_engineering_core_coverage.sh"
fi

echo "✅ Engineering scorecard gate passed"
