#!/usr/bin/env bash
# Validate the root DESIGN.md file with Google's design.md CLI.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f DESIGN.md ]]; then
  echo "missing DESIGN.md at repo root" >&2
  exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required to run @google/design.md lint" >&2
  exit 1
fi

echo "Running @google/design.md lint..."
npx --yes @google/design.md lint DESIGN.md
