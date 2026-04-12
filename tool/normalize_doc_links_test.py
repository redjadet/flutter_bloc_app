import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


def _load_module():
    script_path = Path(__file__).with_name("normalize_doc_links.py")
    spec = importlib.util.spec_from_file_location("normalize_doc_links", script_path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class NormalizeDocLinksTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = _load_module()

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.repo_root = Path(self._tmp.name)
        (self.repo_root / "docs").mkdir()

    def tearDown(self):
        self._tmp.cleanup()

    def write_file(self, relative_path: str, content: str) -> Path:
        path = self.repo_root / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return path

    def test_rewrites_repo_root_paths_from_docs_file(self):
        path = self.write_file(
            "docs/CODE_QUALITY.md",
            "Coverage lives in `coverage/coverage_summary.md`.\n",
        )
        self.write_file("coverage/coverage_summary.md", "ok\n")

        change = self.module.normalize_file(path, self.repo_root)

        self.assertIsNotNone(change)
        self.assertEqual(
            path.read_text(encoding="utf-8"),
            "Coverage lives in [`coverage/coverage_summary.md`](../coverage/coverage_summary.md).\n",
        )

    def test_rewrites_nested_docs_links_relative_to_docs_root(self):
        path = self.write_file(
            "docs/offline_first/IMPLEMENTATION_COMPLETE.md",
            "See `offline_first/counter.md` and `validation_scripts.md`.\n",
        )
        self.write_file("docs/offline_first/counter.md", "counter\n")
        self.write_file("docs/validation_scripts.md", "validation\n")

        change = self.module.normalize_file(path, self.repo_root)

        self.assertIsNotNone(change)
        self.assertEqual(
            path.read_text(encoding="utf-8"),
            "See [`offline_first/counter.md`](counter.md) and [`validation_scripts.md`](../validation_scripts.md).\n",
        )

    def test_prefers_root_readme_from_nested_docs(self):
        path = self.write_file(
            "docs/offline_first/offline_first_plan.md",
            "Canonical refs: `README.md`.\n",
        )
        self.write_file("README.md", "root\n")
        self.write_file("docs/README.md", "docs index\n")

        change = self.module.normalize_file(path, self.repo_root)

        self.assertIsNotNone(change)
        self.assertEqual(
            path.read_text(encoding="utf-8"),
            "Canonical refs: [`README.md`](../../README.md).\n",
        )

    def test_unresolved_existing_link_reverts_to_literal(self):
        path = self.write_file(
            "docs/STARTUP_TIME_PROFILING.md",
            "Record metrics in [`analysis/startup_metrics.md`](analysis/startup_metrics.md).\n",
        )

        change = self.module.normalize_file(path, self.repo_root)

        self.assertIsNotNone(change)
        self.assertEqual(
            path.read_text(encoding="utf-8"),
            "Record metrics in `analysis/startup_metrics.md`.\n",
        )

    def test_valid_existing_relative_link_is_preserved(self):
        path = self.write_file(
            "docs/ai_integration.md",
            "See [`README.md`](../README.md).\n",
        )
        self.write_file("README.md", "root\n")
        self.write_file("docs/README.md", "docs index\n")

        change = self.module.normalize_file(path, self.repo_root)

        self.assertIsNone(change)
        self.assertEqual(
            path.read_text(encoding="utf-8"),
            "See [`README.md`](../README.md).\n",
        )

    def test_existing_link_with_fragment_preserved_when_target_resolves(self):
        path = self.write_file(
            "docs/engineering/routing.md",
            "See [`ai_code_review_protocol.md`](../ai_code_review_protocol.md#special-cases).\n",
        )
        self.write_file("docs/ai_code_review_protocol.md", "# AI\n\n## Special Cases\n")

        change = self.module.normalize_file(path, self.repo_root)

        self.assertIsNone(change)
        self.assertEqual(
            path.read_text(encoding="utf-8"),
            "See [`ai_code_review_protocol.md`](../ai_code_review_protocol.md#special-cases).\n",
        )

    def test_existing_link_fragment_preserved_when_rewriting_broken_target(self):
        path = self.write_file(
            "docs/engineering/routing.md",
            "See [`ai_code_review_protocol.md`](../missing.md#special-cases).\n",
        )
        self.write_file("docs/ai_code_review_protocol.md", "# AI\n\n## Special Cases\n")

        change = self.module.normalize_file(path, self.repo_root)

        self.assertIsNotNone(change)
        self.assertEqual(
            path.read_text(encoding="utf-8"),
            "See [`ai_code_review_protocol.md`](../ai_code_review_protocol.md#special-cases).\n",
        )


if __name__ == "__main__":
    unittest.main()
