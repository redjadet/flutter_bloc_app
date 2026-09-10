#!/usr/bin/env python3
"""Detect HiveRepositoryBase RMW outside runWithBox (lost-update class).

`getBox()` is implemented as `runWithBox((box) async => box)`, so the per-box
mutex ends when the box is returned. Read-modify-write after `await getBox()`
can lose concurrent mutations. Prefer wrapping the full mutation in
`runWithBox` (see HiveSettingsRepository / HiveNotesRepository).

Allowlist entries are per-method signatures (`path#method`), not whole files, so
new unsafe methods in a debt file still fail.

Exit codes:
  0 — no new violations (allowlisted debt only, or clean)
  1 — new violation or stale allowlist entry
  2 — usage error
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

WRITE_RE = re.compile(
    r"\b(box\.(put|delete|clear|add|putAt|putAll|deleteAt|deleteAll)\s*\(|"
    r"safeDeleteKey\s*\(|"
    r"_deleteKeys\s*\(|"
    r"_save[A-Za-z0-9_]*\s*\()"
)
GETBOX_RE = re.compile(r"await\s+getBox\s*\(")
MEMBER_START = re.compile(
    r"^  (@override|@[A-Za-z]|"
    r"(?:static\s+)?(?:Future|Stream|void|bool|int|double|String|List|Map|Set|"
    r"Iterable|Object|dynamic|covariant|[A-Z]\w*)\b)"
)
NAME_RE = re.compile(
    r"(?:Future(?:<[^;\n(]+>)?|Stream(?:<[^;\n(]+>)?|void|bool|int|double|"
    r"String|List(?:<[^;\n(]+>)?|Map(?:<[^;\n(]+>)?|Set(?:<[^;\n(]+>)?|"
    r"Iterable(?:<[^;\n(]+>)?|Object|dynamic|[A-Z]\w*)\s+(\w+)\s*[\(<]"
)
IGNORE_SUFFIXES = (".g.dart", ".freezed.dart", ".gr.dart")


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def load_allowlist(path: Path) -> set[str]:
    if not path.is_file():
        return set()
    entries: set[str] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        entries.add(line)
    return entries


def enclosing_member(lines: list[str], idx: int) -> str:
    for k in range(idx, -1, -1):
        if not MEMBER_START.match(lines[k]):
            continue
        line = lines[k]
        if line.strip().startswith("@"):
            for m in range(k + 1, min(len(lines), k + 4)):
                stripped = lines[m].strip()
                if stripped and not stripped.startswith("@"):
                    line = lines[m]
                    break
        match = NAME_RE.search(line)
        if match:
            return match.group(1)
        return f"L{k + 1}"
    return f"L{idx + 1}"


def find_violations(path: Path) -> list[tuple[str, int, int]]:
    """Return (signature, getBox_line, write_line) triples."""
    text = path.read_text(encoding="utf-8")
    if "getBox(" not in text:
        return []
    root = repo_root()
    rel = path.resolve().relative_to(root).as_posix()
    lines = text.splitlines()
    found: list[tuple[str, int, int]] = []
    seen_sigs: set[str] = set()
    for i, line in enumerate(lines):
        if not GETBOX_RE.search(line) or line.lstrip().startswith("//"):
            continue
        write_line: int | None = None
        for j in range(i + 1, min(len(lines), i + 80)):
            nxt = lines[j]
            if j > i + 1 and MEMBER_START.match(nxt):
                break
            if WRITE_RE.search(nxt) and not nxt.lstrip().startswith("//"):
                write_line = j + 1
                break
        if write_line is None:
            continue
        sig = f"{rel}#{enclosing_member(lines, i)}"
        if sig in seen_sigs:
            continue
        seen_sigs.add(sig)
        found.append((sig, i + 1, write_line))
    return found


def collect_paths(explicit: list[str] | None) -> list[Path]:
    root = repo_root()
    if explicit:
        out: list[Path] = []
        for item in explicit:
            p = Path(item)
            if not p.is_absolute():
                p = (root / p).resolve()
            if p.is_dir():
                out.extend(
                    q
                    for q in p.rglob("*.dart")
                    if not q.name.endswith(IGNORE_SUFFIXES)
                )
            elif p.is_file() and p.suffix == ".dart":
                out.append(p)
        return sorted(set(out))

    roots = [root / "apps/mobile/lib", root / "packages/storage/lib"]
    out = []
    for base in roots:
        if not base.is_dir():
            continue
        out.extend(
            q for q in base.rglob("*.dart") if not q.name.endswith(IGNORE_SUFFIXES)
        )
    return sorted(out)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--paths",
        nargs="+",
        help="Optional files/dirs (fixtures or scoped scans)",
    )
    parser.add_argument(
        "--allowlist",
        default=str(repo_root() / "tool/fixtures/hive_getbox_rmw/allowlist.txt"),
        help="Debt allowlist (path#method signatures)",
    )
    parser.add_argument(
        "--no-allowlist",
        action="store_true",
        help="Treat every violation as failing (fixture mode)",
    )
    args = parser.parse_args()

    root = repo_root()
    allowlist_path = Path(args.allowlist)
    if not allowlist_path.is_absolute():
        allowlist_path = root / allowlist_path
    allowlist = set() if args.no_allowlist else load_allowlist(allowlist_path)

    # Reject legacy whole-file allowlist entries (no '#') outside fixture mode.
    if allowlist and not args.no_allowlist:
        legacy = sorted(e for e in allowlist if "#" not in e)
        if legacy:
            print("❌ hive_getbox_rmw allowlist must use path#method signatures:")
            for item in legacy:
                print(f"  {item}")
            return 1

    files = collect_paths(args.paths)
    new_violations: list[str] = []
    debt_hits: set[str] = set()

    for path in files:
        for sig, get_line, write_line in find_violations(path):
            if sig in allowlist:
                debt_hits.add(sig)
                continue
            new_violations.append(
                f"{sig} (@{get_line}→write@{write_line}): await getBox() then "
                f"write outside runWithBox (see HiveNotesRepository)"
            )

    stale = sorted(allowlist - debt_hits) if allowlist and not args.paths else []
    if args.paths:
        stale = []

    if new_violations or stale:
        if new_violations:
            print("❌ Hive getBox RMW outside runWithBox (lost-update risk):")
            for item in new_violations:
                print(f"  {item}")
            print(
                "  Fix: action: () => runWithBox((box) async { ... mutate ... })"
            )
        if stale:
            print("❌ Stale hive_getbox_rmw allowlist entries (no longer violate):")
            for item in stale:
                print(f"  {item}")
            print(f"  Remove from {allowlist_path.relative_to(root)}")
        return 1

    if debt_hits and not args.no_allowlist:
        print(
            f"ℹ️  Allowlisted Hive getBox RMW debt methods: {len(debt_hits)} "
            f"(migrate to runWithBox when touching)"
        )
    print("✅ No new Hive getBox RMW violations")
    return 0


if __name__ == "__main__":
    sys.exit(main())
