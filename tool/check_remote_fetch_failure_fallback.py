#!/usr/bin/env python3
"""Fail when remote read ops swallow fetch errors via onFailureFallback.

Empty/default fallbacks on fetchAll/load are indistinguishable from a real empty
remote snapshot. Offline-first pullRemote/merge then deletes or overwrites local
data. See docs/offline_first/dont_overwrite_guide.md § Remote fetch failures.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

READ_OPERATIONS = frozenset(
    {
        "fetchAll",
        "load",
        "getAll",
        "fetch",
        "read",
        "list",
    }
)

CALL_OPENERS = ("_executeForUser", "runWithAuthUser")
OPERATION_RE = re.compile(r"operation:\s*'([A-Za-z0-9_]+)'")
CHECK_IGNORE_RE = re.compile(r"check-ignore")


def _line_number_at(content: str, index: int) -> int:
    return content.count("\n", 0, index) + 1


def _has_check_ignore_before(content: str, line_no: int) -> bool:
    lines = content.splitlines()
    idx = line_no - 1
    for offset in (0, 1):
        pos = idx - offset
        if 0 <= pos < len(lines) and CHECK_IGNORE_RE.search(lines[pos]):
            return True
    return False


def _extract_balanced_calls(content: str, opener: str) -> list[tuple[int, str]]:
    calls: list[tuple[int, str]] = []
    start = 0
    while True:
        idx = content.find(opener, start)
        if idx == -1:
            break
        paren = content.find("(", idx)
        if paren == -1:
            break
        depth = 0
        end = paren
        while end < len(content):
            char = content[end]
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    calls.append((idx, content[paren + 1 : end]))
                    break
            end += 1
        start = end + 1 if end < len(content) else len(content)
    return calls


def scan_file(path: Path) -> list[str]:
    content = path.read_text(encoding="utf-8")
    violations: list[str] = []

    for opener in CALL_OPENERS:
        for call_start, body in _extract_balanced_calls(content, opener):
            if "onFailureFallback" not in body:
                continue
            operation_match = OPERATION_RE.search(body)
            if operation_match is None:
                continue
            operation = operation_match.group(1)
            if operation not in READ_OPERATIONS:
                continue
            line_no = _line_number_at(content, call_start)
            if _has_check_ignore_before(content, line_no):
                continue
            violations.append(
                f"{path}:{line_no}: remote read operation '{operation}' must not "
                "use onFailureFallback (propagate errors to offline-first pullRemote)"
            )
    return violations


def collect_dart_files(paths: list[Path]) -> list[Path]:
    files: list[Path] = []
    for raw in paths:
        path = raw
        if path.is_file():
            if path.suffix == ".dart":
                files.append(path)
            continue
        if path.is_dir():
            files.extend(sorted(path.rglob("*.dart")))
    return files


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Reject onFailureFallback on remote fetch/load operations "
            "(offline-first data-loss guard)."
        )
    )
    parser.add_argument(
        "paths",
        nargs="*",
        default=["lib"],
        help="Dart files or directories to scan (default: lib)",
    )
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    scan_paths = [project_root / p for p in args.paths]
    dart_files = collect_dart_files(scan_paths)

    all_violations: list[str] = []
    for dart_file in dart_files:
        all_violations.extend(scan_file(dart_file))

    if all_violations:
        print(
            "❌ Remote fetch failure fallback: "
            f"{len(all_violations)} violation(s)",
            file=sys.stderr,
        )
        for violation in all_violations:
            print(violation, file=sys.stderr)
        print(
            "Remediation: remove onFailureFallback from fetchAll/load; let "
            "pullRemote catch errors. Writes may keep no-op fallbacks.",
            file=sys.stderr,
        )
        print(
            "See docs/offline_first/dont_overwrite_guide.md § Remote fetch failures.",
            file=sys.stderr,
        )
        return 1

    print("✅ No remote fetch failure fallback violations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
