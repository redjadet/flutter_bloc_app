"""Regression: integration runner must split dart-defines into separate argv."""

from __future__ import annotations

import os
import subprocess
import textwrap
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RUNNER_PATH = PROJECT_ROOT / "tool" / "run_integration_tests.sh"


class RunIntegrationTestsDartDefinesTest(unittest.TestCase):
    def test_dart_defines_are_split_into_separate_argv_entries(self) -> None:
        """Packed one-line defines corrupt the first key and break Android auth."""
        script = textwrap.dedent(
            f"""
            set -euo pipefail
            export INTEGRATION_TESTS_SOURCE_ONLY=1
            # Marker keys guaranteed present even when direnv reloads .envrc.
            export FIREBASE_ANDROID_API_KEY='test-android-key'
            export FIREBASE_ANDROID_APP_ID='1:123:android:abc'
            export HUGGINGFACE_API_KEY='server-only-test-token'
            export CHAT_FASTAPICLOUD_DEMO_SECRET='server-only-shared-secret'
            source "{RUNNER_PATH}"
            trap - EXIT
            [ "${{#INTEGRATION_DART_DEFINES[@]}}" -ge 2 ]
            found_api=0
            found_app=0
            for def in "${{INTEGRATION_DART_DEFINES[@]}}"; do
              case "$def" in
                --dart-define=HUGGINGFACE_API_KEY=*)
                  echo "provider credential forwarded to Flutter argv" >&2
                  exit 8
                  ;;
                --dart-define=CHAT_FASTAPICLOUD_DEMO_SECRET=*)
                  echo "shared backend secret forwarded to Flutter argv" >&2
                  exit 9
                  ;;
                *' --dart-define='*)
                  echo "packed dart-define argv: $def" >&2
                  exit 2
                  ;;
                --dart-define=FIREBASE_ANDROID_API_KEY=test-android-key)
                  found_api=1
                  ;;
                --dart-define=FIREBASE_ANDROID_APP_ID=1:123:android:abc)
                  found_app=1
                  ;;
                --dart-define=*=*)
                  ;;
                *)
                  echo "unexpected dart-define token: $def" >&2
                  exit 3
                  ;;
              esac
            done
            [ "$found_api" -eq 1 ] || {{
              echo "missing exact ANDROID_API_KEY argv" >&2
              exit 4
            }}
            [ "$found_app" -eq 1 ] || {{
              echo "missing exact ANDROID_APP_ID argv" >&2
              exit 5
            }}
            case ",$INTEGRATION_DART_DEFINE_KEYS," in
              *,FIREBASE_ANDROID_API_KEY,*) ;;
              *) echo "missing ANDROID_API_KEY in keys: $INTEGRATION_DART_DEFINE_KEYS" >&2; exit 6 ;;
            esac
            case ",$INTEGRATION_DART_DEFINE_KEYS," in
              *,FIREBASE_ANDROID_APP_ID,*) ;;
              *) echo "missing ANDROID_APP_ID in keys: $INTEGRATION_DART_DEFINE_KEYS" >&2; exit 7 ;;
            esac
            """
        )

        env = dict(os.environ)
        env["INTEGRATION_TESTS_SOURCE_ONLY"] = "1"
        env["FIREBASE_ANDROID_API_KEY"] = "test-android-key"
        env["FIREBASE_ANDROID_APP_ID"] = "1:123:android:abc"
        env["HUGGINGFACE_API_KEY"] = "server-only-test-token"
        env["CHAT_FASTAPICLOUD_DEMO_SECRET"] = "server-only-shared-secret"
        # Keep this fixture independent from a developer's allowed .envrc.
        env["PATH"] = "/usr/bin:/bin"

        result = subprocess.run(
            ["bash", "-c", script],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
            env=env,
        )

        self.assertEqual(
            result.returncode,
            0,
            msg=f"stdout={result.stdout!r}\nstderr={result.stderr!r}",
        )


if __name__ == "__main__":
    unittest.main()
