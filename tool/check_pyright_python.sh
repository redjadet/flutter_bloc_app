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
PYRIGHT_MODE="${CHECK_PYRIGHT_PYTHON_MODE:-always}"

should_run_pyright_auto() {
  local file

  if [ -n "${CI:-}" ]; then
    return 0
  fi

  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  local -a changed_files=()
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    changed_files+=("$file")
  done < <(
    {
      git diff --name-only --diff-filter=ACMRTUXB
      git diff --cached --name-only --diff-filter=ACMRTUXB
      git ls-files --others --exclude-standard
    } | sort -u | sed '/^$/d'
  )

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  for file in "${changed_files[@]}"; do
    case "$file" in
      demos/render_chat_api/*|\
      tool/*.py|\
      pyrightconfig.json|\
      demos/render_chat_api/requirements*.txt)
        return 0
        ;;
    esac
  done

  return 1
}

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

case "$PYRIGHT_MODE" in
  always)
    ;;
  auto)
    if ! should_run_pyright_auto; then
      echo "Skipping Pyright (no Python-related local changes; override with CHECK_PYRIGHT_PYTHON_MODE=always)"
      exit 0
    fi
    ;;
  *)
    echo "ERROR: Invalid CHECK_PYRIGHT_PYTHON_MODE='$PYRIGHT_MODE' (expected always or auto)." >&2
    exit 1
    ;;
esac

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

python_supports_demo_venv() {
  "$1" - <<'PY' >/dev/null 2>&1
import sys
sys.exit(0 if sys.version_info >= (3, 10) else 1)
PY
}

find_demo_venv_python() {
  local expected_version="${1:-}"
  local candidate
  local -a candidates=()

  if [ -n "$expected_version" ]; then
    candidates+=("$DEMO_VENV/bin/python$expected_version")
  fi
  candidates+=("$DEMO_VENV/bin/python3" "$DEMO_VENV/bin/python")

  for candidate in "${candidates[@]}"; do
    if [ -x "$candidate" ] || [ -L "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

ensure_demo_venv() {
  local existing_python=""
  existing_python="$(find_demo_venv_python || true)"

  if [ -n "$existing_python" ]; then
    if python_supports_demo_venv "$existing_python"; then
      return 0
    fi

    echo "INFO: Existing venv python is not runnable or is older than 3.10; recreating $DEMO_VENV ..."
    rm -rf "$DEMO_VENV"
  fi
  if [ ! -f "$REQS" ]; then
    echo "ERROR: Missing $REQS"
    exit 1
  fi
  echo "INFO: Creating demos/render_chat_api/.venv and installing requirements.txt ..."
  "$PYTHON_BIN" -m venv "$DEMO_VENV"

  local venv_python=""
  local venv_version=""
  venv_version="$("$PYTHON_BIN" - <<'PY'
import sys
print(f"{sys.version_info[0]}.{sys.version_info[1]}")
PY
  )"

  venv_python="$(find_demo_venv_python "$venv_version" || true)"
  if [ -z "$venv_python" ]; then
    echo "ERROR: venv created but no python executable found under $DEMO_VENV/bin" >&2
    ls -la "$DEMO_VENV/bin" >&2 || true
    exit 1
  fi

  if ! python_supports_demo_venv "$venv_python"; then
    echo "ERROR: venv python exists but is not runnable or is older than 3.10: $venv_python" >&2
    ls -la "$DEMO_VENV/bin" >&2 || true
    exit 1
  fi

  "$venv_python" -m pip install -q -U pip setuptools wheel
  "$venv_python" -m pip install -q -r "$REQS"
  if [ -f "$DEV_REQS" ]; then
    "$venv_python" -m pip install -q -r "$DEV_REQS"
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
