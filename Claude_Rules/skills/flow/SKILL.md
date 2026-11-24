---
name: flow
description: Use for ANY feature, bug, or code change. This is the default dev loop. Orchestrates intake, plan, implement (TDD), validate, self-review, and PR, then stops for a human decision before production.
---

## /flow — the dev loop

The single entry point for development work. It sequences the other skills and adds
model tiering, token discipline and the human production gate. Project facts come
from `CLAUDE.md`. Read `token-discipline.md` (next to this file) once per session.

```
INTAKE → PLAN → IMPLEMENT(TDD) → VALIDATE → SELF-REVIEW → ⟨GO?⟩ → PR → ⟦HUMAN GATE⟧ → SHIP → LEARN
                     ↑______________________________________|  NO-GO: re-loop with findings (cap 3)
```

### Stage 0 — INTAKE (main thread, top tier)
Classify and size the task in one line:
- **Trivial** (one-liner, doc tweak, obvious config): branch first as in `/pr` step 1,
  edit, run the affected test, go to Stage 6. No subagents. A change to a
  Sensitive path is never trivial.
- **Bug**: follow `/debug-parallel`, then continue at Stage 3.
- **Feature / non-trivial**: Stage 1.
- **Large, independent tracks**: `/build`.

Before editing, switch to a topic branch (see `/pr` step 1).

### Stage 1 — PLAN (top tier)
Design-heavy with no spec: settle requirements with the user and compare two or three
approaches first. Then write a short checklist: files, tests, acceptance criteria, risks.

### Stage 2 — IMPLEMENT (mid-tier subagent, TDD)
Instruct it to write the **failing test first**, then the minimal code, run affected
tests, and **return only** a diff summary and test result. If the area has no test
setup, say so and agree on another check; do not silently skip. Isolate risky or
multi-file work in a worktree, but see the warning in `/build`.

### Stage 3 — VALIDATE (mid- or small-tier subagent)
Run the Test, Lint and Build commands for affected areas. Return `PASS/FAIL` and
failing lines only.

### Stage 4 — SELF-REVIEW
Run `/self-review`. Never skip it when a Sensitive path is touched.

### Stage 5 — GATE (main thread, top tier)
- **NO-GO**: send the specific findings to Stage 2. **Cap: 3 iterations**, then stop
  and escalate with the open blockers.
- **GO**: Stage 6.

### Stage 6 — PR
Run `/pr`.

### Stage 7 — HUMAN GATE (hard stop)
STOP. Report PR number, whether it merged, test and review verdicts, rough token
spend. Wait for an explicit "ship it". If `INTEGRATION_BRANCH` and
`PRODUCTION_BRANCH` are the same, stop with the PR **open**: merging it is the
production decision.

### Stage 8 — SHIP (only after the human says so)
Run `/ship`.

### Stage 9 — LEARN
Record one line: what shipped and any new footgun. Propose new footguns as an
addition to `CLAUDE.md`; include them in the next PR once approved.

### Rules
- For non-trivial work the main thread never reads full test logs or file dumps.
- Never cross Stage 7 autonomously.
- Right-size: do not spend a fleet on a one-liner.
