#!/usr/bin/env bash
# Feature modularity and domain purity gates. See docs/modularity.md.
# - Declarative cross-feature rules (library_demo / settings / remote_config)
# - Universal: lib/shared must not import features
# - Universal: lib/features/*/domain must not import infra / app / DI / other layers
#
# Feature-to-feature default-deny is reported via tool/modular_metrics.sh --cross-feature-only;
# promote to failing here only after exceptions are documented (Phase 1B).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Feature modularity + domain purity checks..."

VIOLATIONS=""
DOMAIN_GLOBS=(lib/features --glob "*/domain/**/*.dart" --glob "!**/*.g.dart" --glob "!**/*.freezed.dart" --glob "!**/*.gr.dart")

append_block() {
  local title=$1
  local body=$2
  if [[ -n "$body" ]]; then
    VIOLATIONS+=$'\n'"=== ${title} ==="$'\n'"${body}"$'\n'
  fi
}

# --- Declarative known rules: PATH_PREFIX|PATTERN|HUMAN_LABEL ---
KNOWN_RULES=$'lib/features/library_demo|package:flutter_bloc_app/features/scapes/|library_demo must not import scapes\nlib/features/settings|package:flutter_bloc_app/features/(graphql_demo|profile|remote_config)/|settings must not import graphql_demo, profile, or remote_config\nlib/features/remote_config|package:flutter_bloc_app/features/settings/|remote_config must not import settings (use lib/shared/widgets/)'

if command -v rg &>/dev/null; then
  while IFS='|' read -r dir pattern label; do
    [[ -z "$dir" || "$dir" =~ ^# ]] && continue
    hits=$(rg -n "$pattern" "$dir" --glob "*.dart" 2>/dev/null || true)
    append_block "$label" "$hits"
  done <<< "$KNOWN_RULES"

  hits=$(rg -n "package:flutter_bloc_app/features/" lib/shared --glob "*.dart" 2>/dev/null || true)
  append_block "lib/shared must not import package:flutter_bloc_app/features/*" "$hits"

  domain_forbidden=(
    "^import ['\\\"]package:flutter/"
    "^import ['\\\"]package:get_it/"
    "^import ['\\\"]package:hive/"
    "^import ['\\\"]package:supabase"
    "^import ['\\\"]package:dio/"
    "^import ['\\\"]package:retrofit/"
    "^import ['\\\"]package:flutter_bloc_app/app/"
    "^import ['\\\"]package:flutter_bloc_app/core/di/"
    "^import ['\\\"]package:flutter_bloc_app/features/[^'\\\"]+/(presentation|data)/"
  )
  domain_msgs=(
    "Domain: Flutter imports (use pure Dart in domain)"
    "Domain: get_it imports"
    "Domain: hive imports"
    "Domain: supabase imports"
    "Domain: dio imports"
    "Domain: retrofit imports"
    "Domain: app/ imports"
    "Domain: core/di imports"
    "Domain: imports of feature presentation/ or data/ layers"
  )
  for i in "${!domain_forbidden[@]}"; do
    pat="${domain_forbidden[$i]}"
    msg="${domain_msgs[$i]}"
    hits=$(rg -n "$pat" "${DOMAIN_GLOBS[@]}" 2>/dev/null || true)
    append_block "$msg" "$hits"
  done
else
  while IFS='|' read -r dir pattern label; do
    [[ -z "$dir" || "$dir" =~ ^# ]] && continue
    case "$pattern" in
      *scapes*)
        hits=$(grep -Rsn "package:flutter_bloc_app/features/scapes/" "$dir" --include="*.dart" 2>/dev/null || true)
        ;;
      *graphql_demo*)
        hits=$(grep -RsnE "package:flutter_bloc_app/features/(graphql_demo|profile|remote_config)/" "$dir" --include="*.dart" 2>/dev/null || true)
        ;;
      *)
        hits=$(grep -Rsn "package:flutter_bloc_app/features/settings/" "$dir" --include="*.dart" 2>/dev/null || true)
        ;;
    esac
    append_block "$label" "$hits"
  done <<< "$KNOWN_RULES"

  hits=$(grep -Rsn "package:flutter_bloc_app/features/" lib/shared --include="*.dart" 2>/dev/null || true)
  append_block "lib/shared must not import package:flutter_bloc_app/features/*" "$hits"

  echo "⚠️  ripgrep not found: skipping automated domain import patterns (install rg or rely on CI)."
fi

if [[ -n "$VIOLATIONS" ]]; then
  echo "❌ Modularity / domain purity violations:"
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ No modularity or domain-purity violations"
exit 0
