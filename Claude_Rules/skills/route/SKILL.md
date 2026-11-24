---
name: route
description: Use to hand a single-domain task (frontend, backend, data, AI, infrastructure, or other) to the right subagent, using the Task routing table in CLAUDE.md.
---

## Route a task

`/route <task>`

1. Match the task to one Task routing row. No match: ask, or use `/flow` directly.
   Several: use `/build` if independent, `/flow` if not.
2. Spawn the row's agent type (fall back to `general-purpose` if unavailable), in a
   worktree for multi-file or risky work (see the warning in `/build`).
3. Give it the task, the live paths and notes, the area's commands, and the Footguns,
   Dead paths and `NEVER` rules.
4. It works TDD and returns files changed, tests run (pass/fail) and new dependencies.
5. Continue with `/self-review`, then `/pr`.

### Rules
- Stay inside the row's live paths unless the user agrees otherwise.
- Verify counts and other runtime values; never hardcode them from docs.
- Infrastructure tasks change files only. Releases go through `/ship`.
