import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RUNNER_PATH = PROJECT_ROOT / "tool" / "run_integration_tests.sh"


def _device_shell_script(project_root: Path, body: str, prelude: str = "") -> str:
    return textwrap.dedent(
        f"""
        set -euo pipefail
        export INTEGRATION_TESTS_SOURCE_ONLY=1
        {prelude}
        source "{RUNNER_PATH}"
        trap - EXIT
        PROJECT_ROOT="{project_root}"
        cd "{project_root}"
        {body}
        """
    )


class RunIntegrationTestsDeviceTest(unittest.TestCase):
    def test_select_device_skips_flutter_devices_for_booted_ios_simulator(self) -> None:
        mock_udid = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            script = _device_shell_script(
                project_root,
                f"""
                export CHECKLIST_INTEGRATION_DEVICE="{mock_udid}"
                xcrun() {{
                  if [ "$1" = "simctl" ] && [ "$2" = "list" ] && [ "$3" = "devices" ] && [ "$4" = "booted" ]; then
                    printf '%s\\n' '{{"devices":{{"com.apple.CoreSimulator.SimRuntime.iOS-26-5":[{{"state":"Booted","udid":"{mock_udid}","isAvailable":true}}]}}}}'
                    return 0
                  fi
                  echo "unexpected xcrun call: $*" >&2
                  exit 98
                }}
                export -f xcrun
                flutter() {{
                  if [ "${{1:-}}" = "devices" ]; then
                    echo "flutter devices must not run when UDID fast-path succeeds" >&2
                    exit 99
                  fi
                  echo "unexpected flutter call: $*" >&2
                  exit 97
                }}
                export -f flutter
                DEVICE_ID="$(select_device_id)"
                [ "$DEVICE_ID" = "{mock_udid}" ]
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
            self.assertIn("skipped flutter devices discovery", result.stderr)

    def test_select_device_accepts_integration_test_device_alias(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            script = _device_shell_script(
                project_root,
                """
                export INTEGRATION_TEST_DEVICE="emulator-5554"
                adb() {
                  if [ "$1" = "devices" ]; then
                    printf '%s\n' "List of devices attached"
                    printf '%s\n' "emulator-5554 device"
                    return 0
                  fi
                  echo "unexpected adb call: $*" >&2
                  exit 98
                }
                export -f adb
                flutter() {
                  if [ "${1:-}" = "devices" ]; then
                    echo "flutter devices must not run when adb fast-path succeeds" >&2
                    exit 99
                  fi
                  echo "unexpected flutter call: $*" >&2
                  exit 97
                }
                export -f flutter
                DEVICE_ID="$(select_device_id)"
                [ "$DEVICE_ID" = "emulator-5554" ]
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
            self.assertIn("adb-visible", result.stderr)

    def test_select_device_falls_back_to_flutter_devices_when_fast_path_misses(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            script = _device_shell_script(
                project_root,
                """
                export CHECKLIST_INTEGRATION_DEVICE="emulator-5554"
                uname() {
                  if [ "${1:-}" = "-s" ]; then
                    printf '%s\n' Linux
                    return 0
                  fi
                  command uname "$@"
                }
                export -f uname
                adb() {
                  if [ "$1" = "devices" ]; then
                    printf '%s\n' "List of devices attached"
                    return 0
                  fi
                  echo "unexpected adb call: $*" >&2
                  exit 98
                }
                export -f adb
                flutter() {
                  if [ "${1:-}" = "devices" ]; then
                    printf ran > "$PROJECT_ROOT/flutter_devices_ran"
                    printf '%s\n' "sdk gphone64 arm64 • emulator-5554 • android-arm64 • Android 15 (API 35) (emulator)"
                    return 0
                  fi
                  echo "unexpected flutter call: $*" >&2
                  exit 97
                }
                export -f flutter
                DEVICE_ID="$(select_device_id)"
                [ "$DEVICE_ID" = "emulator-5554" ]
                [ -f "$PROJECT_ROOT/flutter_devices_ran" ]
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
            self.assertNotIn("skipped flutter devices discovery", result.stderr)

    def test_select_device_falls_back_to_flutter_devices_when_ios_sim_boot_fails(
        self,
    ) -> None:
        mock_udid = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            script = _device_shell_script(
                project_root,
                f"""
                export CHECKLIST_INTEGRATION_DEVICE="{mock_udid}"
                export IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS=0
                uname() {{
                  if [ "${{1:-}}" = "-s" ]; then
                    printf '%s\\n' Darwin
                    return 0
                  fi
                  command uname "$@"
                }}
                export -f uname
                xcrun() {{
                  if [ "$1" = "simctl" ] && [ "$2" = "list" ] && [ "$3" = "devices" ]; then
                    case "${{4:-}}" in
                      booted)
                        printf '%s\\n' '{{"devices":{{}}}}'
                        return 0
                        ;;
                      available)
                        printf '%s\\n' '{{"devices":{{"com.apple.CoreSimulator.SimRuntime.iOS-26-5":[{{"state":"Shutdown","udid":"{mock_udid}","isAvailable":true}}]}}}}'
                        return 0
                        ;;
                    esac
                  fi
                  if [ "$1" = "simctl" ] && [ "$2" = "boot" ] && [ "$3" = "{mock_udid}" ]; then
                    return 0
                  fi
                  echo "unexpected xcrun call: $*" >&2
                  exit 98
                }}
                export -f xcrun
                flutter() {{
                  if [ "${{1:-}}" = "devices" ]; then
                    printf ran > "$PROJECT_ROOT/flutter_devices_ran"
                    printf '%s\\n' "iPhone 17 Pro • {mock_udid} • com.apple.CoreSimulator.SimRuntime.iOS-26-5 • iOS 26.5 (simulator)"
                    return 0
                  fi
                  echo "unexpected flutter call: $*" >&2
                  exit 97
                }}
                export -f flutter
                DEVICE_ID="$(select_device_id)"
                [ "$DEVICE_ID" = "{mock_udid}" ]
                [ -f "$PROJECT_ROOT/flutter_devices_ran" ]
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
            self.assertIn(
                "falling back to flutter devices discovery",
                result.stderr,
            )
            self.assertNotIn(
                "(booted iOS simulator; skipped flutter devices discovery)",
                result.stderr,
            )

    def test_linux_github_actions_skip_honors_integration_test_device_alias(self) -> None:
        script = _device_shell_script(
            PROJECT_ROOT,
            """
            [ "$(requested_integration_device_id)" = "emulator-5554" ]
            """,
            prelude="""
            export GITHUB_ACTIONS=true
            export GITHUB_EVENT_NAME=workflow_dispatch
            export INTEGRATION_TEST_DEVICE=emulator-5554
            uname() {
              if [ "${1:-}" = "-s" ]; then
                printf '%s\n' Linux
                return 0
              fi
              command uname "$@"
            }
            export -f uname
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

    def test_select_device_skips_flutter_devices_for_adb_visible_emulator(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            script = _device_shell_script(
                project_root,
                """
                export CHECKLIST_INTEGRATION_DEVICE="emulator-5554"
                adb() {
                  if [ "$1" = "devices" ]; then
                    printf '%s\n' "List of devices attached"
                    printf '%s\n' "emulator-5554 device"
                    return 0
                  fi
                  echo "unexpected adb call: $*" >&2
                  exit 98
                }
                export -f adb
                flutter() {
                  if [ "${1:-}" = "devices" ]; then
                    echo "flutter devices must not run when adb fast-path succeeds" >&2
                    exit 99
                  fi
                  echo "unexpected flutter call: $*" >&2
                  exit 97
                }
                export -f flutter
                DEVICE_ID="$(select_device_id)"
                [ "$DEVICE_ID" = "emulator-5554" ]
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
            self.assertIn("adb-visible", result.stderr)

    def test_select_device_prefers_simulator_over_physical_iphone(self) -> None:
        sim_udid = "CCCCCCCC-DDDD-EEEE-FFFF-000000000001"
        physical_udid = "00008120-001144943C83C01E"
        with tempfile.TemporaryDirectory() as tmp_dir:
            project_root = Path(tmp_dir)
            script = _device_shell_script(
                project_root,
                f"""
                uname() {{
                  if [ "${{1:-}}" = "-s" ]; then
                    printf '%s\\n' Darwin
                    return 0
                  fi
                  command uname "$@"
                }}
                export -f uname
                xcrun() {{
                  if [ "$1" = "simctl" ] && [ "$2" = "list" ] && [ "$3" = "devices" ]; then
                    case "${{4:-}}" in
                      booted)
                        printf '%s\\n' '{{"devices":{{}}}}'
                        return 0
                        ;;
                      available)
                        printf '%s\\n' '{{"devices":{{"com.apple.CoreSimulator.SimRuntime.iOS-26-5":[{{"state":"Shutdown","udid":"{sim_udid}","isAvailable":true,"name":"iPhone 17 Pro"}}]}}}}'
                        return 0
                        ;;
                    esac
                  fi
                  echo "unexpected xcrun call: $*" >&2
                  exit 98
                }}
                export -f xcrun
                flutter() {{
                  if [ "${{1:-}}" = "devices" ]; then
                    printf '%s\\n' "İlker iPhone Pro • {physical_udid} • ios • iOS 26.5.2"
                    printf '%s\\n' "iPhone 17 Pro • {sim_udid} • com.apple.CoreSimulator.SimRuntime.iOS-26-5 • iOS 26.5 (simulator)"
                    return 0
                  fi
                  echo "unexpected flutter call: $*" >&2
                  exit 97
                }}
                export -f flutter
                DEVICE_ID="$(select_device_id)"
                [ "$DEVICE_ID" = "{sim_udid}" ]
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


if __name__ == "__main__":
    unittest.main()
