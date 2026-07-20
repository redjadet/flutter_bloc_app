import importlib.util
import tempfile
import unittest
from pathlib import Path


def _load_module():
    script_path = Path(__file__).with_name("update_agent_toolchain_versions.py")
    spec = importlib.util.spec_from_file_location(
        "update_agent_toolchain_versions",
        script_path,
    )
    if spec is None or spec.loader is None:
        msg = f"Could not load module spec for {script_path}"
        raise RuntimeError(msg)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class UpdateAgentToolchainVersionsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = _load_module()

    def _swap_project_root(self, root: Path):
        original = self.module.PROJECT_ROOT
        setattr(self.module, "PROJECT_ROOT", root)
        return original

    def test_parse_env_file_ignores_comments_and_requires_keys(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "toolchain_versions.env"
            path.write_text(
                "# comment\n\nFLUTTER_VERSION=3.44.6\nDART_VERSION=3.12.2\n",
                encoding="utf-8",
            )
            values = self.module.parse_env_file(path)
            self.assertEqual(values["FLUTTER_VERSION"], "3.44.6")
            self.assertEqual(values["DART_VERSION"], "3.12.2")

    def test_parse_env_file_rejects_missing_dart(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "toolchain_versions.env"
            path.write_text("FLUTTER_VERSION=3.44.6\n", encoding="utf-8")
            with self.assertRaises(SystemExit):
                self.module.parse_env_file(path)

    def test_parse_env_file_rejects_duplicate_keys(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "toolchain_versions.env"
            path.write_text(
                "FLUTTER_VERSION=3.44.6\nDART_VERSION=3.12.2\nFLUTTER_VERSION=3.41.9\n",
                encoding="utf-8",
            )
            with self.assertRaises(SystemExit):
                self.module.parse_env_file(path)

    def test_parse_env_file_rejects_malformed_line(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "toolchain_versions.env"
            path.write_text(
                "FLUTTER_VERSION=3.44.6\nNOT_A_KEY\nDART_VERSION=3.12.2\n",
                encoding="utf-8",
            )
            with self.assertRaises(SystemExit):
                self.module.parse_env_file(path)

    def test_sync_readme_badges(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            readme = root / "README.md"
            readme.write_text(
                "[![Flutter](https://img.shields.io/badge/Flutter-3.41.9-blue.svg)]"
                "(https://flutter.dev)\n"
                "[![Dart](https://img.shields.io/badge/Dart-3.11.5-blue.svg)]"
                "(https://dart.dev)\n",
                encoding="utf-8",
            )
            original_root = self._swap_project_root(root)
            try:
                changed = self.module.sync_readme_badges("3.44.6", "3.12.2")
            finally:
                setattr(self.module, "PROJECT_ROOT", original_root)
            self.assertTrue(changed)
            text = readme.read_text(encoding="utf-8")
            self.assertIn("badge/Flutter-3.44.6-", text)
            self.assertIn("badge/Dart-3.12.2-", text)

    def test_sync_workflow_flutter_only_does_not_require_dart(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "ci.yml"
            path.write_text(
                "env:\n  FLUTTER_VERSION: '3.41.9'\n",
                encoding="utf-8",
            )
            changed = self.module.sync_workflow_flutter_version(path, "3.44.6")
            self.assertTrue(changed)
            text = path.read_text(encoding="utf-8")
            self.assertIn("FLUTTER_VERSION: '3.44.6'", text)
            self.assertNotIn("DART_VERSION", text)

    def test_sync_workflow_updates_all_flutter_version_pins(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "ci.yml"
            path.write_text(
                "env:\n"
                "  FLUTTER_VERSION: '3.41.9'\n"
                "jobs:\n"
                "  build:\n"
                "    env:\n"
                "      FLUTTER_VERSION: '3.40.0'\n",
                encoding="utf-8",
            )
            changed = self.module.sync_workflow_flutter_version(path, "3.44.6")
            self.assertTrue(changed)
            text = path.read_text(encoding="utf-8")
            self.assertEqual(text.count("FLUTTER_VERSION: '3.44.6'"), 2)
            self.assertNotIn("3.41.9", text)
            self.assertNotIn("3.40.0", text)

    def test_sync_deploy_web_normalizes_bare_flutter_version(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "deploy_web.yml"
            path.write_text(
                "env:\n"
                "  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true\n"
                "jobs:\n"
                "  build:\n"
                "    steps:\n"
                "      - uses: subosito/flutter-action@v2\n"
                "        with:\n"
                "          flutter-version: 3.41.9\n",
                encoding="utf-8",
            )
            changed = self.module.sync_workflow_flutter_version(path, "3.44.6")
            self.assertTrue(changed)
            text = path.read_text(encoding="utf-8")
            self.assertIn("FLUTTER_VERSION: '3.44.6'", text)
            self.assertIn("flutter-version: ${{ env.FLUTTER_VERSION }}", text)
            self.assertNotRegex(text, r"flutter-version:\s*3\.")

    def test_sync_melos_baseline_header_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = root / "docs" / "engineering" / "melos_dependency_baseline.txt"
            path.parent.mkdir(parents=True)
            path.write_text(
                "Dart SDK 3.11.5\nFlutter SDK 3.41.9\n\ndependencies:\n- foo 1.0.0\n",
                encoding="utf-8",
            )
            original_root = self._swap_project_root(root)
            try:
                changed = self.module.sync_melos_baseline("3.44.6", "3.12.2")
            finally:
                setattr(self.module, "PROJECT_ROOT", original_root)
            self.assertTrue(changed)
            lines = path.read_text(encoding="utf-8").splitlines()
            self.assertEqual(lines[0], "Dart SDK 3.12.2")
            self.assertEqual(lines[1], "Flutter SDK 3.44.6")
            self.assertIn("- foo 1.0.0", lines)

    def _write_aligned_sinks(self, root: Path) -> None:
        (root / "README.md").write_text(
            "badge/Flutter-3.44.6- and badge/Dart-3.12.2-\n",
            encoding="utf-8",
        )
        (root / "docs").mkdir()
        (root / "docs" / "tech_stack.md").write_text(
            "| Flutter | `3.44.6` |\n| Dart | `3.12.2` |\n",
            encoding="utf-8",
        )
        workflows = root / ".github" / "workflows"
        workflows.mkdir(parents=True)
        for name in (
            "ci.yml",
            "dependency-updates.yml",
            "drift.yml",
            "deploy_web.yml",
        ):
            (workflows / name).write_text(
                "env:\n  FLUTTER_VERSION: '3.44.6'\n",
                encoding="utf-8",
            )
        engineering = root / "docs" / "engineering"
        engineering.mkdir(parents=True)
        (engineering / "melos_dependency_baseline.txt").write_text(
            "Dart SDK 3.12.2\nFlutter SDK 3.44.6\n",
            encoding="utf-8",
        )

    def test_check_literal_sinks_reports_flutter_only_workflow_ok(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self._write_aligned_sinks(root)
            original_root = self._swap_project_root(root)
            try:
                errors = self.module.check_literal_sinks("3.44.6", "3.12.2")
            finally:
                setattr(self.module, "PROJECT_ROOT", original_root)
            self.assertEqual(errors, [])

    def test_check_literal_sinks_rejects_short_melos_header(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self._write_aligned_sinks(root)
            (root / "docs" / "engineering" / "melos_dependency_baseline.txt").write_text(
                "Dart SDK 3.12.2\n",
                encoding="utf-8",
            )
            original_root = self._swap_project_root(root)
            try:
                errors = self.module.check_literal_sinks("3.44.6", "3.12.2")
            finally:
                setattr(self.module, "PROJECT_ROOT", original_root)
            self.assertTrue(any("header too short" in e for e in errors))

    def test_check_literal_sinks_rejects_stale_second_workflow_pin(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self._write_aligned_sinks(root)
            (root / ".github" / "workflows" / "ci.yml").write_text(
                "env:\n"
                "  FLUTTER_VERSION: '3.44.6'\n"
                "jobs:\n"
                "  build:\n"
                "    env:\n"
                "      FLUTTER_VERSION: '3.41.9'\n",
                encoding="utf-8",
            )
            original_root = self._swap_project_root(root)
            try:
                errors = self.module.check_literal_sinks("3.44.6", "3.12.2")
            finally:
                setattr(self.module, "PROJECT_ROOT", original_root)
            self.assertTrue(any("stale/mismatched" in e for e in errors))

    def test_check_literal_sinks_ignores_commented_flutter_version(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self._write_aligned_sinks(root)
            (root / ".github" / "workflows" / "ci.yml").write_text(
                "env:\n"
                "  # FLUTTER_VERSION: '3.41.9'\n"
                "  FLUTTER_VERSION: '3.44.6'\n",
                encoding="utf-8",
            )
            original_root = self._swap_project_root(root)
            try:
                errors = self.module.check_literal_sinks("3.44.6", "3.12.2")
            finally:
                setattr(self.module, "PROJECT_ROOT", original_root)
            self.assertEqual(errors, [])

    def test_parse_sdk_version_output_from_flutter_and_dart(self):
        flutter_out = (
            "Flutter 3.44.6 • channel stable\n"
            "Tools • Dart 3.12.2 • DevTools 2.57.0\n"
        )
        dart_out = (
            'Dart SDK version: 3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) '
            'on "macos_arm64"\n'
        )
        flutter, dart = self.module.parse_sdk_version_output(flutter_out, dart_out)
        self.assertEqual(flutter, "3.44.6")
        self.assertEqual(dart, "3.12.2")

    def test_parse_sdk_version_output_falls_back_to_flutter_out_for_dart(self):
        flutter_out = "Flutter 3.44.6 • channel stable • Dart 3.12.2\n"
        flutter, dart = self.module.parse_sdk_version_output(flutter_out, "no dart here")
        self.assertEqual(flutter, "3.44.6")
        self.assertEqual(dart, "3.12.2")


if __name__ == "__main__":
    unittest.main()
