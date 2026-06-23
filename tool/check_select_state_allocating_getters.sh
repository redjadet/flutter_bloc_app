#!/usr/bin/env bash
# Prevent selector rebuild regressions from list getters that allocate with toList().
#
# Directly returning state.allocatingListGetter from selectState/TypeSafeBlocSelector
# defeats selector equality because each state emission returns a new list instance.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

PATHS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --paths)
      shift
      if [[ $# -eq 0 ]]; then
        echo "❌ --paths requires at least one path" >&2
        exit 1
      fi
      while [[ $# -gt 0 && "$1" != --* ]]; do
        PATHS+=("$1")
        shift
      done
      ;;
    -h|--help)
      sed -n '1,8p' "$0" | tail -n +2
      exit 0
      ;;
    *)
      echo "❌ Unknown argument: $1 (try --paths or --help)" >&2
      exit 1
      ;;
  esac
done

echo "🔍 Checking selectState selectors for allocating list getters..."

python3 - "$PROJECT_ROOT" "${PATHS[@]}" <<'PY'
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])
manual_paths = [Path(p) for p in sys.argv[2:]]

generated_suffixes = (".freezed.dart", ".g.dart", ".gr.dart")


def dart_files() -> list[Path]:
    if manual_paths:
        selected = [
            (root / path if not path.is_absolute() else path)
            for path in manual_paths
            if (root / path if not path.is_absolute() else path).suffix == ".dart"
        ]
        selected.extend(
            path
            for path in (root / "lib").rglob("*.dart")
            if "presentation" in path.parts and "state" in path.name
        )
        return sorted(set(selected))
    try:
        result = subprocess.run(
            ["rg", "--files", "lib", "--glob", "*.dart"],
            cwd=root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        )
        return [root / line for line in result.stdout.splitlines() if line]
    except Exception:
        return list((root / "lib").rglob("*.dart"))


def is_scanned(path: Path) -> bool:
    relative = path.relative_to(root) if path.is_absolute() else path
    text = relative.as_posix()
    if text.endswith(generated_suffixes):
        return False
    return "presentation/" in text or text.startswith("tool/fixtures/")


def find_allocating_getters(files: list[Path]) -> dict[str, list[str]]:
    getters: dict[str, list[str]] = {}
    getter_re = re.compile(r"\bList(?:<[^;\n=]+>)?\??\s+get\s+([A-Za-z_]\w*)\b")

    for path in files:
        if not is_scanned(path) or not path.exists():
            continue
        relative = path.relative_to(root).as_posix()
        if "state" not in path.name and not relative.startswith("tool/fixtures/"):
            continue

        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        index = 0
        while index < len(lines):
            match = getter_re.search(lines[index])
            if not match:
                index += 1
                continue

            name = match.group(1)
            start = index
            body = [lines[index]]
            if "=>" in lines[index]:
                while index < len(lines) and ";" not in lines[index]:
                    index += 1
                    if index < len(lines):
                        body.append(lines[index])
            else:
                depth = lines[index].count("{") - lines[index].count("}")
                index += 1
                while index < len(lines) and depth > 0:
                    body.append(lines[index])
                    depth += lines[index].count("{") - lines[index].count("}")
                    index += 1
                index -= 1

            body_text = "\n".join(body)
            if ".toList(" in body_text:
                getters.setdefault(name, []).append(f"{relative}:{start + 1}")
            index += 1

    return getters


def selector_windows(lines: list[str]) -> list[tuple[int, int]]:
    windows: list[tuple[int, int]] = []
    for index, line in enumerate(lines):
        if "selector:" not in line:
            continue
        end = min(len(lines), index + 80)
        for cursor in range(index + 1, end):
            stripped = lines[cursor].strip()
            if stripped.startswith("builder:") or stripped.startswith("buildWhen:"):
                end = cursor
                break
            if cursor > index + 2 and re.match(r"^\s*\)\s*[,;]?\s*$", lines[cursor]):
                end = cursor + 1
                break
        windows.append((index, end))
    return windows


files = dart_files()
allocating_getters = find_allocating_getters(files)
violations: list[str] = []

if allocating_getters:
    getter_names = sorted(allocating_getters)
    getter_pattern = re.compile(
        r"\bstate\s*\.\s*(" + "|".join(re.escape(name) for name in getter_names) + r")\b"
    )

    for path in files:
        if not is_scanned(path) or not path.exists():
            continue
        relative = path.relative_to(root).as_posix()
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        if not any("selectState" in line or "TypeSafeBlocSelector" in line for line in lines):
            continue
        for start, end in selector_windows(lines):
            for line_no in range(start, end):
                match = getter_pattern.search(lines[line_no])
                if not match:
                    continue
                getter = match.group(1)
                source = ", ".join(allocating_getters.get(getter, []))
                violations.append(
                    f"{relative}:{line_no + 1}: selector reads allocating list getter "
                    f"state.{getter} (getter: {source})"
                )

if violations:
    print("❌ selectState selector reads allocating list getter")
    print()
    for violation in violations:
        print(violation)
    print()
    print("Use value-equality view data, filter inside selector helper, or memoize.")
    sys.exit(1)

print("✅ No selectState allocating-list getter risks found")
PY
