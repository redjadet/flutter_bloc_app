#!/usr/bin/env bash
# Run Pyright on repo Python: Render FastAPI demo (demos/render_chat_api) and tool/.
# Catches unresolved imports, pyrightconfig mistakes (e.g. venvPath under executionEnvironments),
# and type errors. Uses npx pyright; bootstraps demos/render_chat_api/.venv when missing.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

DEMO_VENV="$PROJECT_ROOT/demos/render_chat_api/.venv"
REQS="$PROJECT_ROOT/demos/render_chat_api/requirements.txt"
DEV_REQS="$PROJECT_ROOT/demos/render_chat_api/requirements-dev.txt"

pick_python() {
  # Prefer a Python >=3.10 runtime. Some demo dependencies (e.g. FastAPI, pytest)
  # no longer publish wheels for older Python versions.
  for candidate in python3.12 python3.11 python3.10 python3; do
    if ! command -v "$candidate" >/dev/null 2>&1; then
      continue
    fi
    if "$candidate" - <<'PY' >/dev/null 2>&1; then
import sys
sys.exit(0 if sys.version_info >= (3, 10) else 1)
PY
      echo "$candidate"
      return 0
    fi
  done

  echo "ERROR: Python >=3.10 is required for demos/render_chat_api dependencies." >&2
  echo "Install Python 3.10+ (or ensure python3 points to 3.10+)." >&2
  exit 1
}

PYTHON_BIN="$(pick_python)"

validate_root_pyrightconfig() {
  "$PYTHON_BIN" <<'PY'
import json
import sys
from pathlib import Path

path = Path("pyrightconfig.json")
if not path.is_file():
    sys.exit(0)
data = json.loads(path.read_text(encoding="utf-8"))
for i, env in enumerate(data.get("executionEnvironments") or []):
    if not isinstance(env, dict):
        continue
    for key in ("venvPath", "venv"):
        if key in env:
            print(
                f"ERROR: pyrightconfig.json has '{key}' inside "
                f"executionEnvironments[{i}]. Move it to the top level; "
                "Pyright ignores nested venv settings and imports break.",
                file=sys.stderr,
            )
            sys.exit(1)
sys.exit(0)
PY
}

ensure_demo_venv() {
  if [ -x "$DEMO_VENV/bin/python" ]; then
    return 0
  fi
  if [ ! -f "$REQS" ]; then
    echo "ERROR: Missing $REQS"
    exit 1
  fi
  echo "INFO: Creating demos/render_chat_api/.venv and installing requirements.txt ..."
  "$PYTHON_BIN" -m venv "$DEMO_VENV"
  "$DEMO_VENV/bin/python" -m pip install -q -U pip setuptools wheel
  "$DEMO_VENV/bin/python" -m pip install -q -r "$REQS"
  if [ -f "$DEV_REQS" ]; then
    "$DEMO_VENV/bin/python" -m pip install -q -r "$DEV_REQS"
  fi
}

echo "Checking Pyright config guard (repo root pyrightconfig.json)..."
validate_root_pyrightconfig

echo "Ensuring Render demo Python venv (for import resolution)..."
ensure_demo_venv

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx not found; install Node.js to run Pyright."
  exit 1
fi

echo "Running npx pyright on demos/render_chat_api and tool/ ..."
if ! npx --yes pyright demos/render_chat_api tool; then
  echo "ERROR: Pyright failed. See demos/render_chat_api/README.md (IDE / Pyright)."
  exit 1
fi

echo "OK: Pyright (Python) — demos/render_chat_api + tool/"
