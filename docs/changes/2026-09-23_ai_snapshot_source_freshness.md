# Source-aware AI snapshot freshness

The [Medium article](https://medium.com/data-science-collective/stop-wasting-llm-tokens-building-a-self-updating-codebase-knowledge-graph-with-okf-20284060c1b1) proposes a Git-triggered pipeline that drafts, links, and lints codebase knowledge in [Open Knowledge Format](https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/main/SPEC.md). Only its opening is publicly visible, so implementation details and claimed token savings were not verified. The current OKF v0.2 specification defines a portable Markdown bundle with optional provenance, verification, and freshness fields; it does not prescribe a Git hook or runtime.

This repository already has a shared agent entry map, progressive context loading, curated discovery snapshots, a deterministic report refresh, and an optional structural code graph. A new OKF bundle would duplicate owning docs without evidence that retrieval improves. The useful gap was narrower: `--strict-head` rejected all eight discovery snapshots after later docs/tooling commits, even when the sources behind the snapshots had not changed.

The strict check now accepts an available `git_head` when relevant committed source paths match `HEAD`, including after a squash merge. It still rejects source drift. A fixture exercises both outcomes in a temporary Git repository, independent of checkout history.

## Must remain true

- Code/tests and owning docs outrank `ai/` snapshots. Agents verify material claims against current sources.
- `git_head` identifies the source revision used by `refresh_ai_reports.sh`; strict proof requires that commit locally.
- Refresh regenerates bounded metrics and metadata while curated narrative remains reviewed by an agent or maintainer.

## Failure modes

- Any source path change since the recorded revision makes strict proof fail and calls for snapshot review/refresh.
- Shallow checkouts may lack the recorded revision. Strict proof then fails closed; the harness tests its behavior in a small local repository.
- A source path with unchanged final content passes even if intermediate commits touched it. This is valid for a content snapshot, but semantic claims still need direct review.

## Rejected alternatives

- Auto-drafting knowledge on every commit could turn unverified model output into agent authority and add repeated token, hook, and review costs.
- Requiring exact `HEAD` caused metadata churn on unrelated commits and did not prove snapshot accuracy.
- Making the optional code graph the default would contradict its failed repo pilot and add local tool dependence for agents on other hosts.
