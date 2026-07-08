#!/usr/bin/env python3
"""Add missing imports to library files (including symbols used in parts)."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
MOBILE = REPO / "apps/mobile"
TARGETS = [MOBILE / "lib", MOBILE / "test", MOBILE / "integration_test"]

RULES: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"\bcontext\.cubit\b|\bcontext\.bloc\b|\bcontext\.watchCubit\b|\bcontext\.selectState\b|\bcontext\.tryCubit\b|\bcontext\.tryBloc\b|\bcontext\.watchBloc\b|\bcontext\.watchState\b"), "import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';"),
    (re.compile(r"\bcontext\.l10n\b"), "import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';"),
    (re.compile(r"\bstringFromDynamic\b|\bmapFromDynamic\b|\blistFromDynamic\b|\bboolFromDynamic\b|\bintFromDynamic\b|\bdoubleFromDynamic\b|\bstringFromDynamicTrimmed\b|\bparseMapOfMaps\b"), "import 'package:utilities/utilities.dart';"),
    (re.compile(r"\bSubscriptionManager\b"), "import 'package:utilities/utilities.dart';"),
    (re.compile(r"\bNavigationUtils\b"), "import 'package:flutter_bloc_app/app/utils/navigation.dart';"),
    (re.compile(r"\bErrorHandling\b"), "import 'package:flutter_bloc_app/app/utils/error_handling.dart';"),
    (re.compile(r"\bContextUtils\b"), "import 'package:flutter_bloc_app/app/utils/context_utils.dart';"),
    (re.compile(r"\bCubitHelpers\b"), "import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';"),
    (re.compile(r"\bBackendAvailability\b"), "import 'package:flutter_bloc_app/app/config/backend_availability.dart';"),
    (re.compile(r"\bAppMemoryTrimLevel\b"), "import 'package:utilities/utilities.dart';"),
    (re.compile(r"\bTypeSafeBlocSelector\b|\bTypeSafeBlocBuilder\b|\bTypeSafeBlocConsumer\b|\bTypeSafeBlocListener\b"), "import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';"),
    (re.compile(r"\bRootAwareBackButton\b"), "import 'package:flutter_bloc_app/app/widgets/root_aware_back_button.dart';"),
    (re.compile(r"\bCommonPageLayout\b"), "import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';"),
    (re.compile(r"\bCommonCard\b|\bCommonDropdownField\b"), "import 'package:design_system/design_system.dart';"),
    (re.compile(r"\bNativePlatformService\b|\bNativePlatformInfo\b"), "import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';"),
    (re.compile(r"\bAppLogger\b"), "import 'package:app_shared_flutter/app_shared_flutter.dart';"),
    (re.compile(r"\.responsive[A-Z][A-Za-z]*|context\.pagePadding|context\.pageHorizontalPadding|context\.allGap"), "import 'package:design_system/responsive.dart';"),
    (re.compile(r"\bViewStatus\b|\bViewStatusX\b"), "import 'package:design_system/design_system.dart';"),
    (re.compile(r"\bUint8List\b"), "import 'dart:typed_data';"),
    (re.compile(r"\bSettableMetadata\b"), "import 'package:firebase_storage/firebase_storage.dart';"),
]


def is_part_file(text: str) -> bool:
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("//"):
            continue
        return s.startswith("part of")
    return False


def library_text(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    if is_part_file(text):
        return ""
    combined = text
    for match in re.finditer(r"^part '([^']+)';", text, re.MULTILINE):
        part_path = path.parent / match.group(1)
        if part_path.exists():
            combined += "\n" + part_path.read_text(encoding="utf-8")
    return combined


def ensure_import(text: str, imp: str) -> str:
    if imp in text:
        return text
    lines = text.splitlines(keepends=True)
    insert_at = 0
    for i, line in enumerate(lines):
        s = line.strip()
        if s.startswith("library ") or s.startswith("import ") or s.startswith("export ") or s.startswith("part "):
            insert_at = i + 1
            continue
        if s.startswith("//") or s == "":
            insert_at = max(insert_at, i + 1)
            continue
        break
    lines.insert(insert_at, imp + "\n")
    return "".join(lines)


def process(path: Path) -> bool:
    if is_part_file(path.read_text(encoding="utf-8")):
        return False
    combined = library_text(path)
    if not combined:
        return False
    original = path.read_text(encoding="utf-8")
    updated = original
    for pattern, imp in RULES:
        if pattern.search(combined):
            updated = ensure_import(updated, imp)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = 0
    for base in TARGETS:
        if not base.exists():
            continue
        for path in sorted(base.rglob("*.dart")):
            if process(path):
                changed += 1
    print(f"patched imports in {changed} library files")


if __name__ == "__main__":
    main()
