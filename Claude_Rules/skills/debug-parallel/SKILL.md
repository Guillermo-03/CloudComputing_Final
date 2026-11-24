---
name: debug-parallel
description: Use when fixing a bug. Investigates one hypothesis per subagent in parallel and accepts a fix only with a reproducing test that failed before it.
---

## Parallel test-driven bug fixing

`/debug-parallel <bug description>`

### 1. Hypothesize (main thread)
Locate the relevant area. List the top 5 hypotheses ranked by likelihood, each with
root cause, files, and evidence that would confirm or rule it out. Print them, then
investigate the top 3-4. An obvious single cause needs one investigator, not a fleet.

### 2. Investigate (one subagent per hypothesis, in parallel)
Give each its own worktree (see the warning in `/build`), so fixes cannot collide.
Fill in commands and test locations from `CLAUDE.md`.

```
Investigate hypothesis <N>.
BUG: <description>
HYPOTHESIS: <root cause>
FILES: <likely files>
TEST: <command and location>

1. READ the code and recent logs.
2. DIAGNOSE. If clearly wrong, STOP: "RULED_OUT: <reason>".
3. WRITE A FAILING TEST that proves this root cause; run it. If it passes, STOP:
   "RULED_OUT: test did not fail".
4. FIX minimally. No refactors. Do not change existing test expectations.
5. VERIFY the full suite for the area.
6. REPORT:
   RESULT: CONFIRMED | RULED_OUT
   ROOT_CAUSE: <one sentence>
   TEST_FILE / TEST_NAME: <...>
   CHANGED_FILES: <list>
   WORKTREE: <path>
   DIFF_SUMMARY: <what and why>
```

### 3. Evaluate
- Reject RULED_OUT results and any fix whose test does not fail without it.
- Several confirmed: keep independent fixes; for overlaps, keep the more complete one.
- None confirmed: report findings and ask for context. Do not guess.

### 4. Merge and verify
Apply the winning fix to the working tree. Remove only the worktrees created here,
after the fix is safely applied. Run the affected suites, then report root cause, what
the test proves, and files changed. Do not commit; `/flow` or the user decides.

### Rules
- No fix without a reproducing test. If the area has no test setup, stop and agree on
  a repeatable reproduction with the user.
- Check routing, queries and config before network or timeout theories.
