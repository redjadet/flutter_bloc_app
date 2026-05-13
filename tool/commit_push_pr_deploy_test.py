import argparse
import unittest
from pathlib import Path
import sys
from unittest import mock

TOOL_ROOT = Path(__file__).resolve().parent
if str(TOOL_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOL_ROOT))

import commit_push_pr_deploy


class CommitPushPrDeployTest(unittest.TestCase):
    def test_supabase_function_plan_uses_per_function_commands(self) -> None:
        with mock.patch.object(
            commit_push_pr_deploy,
            "_compute_deploy_fingerprint",
            return_value="fp-1",
        ):
            plan = commit_push_pr_deploy.build_plan(
                staged=["supabase/functions/chat-complete/index.ts"],
                unstaged=[],
                untracked=[],
                branch="feature/test",
            )

        self.assertEqual(len(plan), 1)
        target = plan[0]
        self.assertEqual(target.platform, "supabase")
        self.assertEqual(
            target.commands,
            ("npx supabase functions deploy chat-complete",),
        )

    def test_fastapi_docs_only_change_does_not_require_deploy(self) -> None:
        with mock.patch.object(
            commit_push_pr_deploy,
            "_compute_deploy_fingerprint",
            return_value="fp-1",
        ):
            plan = commit_push_pr_deploy.build_plan(
                staged=["demos/render_chat_api/README.md", "demos/render_chat_api/tests/test_main.py"],
                unstaged=[],
                untracked=[],
                branch="feature/test",
            )

        self.assertEqual(plan, [])

    def test_fastapi_api_change_prefers_fastapi_script_when_present(self) -> None:
        """deploy_fastapi_cloud_chat_api.sh is chosen before render trigger when both exist."""
        original_exists = Path.exists

        def fake_exists(path: Path) -> bool:
            if path == commit_push_pr_deploy.RENDER_DEPLOY_TRIGGER_SCRIPT:
                return True
            if path == commit_push_pr_deploy.FASTAPI_CLOUD_DEPLOY_SCRIPT:
                return True
            return original_exists(path)

        with mock.patch.object(Path, "exists", autospec=True, side_effect=fake_exists):
            with mock.patch.object(
                commit_push_pr_deploy,
                "_compute_deploy_fingerprint",
                return_value="fp-1",
            ):
                plan = commit_push_pr_deploy.build_plan(
                    staged=["demos/render_chat_api/main.py"],
                    unstaged=[],
                    untracked=[],
                    branch="feature/test",
                )

        self.assertEqual(len(plan), 1)
        self.assertEqual(
            plan[0].commands,
            ("./tool/deploy_fastapi_cloud_chat_api.sh",),
        )

    def test_fastapi_api_change_uses_render_when_fastapi_script_missing(self) -> None:
        original_exists = Path.exists

        def fake_exists(path: Path) -> bool:
            if path == commit_push_pr_deploy.FASTAPI_CLOUD_DEPLOY_SCRIPT:
                return False
            if path == commit_push_pr_deploy.RENDER_DEPLOY_TRIGGER_SCRIPT:
                return True
            return original_exists(path)

        with mock.patch.object(Path, "exists", autospec=True, side_effect=fake_exists):
            with mock.patch.object(
                commit_push_pr_deploy,
                "_compute_deploy_fingerprint",
                return_value="fp-1",
            ):
                plan = commit_push_pr_deploy.build_plan(
                    staged=["demos/render_chat_api/main.py"],
                    unstaged=[],
                    untracked=[],
                    branch="feature/test",
                )

        self.assertEqual(len(plan), 1)
        self.assertEqual(
            plan[0].commands,
            ("./tool/trigger_render_chat_api_deploy.sh",),
        )

    def test_blocks_when_deploy_surface_is_partially_staged(self) -> None:
        with mock.patch.object(
            commit_push_pr_deploy,
            "_compute_deploy_fingerprint",
            return_value="fp-1",
        ):
            plan = commit_push_pr_deploy.build_plan(
                staged=["functions/src/index.ts"],
                unstaged=["firestore.rules"],
                untracked=[],
                branch="feature/test",
            )

        self.assertEqual(len(plan), 1)
        self.assertEqual(plan[0].platform, "firebase")
        self.assertEqual(plan[0].blocking_files, ("firestore.rules",))

    def test_firebase_rules_and_indexes_include_preflight_then_separate_deploys(self) -> None:
        with mock.patch.object(
            commit_push_pr_deploy,
            "_compute_deploy_fingerprint",
            return_value="fp-1",
        ):
            plan = commit_push_pr_deploy.build_plan(
                staged=["firestore.rules", "firestore.indexes.json"],
                unstaged=[],
                untracked=[],
                branch="feature/test",
            )

        self.assertEqual(len(plan), 1)
        self.assertEqual(
            plan[0].commands,
            (
                "bash tool/firebase_preflight.sh --require-cli",
                "firebase deploy --only firestore:rules",
                "firebase deploy --only firestore:indexes",
            ),
        )

    def test_firebase_json_only_triggers_preflight(self) -> None:
        with mock.patch.object(
            commit_push_pr_deploy,
            "_compute_deploy_fingerprint",
            return_value="fp-1",
        ):
            plan = commit_push_pr_deploy.build_plan(
                staged=["firebase.json"],
                unstaged=[],
                untracked=[],
                branch="feature/test",
            )

        self.assertEqual(len(plan), 1)
        self.assertEqual(plan[0].platform, "firebase")
        self.assertEqual(
            plan[0].commands,
            ("bash tool/firebase_preflight.sh --require-cli",),
        )

    def test_firebase_test_only_change_does_not_require_deploy(self) -> None:
        with mock.patch.object(
            commit_push_pr_deploy,
            "_compute_deploy_fingerprint",
            return_value="fp-1",
        ):
            plan = commit_push_pr_deploy.build_plan(
                staged=["functions/test/index.test.js"],
                unstaged=[],
                untracked=[],
                branch="feature/test",
            )

        self.assertEqual(plan, [])

    def test_marks_target_as_already_deployed_when_scorecard_matches(self) -> None:
        with mock.patch.object(
            commit_push_pr_deploy.validation_reuse,
            "find_successful_command_event",
            return_value={"command": "deploy_firebase", "status": "ok"},
        ) as mocked_find:
            with mock.patch.object(
                commit_push_pr_deploy,
                "_compute_deploy_fingerprint",
                return_value="fp-1",
            ):
                plan = commit_push_pr_deploy.build_plan(
                    staged=["functions/src/index.ts"],
                    unstaged=[],
                    untracked=[],
                    branch="feature/test",
                )

        self.assertEqual(len(plan), 1)
        self.assertTrue(plan[0].already_deployed)
        mocked_find.assert_called_once_with(
            "deploy_firebase",
            fingerprint="fp-1",
            branch="feature/test",
        )

    def test_build_plan_fingerprints_only_relevant_staged_files(self) -> None:
        captured: list[list[str]] = []

        def fake_fingerprint(paths: list[str]) -> str:
            captured.append(list(paths))
            return "fp-1"

        with mock.patch.object(
            commit_push_pr_deploy,
            "_compute_deploy_fingerprint",
            side_effect=fake_fingerprint,
        ):
            plan = commit_push_pr_deploy.build_plan(
                staged=["functions/src/index.ts", "README.md"],
                unstaged=[],
                untracked=[],
                branch="feature/test",
            )

        self.assertEqual(len(plan), 1)
        self.assertEqual(captured, [["functions/src/index.ts"]])

    def test_post_merge_runs_helper_script(self) -> None:
        with mock.patch("subprocess.run", return_value=mock.Mock(returncode=0)) as run:
            rc = commit_push_pr_deploy._post_merge_command(mock.Mock())

        self.assertEqual(rc, 0)
        run.assert_called_once_with(
            ["bash", str(commit_push_pr_deploy.POST_MERGE_SCRIPT)],
            check=False,
            cwd=commit_push_pr_deploy.PROJECT_ROOT,
        )

    def test_post_merge_missing_script_returns_2(self) -> None:
        missing = Path("/nonexistent/commit_push_pr_post_merge.sh")
        with mock.patch.object(commit_push_pr_deploy, "POST_MERGE_SCRIPT", missing):
            rc = commit_push_pr_deploy._post_merge_command(mock.Mock())
        self.assertEqual(rc, 2)


    def test_merge_cleanup_runs_helper_script(self) -> None:
        ns = argparse.Namespace(merge_cleanup_remote="origin", gh_merge_args=[])
        with mock.patch("subprocess.run", return_value=mock.Mock(returncode=0)) as run:
            rc = commit_push_pr_deploy._merge_cleanup_command(ns)
        self.assertEqual(rc, 0)
        run.assert_called_once_with(
            ["bash", str(commit_push_pr_deploy.MERGE_AND_CLEANUP_SCRIPT)],
            check=False,
            cwd=commit_push_pr_deploy.PROJECT_ROOT,
        )

    def test_merge_cleanup_forwards_remote_and_gh_args(self) -> None:
        ns = argparse.Namespace(merge_cleanup_remote="upstream", gh_merge_args=["203", "--merge"])
        with mock.patch("subprocess.run", return_value=mock.Mock(returncode=0)) as run:
            rc = commit_push_pr_deploy._merge_cleanup_command(ns)
        self.assertEqual(rc, 0)
        run.assert_called_once_with(
            [
                "bash",
                str(commit_push_pr_deploy.MERGE_AND_CLEANUP_SCRIPT),
                "--remote",
                "upstream",
                "203",
                "--merge",
            ],
            check=False,
            cwd=commit_push_pr_deploy.PROJECT_ROOT,
        )

    def test_merge_cleanup_missing_script_returns_2(self) -> None:
        missing = Path("/nonexistent/commit_push_pr_merge_and_cleanup.sh")
        ns = argparse.Namespace(merge_cleanup_remote="origin", gh_merge_args=[])
        with mock.patch.object(commit_push_pr_deploy, "MERGE_AND_CLEANUP_SCRIPT", missing):
            rc = commit_push_pr_deploy._merge_cleanup_command(ns)
        self.assertEqual(rc, 2)


if __name__ == "__main__":
    unittest.main()
