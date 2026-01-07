#!/usr/bin/env bash
# Check for missing localization keys across ARB files.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for missing localization keys across ARB files..."

python3 - <<'PY'
import glob
import json
import os
import sys

arb_files = sorted(glob.glob(os.path.join("lib", "l10n", "app_*.arb")))
if not arb_files:
    print("ℹ️  No ARB files found in lib/l10n")
    sys.exit(0)

def load_keys(path):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return {k for k in data.keys() if not k.startswith("@")}

reference_path = next((p for p in arb_files if p.endswith("app_en.arb")), arb_files[0])
reference_keys = load_keys(reference_path)

violations = []

for path in arb_files:
    keys = load_keys(path)
    missing = sorted(reference_keys - keys)
    extra = sorted(keys - reference_keys)
    if missing:
        violations.append((path, "missing", missing))
    if extra:
        violations.append((path, "extra", extra))

if violations:
    print("❌ Localization key mismatch detected:")
    for path, kind, keys in violations:
        rel = os.path.relpath(path)
        print(f"- {rel}: {kind} keys ({len(keys)})")
        for key in keys:
            print(f"  - {key}")
    sys.exit(1)

print("✅ Localization keys are consistent across ARB files")
PY
