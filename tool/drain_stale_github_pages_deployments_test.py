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

    def test_is_stale_pages_status_treats_non_succeed_as_stale(self):
        self.assertFalse(self.module.is_stale_pages_status("succeed"))
        self.assertTrue(self.module.is_stale_pages_status("deployment_cancelled"))
        self.assertFalse(
            self.module.is_stale_pages_status("deployment_cancelled", nudged=True),
        )
        self.assertTrue(self.module.is_stale_pages_status("deployment_failed"))

    def test_is_terminal_pages_status_accepts_cancelled_and_failed(self):
        self.assertTrue(self.module.is_terminal_pages_status("deployment_cancelled"))
        self.assertTrue(self.module.is_terminal_pages_status("deployment_failed"))
        self.assertFalse(self.module.is_terminal_pages_status("deployment_queued"))

    def test_needs_post_cancel_wait_for_nudged_terminal_blockers(self):
        self.assertTrue(
            self.module.needs_post_cancel_wait("deployment_cancelled"),
        )
        self.assertFalse(self.module.needs_post_cancel_wait("succeed"))

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

    def test_resolve_exclude_sha_treats_empty_as_none(self):
        self.assertIsNone(self.module.resolve_exclude_sha(""))
        self.assertIsNone(self.module.resolve_exclude_sha(None))
        self.assertEqual(
            self.module.resolve_exclude_sha("abc123"),
            "abc123",
        )

    def test_collect_stale_deployments_excludes_current_sha(self):
        class FakeClient:
            def list_environment_deployments(self, *, environment, max_deployments):
                return [{"sha": "current1234567890"}, {"sha": "other1234567890"}]

            def pages_status(self, sha):
                return self.module.PagesStatusLookup(
                    found=True,
                    status={
                        "current1234567890": "",
                        "other1234567890": "deployment_queued",
                    }[sha],
                )

        fake = FakeClient()
        fake.module = self.module
        stale = self.module.collect_stale_deployments(
            fake,
            environment="github-pages",
            max_deployments=10,
            exclude_sha="current1234567890",
        )
        self.assertEqual(len(stale), 1)
        self.assertEqual(stale[0].sha, "other1234567890")

    def test_collect_stale_deployments_skips_missing_pages_records(self):
        class FakeClient:
            def list_environment_deployments(self, *, environment, max_deployments):
                return [{"sha": "missing123456789"}, {"sha": "other1234567890"}]

            def pages_status(self, sha):
                if sha == "missing123456789":
                    return self.module.PagesStatusLookup(found=False)
                return self.module.PagesStatusLookup(
                    found=True,
                    status="deployment_queued",
                )

        fake = FakeClient()
        fake.module = self.module
        stale = self.module.collect_stale_deployments(
            fake,
            environment="github-pages",
            max_deployments=10,
        )
        self.assertEqual(len(stale), 1)
        self.assertEqual(stale[0].sha, "other1234567890")

    def test_ensure_pages_deployment_terminal_accepts_cancelled_status(self):
        class FakeClient:
            def __init__(self):
                self.calls = 0

            def pages_status(self, sha):
                self.calls += 1
                return self.module.PagesStatusLookup(
                    found=True,
                    status="deployment_cancelled",
                )

            def cancel_pages_deployment(self, sha):
                raise AssertionError("should not cancel terminal deployment")

        fake = FakeClient()
        fake.module = self.module
        self.module.ensure_pages_deployment_terminal(
            fake,
            "current1234567890",
            post_terminal_wait_seconds=0,
        )
        self.assertEqual(fake.calls, 1)


if __name__ == "__main__":
    unittest.main()
