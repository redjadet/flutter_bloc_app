#!/usr/bin/env python3
"""Flag local TextEditingController declarations inside async blocks in dialog-using files.

When a file uses showDialog/showAdaptiveDialog, creating ``final foo = TextEditingController()``
inside an ``async`` function (including top-level helpers) is fragile: disposing that controller
from the outer function after ``await showDialog`` can race route teardown. Prefer a
StatefulWidget dialog with controllers in initState / dispose in State.dispose.

State class fields like ``final _c = TextEditingController()`` are allowed (enclosing brace is the
class body with ``extends State``). Assignments in initState are allowed via ``void initState()``
range detection.

Exit 1 if any violation; exit 0 if clean.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

LOCAL_CONTROLLER_DECL = re.compile(
    r"(?:^|\n)\s*(?:final|var)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*TextEditingController\s*\(",
    re.MULTILINE,
)

DIALOG_NAMES = ("showDialog", "showAdaptiveDialog")


def _skip_string_or_comment(s: str, i: int) -> int:
    """Advance i past a comment or string starting at s[i]; return new index (exclusive end)."""
    n = len(s)
    if i >= n:
        return i
    if s[i] == "/" and i + 1 < n:
        if s[i + 1] == "/":
            j = s.find("\n", i)
            return n if j == -1 else j + 1
        if s[i + 1] == "*":
            j = s.find("*/", i + 2)
            return n if j == -1 else j + 2
    if s[i] == "r" and i + 1 < n and s[i + 1] in "'\"":
        i += 1
    if s[i] in "'\"":
        quote = s[i]
        if quote in "\"'" and i + 2 < n and s[i : i + 3] == quote * 3:
            end = s.find(quote * 3, i + 3)
            return n if end == -1 else end + 3
        i += 1
        while i < n:
            if s[i] == "\\" and i + 1 < n:
                i += 2
                continue
            if s[i] == quote:
                return i + 1
            i += 1
        return n
    return i


def opening_brace_enclosing(s: str, pos: int) -> int | None:
    """Index of the ``{`` that opens the innermost block containing byte offset ``pos``."""
    stack: list[int] = []
    i = 0
    while i < pos:
        ch = s[i]
        if ch in "/'\"r":
            nxt = _skip_string_or_comment(s, i)
            if nxt != i:
                i = nxt
                continue
        if ch == "{":
            stack.append(i)
        elif ch == "}" and stack:
            stack.pop()
        i += 1
    return stack[-1] if stack else None


def init_state_inner_ranges(s: str) -> list[tuple[int, int]]:
    """Byte ranges strictly inside ``void initState()`` bodies (after opening ``{``)."""
    ranges: list[tuple[int, int]] = []
    pos = 0
    while True:
        j = s.find("void initState()", pos)
        if j == -1:
            break
        k = s.find("{", j)
        if k == -1:
            break
        close = matching_brace_close(s, k)
        if close is None:
            pos = k + 1
            continue
        ranges.append((k + 1, close))
        pos = close + 1
    return ranges


def matching_brace_close(s: str, open_idx: int) -> int | None:
    """Given index of ``{``, return index of matching ``}`` or None."""
    if open_idx >= len(s) or s[open_idx] != "{":
        return None
    depth = 1
    i = open_idx + 1
    while i < len(s):
        ch = s[i]
        if ch in "/'\"r":
            nxt = _skip_string_or_comment(s, i)
            if nxt != i:
                i = nxt
                continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return None


def _in_any_range(p: int, ranges: list[tuple[int, int]]) -> bool:
    return any(a <= p < b for a, b in ranges)


def _snippet_before(s: str, open_brace: int, width: int = 200) -> str:
    lo = max(0, open_brace - width)
    return s[lo:open_brace].replace("\n", " ")


def _is_allowed_state_field(snippet: str) -> bool:
    """Direct ``State`` subclass field: class opening brace, no ``async`` in the tail."""
    if not re.search(r"extends\s+State\b", snippet):
        return False
    tail = snippet[-60:]
    return "async" not in tail


def _is_async_risk_block(snippet: str) -> bool:
    tail = snippet[-80:]
    if "async" in tail or ") async" in snippet:
        return True
    if re.search(r"\bFuture\s*<[^>]{0,200}>\s+\w+\s*\([^)]*\)\s*async\s*$", snippet):
        return True
    return False


def _is_ignored(lines: list[str], lineno: int) -> bool:
    if lineno < 1 or lineno > len(lines):
        return False
    cur = lines[lineno - 1]
    prev = lines[lineno - 2] if lineno > 1 else ""
    return "check-ignore" in cur or "check-ignore" in prev


def _byte_offset_to_lineno(s: str, offset: int) -> int:
    return s.count("\n", 0, offset) + 1


def check_file(path: Path, text: str) -> list[str]:
    if not any(d in text for d in DIALOG_NAMES):
        return []
    if "TextEditingController" not in text:
        return []
    lines = text.splitlines()
    init_ranges = init_state_inner_ranges(text)
    violations: list[str] = []
    for m in LOCAL_CONTROLLER_DECL.finditer(text):
        start = m.start(1)
        if _in_any_range(start, init_ranges):
            continue
        ob = opening_brace_enclosing(text, start)
        if ob is None:
            continue
        snippet = _snippet_before(text, ob)
        if _is_allowed_state_field(snippet):
            continue
        if not _is_async_risk_block(snippet):
            continue
        lineno = _byte_offset_to_lineno(text, start)
        if _is_ignored(lines, lineno):
            continue
        violations.append(
            f"{path}:{lineno}: local TextEditingController in async block with dialog API "
            f"(use StatefulWidget dialog; initState + State.dispose)"
        )
    return violations


def iter_dart_files(root: Path) -> list[Path]:
    out: list[Path] = []
    for p in root.rglob("*.dart"):
        if p.suffix != ".dart":
            continue
        name = p.name
        if name.endswith(".g.dart") or name.endswith(".freezed.dart"):
            continue
        out.append(p)
    return sorted(out)


def main() -> int:
    root = Path(__file__).resolve().parent.parent / "lib"
    if not root.is_dir():
        print("check_dialog_text_controller_lifecycle: lib/ not found", file=sys.stderr)
        return 1
    all_v: list[str] = []
    for path in iter_dart_files(root):
        try:
            text = path.read_text(encoding="utf-8")
        except OSError as e:
            print(f"{path}: read error: {e}", file=sys.stderr)
            return 1
        all_v.extend(check_file(path, text))
    if all_v:
        print(
            "❌ Local TextEditingController in async code paths that use dialog APIs:\n"
            + "\n".join(all_v)
        )
        return 1
    print("✅ No local TextEditingController + async + dialog anti-pattern")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
