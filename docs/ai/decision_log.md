# AI engineering decision log

| Date | Decision | Rationale | Impact |
| --- | --- | --- | --- |
| 2026-05-21 | `docs/` remains behavior canon | Avoid drift vs `ai/` | Agents must link, not copy |
| 2026-05-21 | Audits under `docs/audits/` with `git add -f` | Folder gitignored for generated audits | Track ranked findings explicitly |
| 2026-05-21 | `AGENTS.md` Map bullets only for AI entry | 120-line gate | Roles live in `governance.md` |
| 2026-05-21 | Feature map 16 full + 15 stub | Cost vs coverage | Stubs upgraded on touch |
| 2026-05-21 | Five contract pilots only | Prove template before 31× stubs | counter, chat, auth, settings, todo_list |
| 2026-05-21 | ARCH-003 closed on branch | Phase 4 exit without coupling refactors | Four feature barrels + barrel tests; ARCH-001/002 remain backlog |
| 2026-05-21 | Phase 5 = doc honor system | No CI script spec yet | Refresh via `ai/README.md`; Feature Brief not mechanical |

Add rows when plan or architecture choices change.
