import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "deploy_web.yml"


class DeployWebWorkflowTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.workflow = WORKFLOW.read_text(encoding="utf-8")

    def test_branch_tip_guard_runs_for_branch_workflow_dispatch(self):
        block = self._step_block("Skip deploy when commit is no longer branch tip")

        self.assertIn("id: branch_tip", block)
        self.assertIn("if: startsWith(github.ref, 'refs/heads/')", block)
        self.assertNotIn("github.event_name == 'push'", block)
        self.assertIn("commits/${GITHUB_REF_NAME}", block)

    def test_pages_deploy_steps_respect_branch_tip_skip(self):
        guarded_steps = [
            "Skip deploy when Pages already published for commit",
            "Drain stale GitHub Pages deployments",
            "- id: deployment",
            "Drain stale GitHub Pages deployments (retry)",
            "Re-dispatch Deploy web workflow after Pages failure",
            "Re-check deploy guards before failing",
            "Fail when Pages deploy did not succeed",
        ]

        for step_name in guarded_steps:
            with self.subTest(step=step_name):
                block = self._step_block(step_name)
                self.assertIn("steps.branch_tip.outputs.skip != 'true'", block)

    def test_final_skip_guard_runs_for_branch_refs_after_failed_deploy(self):
        block = self._step_block("Re-check deploy guards before failing")

        self.assertIn("id: final_skip", block)
        self.assertIn("steps.deployment.outcome == 'failure'", block)
        self.assertIn("startsWith(github.ref, 'refs/heads/')", block)
        self.assertIn("commits/${GITHUB_REF_NAME}", block)
        self.assertIn("--check-published-for-sha", block)

    def test_fail_step_respects_final_skip_guard(self):
        block = self._step_block("Fail when Pages deploy did not succeed")

        self.assertIn("steps.final_skip.outputs.skip != 'true'", block)

    def _step_block(self, marker: str) -> str:
        pattern = re.compile(
            rf"(?ms)^      (?=- (?:name: {re.escape(marker)}|id: {re.escape(marker.removeprefix('- id: '))}))"
            r".*?(?=^      - |\Z)"
        )
        match = pattern.search(self.workflow)
        if match is None:
            self.fail(f"Could not find workflow step: {marker}")
        return match.group(0)


if __name__ == "__main__":
    unittest.main()
