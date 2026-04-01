#!/usr/bin/env python3
"""Sync Flutter/Dart version markers from README into repo canon and AI adapters."""

from __future__ import annotations

import re
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
README_PATH = PROJECT_ROOT / "README.md"


def extract_versions() -> tuple[str, str]:
    text = README_PATH.read_text(encoding="utf-8")
    flutter_match = re.search(r"Flutter `([^`]+)`", text)
    dart_match = re.search(r"Dart `([^`]+)`", text)
    if flutter_match is None or dart_match is None:
        raise SystemExit("Could not extract Flutter/Dart versions from README.md")
    return flutter_match.group(1), dart_match.group(1)


def replace_required(
    path: Path,
    pattern: str,
    replacement: str,
    *,
    count: int = 1,
) -> bool:
    text = path.read_text(encoding="utf-8")
    updated, replacements = re.subn(pattern, replacement, text, count=count, flags=re.MULTILINE)
    if replacements == 0:
        raise SystemExit(f"Expected pattern not found in {path}")
    if updated == text:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def main() -> int:
    flutter_version, dart_version = extract_versions()
    replacements = [
        (
            PROJECT_ROOT / "AGENTS.md",
            r"^- Flutter \S+ / Dart \S+$",
            f"- Flutter {flutter_version} / Dart {dart_version}",
        ),
        (
            PROJECT_ROOT / "docs/agents_quick_reference.md",
            r"^- Flutter \S+ / Dart \S+$",
            f"- Flutter {flutter_version} / Dart {dart_version}",
        ),
        (
            PROJECT_ROOT / "docs/ai_code_review_protocol.md",
            r"^Pinned repo toolchain: Flutter \S+ / Dart \S+\.$",
            f"Pinned repo toolchain: Flutter {flutter_version} / Dart {dart_version}.",
        ),
        (
            PROJECT_ROOT / "docs/new_developer_guide.md",
            r"^- Flutter `[^`]+`$",
            f"- Flutter `{flutter_version}`",
        ),
        (
            PROJECT_ROOT / "docs/new_developer_guide.md",
            r"^- Dart `[^`]+`$",
            f"- Dart `{dart_version}`",
        ),
        (
            PROJECT_ROOT / "tool/agent_host_templates/codex/skills/flutter-bloc-app-quick-reference/SKILL.md",
            r"^- Flutter \S+ / Dart \S+$",
            f"- Flutter {flutter_version} / Dart {dart_version}",
        ),
        (
            PROJECT_ROOT / "tool/agent_host_templates/cursor/skills/agents-quick-reference/SKILL.md",
            r"^- Flutter \S+ / Dart \S+$",
            f"- Flutter {flutter_version} / Dart {dart_version}",
        ),
    ]

    changed_paths: list[Path] = []
    for path, pattern, replacement in replacements:
        if replace_required(path, pattern, replacement):
            changed_paths.append(path.relative_to(PROJECT_ROOT))

    print(f"Toolchain source: README.md -> Flutter {flutter_version}, Dart {dart_version}")
    if changed_paths:
        print("Updated toolchain markers:")
        for path in changed_paths:
            print(f"- {path}")
    else:
        print("Toolchain markers already up to date.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
