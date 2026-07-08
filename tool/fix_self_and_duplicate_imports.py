#!/usr/bin/env python3
"""Remove self-imports and duplicate import/export lines in apps/mobile."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
MOBILE = REPO / "apps/mobile"
TARGETS = [MOBILE / "lib", MOBILE / "test", MOBILE / "integration_test"]

DIRECTIVE_RE = re.compile(
    r"^(?P<kind>import|export)\s+'(?P<uri>[^']+)';?\s*$"
)


def package_uri_for(path: Path) -> str | None:
    try:
        rel = path.relative_to(MOBILE / "lib").as_posix()
    except ValueError:
        return None
    return f"package:flutter_bloc_app/{rel}"


def clean_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    self_uri = package_uri_for(path)
    lines = original.splitlines(keepends=True)
    seen_directives: set[str] = set()
    out: list[str] = []
    changed = False

    for line in lines:
        stripped = line.rstrip("\n")
        match = DIRECTIVE_RE.match(stripped)
        if match:
            uri = match.group("uri")
            if self_uri and uri == self_uri:
                changed = True
                continue
            key = stripped.strip()
            if key in seen_directives:
                changed = True
                continue
            seen_directives.add(key)
        out.append(line)

    updated = "".join(out)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        return True
    return changed


def main() -> None:
    changed = 0
    for base in TARGETS:
        if not base.exists():
            continue
        for path in sorted(base.rglob("*.dart")):
            if clean_file(path):
                changed += 1
                print(path.relative_to(REPO))
    print(f"cleaned {changed} files")


if __name__ == "__main__":
    main()
