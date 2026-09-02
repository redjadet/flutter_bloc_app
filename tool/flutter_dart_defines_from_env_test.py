"""Regression: dart-define helper loads gitignored .env before emitting defines."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
HELPER_PATH = PROJECT_ROOT / "tool" / "flutter_dart_defines_from_env.sh"
FLUTTER_WRAPPER = PROJECT_ROOT / "tool" / "direnv" / "bin" / "flutter"
WEB_BUILD_HELPER = PROJECT_ROOT / "tool" / "build_web_github_pages.sh"


class FlutterDartDefinesFromEnvTest(unittest.TestCase):
    def _run_helper(
        self,
        dotenv_dir: Path,
        *,
        extra_env: dict[str, str] | None = None,
        release_safe: bool = False,
    ) -> subprocess.CompletedProcess[str]:
        env = {
            "PATH": "/usr/bin:/bin",
            "HOME": os.environ.get("HOME", "/tmp"),
            "FLUTTER_BLOC_APP_DOTENV_DIR": str(dotenv_dir),
        }
        if extra_env:
            env.update(extra_env)
        args = ["bash", str(HELPER_PATH)]
        if release_safe:
            args.append("--release")
        return subprocess.run(
            args,
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
            env=env,
        )

    def test_loads_dotenv_before_emitting_defines(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_dir = Path(tmp)
            (dotenv_dir / ".env").write_text(
                "AI_DECISION_API_BASE_URL=http://dotenv-regression.test\n",
                encoding="utf-8",
            )

            result = self._run_helper(dotenv_dir)

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(
                "--dart-define=AI_DECISION_API_BASE_URL=http://dotenv-regression.test",
                result.stdout,
            )

    def test_dotenv_local_overrides_base_env(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_dir = Path(tmp)
            (dotenv_dir / ".env").write_text(
                "AI_DECISION_API_BASE_URL=http://dotenv-base.test\n",
                encoding="utf-8",
            )
            (dotenv_dir / ".env.local").write_text(
                "AI_DECISION_API_BASE_URL=http://dotenv-local.test\n",
                encoding="utf-8",
            )

            result = self._run_helper(dotenv_dir)

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(
                "--dart-define=AI_DECISION_API_BASE_URL=http://dotenv-local.test",
                result.stdout,
            )
            self.assertNotIn("dotenv-base.test", result.stdout)

    def test_rejects_whitespace_values_in_space_separated_output(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_dir = Path(tmp)
            (dotenv_dir / ".env").write_text(
                'AI_DECISION_API_BASE_URL="value with spaces"\n',
                encoding="utf-8",
            )

            result = self._run_helper(dotenv_dir)

            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertEqual(result.stdout, "")
            self.assertIn("contains whitespace", result.stderr)

    def test_release_policy_rejects_every_client_secret_key(self) -> None:
        prohibited = (
            "HUGGINGFACE_API_KEY",
            "GEMINI_API_KEY",
            "GOOGLE_API_KEY",
            "CHAT_FASTAPICLOUD_DEMO_SECRET",
            "CHAT_RENDER_DEMO_SECRET",
        )
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_dir = Path(tmp)
            for key in prohibited:
                with self.subTest(key=key):
                    result = self._run_helper(
                        dotenv_dir,
                        extra_env={key: "test-only-value"},
                        release_safe=True,
                    )

                    self.assertEqual(result.returncode, 2, result.stderr)
                    self.assertEqual(result.stdout, "")
                    self.assertIn(key, result.stderr)

    def test_release_policy_keeps_public_client_configuration(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            result = self._run_helper(
                Path(tmp),
                extra_env={"FIREBASE_PROJECT_ID": "public-test-project"},
                release_safe=True,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(
                "--dart-define=FIREBASE_PROJECT_ID=public-test-project",
                result.stdout,
            )

    def _run_flutter_wrapper(
        self,
        temp_dir: Path,
        *args: str,
    ) -> subprocess.CompletedProcess[str]:
        fake_bin = temp_dir / "fake-bin"
        fake_bin.mkdir()
        fake_flutter = fake_bin / "flutter"
        fake_flutter.write_text(
            "#!/usr/bin/env bash\nprintf '%s\\n' \"$@\"\n",
            encoding="utf-8",
        )
        fake_flutter.chmod(0o755)
        env = {
            "PATH": f"{FLUTTER_WRAPPER.parent}:{fake_bin}:/usr/bin:/bin",
            "HOME": os.environ.get("HOME", "/tmp"),
            "FLUTTER_BLOC_APP_DOTENV_DIR": str(temp_dir),
        }
        return subprocess.run(
            [str(FLUTTER_WRAPPER), *args],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
            env=env,
        )

    def test_flutter_wrapper_rejects_provider_key_for_release_build(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            temp_dir = Path(tmp)
            (temp_dir / ".env").write_text(
                "GEMINI_API_KEY=test-provider-key\n",
                encoding="utf-8",
            )

            result = self._run_flutter_wrapper(temp_dir, "build", "web")

            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertEqual(result.stdout, "")
            self.assertIn("GEMINI_API_KEY", result.stderr)

    def test_flutter_wrapper_allows_provider_key_for_debug_build(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            temp_dir = Path(tmp)
            (temp_dir / ".env").write_text(
                "GEMINI_API_KEY=test-provider-key\n",
                encoding="utf-8",
            )

            result = self._run_flutter_wrapper(
                temp_dir,
                "build",
                "web",
                "--debug",
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(
                "--dart-define=GEMINI_API_KEY=test-provider-key",
                result.stdout.splitlines(),
            )

    def test_flutter_wrapper_ignores_dotenv_for_unrelated_command(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            temp_dir = Path(tmp)
            (temp_dir / ".env").write_text("not valid dotenv\n", encoding="utf-8")

            result = self._run_flutter_wrapper(temp_dir, "doctor")

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("doctor", result.stdout.splitlines())

    def test_web_release_helper_requests_release_policy(self) -> None:
        text = WEB_BUILD_HELPER.read_text(encoding="utf-8")
        self.assertIn(
            'flutter_dart_defines_from_env.sh" --release',
            text,
        )


if __name__ == "__main__":
    unittest.main()
