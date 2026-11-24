---
name: build
description: Use for a large feature with two or more independent tracks. Runs one subagent per Task routing domain in separate worktrees, each opening its own PR.
---

## Build — parallel tracks

**Use when** the feature spans at least two domains in the `CLAUDE.md` Task routing
table and the tracks are independent. **Otherwise** use `/flow`.

> **Worktree warning.** Do not assume `isolation: "worktree"` separates agents. On
> case-insensitive macOS, paths that differ only by case are the same folder and
> agents can overwrite each other. Use explicit
> `git worktree add <distinct path> -b <branch> origin/<INTEGRATION_BRANCH>`, and run
> tracks that touch the same files sequentially.

### Steps
1. Split into tracks. Agree shared contracts (API shapes, schema) before starting.
   Show the split to the user.
2. Create one worktree per track and launch one agent each, in one message, in the
   background. Give each its routing row, paths, commands, Footguns and Sensitive paths.
3. Each agent works TDD and reports files changed, tests, new dependencies.
4. Run `/self-review` for each track in its worktree, then `/pr` on GO. The 3-iteration
   cap applies per track.
5. Verify tests and builds with the tracks combined, on a throwaway branch.
6. Stop at the human gate. Never `/ship` from here.
