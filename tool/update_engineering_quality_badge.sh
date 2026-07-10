#!/usr/bin/env bash
# Keep README engineering score badge derived from docs/engineering/engineering_quality_scorecard.md.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/update_engineering_quality_badge.sh [--check]

Derive the visible README engineering badge from docs/engineering/engineering_quality_scorecard.md.
Overall score is the lowest score in the scorecard table; one weak area means
the visible engineering score drops.

Options:
  --check  Fail if README badge is stale instead of updating it.
EOF
}

check_only=0
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--check" ]]; then
  check_only=1
  shift
fi

if (($# > 0)); then
  usage >&2
  exit 2
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

python3 - "$check_only" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

check_only = sys.argv[1] == "1"
scorecard = Path("docs/engineering/engineering_quality_scorecard.md")
readme = Path("README.md")

if not scorecard.exists():
    raise SystemExit(f"missing file: {scorecard}")
if not readme.exists():
    raise SystemExit(f"missing file: {readme}")

scores: list[int] = []
for line in scorecard.read_text(encoding="utf-8").splitlines():
    match = re.match(r"^\|\s*[^|]+\s*\|\s*([0-9]+)\s*/\s*10\s*\|", line)
    if match:
        scores.append(int(match.group(1)))

if not scores:
    raise SystemExit("No engineering scores found in docs/engineering/engineering_quality_scorecard.md")

score = min(scores)
if not 0 <= score <= 10:
    raise SystemExit(f"Invalid engineering score: {score}")

if score == 10:
    color = "brightgreen"
elif score >= 8:
    color = "yellow"
elif score >= 6:
    color = "orange"
else:
    color = "red"

expected = (
    f"[![Engineering score](https://img.shields.io/badge/"
    f"Engineering-{score}%2F10-{color}.svg)](docs/engineering/engineering_quality_scorecard.md)"
)

content = readme.read_text(encoding="utf-8")
pattern = re.compile(
    r"^\[!\[Engineering score\]\(https://img\.shields\.io/badge/"
    r"Engineering-[0-9]+%2F10-[A-Za-z0-9_-]+\.svg\)\]"
    r"\(docs/engineering/engineering_quality_scorecard\.md\)$",
    re.MULTILINE,
)

if pattern.search(content):
    updated = pattern.sub(expected, content, count=1)
else:
    anchor = "[![Harness score](https://img.shields.io/badge/Harness-"
    idx = content.find(anchor)
    if idx == -1:
        raise SystemExit("README.md missing Harness score badge anchor")
    # Insert engineering badge immediately above harness badge for quick disambiguation.
    updated = content.replace(anchor, f"{expected}\n{anchor}", 1)

if updated == content:
    print(f"ok|engineering-score-badge|{score}/10")
    raise SystemExit(0)

if check_only:
    print(
        "stale|engineering-score-badge|README.md does not match "
        f"docs/engineering/engineering_quality_scorecard.md ({score}/10)",
        file=sys.stderr,
    )
    raise SystemExit(1)

readme.write_text(updated, encoding="utf-8")
print(f"updated|engineering-score-badge|{score}/10")
PY

