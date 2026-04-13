import os
import subprocess
import tempfile
import textwrap
import time
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RUNNER_PATH = PROJECT_ROOT / "tool" / "run_integration_tests.sh"


def _lock_shell_script(project_root: Path, body: str) -> str:
    return textwrap.dedent(
        f"""
        set -euo pipefail
        export INTEGRATION_TESTS_SOURCE_ONLY=1
        source "{RUNNER_PATH}"
        trap - EXIT
        PROJECT_ROOT="{project_root}"
        cd "{project_root}"
        mkdir -p "$PROJECT_ROOT/.dart_tool"
        {body}
        """
    )


class RunIntegrationTestsLockTest(unittest.TestCase):
    def test_second_run_is_blocked_while_first_lock_is_active(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            holder_script = _lock_shell_script(
                project_root,
                """
                acquire_integration_lock "integration_test/holder_test.dart"
                sleep 5
                release_integration_lock
                """,
            )
            contender_script = _lock_shell_script(
                project_root,
                'acquire_integration_lock "integration_test/contender_test.dart"',
            )

            holder = subprocess.Popen(
                ["bash", "-c", holder_script],
                cwd=PROJECT_ROOT,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            try:
                lock_dir = project_root / ".dart_tool" / "integration_test_lock"
                deadline = time.time() + 5
                while time.time() < deadline and not lock_dir.exists():
                    time.sleep(0.05)
                self.assertTrue(lock_dir.exists(), "holder never acquired the lock")

                contender = subprocess.run(
                    ["bash", "-c", contender_script],
                    cwd=PROJECT_ROOT,
                    capture_output=True,
                    text=True,
                    check=False,
                )

                self.assertEqual(contender.returncode, 2)
                self.assertIn(
                    "Another integration test run is already in progress.",
                    contender.stderr,
                )
            finally:
                holder.terminate()
                holder.wait(timeout=10)

    def test_stale_lock_is_removed_and_reacquired(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            lock_dir = project_root / ".dart_tool" / "integration_test_lock"
            lock_dir.mkdir(parents=True)
            (lock_dir / "details.txt").write_text(
                "\n".join(
                    (
                        "started_at=2026-04-13T00:00:00Z",
                        "pid=999999",
                        "user=tester",
                        "host=test-host",
                        "cwd=/tmp/fake",
                        "command=./bin/integration_tests",
                    )
                )
                + "\n",
                encoding="utf-8",
            )

            script = _lock_shell_script(
                project_root,
                """
                acquire_integration_lock "integration_test/stale_recovery_test.dart"
                [ -f "$INTEGRATION_LOCK_DIR/details.txt" ]
                release_integration_lock
                """,
            )

            result = subprocess.run(
                ["bash", "-c", script],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, msg=result.stderr)
            self.assertIn("Removing stale integration test lock", result.stderr)
            self.assertFalse(lock_dir.exists())


if __name__ == "__main__":
    unittest.main()
