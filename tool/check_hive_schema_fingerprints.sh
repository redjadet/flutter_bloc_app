#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

dart run tool/generate_hive_schema_fingerprints.dart --check-generated

# Optional: enforce that listed input files didn't change since last generation.
# This is intentionally opt-in to avoid CI churn on harmless diffs.
if [[ "${HIVE_SCHEMA_ENFORCE_INPUTS:-}" == "true" ]]; then
  dart run tool/generate_hive_schema_fingerprints.dart --check-inputs --enforce-inputs
else
  dart run tool/generate_hive_schema_fingerprints.dart --check-inputs
fi
dart run tool/generate_hive_schema_fingerprints.dart --check-inputs

if [[ "${HIVE_SCHEMA_ENFORCE_INPUTS:-false}" == "true" ]]; then
  dart run tool/generate_hive_schema_fingerprints.dart \
    --check-inputs \
    --enforce-inputs
fi
