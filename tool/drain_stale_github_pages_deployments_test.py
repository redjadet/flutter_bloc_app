import importlib.util
import sys
import unittest
from pathlib import Path


def _load_module():
    script_path = Path(__file__).with_name("drain_stale_github_pages_deployments.py")
    spec = importlib.util.spec_from_file_location(
        "drain_stale_github_pages_deployments",
        script_path,
    )
    if spec is None or spec.loader is None:
        msg = f"Could not load module spec for {script_path}"
        raise RuntimeError(msg)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class DrainStaleGitHubPagesDeploymentsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = _load_module()

    def test_is_stale_pages_status_treats_empty_as_stale(self):
        self.assertTrue(self.module.is_stale_pages_status(""))
        self.assertTrue(self.module.is_stale_pages_status(None))

    def test_is_stale_pages_status_ignores_terminal_states(self):
        self.assertFalse(self.module.is_stale_pages_status("succeed"))
        self.assertFalse(self.module.is_stale_pages_status("deployment_cancelled"))

    def test_is_stale_pages_status_flags_in_progress_states(self):
        self.assertTrue(
            self.module.is_stale_pages_status("deployment_queued"),
        )
        self.assertTrue(
            self.module.is_stale_pages_status("deployment_in_progress"),
        )

    def test_unique_shas_preserves_order_and_deduplicates(self):
        deployments = [
            {"sha": "abc1234"},
            {"sha": "def5678"},
            {"sha": "abc1234"},
            {"sha": ""},
        ]
        self.assertEqual(
            self.module.unique_shas(deployments),
            ["abc1234", "def5678"],
        )

    def test_collect_stale_deployments_includes_current_sha_when_non_terminal(
        self,
    ):
        class FakeClient:
            def list_environment_deployments(self, *, environment, per_page):
                return [{"sha": "current1234567890"}, {"sha": "other1234567890"}]

            def pages_status(self, sha):
                return {
                    "current1234567890": "",
                    "other1234567890": "deployment_queued",
                }[sha]

        stale = self.module.collect_stale_deployments(
            FakeClient(),
            environment="github-pages",
            max_deployments=10,
        )
        self.assertEqual(len(stale), 2)
        self.assertEqual(stale[0].sha, "current1234567890")
        self.assertEqual(stale[1].sha, "other1234567890")


if __name__ == "__main__":
    unittest.main()
