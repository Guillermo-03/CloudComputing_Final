---
name: self-review
description: Use before opening a PR. Reviews your own working diff against the project's footguns, runs a general code review and the affected tests, and returns GO or NO-GO.
---

## Self-review — before /pr

### 1. Collect the diff
Run `git status --short`, `git diff` and `git diff --staged`; include untracked
files. Also include commits on this branch that are not on
`origin/<INTEGRATION_BRANCH>`. Nothing changed: say so and stop.

### 2. Project review
Spawn `project-reviewer` (mid tier) on that scope. Ask for the distilled verdict only.

### 3. General review
Run the built-in `/code-review` on the same diff.

### 4. Tests
Run the Test command from `CLAUDE.md` for each affected area.

### 5. Verdict
```
SELF-REVIEW — <scope>
BLOCKERS: <list or None>
WARNINGS: <list or None>
NITS:     <list or None>
TESTS:    <PASS | FAIL details>
VERDICT:  GO | NO-GO
```
- **GO**: hand off to `/pr`.
- **NO-GO**: list exactly what to fix; do not open a PR. Under `/flow`, loop at most
  3 times, then escalate.

### Rules
- Never apply fixes silently; surface the findings.
- Never skip review of a Sensitive path because the diff is small.
- Never report GO without running step 4. If no tests exist, state that and report
  the checks used instead.
- Do not commit, push or open PRs here.
