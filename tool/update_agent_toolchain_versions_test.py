import importlib.util
import sys
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
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class UpdateAgentToolchainVersionsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = _load_module()

    def test_agents_marker_preserves_trailing_prose_punctuation(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "AGENTS.md"
            target.write_text(
                "Flutter 3.41.7 / Dart 3.11.4. Clean Architecture:\n",
                encoding="utf-8",
            )

            changed = self.module.replace_required(
                target,
                self.module.AGENTS_TOOLCHAIN_PATTERN,
                r"\g<1>3.41.8\g<2>3.11.5\g<3>",
            )

            self.assertTrue(changed)
            self.assertEqual(
                target.read_text(encoding="utf-8"),
                "Flutter 3.41.8 / Dart 3.11.5. Clean Architecture:\n",
            )

    def test_extract_version_reads_readme_badge_marker(self):
        text = (
            "[![Flutter](https://img.shields.io/badge/Flutter-3.41.8-blue.svg)]"
            "(https://flutter.dev)\n"
        )

        self.assertEqual(self.module._extract_version(text, "Flutter"), "3.41.8")


if __name__ == "__main__":
    unittest.main()
