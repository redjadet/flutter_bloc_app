#!/usr/bin/env python3
"""Regression harness for tool/run_file_length_lint.sh plugin wiring."""

from __future__ import annotations

import importlib.util
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tool" / "run_file_length_lint.sh"
MAX_LINES = 225
PROBE_LINES = MAX_LINES + 3

LONG_PROBE = ROOT / "lib" / "_file_length_lint_regression_probe.dart"
COMMENT_PROBE = ROOT / "lib" / "_file_length_lint_comment_probe.dart"
EXCLUDE_PROBE = ROOT / "lib" / "_file_length_lint_exclude_probe.g.dart"


def _load_physical_checker():
    module_path = ROOT / "tool" / "check_file_length_physical.py"
    spec = importlib.util.spec_from_file_location(
        "check_file_length_physical",
        module_path,
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"unable to load {module_path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def run_script() -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["bash", str(SCRIPT)],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )


def write_long_probe(path: Path, line_count: int) -> None:
    lines = [f"// regression probe line {i}" for i in range(1, line_count + 1)]
    lines.append("void main() {}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


class RunFileLengthLintTest(unittest.TestCase):
    def tearDown(self) -> None:
        LONG_PROBE.unlink(missing_ok=True)
        COMMENT_PROBE.unlink(missing_ok=True)
        EXCLUDE_PROBE.unlink(missing_ok=True)

    def test_long_physical_file_fails_with_file_too_long(self) -> None:
        write_long_probe(LONG_PROBE, PROBE_LINES)
        physical_lines = len(LONG_PROBE.read_text(encoding="utf-8").splitlines())
        self.assertGreater(
            physical_lines,
            MAX_LINES,
            "probe must exceed max_lines using physical newlines",
        )

        result = run_script()
        combined = result.stdout + result.stderr

        self.assertNotEqual(result.returncode, 0, combined)
        self.assertIn("FILE_TOO_LONG", combined)
        self.assertIn("_file_length_lint_regression_probe.dart", combined)

    def test_comment_tokens_on_one_physical_line_do_not_trigger(self) -> None:
        COMMENT_PROBE.write_text(
            "// " + "x " * 500 + "\nvoid main() {}\n",
            encoding="utf-8",
        )

        result = run_script()
        combined = result.stdout + result.stderr

        for line in combined.splitlines():
            if "FILE_TOO_LONG" in line and "_file_length_lint_comment_probe.dart" in line:
                self.fail(f"unexpected FILE_TOO_LONG for comment probe: {line}")

        self.assertEqual(
            result.returncode,
            0,
            f"script should pass; probe uses one physical line\n{combined}",
        )

    def test_glob_excludes_lib_root_generated_files(self) -> None:
        checker = _load_physical_checker()
        patterns = list(checker.DEFAULT_EXCLUDES)

        self.assertTrue(
            checker._matches_any("lib/schema.g.dart", patterns),
            "**/*.g.dart must exclude generated files directly under lib/",
        )
        self.assertTrue(
            checker._matches_any("lib/features/foo/foo.g.dart", patterns),
            "**/*.g.dart must exclude nested generated files",
        )
        self.assertEqual(
            checker._glob_to_regex("**/*.g.dart").pattern,
            r"^.*/[^/]*\.g\.dart$",
            "glob regex must match file_length_lint plugin Glob",
        )

    def test_long_generated_file_in_lib_root_is_excluded(self) -> None:
        write_long_probe(EXCLUDE_PROBE, PROBE_LINES)

        result = run_script()
        combined = result.stdout + result.stderr

        self.assertEqual(
            result.returncode,
            0,
            f"generated .g.dart probe must be excluded\n{combined}",
        )
        self.assertNotIn("_file_length_lint_exclude_probe.g.dart", combined)


if __name__ == "__main__":
    unittest.main()
