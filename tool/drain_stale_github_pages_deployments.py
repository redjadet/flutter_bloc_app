#!/usr/bin/env python3
"""Cancel non-terminal GitHub Pages deployments that block deploy-pages."""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass


API_VERSION = "2026-03-10"
DEFAULT_ENVIRONMENT = "github-pages"

TERMINAL_STATUSES = frozenset(
    {
        "succeed",
        "deployment_cancelled",
        "deployment_failed",
        "deployment_content_failed",
        "deployment_lost",
    }
)


@dataclass(frozen=True)
class PagesDeployment:
    sha: str
    status: str | None


def is_stale_pages_status(status: str | None) -> bool:
    """Return True when a Pages deployment should be cancelled before a new deploy."""
    if status in TERMINAL_STATUSES:
        return False
    return True


def unique_shas(deployments: list[dict[str, object]]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for deployment in deployments:
        sha = deployment.get("sha")
        if not isinstance(sha, str) or not sha or sha in seen:
            continue
        seen.add(sha)
        ordered.append(sha)
    return ordered


class GitHubPagesDrainClient:
    def __init__(
        self,
        repository: str,
        token: str,
        *,
        api_version: str = API_VERSION,
    ) -> None:
        self.repository = repository
        self.token = token
        self.api_version = api_version

    def _request(
        self,
        method: str,
        path: str,
        *,
        accept_statuses: frozenset[int] = frozenset({200, 201, 204}),
    ) -> tuple[int, str]:
        request = urllib.request.Request(
            f"https://api.github.com{path}",
            method=method,
            headers={
                "Accept": "application/vnd.github+json",
                "Authorization": f"Bearer {self.token}",
                "X-GitHub-Api-Version": self.api_version,
                "User-Agent": "flutter-bloc-app-pages-drain",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                status = response.status
                body = response.read().decode("utf-8")
        except urllib.error.HTTPError as error:
            status = error.code
            body = error.read().decode("utf-8")
        if status not in accept_statuses:
            raise RuntimeError(
                f"GitHub API {method} {path} failed with HTTP {status}: {body}"
            )
        return status, body

    def list_environment_deployments(
        self,
        *,
        environment: str,
        per_page: int,
    ) -> list[dict[str, object]]:
        _, body = self._request(
            "GET",
            f"/repos/{self.repository}/deployments"
            f"?environment={environment}&per_page={per_page}",
        )
        payload = json.loads(body)
        if not isinstance(payload, list):
            raise RuntimeError("Expected deployment list from GitHub API")
        return payload

    def pages_status(self, sha: str) -> str | None:
        try:
            _, body = self._request(
                "GET",
                f"/repos/{self.repository}/pages/deployments/{sha}",
                accept_statuses=frozenset({200}),
            )
        except RuntimeError:
            return None
        payload = json.loads(body)
        if not isinstance(payload, dict):
            return None
        status = payload.get("status")
        return status if isinstance(status, str) else ""

    def cancel_pages_deployment(self, sha: str) -> None:
        self._request(
            "POST",
            f"/repos/{self.repository}/pages/deployments/{sha}/cancel",
            accept_statuses=frozenset({200, 201, 204, 404}),
        )


def collect_stale_deployments(
    client: GitHubPagesDrainClient,
    *,
    environment: str,
    max_deployments: int,
    exclude_sha: str | None = None,
) -> list[PagesDeployment]:
    deployments = client.list_environment_deployments(
        environment=environment,
        per_page=max_deployments,
    )
    stale: list[PagesDeployment] = []
    for sha in unique_shas(deployments):
        if exclude_sha and sha == exclude_sha:
            continue
        status = client.pages_status(sha)
        if is_stale_pages_status(status):
            stale.append(PagesDeployment(sha=sha, status=status))
    return stale


def ensure_pages_deployment_terminal(
    client: GitHubPagesDrainClient,
    sha: str,
    *,
    poll_timeout_seconds: int = 180,
    poll_interval_seconds: int = 5,
    wait_after_cancel_seconds: int = 10,
    post_terminal_wait_seconds: int = 30,
) -> None:
    """Cancel a SHA if needed and wait until its Pages status is terminal."""
    deadline = time.monotonic() + poll_timeout_seconds
    while True:
        status = client.pages_status(sha)
        if not is_stale_pages_status(status):
            if post_terminal_wait_seconds > 0:
                print(
                    "Pages deployment for "
                    f"{sha[:7]} is terminal ({status!r}); "
                    f"waiting {post_terminal_wait_seconds}s before redeploy."
                )
                time.sleep(post_terminal_wait_seconds)
            return

        if time.monotonic() >= deadline:
            raise RuntimeError(
                "Timed out waiting for Pages deployment "
                f"{sha[:7]} to reach a terminal status (last={status!r})."
            )

        print(
            "Cancelling in-flight Pages deployment for "
            f"{sha[:7]} (status={status!r})"
        )
        client.cancel_pages_deployment(sha)
        if wait_after_cancel_seconds > 0:
            time.sleep(wait_after_cancel_seconds)
        time.sleep(poll_interval_seconds)


def drain_stale_pages_deployments(
    client: GitHubPagesDrainClient,
    *,
    environment: str = DEFAULT_ENVIRONMENT,
    max_deployments: int = 10,
    exclude_sha: str | None = None,
    wait_after_cancel_seconds: int = 5,
    poll_timeout_seconds: int = 120,
    poll_interval_seconds: int = 5,
) -> list[PagesDeployment]:
    cancelled: list[PagesDeployment] = []
    deadline = time.monotonic() + poll_timeout_seconds

    while True:
        stale = collect_stale_deployments(
            client,
            environment=environment,
            max_deployments=max_deployments,
            exclude_sha=exclude_sha,
        )
        if not stale:
            return cancelled

        if time.monotonic() >= deadline:
            remaining = ", ".join(
                f"{item.sha[:7]}({item.status!r})" for item in stale
            )
            raise RuntimeError(
                "Timed out waiting for GitHub Pages queue to drain. "
                f"Remaining stale deployments: {remaining}"
            )

        for deployment in stale:
            print(
                "Cancelling stale Pages deployment for "
                f"{deployment.sha[:7]} (status={deployment.status!r})"
            )
            client.cancel_pages_deployment(deployment.sha)
            cancelled.append(deployment)
            if wait_after_cancel_seconds > 0:
                time.sleep(wait_after_cancel_seconds)

        time.sleep(poll_interval_seconds)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Cancel stale GitHub Pages deployments blocking deploy-pages.",
    )
    parser.add_argument(
        "--repository",
        default=os.environ.get("GITHUB_REPOSITORY"),
        help="owner/repo (defaults to GITHUB_REPOSITORY)",
    )
    parser.add_argument(
        "--token",
        default=os.environ.get("GITHUB_TOKEN"),
        help="GitHub token (defaults to GITHUB_TOKEN)",
    )
    parser.add_argument(
        "--exclude-sha",
        default=os.environ.get("GITHUB_SHA"),
        help="Deployment SHA to leave untouched (defaults to GITHUB_SHA)",
    )
    parser.add_argument(
        "--ensure-current-sha-terminal",
        action="store_true",
        help=(
            "After draining other SHAs, cancel/wait until --exclude-sha "
            "(or GITHUB_SHA) reaches a terminal Pages status"
        ),
    )
    parser.add_argument(
        "--post-terminal-wait-seconds",
        type=int,
        default=30,
        help="Extra wait after current SHA becomes terminal (retry redeploys)",
    )
    parser.add_argument(
        "--environment",
        default=DEFAULT_ENVIRONMENT,
        help="GitHub deployment environment name",
    )
    parser.add_argument(
        "--max-deployments",
        type=int,
        default=10,
        help="Recent deployments to inspect",
    )
    parser.add_argument(
        "--wait-after-cancel-seconds",
        type=int,
        default=5,
        help="Sleep after each cancel request",
    )
    parser.add_argument(
        "--poll-timeout-seconds",
        type=int,
        default=120,
        help="Max time to wait for queue to drain",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    if not args.repository:
        raise SystemExit("Missing --repository or GITHUB_REPOSITORY")
    if not args.token:
        raise SystemExit("Missing --token or GITHUB_TOKEN")

    client = GitHubPagesDrainClient(
        repository=args.repository,
        token=args.token,
    )
    cancelled = drain_stale_pages_deployments(
        client,
        environment=args.environment,
        max_deployments=args.max_deployments,
        exclude_sha=args.exclude_sha,
        wait_after_cancel_seconds=args.wait_after_cancel_seconds,
        poll_timeout_seconds=args.poll_timeout_seconds,
    )
    if args.ensure_current_sha_terminal and args.exclude_sha:
        ensure_pages_deployment_terminal(
            client,
            args.exclude_sha,
            poll_timeout_seconds=args.poll_timeout_seconds,
            post_terminal_wait_seconds=args.post_terminal_wait_seconds,
        )
    if cancelled:
        print(f"Drained {len(cancelled)} stale Pages deployment(s).")
    else:
        print("No stale Pages deployments found.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
