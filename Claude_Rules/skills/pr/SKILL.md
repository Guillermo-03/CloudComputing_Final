---
name: pr
description: Use when ready to open a PR. Self-reviews, branches from the integration branch, runs tests, verifies commit contents, and opens a PR against the integration branch.
---

## Open a PR

Use `INTEGRATION_BRANCH` and Commands from `CLAUDE.md`.

### 0. Self-review
Run `/self-review`; continue only on **GO**. Trivial changes from `/flow` may skip it,
unless they touch a Sensitive path.

### 1. Branch
If on an integration or production branch, cut a topic branch:
```
git fetch origin
git switch -c <type>/<slug> origin/<INTEGRATION_BRANCH>
```
Types: `feat`, `fix`, `chore`, `docs`, `refactor`. If uncommitted changes block the
switch, stop and report; never discard them.

### 2. Test
Run the Test command for what you touched. Check for side effects.

### 3. Commit and verify contents
```
git add <explicit paths>
git commit -m "<type>(<scope>): <summary>"
git show --stat HEAD
```
Do not hide `git add` errors. The file list must match the change: a commit can
silently miss files that its message claims.

### 4. Push and open
```
git push -u origin HEAD
gh pr create --base <INTEGRATION_BRANCH> --fill
```
Use the PR template if the repo has one.

### 5. Merge policy
Auto-merge applies only if `AUTO_MERGE` is yes **and** `INTEGRATION_BRANCH` differs
from `PRODUCTION_BRANCH`. Otherwise leave the PR open for a human.

### 6. Stop
Report PR, checks and review verdict. Never continue to `/ship` without an explicit
human instruction.

### Rules
- When the branches differ, PRs never target `PRODUCTION_BRANCH`; that is `/ship`.
- Never push directly to either branch.
- Never skip `git show --stat`.
- Do not touch Dead paths.
