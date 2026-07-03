#!/usr/bin/env python3
"""Physical line-count gate mirroring file_length_lint plugin config.

Avoids a second full-repo `dart analyze .` (native plugins can hang/crash on `.`).
Reads `file_length_lint:` from analysis_options.yaml and walks lib/**/*.dart.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = (
    WORKSPACE_ROOT / "apps" / "mobile"
    if (WORKSPACE_ROOT / "apps" / "mobile" / "pubspec.yaml").is_file()
    else WORKSPACE_ROOT
)
ANALYSIS_OPTIONS = WORKSPACE_ROOT / "analysis_options.yaml"

# Must match analysis_options.yaml file_length_lint.max_lines (parse fallback).
DEFAULT_MAX_LINES = 225
# Mirrors custom_lints/file_length_lint defaultExcludedPatterns + common lib paths.
DEFAULT_EXCLUDES = (
    "**/*.g.dart",
    "**/*.freezed.dart",
    "**/*.gen.dart",
    "**/*.gr.dart",
    "**/*.mocks.dart",
    "**/*.part.dart",
    "lib/l10n/**",
    "test/**",
    "tool/**",
    "integration_test/**",
    "**/test/**",
    "**/tool/**",
    "**/integration_test/**",
)


def _load_file_length_config() -> tuple[int, list[str]]:
    text = ANALYSIS_OPTIONS.read_text(encoding="utf-8")
    max_lines = DEFAULT_MAX_LINES
    excludes: list[str] = []
    include_defaults = True

    in_section = False
    in_excludes = False
    for raw_line in text.splitlines():
        line = raw_line.rstrip()
        if not in_section:
            if re.match(r"^file_length_lint:\s*$", line):
                in_section = True
            continue

        if re.match(r"^[A-Za-z0-9_]+:", line) and not line.startswith(" "):
            break

        max_match = re.match(r"^\s+max_lines:\s*(\d+)\s*$", line)
        if max_match:
            max_lines = int(max_match.group(1))
            continue

        defaults_match = re.match(r"^\s+include_defaults:\s*(true|false)\s*$", line, re.I)
        if defaults_match:
            include_defaults = defaults_match.group(1).lower() == "true"
            continue

        if re.match(r"^\s+excludes:\s*$", line):
            in_excludes = True
            continue

        if in_excludes:
            item_match = re.match(r"^\s+-\s+(.+?)\s*$", line)
            if item_match:
                excludes.append(item_match.group(1))
                continue
            if line.strip() and not line.startswith(" "):
                in_excludes = False

    patterns = list(excludes)
    if include_defaults:
        patterns = list(DEFAULT_EXCLUDES) + patterns
    return max_lines, patterns


def _glob_to_regex(pattern: str) -> re.Pattern[str]:
    """Mirror custom_lints/file_length_lint Glob._createRegex (char-wise, not replace chain)."""
    parts: list[str] = ["^"]
    i = 0
    while i < len(pattern):
        char = pattern[i]
        if char == "*":
            if i + 1 < len(pattern) and pattern[i + 1] == "*":
                parts.append(".*")
                i += 1
            else:
                parts.append("[^/]*")
        elif char == "?":
            parts.append("[^/]")
        else:
            parts.append(re.escape(char))
        i += 1
    parts.append("$")
    return re.compile("".join(parts))


def _matches_any(relative_posix: str, patterns: list[str]) -> bool:
    for pattern in patterns:
        if _glob_to_regex(pattern).match(relative_posix):
            return True
    return False


def _physical_line_count(path: Path) -> int:
    return len(path.read_text(encoding="utf-8").splitlines())


def main() -> int:
    max_lines, exclude_patterns = _load_file_length_config()
    lib_dir = APP_ROOT / "lib"
    if not lib_dir.is_dir():
        print("✅ file_length_lint passed (no lib/ directory).")
        return 0

    violations: list[tuple[str, int]] = []
    for dart_file in sorted(lib_dir.rglob("*.dart")):
        relative = dart_file.relative_to(APP_ROOT).as_posix()
        if _matches_any(relative, exclude_patterns):
            continue
        count = _physical_line_count(dart_file)
        if count > max_lines:
            violations.append((relative, count))

    if not violations:
        print(
            f"✅ file_length_lint passed (no file_too_long; max {max_lines} physical lines)."
        )
        return 0

    for relative, count in violations:
        print(
            "ERROR|FILE_TOO_LONG|file_too_long|"
            f"{relative}|1|1|"
            f"File has {count} physical lines (max {max_lines})"
        )
    print("❌ file_length_lint reported file_too_long violations (see lines above).")
    return 1


if __name__ == "__main__":
    sys.exit(main())
