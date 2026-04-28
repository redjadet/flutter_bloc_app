import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tool" / "check_widget_identity.dart"
FIXTURES = ROOT / "tool" / "fixtures" / "widget_identity"


class CheckWidgetIdentityTest(unittest.TestCase):
    def run_guard(self, fixture_name: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                "dart",
                "run",
                str(SCRIPT),
                str(FIXTURES / fixture_name),
            ],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_flags_unkeyed_local_state_owner_in_dynamic_children(self):
        result = self.run_guard("bad_dynamic_children_local_state.dart")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FixtureSearchRow", result.stderr)
        self.assertIn("without a stable key", result.stderr)

    def test_allows_keyed_local_state_owner_in_dynamic_children(self):
        result = self.run_guard("good_dynamic_children_local_state.dart")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("no issues found", result.stdout)


if __name__ == "__main__":
    unittest.main()
