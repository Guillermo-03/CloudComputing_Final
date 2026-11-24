---
name: ship
description: Use only when a human explicitly asks to release to production. Verifies the gate, promotes exactly what was tested, deploys with the project's documented method, and confirms health.
---

## Ship — sanctioned release

Requires an explicit human "ship it" in this session. Stop and report if any step
fails. If `DEPLOY_METHOD`, `GATE_CHECK`, `HEALTH_CHECK` or `ROLLBACK` is unknown, ask
before starting. If `DEPLOY_METHOD` is "none", say there is nothing to deploy and stop.

### 1. Confirm the source
- No other release in flight.
- `GATE_CHECK` is green for the exact commit to be released. Red or missing: STOP.
- Record that commit SHA.

### 2. Promote
**Branches differ:** use `PROMOTE_COMMAND`, or if "none", open a PR from
`INTEGRATION_BRANCH` to `PRODUCTION_BRANCH`:
`gh pr create --base <PRODUCTION_BRANCH> --head <INTEGRATION_BRANCH> --fill`.
Before merging:
```
git fetch origin
git rev-parse <gated-sha>^{tree}
git rev-parse origin/<promotion-branch>^{tree}
```
The trees must be identical; otherwise STOP and re-run the gate.

**Branches are the same:** the release is the reviewed PR. Confirm its head SHA is the
gated one and it is up to date with the base.

Show the PR and SHA, get the human's approval for this merge, then merge. If the
release is already on the branch, skip the merge and confirm its SHA.

### 3. Deploy
- `DEPLOY_ON_MERGE` yes: watch the run to its end and check its **conclusion**.
- `DEPLOY_ON_MERGE` no: run `DEPLOY_METHOD` from a clean checkout of the released
  commit, only after the human approves the command. If a guardrail blocks it, ask the
  human to run it; do not work around the block.

Never do anything listed under `NEVER`.

### 4. Confirm production
Run `HEALTH_CHECK`. A successful deploy command is not proof of health. On failure,
report it and propose `ROLLBACK`; run it only with approval, unless it is automatic.

### 5. Report
Released SHA, deploy conclusion, health results.

### Rules
- Never release a red, stale or untested commit.
- A bug found mid-release is logged for the next session; do not pivot.
