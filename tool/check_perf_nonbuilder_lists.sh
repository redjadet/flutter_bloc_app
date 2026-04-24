#!/usr/bin/env bash
# Check for likely dynamic ListView/GridView children (eager build) in presentation.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for dynamic non-builder ListView/GridView in presentation..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

FILES=""
if command -v rg &> /dev/null; then
  FILES=$(rg --files lib/features \
    --glob "*/presentation/**" \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  FILES=$(find lib/features -type f -name "*.dart" -path "*/presentation/*" 2>/dev/null || true)
fi

VIOLATIONS=$(FILES_FOR_CHECK="$FILES" python3 - "$PROJECT_ROOT" <<'PY'
from __future__ import annotations

import re
import sys
import os
from pathlib import Path

root = Path(sys.argv[1])
files = [
    line.strip()
    for line in os.environ.get("FILES_FOR_CHECK", "").splitlines()
    if line.strip()
]


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def extract_call(text: str, start: int) -> str | None:
    open_index = text.find("(", start)
    if open_index < 0:
        return None

    depth = 0
    for index in range(open_index, len(text)):
        char = text[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return text[start : index + 1]
    return None


def children_expression(call: str) -> str | None:
    match = re.search(r"\bchildren\s*:", call)
    if not match:
        return None
    expr = call[match.end() :]
    # Good enough for a guardrail: inspect only the children argument area.
    return expr.split("\n),", 1)[0]


constructors = ("ListView(", "GridView(")
builder_markers = (
    "ListView.builder(",
    "ListView.separated(",
    "ListView.custom(",
    "GridView.builder(",
    "GridView.custom(",
)

for relative in files:
    path = root / relative
    text = path.read_text()
    for constructor in constructors:
        search_from = 0
        while True:
            start = text.find(constructor, search_from)
            if start < 0:
                break
            search_from = start + len(constructor)
            if any(text.startswith(marker, start) for marker in builder_markers):
                continue
            call = extract_call(text, start)
            if call is None:
                continue
            expr = children_expression(call)
            if expr is None:
                continue
            stripped = expr.lstrip()
            if re.match(r"^(?:const\s+)?(?:<[^>]+>\s*)?\[", stripped):
                continue
            if (
                ".map(" in stripped
                or stripped.startswith("List.generate(")
                or stripped.startswith("Iterable.generate(")
            ):
                print(
                    f"{relative}:{line_number(text, start)}: "
                    "dynamic ListView/GridView children eagerly build rows"
                )
PY
)

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Potential perf issue: dynamic non-builder ListView/GridView children"
  echo "$VIOLATIONS"
  echo "Prefer builder-based lists for large or dynamic data sets; small static/prebuilt section lists may use children for stable identity."
  exit 1
else
  echo "✅ No dynamic non-builder ListView/GridView usage detected"
  exit 0
fi
