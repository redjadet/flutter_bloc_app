#!/usr/bin/env python3
"""Ensure Runlayer Cursor plugin hooks.json declares a numeric schema version.

Cursor validates plugin hooks via claude-plugin-config and requires a numeric
top-level ``version`` (e.g. ``1``). Upstream fix:
https://github.com/runlayer/plugins/pull/6

This script is idempotent: safe to run after plugin updates if the marketplace
cache republishes an older hooks file without ``version``.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def _runlayer_hook_paths(base: Path) -> list[Path]:
    if not base.is_dir():
        return []
    return sorted(base.glob("*/hooks/hooks.json"))


def ensure_version(path: Path, *, dry_run: bool) -> bool:
    text = path.read_text(encoding="utf-8")
    try:
        data = json.loads(text)
    except json.JSONDecodeError as e:
        print(f"skip (invalid JSON): {path}: {e}", file=sys.stderr)
        return False

    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        print(f"skip (no hooks object): {path}", file=sys.stderr)
        return False

    ver = data.get("version")
    if ver == 1 and isinstance(ver, int):
        return False

    new_data = {"version": 1, "hooks": hooks}
    for key, value in data.items():
        if key not in ("version", "hooks"):
            new_data[key] = value

    out = json.dumps(new_data, indent=2) + "\n"
    if dry_run:
        print(f"would update: {path}")
        return True

    path.write_text(out, encoding="utf-8")
    print(f"updated: {path}")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print paths that would change without writing",
    )
    parser.add_argument(
        "--cache-root",
        type=Path,
        default=Path.home() / ".cursor/plugins/cache/cursor-public/runlayer",
        help="Directory containing versioned Runlayer plugin folders",
    )
    args = parser.parse_args()

    paths = _runlayer_hook_paths(args.cache_root)
    if not paths:
        print(
            f"No hooks found under {args.cache_root} "
            "(Runlayer Cursor plugin not installed or cache path differs).",
            file=sys.stderr,
        )
        return 0

    for p in paths:
        ensure_version(p, dry_run=args.dry_run)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
