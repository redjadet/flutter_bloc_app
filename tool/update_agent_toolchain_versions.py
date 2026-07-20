#!/usr/bin/env python3
"""Sync Flutter/Dart version markers from docs/toolchain_versions.env into literal sinks."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = PROJECT_ROOT / "docs" / "toolchain_versions.env"
VERSION_TOKEN_PATTERN = r"[0-9]+(?:\.[0-9]+){2}(?:[-+][0-9A-Za-z.-]+)?"

# Keep in sync with docs and CI; bash drift check delegates to this module.
WORKFLOW_FLUTTER_SINKS = (
    ".github/workflows/ci.yml",
    ".github/workflows/dependency-updates.yml",
    ".github/workflows/drift.yml",
    ".github/workflows/deploy_web.yml",
)


def parse_env_file(path: Path) -> dict[str, str]:
    if not path.is_file():
        raise SystemExit(f"Missing toolchain pin file: {path}")
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise SystemExit(f"Invalid toolchain env line in {path}: {raw_line!r}")
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip("'\"")
        if not key:
            raise SystemExit(f"Empty key in {path}: {raw_line!r}")
        if key in values:
            raise SystemExit(f"Duplicate key {key!r} in {path}")
        values[key] = value
    flutter = values.get("FLUTTER_VERSION", "").strip()
    dart = values.get("DART_VERSION", "").strip()
    if not flutter or not dart:
        raise SystemExit(
            f"FLUTTER_VERSION and DART_VERSION are required in {path} "
            f"(got FLUTTER_VERSION={flutter!r}, DART_VERSION={dart!r})"
        )
    if not re.fullmatch(VERSION_TOKEN_PATTERN, flutter):
        raise SystemExit(f"Invalid FLUTTER_VERSION in {path}: {flutter!r}")
    if not re.fullmatch(VERSION_TOKEN_PATTERN, dart):
        raise SystemExit(f"Invalid DART_VERSION in {path}: {dart!r}")
    return {"FLUTTER_VERSION": flutter, "DART_VERSION": dart}


def extract_versions(path: Path = ENV_PATH) -> tuple[str, str]:
    values = parse_env_file(path)
    return values["FLUTTER_VERSION"], values["DART_VERSION"]


def write_env_file(path: Path, flutter_version: str, dart_version: str) -> None:
    path.write_text(
        (
            "# Canonical Flutter/Dart pins for this repo.\n"
            "# Edit pins here, then: python3 tool/update_agent_toolchain_versions.py\n"
            "# After SDK upgrade: python3 tool/update_agent_toolchain_versions.py --from-sdk\n"
            "# Human display: docs/tech_stack.md (table is synced from this file).\n"
            "# DART_VERSION is the Dart bundled with the pinned Flutter, not a separate install.\n"
            f"FLUTTER_VERSION={flutter_version}\n"
            f"DART_VERSION={dart_version}\n"
        ),
        encoding="utf-8",
    )


def replace_required(
    path: Path,
    pattern: str,
    replacement: str,
    *,
    count: int = 0,
    flags: int = re.MULTILINE,
) -> bool:
    text = path.read_text(encoding="utf-8")
    updated, replacements = re.subn(
        pattern,
        replacement,
        text,
        count=count,
        flags=flags,
    )
    if replacements == 0:
        raise SystemExit(
            f"Expected toolchain marker pattern not found in {path}: {pattern}\n"
            "Hint: the toolchain marker format likely changed; update "
            "tool/update_agent_toolchain_versions.py replacement patterns."
        )
    if updated == text:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def _resolve_sdk_binaries() -> tuple[str, str]:
    try:
        flutter_bin = subprocess.check_output(
            [
                "bash",
                "-lc",
                (
                    f'source "{PROJECT_ROOT}/tool/resolve_flutter_dart.sh" && '
                    "resolve_flutter_sdk_flutter"
                ),
            ],
            text=True,
            stderr=subprocess.STDOUT,
        ).strip()
    except subprocess.CalledProcessError as exc:
        raise SystemExit(
            f"Could not resolve Flutter SDK binary for --from-sdk: {exc.output}"
        ) from exc
    if not flutter_bin:
        raise SystemExit("Could not resolve Flutter SDK binary for --from-sdk")
    dart_bin = str(Path(flutter_bin).resolve().parent / "dart")
    if not Path(dart_bin).is_file():
        raise SystemExit(f"Resolved Flutter SDK is missing dart at {dart_bin}")
    return flutter_bin, dart_bin


def parse_sdk_version_output(flutter_out: str, dart_out: str) -> tuple[str, str]:
    flutter_match = re.search(
        rf"Flutter\s+({VERSION_TOKEN_PATTERN})",
        flutter_out,
    )
    dart_match = re.search(
        rf"Dart(?:\s+SDK)?\s+version:\s*({VERSION_TOKEN_PATTERN})",
        dart_out,
    ) or re.search(rf"\bDart\s+({VERSION_TOKEN_PATTERN})\b", flutter_out)
    if flutter_match is None or dart_match is None:
        raise SystemExit(
            "Could not parse Flutter/Dart versions from SDK output.\n"
            f"flutter --version:\n{flutter_out}\n"
            f"dart --version:\n{dart_out}"
        )
    return flutter_match.group(1), dart_match.group(1)


def detect_sdk_versions() -> tuple[str, str]:
    flutter_bin, dart_bin = _resolve_sdk_binaries()
    try:
        flutter_out = subprocess.check_output(
            [flutter_bin, "--version"],
            text=True,
            stderr=subprocess.STDOUT,
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        raise SystemExit(
            f"Could not run `{flutter_bin} --version` for --from-sdk: {exc}"
        ) from exc
    try:
        dart_out = subprocess.check_output(
            [dart_bin, "--version"],
            text=True,
            stderr=subprocess.STDOUT,
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        raise SystemExit(
            f"Could not run `{dart_bin} --version` for --from-sdk: {exc}"
        ) from exc
    return parse_sdk_version_output(flutter_out, dart_out)


def sync_readme_badges(flutter_version: str, dart_version: str) -> bool:
    path = PROJECT_ROOT / "README.md"
    changed = replace_required(
        path,
        rf"(badge/Flutter-){VERSION_TOKEN_PATTERN}(-)",
        rf"\g<1>{flutter_version}\g<2>",
    )
    changed = (
        replace_required(
            path,
            rf"(badge/Dart-){VERSION_TOKEN_PATTERN}(-)",
            rf"\g<1>{dart_version}\g<2>",
        )
        or changed
    )
    return changed


def sync_tech_stack_table(flutter_version: str, dart_version: str) -> bool:
    path = PROJECT_ROOT / "docs" / "tech_stack.md"
    changed = replace_required(
        path,
        r"^(\| Flutter \| `)[^`]+(` \|)$",
        rf"\g<1>{flutter_version}\g<2>",
    )
    changed = (
        replace_required(
            path,
            r"^(\| Dart \| `)[^`]+(` \|)$",
            rf"\g<1>{dart_version}\g<2>",
        )
        or changed
    )
    return changed


_FLUTTER_ENV_LINE = re.compile(
    rf"^(?P<indent>\s*)FLUTTER_VERSION:\s*['\"]?{VERSION_TOKEN_PATTERN}['\"]?\s*$",
    flags=re.MULTILINE,
)


def _collect_flutter_version_pins(text: str) -> list[str]:
    """Non-comment FLUTTER_VERSION env values (line-anchored)."""
    pins: list[str] = []
    for line in text.splitlines():
        stripped = line.lstrip()
        if not stripped or stripped.startswith("#"):
            continue
        match = _FLUTTER_ENV_LINE.match(line)
        if match is not None:
            value_match = re.search(
                rf"FLUTTER_VERSION:\s*['\"]?({VERSION_TOKEN_PATTERN})['\"]?",
                line,
            )
            if value_match is not None:
                pins.append(value_match.group(1))
            continue
        if re.match(r"^\s*FLUTTER_VERSION:\s*", line):
            pins.append("")
    return pins


def sync_workflow_flutter_version(path: Path, flutter_version: str) -> bool:
    text = path.read_text(encoding="utf-8")
    updated = text
    if _FLUTTER_ENV_LINE.search(updated):
        updated = _FLUTTER_ENV_LINE.sub(
            rf"\g<indent>FLUTTER_VERSION: '{flutter_version}'",
            updated,
        )
    else:
        # Inject into the top-level env: block (content before jobs:).
        jobs_match = re.search(r"^jobs:\s*$", updated, flags=re.MULTILINE)
        prefix = updated[: jobs_match.start()] if jobs_match is not None else updated
        env_match = re.search(r"^env:\s*\n", prefix, flags=re.MULTILINE)
        if env_match is None:
            raise SystemExit(
                f"Expected top-level env: block before jobs: in {path} "
                "(or an existing FLUTTER_VERSION pin)"
            )
        insert_at = env_match.end()
        updated = (
            updated[:insert_at]
            + f"  FLUTTER_VERSION: '{flutter_version}'\n"
            + updated[insert_at:]
        )

    # Replace any bare flutter-version literals with env reference.
    updated = re.sub(
        rf"^(?P<indent>\s*)flutter-version:\s*{VERSION_TOKEN_PATTERN}\s*$",
        r"\g<indent>flutter-version: ${{ env.FLUTTER_VERSION }}",
        updated,
        flags=re.MULTILINE,
    )

    if updated == text:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def sync_melos_baseline(flutter_version: str, dart_version: str) -> bool:
    path = PROJECT_ROOT / "docs" / "engineering" / "melos_dependency_baseline.txt"
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    if len(lines) < 2:
        raise SystemExit(f"Expected Dart/Flutter SDK header lines in {path}")
    new_header = [
        f"Dart SDK {dart_version}\n",
        f"Flutter SDK {flutter_version}\n",
    ]
    body = lines[2:]
    if lines[0].startswith("Dart SDK ") and lines[1].startswith("Flutter SDK "):
        updated_lines = new_header + body
    elif lines[0].startswith("Flutter SDK ") and lines[1].startswith("Dart SDK "):
        updated_lines = new_header + body
    else:
        raise SystemExit(
            f"Expected first two lines of {path} to be Dart SDK / Flutter SDK headers"
        )
    updated = "".join(updated_lines)
    current = path.read_text(encoding="utf-8")
    if updated == current:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def sync_literal_sinks(flutter_version: str, dart_version: str) -> list[Path]:
    changed_paths: list[Path] = []
    if sync_readme_badges(flutter_version, dart_version):
        changed_paths.append(Path("README.md"))
    if sync_tech_stack_table(flutter_version, dart_version):
        changed_paths.append(Path("docs/tech_stack.md"))
    for rel in WORKFLOW_FLUTTER_SINKS:
        if sync_workflow_flutter_version(PROJECT_ROOT / rel, flutter_version):
            changed_paths.append(Path(rel))
    if sync_melos_baseline(flutter_version, dart_version):
        changed_paths.append(Path("docs/engineering/melos_dependency_baseline.txt"))
    return changed_paths


def check_literal_sinks(flutter_version: str, dart_version: str) -> list[str]:
    """Return human-readable drift messages; empty means aligned."""
    errors: list[str] = []
    readme = (PROJECT_ROOT / "README.md").read_text(encoding="utf-8")
    if f"badge/Flutter-{flutter_version}-" not in readme:
        errors.append(f"README.md missing Flutter badge {flutter_version}")
    if f"badge/Dart-{dart_version}-" not in readme:
        errors.append(f"README.md missing Dart badge {dart_version}")

    tech = (PROJECT_ROOT / "docs" / "tech_stack.md").read_text(encoding="utf-8")
    if f"| Flutter | `{flutter_version}` |" not in tech:
        errors.append(f"docs/tech_stack.md missing Flutter table pin {flutter_version}")
    if f"| Dart | `{dart_version}` |" not in tech:
        errors.append(f"docs/tech_stack.md missing Dart table pin {dart_version}")

    for rel in WORKFLOW_FLUTTER_SINKS:
        text = (PROJECT_ROOT / rel).read_text(encoding="utf-8")
        pins = _collect_flutter_version_pins(text)
        if not pins:
            errors.append(f"{rel} missing FLUTTER_VERSION {flutter_version}")
        elif any(pin != flutter_version for pin in pins):
            errors.append(
                f"{rel} has stale/mismatched FLUTTER_VERSION line(s) "
                f"(expected {flutter_version}, found {pins})"
            )
        if re.search(
            rf"^\s*flutter-version:\s*{VERSION_TOKEN_PATTERN}\s*$",
            text,
            flags=re.MULTILINE,
        ):
            errors.append(f"{rel} still has bare flutter-version literal")

    melos = (
        PROJECT_ROOT / "docs" / "engineering" / "melos_dependency_baseline.txt"
    ).read_text(encoding="utf-8")
    header = melos.splitlines()[:2]
    if len(header) < 2:
        errors.append(
            "docs/engineering/melos_dependency_baseline.txt header too short "
            f"(need Dart SDK / Flutter SDK lines; got {len(header)})"
        )
    else:
        joined = "\n".join(header)
        if (
            f"Dart SDK {dart_version}" not in joined
            or f"Flutter SDK {flutter_version}" not in joined
        ):
            errors.append(
                "docs/engineering/melos_dependency_baseline.txt header missing "
                f"Dart SDK {dart_version} / Flutter SDK {flutter_version}"
            )
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Sync Flutter/Dart pins from docs/toolchain_versions.env",
    )
    parser.add_argument(
        "--from-sdk",
        action="store_true",
        help="Detect installed Flutter/Dart versions, sync sinks, then write env",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit non-zero if literal sinks drift from env (no writes)",
    )
    parser.add_argument(
        "--print-versions",
        action="store_true",
        help="Print flutter|dart from env and exit (for shell helpers)",
    )
    args = parser.parse_args(argv)

    exclusive = sum(bool(x) for x in (args.from_sdk, args.check, args.print_versions))
    if exclusive > 1:
        raise SystemExit("Use only one of --from-sdk, --check, or --print-versions")

    if args.from_sdk:
        flutter_version, dart_version = detect_sdk_versions()
    else:
        flutter_version, dart_version = extract_versions()

    if args.print_versions:
        print(f"{flutter_version}|{dart_version}")
        return 0

    if args.check:
        errors = check_literal_sinks(flutter_version, dart_version)
        if errors:
            print("Toolchain literal sink drift detected:")
            for error in errors:
                print(f"- {error}")
            return 1
        print(
            f"ok|toolchain-check|Flutter {flutter_version} / Dart {dart_version} "
            f"(source {ENV_PATH.relative_to(PROJECT_ROOT)})"
        )
        return 0

    changed_paths = sync_literal_sinks(flutter_version, dart_version)
    if args.from_sdk:
        # Write env after sinks so a mid-sync failure does not advance the SoT file.
        write_env_file(ENV_PATH, flutter_version, dart_version)
        print(
            f"Wrote {ENV_PATH.relative_to(PROJECT_ROOT)} "
            f"from SDK -> Flutter {flutter_version}, Dart {dart_version}"
        )
    print(
        f"Toolchain source: {ENV_PATH.relative_to(PROJECT_ROOT)} "
        f"-> Flutter {flutter_version}, Dart {dart_version}"
    )
    if changed_paths:
        print("Updated toolchain markers:")
        for path in changed_paths:
            print(f"- {path}")
    else:
        print("Toolchain markers already up to date.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
