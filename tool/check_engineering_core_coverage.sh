#!/usr/bin/env bash
# Enforce a minimum aggregate coverage for the app shell critical paths
# (bootstrap/DI/router), normalized to `lib/app/...` in LCOV.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_engineering_core_coverage.sh [--min <percent>]

Reads coverage/lcov.info and enforces an aggregate line coverage floor for the
app shell critical paths:

- `lib/app/bootstrap/`
- `lib/app/composition/`
- `lib/app/router/`

Exit codes:
  0  OK (>= min)
  1  Below min
  2  Missing lcov file
EOF
}

min_pct="75"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --min)
      min_pct="${2:-}"
      shift 2
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if [[ ! -f coverage/lcov.info ]]; then
  echo "missing|core-coverage|coverage/lcov.info not found (run coverage-producing tests first)" >&2
  exit 2
fi

python3 - "$min_pct" <<'PY'
from __future__ import annotations

import sys

min_pct = float(sys.argv[1])

core_found = 0
core_hit = 0

current = None
lf = None
lh = None

def finish_record():
    global core_found, core_hit, current, lf, lh
    if current is None:
        return
    if (
        current.startswith("lib/app/bootstrap/")
        or current.startswith("lib/app/composition/")
        or current.startswith("lib/app/router/")
    ):
        # Treat LF/LH absent as 0.
        core_found += int(lf or 0)
        core_hit += int(lh or 0)
    current = None
    lf = None
    lh = None

with open("coverage/lcov.info", "r", encoding="utf-8") as f:
    for raw in f:
        line = raw.strip()
        if line.startswith("SF:"):
            finish_record()
            path = line[3:]
            # Normalize common prefixes so we can match reliably.
            path = path.replace("\\\\", "/")
            if "/lib/" in path:
                path = path.split("/lib/", 1)[1]
                path = "lib/" + path
            current = path
        elif line.startswith("LF:"):
            lf = int(line[3:])
        elif line.startswith("LH:"):
            lh = int(line[3:])
        elif line == "end_of_record":
            finish_record()

finish_record()

if core_found == 0:
    print(
        "error|core-coverage|No records found under app shell paths "
        "(lib/app/bootstrap|composition|router) in coverage/lcov.info",
        file=sys.stderr,
    )
    raise SystemExit(1)

pct = 100.0 if core_found == 0 else (core_hit / core_found) * 100.0
if pct + 1e-9 < min_pct:
    print(f"fail|core-coverage|{pct:.2f}% < {min_pct:.0f}% ({core_hit}/{core_found} lines)", file=sys.stderr)
    raise SystemExit(1)

print(f"ok|core-coverage|{pct:.2f}% >= {min_pct:.0f}% ({core_hit}/{core_found} lines)")
PY

