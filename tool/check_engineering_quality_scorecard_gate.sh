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

array_entry_count() {
  local array_name="$1"
  local path="$2"

  awk -v array_name="$array_name" '
    $0 == array_name "=(" { in_array = 1; next }
    in_array && /^\)/ { print count; exit }
    in_array && /^[[:space:]]*"[^"]+"[[:space:]]*$/ { count++ }
    END {
      if (!in_array) {
        print count
      }
    }
  ' "$path"
}

checklist_scripts_include() {
  local script="$1"

  awk -v expected="\"tool/${script}\"" '
    /^CHECK_SCRIPTS=\(/ { in_scripts = 1; next }
    in_scripts && /^\)/ { exit }
    in_scripts {
      line = $0
      sub(/^[[:space:]]*/, "", line)
      sub(/[[:space:]]*$/, "", line)
      if (line == expected) {
        found = 1
        exit
      }
    }
    END { exit found ? 0 : 1 }
  ' tool/delivery_checklist.sh
}

baseline_promoted_fail_includes() {
  local script="$1"

  awk -v expected="$script" '
    /^- \*\*Promoted fail \(in checklist\):\*\*/ { in_promoted = 1 }
    in_promoted && /^- \*\*/ && $0 !~ /^- \*\*Promoted fail \(in checklist\):\*\*/ { exit }
    in_promoted && index($0, expected) { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$baseline_doc"
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

baseline_doc="docs/engineering/checklist_quality_gates_baseline.md"
require_file "$baseline_doc"
forbid_contains "$baseline_doc" 'Heuristic `check_deferred_heavy_routes` remains **deferred**'
forbid_contains "$baseline_doc" 'CHECK_SCRIPT_THEMES` (59 entries)'
forbid_contains "$baseline_doc" "## Explicitly deferred (not in MVP)"
require_contains "$baseline_doc" "## Post-MVP status (see deferred backlog)"

check_script_count="$(array_entry_count "CHECK_SCRIPTS" "tool/delivery_checklist.sh")"
check_message_count="$(array_entry_count "CHECK_MESSAGES" "tool/delivery_checklist.sh")"
check_theme_count="$(array_entry_count "CHECK_SCRIPT_THEMES" "tool/delivery_checklist.sh")"
if [[ "$check_script_count" -eq 0 || "$check_script_count" != "$check_message_count" || "$check_script_count" != "$check_theme_count" ]]; then
  missing+=("CHECK_SCRIPTS/CHECK_MESSAGES/CHECK_SCRIPT_THEMES counts disagree: $check_script_count/$check_message_count/$check_theme_count")
fi
require_contains "$baseline_doc" "(currently ${check_script_count} each;"

# Fail-wired quality gates must stay in the delivery checklist.
for promoted_fail_script in \
  check_context_read_watch.sh \
  check_deferred_heavy_routes.sh \
  check_lifecycle_observer_dispose.sh \
  check_navigation_outside_presentation.sh \
  check_sync_io_in_presentation.sh \
  check_remote_image_cache_hints.sh \
  check_cubit_subscription_cancel.sh
do
  if ! checklist_scripts_include "$promoted_fail_script"; then
    missing+=("tool/${promoted_fail_script} is not in CHECK_SCRIPTS")
  fi
done

for baseline_promoted_script in \
  check_context_read_watch.sh \
  check_deferred_heavy_routes.sh \
  check_lifecycle_observer_dispose.sh
do
  if ! baseline_promoted_fail_includes "$baseline_promoted_script"; then
    missing+=("$baseline_doc Post-MVP promoted-fail status omits $baseline_promoted_script")
  fi
done

# Rebuild scoping stays report-only until explicitly promoted into CHECK_SCRIPTS.
if awk '
  BEGIN { in_scripts = 0; found = 0 }
  /^CHECK_SCRIPTS=\(/ { in_scripts = 1; next }
  in_scripts && /^\)/ { in_scripts = 0 }
  in_scripts && /check_bloc_rebuild_scoping\.sh/ { found = 1 }
  END { exit found ? 0 : 1 }
' tool/delivery_checklist.sh; then
  missing+=("tool/check_bloc_rebuild_scoping.sh is in CHECK_SCRIPTS but QG-D03 is still open (warn); update deferred backlog + baseline before wiring")
fi

deferred_doc="docs/engineering/checklist_quality_gates_deferred.md"
if [[ -f "$deferred_doc" ]]; then
  if grep -E '\|[[:space:]]*defer[[:space:]]*\|' "$deferred_doc" | grep -q 'QG-D'; then
    missing+=("$deferred_doc has bare defer decision rows (use open (warn)/reject/ADR-deferred)")
  fi
  require_contains "$deferred_doc" "## Open backlog"
  require_contains "$deferred_doc" "**QG-D03**"
  require_contains "$deferred_doc" "**open (warn)**"
  # Fail-wired gates must not remain in the open backlog.
  for stale_open_claim in \
    "check_context_read_watch.sh" \
    "check_deferred_heavy_routes.sh" \
    "check_lifecycle_observer_dispose.sh"
  do
    if awk -v needle="$stale_open_claim" '
      BEGIN { in_open = 0; found = 0 }
      /^## Open backlog/ { in_open = 1; next }
      /^## / { in_open = 0 }
      in_open && index($0, needle) { found = 1 }
      END { exit found ? 0 : 1 }
    ' "$deferred_doc"; then
      missing+=("$deferred_doc open backlog still lists shipped fail gate: $stale_open_claim")
    fi
  done
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
