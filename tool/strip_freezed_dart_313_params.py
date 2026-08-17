#!/usr/bin/env python3
"""Strip Dart 3.13-illegal `final` from Freezed constructor/function parameters.

Keeps:
- field declarations (`final List<T> _x;`)
- local declarations (`final _that = this;`, `final value = ...`)

Re-run after `build_runner` until Freezed emits 3.13-safe params.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

SKIP_DIRS = {".dart_tool", "build", "third_party"}

# `{required final List x}` and `required final Map...`
_REQUIRED_FINAL = re.compile(r"\brequired\s+final\s+")
# `(final Type x`, `, final Type x`, `{final Type x` — not `{final ident =`
_PARAM_FINAL = re.compile(
    r"([({,])\s*final\s+(?![A-Za-z_][A-Za-z0-9_]*\s*=)",
)
# Over-strip of `{final ident =` locals (newline between `{` and `final`).
_BROKEN_LOCAL = re.compile(r"\{\s*([A-Za-z_][A-Za-z0-9_]*)\s*=")


# Standalone `dart run tool/*.dart` scripts: strip `(final Type` / `, final Type`
# without `{`, and without for-in loop vars (`for (final x in ys)`).
_SCRIPT_PARAM_FINAL = re.compile(
    r"([,(])\s*final\s+(?![A-Za-z_][A-Za-z0-9_]*\s*(?:=|in\b))",
)
_BROKEN_FOR_IN = re.compile(
    r"\b((?:await\s+)?for\s*\()\s*(?!final\b)([A-Za-z_][A-Za-z0-9_]*)\s+in\b",
)


def strip_freezed_dart_313_params(text: str) -> str:
    repaired = _BROKEN_LOCAL.sub(r"{final \1 =", text)
    without_required = _REQUIRED_FINAL.sub("required ", repaired)
    return _PARAM_FINAL.sub(r"\1 ", without_required)


def strip_ordinary_final_parameters(text: str) -> str:
    repaired = _BROKEN_FOR_IN.sub(r"\1final \2 in", text)
    without_required = _REQUIRED_FINAL.sub("required ", repaired)
    return _SCRIPT_PARAM_FINAL.sub(r"\1 ", without_required)


def iter_freezed_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*.freezed.dart"):
        if SKIP_DIRS.intersection(path.parts):
            continue
        files.append(path)
    return files


def apply_to_tree(root: Path) -> list[str]:
    changed: list[str] = []
    for path in iter_freezed_files(root):
        text = path.read_text()
        new = strip_freezed_dart_313_params(text)
        if new != text:
            path.write_text(new)
            changed.append(str(path))
    return changed


def apply_to_tool_scripts(root: Path) -> list[str]:
    changed: list[str] = []
    for path in sorted((root / "tool").glob("*.dart")):
        text = path.read_text()
        new = strip_ordinary_final_parameters(text)
        if new != text:
            path.write_text(new)
            changed.append(str(path))
    return changed


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--root",
        type=Path,
        default=Path("."),
        help="Repo root (default: cwd)",
    )
    parser.add_argument(
        "--tool-scripts",
        action="store_true",
        help="Also strip final params from dart run tool/*.dart scripts",
    )
    args = parser.parse_args(argv)
    root = args.root.resolve()
    changed = apply_to_tree(root)
    print(f"strip_freezed_dart_313_params: {len(changed)} files")
    for item in changed:
        print(item)
    if args.tool_scripts:
        scripts = apply_to_tool_scripts(root)
        print(f"strip_tool_script_final_params: {len(scripts)} files")
        for item in scripts:
            print(item)
    return 0


if __name__ == "__main__":
    sys.exit(main())
