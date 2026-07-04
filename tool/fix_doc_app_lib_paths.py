#!/usr/bin/env python3
"""Rewrite legacy repo-root lib/ doc paths to apps/mobile/lib/."""

from __future__ import annotations

import re
import sys
from pathlib import Path

WORKSPACE = Path(__file__).resolve().parents[1]

TARGET_FILES = [
    *WORKSPACE.glob("docs/**/*.md"),
    *WORKSPACE.glob("ai/reports/**/*.md"),
    *WORKSPACE.glob("tasks/*.md"),
    *WORKSPACE.glob("tool/agent_host_templates/**/*.md"),
    WORKSPACE / "CODEMAP.md",
    WORKSPACE / "README.md",
    WORKSPACE / "CONTRACTS.md",
    WORKSPACE / "DESIGN_layout_components.md",
]

APP_LIB_SEGMENTS = (
    "lib/features/",
    "lib/app/",
    "lib/core/",
    "lib/shared/",
    "lib/l10n/",
    "lib/firebase_options.dart",
    "lib/main_dev.dart",
    "lib/main_staging.dart",
    "lib/main_prod.dart",
    "lib/main_bootstrap.dart",
    "lib/main.dart",
    "lib/app.dart",
)

PACKAGE_LIB_GUARD = re.compile(
    r"(?:apps/mobile/|packages/[\w]+/|custom_lints/[\w_]+/|third_party/|tool/bloc_codegen/)"
)


def fix_link_labels(text: str) -> str:
    """Align markdown link labels with apps/mobile/lib href targets."""
    pattern = re.compile(
        r"\[`((?:lib/(?:app|core|shared|features|l10n)(?:/[^`\]]*)?))`\]"
        r"\((apps/mobile/lib/(?:app|core|shared|features|l10n)(?:/[^)\]]*)?)\)"
    )
    return pattern.sub(
        lambda m: f"[`apps/mobile/{m.group(1)}`]({m.group(2)})",
        text,
    )


def fix_relative_links(text: str) -> str:
    for _ in range(6):
        text = re.sub(r"\(\.\./lib/", "(../apps/mobile/lib/", text)
        text = re.sub(r"\(\.\./\.\./lib/", "(../../apps/mobile/lib/", text)
        text = re.sub(r"\(\.\./\.\./\.\./lib/", "(../../../apps/mobile/lib/", text)
        text = re.sub(
            r"\(\.\./\.\./\.\./\.\./lib/",
            "(../../../../apps/mobile/lib/",
            text,
        )
    text = re.sub(r"\]\(lib/", "](apps/mobile/lib/", text)
    return text


def should_skip_replacement(text: str, index: int) -> bool:
    guard = "apps/mobile/"
    if index >= len(guard) and text[index - len(guard) : index] == guard:
        return True
    prefix = text[:index]
    if re.search(r"(?:^|[\s`(])packages/[\w]+/$", prefix):
        return True
    if re.search(r"(?:^|[\s`(])custom_lints/[\w_]+/$", prefix):
        return True
    if re.search(r"(?:^|[\s`(])third_party/", prefix) and "/lib/" in prefix[-40:]:
        return True
    return False


def replace_segment(text: str, segment: str) -> str:
    """Replace segment unless already under apps/mobile/ or another package lib/."""
    replacement = f"apps/mobile/{segment}"
    out: list[str] = []
    i = 0
    while i < len(text):
        j = text.find(segment, i)
        if j == -1:
            out.append(text[i:])
            break
        if should_skip_replacement(text, j):
            out.append(text[i : j + len(segment)])
            i = j + len(segment)
            continue
        out.append(text[i:j])
        out.append(replacement)
        i = j + len(segment)
    return "".join(out)


def fix_app_lib_paths(text: str) -> str:
    segments = list(APP_LIB_SEGMENTS) + [
        "lib/features",
        "lib/shared",
        "lib/core",
        "lib/app",
        "lib/l10n",
    ]
    # Longest first so `lib/features/` wins over `lib/features`.
    for seg in sorted(set(segments), key=len, reverse=True):
        text = replace_segment(text, seg)

    shorthand = "`lib/{"
    replacement = "`apps/mobile/lib/{"
    i = 0
    while i < len(text):
        j = text.find(shorthand, i)
        if j == -1:
            break
        if should_skip_replacement(text, j):
            i = j + len(shorthand)
            continue
        text = text[:j] + replacement + text[j + len(shorthand) :]
        i = j + len(replacement)
    return text


def dedupe_prefix(text: str) -> str:
    while "apps/mobile/apps/mobile/" in text:
        text = text.replace("apps/mobile/apps/mobile/", "apps/mobile/")
    return text


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = dedupe_prefix(
        fix_link_labels(fix_app_lib_paths(fix_relative_links(original)))
    )
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def main() -> int:
    changed = 0
    for path in sorted(set(TARGET_FILES)):
        if not path.is_file():
            continue
        if process_file(path):
            changed += 1
            print(path.relative_to(WORKSPACE))
    print(f"updated {changed} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
