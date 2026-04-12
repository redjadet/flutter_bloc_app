#!/usr/bin/env python3
"""
Normalize markdown doc references into clickable links.

Goal:
Convert backticked file references like `docs/foo.md` or `foo.md` into clickable
markdown links while preserving the code-style label, e.g.:

  `docs/validation_scripts.md` -> [`validation_scripts.md`](validation_scripts.md)
  `validation_scripts.md`      -> [`validation_scripts.md`](validation_scripts.md)

Rules:
- Only transforms backticked tokens that look like markdown file paths (*.md).
- Skips anything already inside a markdown link label/backticks are handled
  conservatively (best-effort heuristic).
- For files under docs/**, `docs/` prefix is removed from targets to keep paths
  correct relative to that file.
- When fixing existing markdown links of the form
  [backticked-label](relative-path.md#heading), the #heading fragment is
  preserved; only the path portion is resolved on disk.
"""

from __future__ import annotations

import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path


MD_TOKEN_RE = re.compile(r"`(?P<token>[^`\n]+?\.md)`")
MD_LINK_RE = re.compile(r"\[`(?P<label>[^`\n]+?\.md)`]\((?P<target>[^)\n]+)\)")
REPO_ROOT_PREFERRED_PREFIXES = (
    ".github/",
    ".cursor/",
    ".agents/",
    "analysis/",
    "assets/",
    "coverage/",
    "fastlane/",
    "integration_test/",
    "lib/",
    "tasks/",
    "test/",
    "tool/",
)
REPO_ROOT_PREFERRED_FILENAMES = {
    "AGENTS.md",
    "CHANGELOG.md",
    "README.md",
    "SECURITY.md",
}


@dataclass(frozen=True)
class Change:
    path: Path
    replacements: int


def _looks_like_link_context(text: str, start_idx: int, end_idx: int) -> bool:
    # Heuristic: if the backticked token is already part of a markdown link like
    # [something](`foo.md`) we should not touch it.
    window_start = max(0, start_idx - 2)
    window_end = min(len(text), end_idx + 2)
    window = text[window_start:window_end]
    return "](" in window or ")[" in window


def _normalize_token(token: str, file_path: Path) -> str:
    # Display label normalization only (not link target computation).
    #
    # If we are already under docs/, we prefer showing "docs/..." links without the
    # "docs/" prefix, since they’re already within that folder.
    if "docs" in file_path.parts and token.startswith("docs/"):
        return token[len("docs/") :]
    return token


def _is_placeholder_token(token: str) -> bool:
    """
    Heuristic: skip template placeholders like `docs/offline_first/<feature>.md`.

    We treat angle-bracket and brace placeholders as non-files, even if they end
    with ".md", because they can’t resolve to a concrete path.
    """
    return any(ch in token for ch in ("<", ">", "{", "}", "$"))


def _is_under_repo_docs(file_path: Path, repo_root: Path) -> bool:
    try:
        rel = file_path.relative_to(repo_root)
    except ValueError:
        return False
    return len(rel.parts) > 0 and rel.parts[0] == "docs"


def _resolve_token_to_existing_path(token: str, *, file_path: Path, repo_root: Path) -> Path | None:
    """
    Resolve a markdown token to a real file on disk, so we can compute a correct
    relative link target from the current file’s directory.
    """
    if _is_placeholder_token(token):
        return None

    if token.startswith("docs/"):
        candidate = repo_root / token
        return candidate if candidate.is_file() else None

    if token.startswith(("./", "../")):
        candidate = (file_path.parent / token).resolve()
        return candidate if candidate.is_file() else None

    def add_candidate(items: list[Path], seen: set[Path], candidate: Path) -> None:
        candidate = candidate.resolve()
        if candidate not in seen:
            seen.add(candidate)
            items.append(candidate)

    candidates: list[Path] = []
    seen: set[Path] = set()
    add_candidate(candidates, seen, file_path.parent / token)

    if _is_under_repo_docs(file_path, repo_root):
        prefers_repo_root = token.startswith(REPO_ROOT_PREFERRED_PREFIXES) or token in REPO_ROOT_PREFERRED_FILENAMES
        docs_candidate = repo_root / "docs" / token
        repo_candidate = repo_root / token

        if prefers_repo_root:
            add_candidate(candidates, seen, repo_candidate)
            add_candidate(candidates, seen, docs_candidate)
        else:
            add_candidate(candidates, seen, docs_candidate)
            add_candidate(candidates, seen, repo_candidate)

    for candidate in candidates:
        if candidate.is_file():
            return candidate

    return None


def _split_md_link_target(target: str) -> tuple[str, str | None]:
    """
    Split `path/to/file.md#heading` for filesystem resolution.

    Returns (path_part, fragment_without_hash). Fragment is None when absent or
    empty so callers do not emit a trailing '#'.
    """
    if "#" not in target:
        return target, None
    path_part, fragment = target.split("#", 1)
    frag = fragment.strip()
    return path_part, frag if frag else None


def _link_target_for_token(token: str, *, file_path: Path, repo_root: Path) -> str | None:
    if _is_placeholder_token(token):
        return None
    resolved = _resolve_token_to_existing_path(token, file_path=file_path, repo_root=repo_root)
    if resolved is None:
        return None
    return os.path.relpath(resolved, start=file_path.parent.resolve())


def normalize_file(path: Path, repo_root: Path) -> Change | None:
    original = path.read_text(encoding="utf-8")

    replacements = 0
    out_parts: list[str] = []
    last_idx = 0

    for m in MD_TOKEN_RE.finditer(original):
        token = m.group("token").strip()
        start, end = m.span()

        out_parts.append(original[last_idx:start])
        last_idx = end

        if _looks_like_link_context(original, start, end):
            out_parts.append(m.group(0))
            continue

        if not token.endswith(".md"):
            out_parts.append(m.group(0))
            continue

        if _is_placeholder_token(token):
            out_parts.append(m.group(0))
            continue

        target = _link_target_for_token(token, file_path=path, repo_root=repo_root)
        if target is None:
            out_parts.append(m.group(0))
            continue

        label = _normalize_token(token, path)
        out_parts.append(f"[`{label}`]({target})")
        replacements += 1

    out_parts.append(original[last_idx:])
    updated = "".join(out_parts)

    def _fix_existing_md_link(m: re.Match[str]) -> str:
        nonlocal replacements

        label = m.group("label").strip()
        raw_target = m.group("target").strip()
        path_part, fragment = _split_md_link_target(raw_target)
        path_part = path_part.strip()

        # Template placeholders (e.g. `<feature>`) should not be clickable links.
        if _is_placeholder_token(label):
            replacements += 1
            return f"`{label}`"

        # Skip external links and pure-anchor targets.
        if "://" in path_part or raw_target.startswith("#"):
            return m.group(0)

        if not path_part:
            return m.group(0)

        resolved_target = (path.parent / path_part).resolve()
        if resolved_target.is_file():
            return m.group(0)

        desired = _link_target_for_token(label, file_path=path, repo_root=repo_root)
        if desired is None:
            replacements += 1
            return f"`{label}`"

        replacements += 1
        normalized_label = _normalize_token(label, path)
        frag_suffix = f"#{fragment}" if fragment else ""
        return f"[`{normalized_label}`]({desired}{frag_suffix})"

    updated = MD_LINK_RE.sub(_fix_existing_md_link, updated)

    if updated == original:
        return None

    path.write_text(updated, encoding="utf-8")
    return Change(path=path, replacements=replacements)


def iter_markdown_files(repo_root: Path) -> list[Path]:
    files: list[Path] = []

    # Root-level markdown docs.
    for name in ("README.md", "SECURITY.md"):
        p = repo_root / name
        if p.exists():
            files.append(p)

    # docs/** markdown docs
    docs_dir = repo_root / "docs"
    if docs_dir.exists():
        for root, _dirs, filenames in os.walk(docs_dir):
            for fn in filenames:
                if fn.lower().endswith(".md"):
                    files.append(Path(root) / fn)

    # Keep deterministic order.
    return sorted(set(files), key=lambda p: str(p))

def _files_from_args(repo_root: Path, args: list[str]) -> list[Path]:
    files: list[Path] = []

    for raw in args:
        raw = raw.strip()
        if not raw:
            continue

        p = Path(raw)
        if not p.is_absolute():
            p = repo_root / p

        try:
            p = p.resolve()
        except OSError:
            continue

        if not p.exists() or not p.is_file():
            continue

        if p.suffix.lower() != ".md":
            continue

        # Only operate on repo docs: root docs + docs/**.
        try:
            rel = p.relative_to(repo_root)
        except ValueError:
            continue

        if rel.parts[0] == "docs" or rel.as_posix() in ("README.md", "SECURITY.md"):
            files.append(p)

    return sorted(set(files), key=lambda p: str(p))


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    if len(sys.argv) > 1:
        files = _files_from_args(repo_root, sys.argv[1:])
    else:
        files = iter_markdown_files(repo_root)

    if not files:
        print("normalize_doc_links: no matching files")
        return 0

    changes: list[Change] = []
    for f in files:
        try:
            change = normalize_file(f, repo_root=repo_root)
        except UnicodeDecodeError:
            # Skip non-utf8 markdown files (unexpected).
            continue
        if change is not None and change.replacements > 0:
            changes.append(change)

    if not changes:
        print("normalize_doc_links: no changes")
        return 0

    total = sum(c.replacements for c in changes)
    print(f"normalize_doc_links: updated {len(changes)} files, {total} replacements")
    for c in changes[:25]:
        rel = c.path.relative_to(repo_root)
        print(f"- {rel} ({c.replacements})")
    if len(changes) > 25:
        print(f"- ... and {len(changes) - 25} more")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
