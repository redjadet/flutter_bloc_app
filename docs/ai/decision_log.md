# AI engineering decision log

| Date | Decision | Rationale | Impact |
| --- | --- | --- | --- |
| 2026-05-21 | `docs/` remains behavior canon | Avoid drift vs `ai/` | Agents must link, not copy |
| 2026-05-21 | Audits under `docs/audits/` with `git add -f` | Folder gitignored for generated audits | Track ranked findings explicitly |
| 2026-05-21 | `AGENTS.md` Map bullets only for AI entry | 120-line gate | Roles live in `governance.md` |
| 2026-05-21 | Feature map 16 full + 15 stub | Cost vs coverage | Stubs upgraded on touch |
| 2026-05-21 | Five contract pilots only | Prove template before 31× stubs | counter, chat, auth, settings, todo_list |
| 2026-05-21 | ARCH-003 merged (PR #239) | Phase 4 exit | Four feature barrels + barrel tests on `main` |
| 2026-05-21 | ARCH-001/002 merged (PR #240) | Post-merge decouple + cubit split | Shared media/auth ports; flow mixins; lifecycle `isClosed` guards |
| 2026-05-21 | Phase 5 feature-brief guard | `tool/check_feature_brief_linked.sh` | Warn default; `FEATURE_BRIEF_CHECK_STRICT=1` in CI when wired |
| 2026-05-21 | `/commit-push-pr` closed loop | `watch_merge_cleanup` + post-merge sync doc | [`changes/2026-05-21_agent_automated_delivery_loop.md`](../changes/2026-05-21_agent_automated_delivery_loop.md) |

Add rows when plan or architecture choices change.
