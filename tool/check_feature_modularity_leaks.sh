#!/usr/bin/env bash
# Fails on known cross-feature import patterns we keep out of library_demo and settings.
# Extend this script when new boundary rules are added to docs/modularity.md.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking feature modularity (library_demo / settings / remote_config boundaries)..."

VIOLATIONS=""

if command -v rg &>/dev/null; then
  V_LIB=$(rg -n "package:flutter_bloc_app/features/scapes/" lib/features/library_demo --glob "*.dart" 2>/dev/null || true)
  V_SET=$(rg -n "package:flutter_bloc_app/features/(graphql_demo|profile|remote_config)/" lib/features/settings --glob "*.dart" 2>/dev/null || true)
  V_RC=$(rg -n "package:flutter_bloc_app/features/settings/" lib/features/remote_config --glob "*.dart" 2>/dev/null || true)
else
  V_LIB=$(grep -Rsn "package:flutter_bloc_app/features/scapes/" lib/features/library_demo --include="*.dart" 2>/dev/null || true)
  V_SET=$(grep -RsnE "package:flutter_bloc_app/features/(graphql_demo|profile|remote_config)/" lib/features/settings --include="*.dart" 2>/dev/null || true)
  V_RC=$(grep -Rsn "package:flutter_bloc_app/features/settings/" lib/features/remote_config --include="*.dart" 2>/dev/null || true)
fi

if [ -n "$V_LIB" ]; then
  VIOLATIONS="${VIOLATIONS}library_demo must not import scapes:
${V_LIB}
"
fi

if [ -n "$V_SET" ]; then
  VIOLATIONS="${VIOLATIONS}settings must not import graphql_demo, profile, or remote_config packages:
${V_SET}
"
fi

if [ -n "$V_RC" ]; then
  VIOLATIONS="${VIOLATIONS}remote_config must not import the settings feature (prefer lib/shared/widgets/):
${V_RC}
"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Feature boundary violations:"
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ No known feature-boundary import leaks"
exit 0
