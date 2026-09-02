"""Regression: shared dotenv loader override order and script wiring."""

from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
LOAD_ENV_FILE = PROJECT_ROOT / "tool" / "load_env_file.sh"
LOAD_REPO_DOTENV = PROJECT_ROOT / "tool" / "load_repo_dotenv.sh"
RELEASE_SCRIPT = PROJECT_ROOT / "tool" / "release_both_stores.sh"
TRIGGER_SCRIPT = PROJECT_ROOT / "tool" / "trigger_render_chat_api_deploy.sh"


class LoadEnvFileTest(unittest.TestCase):
    def test_later_file_overrides_earlier_exports(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp) / "base.env"
            local = Path(tmp) / "local.env"
            base.write_text("FOO=from_base\n", encoding="utf-8")
            local.write_text("FOO=from_local\n", encoding="utf-8")
            script = f"""
            set -euo pipefail
            source "{LOAD_ENV_FILE}"
            load_env_file "{base}"
            load_env_file "{local}"
            printf "%s" "$FOO"
            """
            result = subprocess.run(
                ["bash", "-c", script],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "from_local")

    def test_loads_empty_values_and_inline_comments(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_file = Path(tmp) / "empty.env"
            dotenv_file.write_text(
                "EMPTY=\n"
                "COMMENTED=value # trailing comment\n"
                'QUOTED="value with spaces"\n',
                encoding="utf-8",
            )
            script = f"""
            set -euo pipefail
            source "{LOAD_ENV_FILE}"
            load_env_file "{dotenv_file}"
            test "$EMPTY" = ""
            test "$COMMENTED" = "value"
            test "$QUOTED" = "value with spaces"
            """
            result = subprocess.run(
                ["bash", "-c", script],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_unquoted_shell_metacharacters_without_executing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_file = Path(tmp) / "quoted.env"
            marker = Path(tmp) / "must-not-exist"
            dotenv_file.write_text(
                "PLAIN=value\n"
                'QUOTED="value with spaces"\n'
                f"COMMAND=$(true)\n",
                encoding="utf-8",
            )
            script = f'''
            set +e
            source "{LOAD_ENV_FILE}"
            load_env_file "{dotenv_file}"
            status=$?
            test "$status" -eq 2
            test -z "${{PLAIN+x}}"
            test -z "${{QUOTED+x}}"
            test ! -e "{marker}"
            '''

            result = subprocess.run(
                ["bash", "-c", script],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("unquoted values cannot contain $ or backticks", result.stderr)

    def test_cli_does_not_claim_missing_file_was_loaded(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            missing = Path(tmp) / "missing.env"
            result = subprocess.run(
                ["bash", str(LOAD_ENV_FILE), str(missing)],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "")

    def test_quoted_command_substitution_is_literal(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_file = Path(tmp) / "quoted.env"
            marker = Path(tmp) / "must-not-exist"
            dotenv_file.write_text(
                f'COMMAND="$(touch {marker})"\n',
                encoding="utf-8",
            )
            script = f'''
            set -euo pipefail
            source "{LOAD_ENV_FILE}"
            load_env_file "{dotenv_file}"
            expected='$(touch {marker})'
            test "$COMMAND" = "$expected"
            test ! -e "{marker}"
            '''
            result = subprocess.run(
                ["bash", "-c", script],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_parses_android_release_example_with_empty_assignments(self) -> None:
        example = PROJECT_ROOT / ".env.android.release.example"
        script = f"""
        set -euo pipefail
        source "{LOAD_ENV_FILE}"
        load_env_file "{example}"
        test "$ANDROID_PACKAGE_NAME" = "com.ilkersevim.blocflutter"
        test "$HUGGINGFACE_MODEL" = ""
        """
        result = subprocess.run(
            ["bash", "-c", script],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_load_repo_dotenv_exports_render_api_key(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_dir = Path(tmp)
            (dotenv_dir / ".env").write_text(
                "RENDER_API_KEY=render-dotenv-test\n",
                encoding="utf-8",
            )
            script = f"""
            set -euo pipefail
            export FLUTTER_BLOC_APP_DOTENV_DIR="{dotenv_dir}"
            source "{LOAD_REPO_DOTENV}"
            load_repo_dotenv "{PROJECT_ROOT}"
            test "$RENDER_API_KEY" = "render-dotenv-test"
            """
            result = subprocess.run(
                ["bash", "-c", script],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
                env={"PATH": "/usr/bin:/bin"},
            )
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_trigger_script_uses_shared_repo_dotenv_loader(self) -> None:
        text = TRIGGER_SCRIPT.read_text(encoding="utf-8")
        self.assertIn('source "$ROOT_DIR/tool/load_repo_dotenv.sh"', text)
        self.assertIn('load_repo_dotenv "$ROOT_DIR"', text)

    def test_trigger_script_loads_render_api_key_from_dotenv_dir(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            dotenv_dir = Path(tmp)
            (dotenv_dir / ".env").write_text(
                "RENDER_API_KEY=render-trigger-test\n",
                encoding="utf-8",
            )
            script = f"""
            set -euo pipefail
            export FLUTTER_BLOC_APP_DOTENV_DIR="{dotenv_dir}"
            ROOT_DIR="{PROJECT_ROOT}"
            source "$ROOT_DIR/tool/load_repo_dotenv.sh"
            load_repo_dotenv "$ROOT_DIR"
            test "$RENDER_API_KEY" = "render-trigger-test"
            """
            result = subprocess.run(
                ["bash", "-c", script],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
                env={"PATH": "/usr/bin:/bin"},
            )
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_release_script_sources_shared_loader(self) -> None:
        text = RELEASE_SCRIPT.read_text(encoding="utf-8")
        self.assertIn('source "$ROOT_DIR/tool/load_env_file.sh"', text)
        self.assertIn('load_env_file ".env.ios.release"', text)
        self.assertIn('load_env_file ".env.android.release"', text)

    def test_android_play_release_script_uses_shared_loader(self) -> None:
        text = (PROJECT_ROOT / "tool" / "release_android_play.sh").read_text(
            encoding="utf-8",
        )
        self.assertIn('source "$ROOT_DIR/tool/load_env_file.sh"', text)
        self.assertIn('load_env_file ".env.android.release"', text)
        self.assertNotIn("source \".env.android.release\"", text)


if __name__ == "__main__":
    unittest.main()
