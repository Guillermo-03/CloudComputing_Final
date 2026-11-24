# AI Closet

## Project profile

- **What it is:** SPA where users photograph their clothes, AI tags each piece, and the app
  builds outfits. CS 686 final project; no app code exists yet.
- **Stack:** (planned) React + Vite, Python Lambdas, PostgreSQL + pgvector on RDS, API
  Gateway, Cognito, S3, SQS, Cloudflare, OpenAI API
- **Layout:** git root is this folder. Planned: `docs/`, `cloud/`, `backend/`, `frontend/`.
- **Dead paths (never edit):** `node_modules/`

## Commands

Run from the folder shown. Use one row per area.

| Area | Folder | Setup | Test | Lint / types | Build | Run |
|------|--------|-------|------|--------------|-------|-----|
| Agent hooks | . | none | `sh .claude/hooks/test_hooks.sh` | none | none | none |

## Branches

- `INTEGRATION_BRANCH`: staging
- `PRODUCTION_BRANCH`: main
- `AUTO_MERGE`: no

## Deploy

- `DEPLOY_METHOD`: none yet (planned: manual, AWS Console)
- `DEPLOY_ON_MERGE`: no
- `GATE_CHECK`: none (no CI)
- `PROMOTE_COMMAND`: `gh pr create --base main --head staging`, merged by a human
- `HEALTH_CHECK`: none yet
- `ROLLBACK`: none yet
- `NEVER`: create, change or delete cloud resources without explicit human approval

## Sensitive paths

Changes here always get a full review, however small:

- Authentication and authorization
- Payments and billing
- Secrets and environment config
- Database schema and migrations
- Public API contracts
- `backend/db/` and `cloud/policies/`

## Footguns

Numbered traps specific to this project. `project-reviewer` checks every one.
Format: the rule, why it exists, what to flag.

1. No PaaS and no Amplify, including its JS library: every tier must be wired by hand.
   Flag either one.
2. Every user-data query filters by the JWT `sub`, or users can read each other's data.
   Flag a query without it.
3. Secrets never go in code, git or chat; this repo is public. Flag keys, passwords,
   account IDs and `.pem` files.
4. AWS is a Learner Lab, so IAM roles and services may be restricted. Flag designs that
   assume role creation works without checking.

## Task routing

| Domain | Live paths | Agent type | Notes |
|--------|------------|------------|-------|
| none yet | | | |

## Universal rules

### Dev loop
- Use `/flow` for every feature, bug or code change. Trivial one-liners skip the
  subagent apparatus, not the tests.
- Work runs autonomously up to `INTEGRATION_BRANCH`, then **stops for an explicit
  human decision before production**. If both branches are the same, stop at the
  open PR.
- Never push directly to `PRODUCTION_BRANCH` or `INTEGRATION_BRANCH`.

### Debugging
Before changing anything to fix a bug:
1. List the top 5 hypotheses, ranked by likelihood.
2. State what evidence would confirm or rule out each.
3. Test them in order.
4. Check routing, queries and config before chasing network or timeout theories.

### Sessions
- One session = one primary objective. Do not mix deploy, bug fix and feature work.
- A bug found during a release is logged and fixed next session. Follow-ups under
  5 minutes are fine.

### Testing
- Run the affected tests before every commit.
- Check side effects: changed response fields, caching, import errors.
- Never claim a test passed without running it.

### Tokens
- Thin orchestrator, distilled subagent returns, model tiering. See
  `.claude/skills/flow/token-discipline.md`.

### Missing settings
If a setting above is blank or still a placeholder, look in the repo (package
manifest, Makefile, CI config). If it is still unclear, ask. Never guess a deploy
command or a production branch.
