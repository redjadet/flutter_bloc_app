import os
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = PROJECT_ROOT / "tool" / "compress_agent_doc.sh"


class CompressAgentDocTest(unittest.TestCase):
    def _make_fake_compressor(self, root: Path) -> Path:
        compressor = root / "fake-compressor"
        scripts = compressor / "scripts"
        scripts.mkdir(parents=True)
        (scripts / "__init__.py").write_text("")
        (scripts / "__main__.py").write_text(
            textwrap.dedent(
                """
                import sys
                from pathlib import Path

                target = Path(sys.argv[1])
                backup = target.with_name(target.stem + ".original.md")
                if backup.exists():
                    print(f"backup exists: {backup}", file=sys.stderr)
                    raise SystemExit(12)
                original = target.read_text()
                backup.write_text(original)
                target.write_text("compressed\\n")
                """
            ).strip()
            + "\n"
        )
        return compressor

    def _run(self, work_dir: Path, *args: str) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["CAVEMAN_COMPRESS_DIR"] = str(self._make_fake_compressor(work_dir))
        return subprocess.run(
            [str(SCRIPT), *args],
            cwd=PROJECT_ROOT,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_existing_backup_requires_overwrite_flag(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            work_dir = Path(tmp)
            target = work_dir / "agent.md"
            backup = work_dir / "agent.original.md"
            target.write_text("current\n")
            backup.write_text("old backup\n")

            result = self._run(work_dir, str(target))

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("--overwrite-backups", result.stderr)
            self.assertEqual(target.read_text(), "current\n")
            self.assertEqual(backup.read_text(), "old backup\n")

    def test_overwrite_flag_replaces_existing_backup(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            work_dir = Path(tmp)
            target = work_dir / "agent.md"
            backup = work_dir / "agent.original.md"
            target.write_text("current\n")
            backup.write_text("old backup\n")

            result = self._run(work_dir, "--overwrite-backups", str(target))

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(target.read_text(), "compressed\n")
            self.assertEqual(backup.read_text(), "current\n")
            self.assertIn("overwriting existing backup", result.stdout)


if __name__ == "__main__":
    unittest.main()
