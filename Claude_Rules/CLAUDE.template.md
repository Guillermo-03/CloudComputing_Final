# <PROJECT NAME>

<!-- Copy to <project>/CLAUDE.md and replace every <...>. Keep the headings and
     setting names: the skills look them up. Write "none" if something does not apply. -->

## Project profile

- **What it is:** <one or two sentences>
- **Stack:** <languages, frameworks, database, hosting>
- **Layout:** <where the live code is; git root if it differs from the app folder>
- **Dead paths (never edit):** <legacy, generated or vendored folders, or "none">

## Commands

Run from the folder shown. Use one row per area.

| Area | Folder | Setup | Test | Lint / types | Build | Run |
|------|--------|-------|------|--------------|-------|-----|
| <app> | <.> | <...> | <...> | <...> | <...> | <...> |

## Branches

- `INTEGRATION_BRANCH`: <branch PRs target>
- `PRODUCTION_BRANCH`: <branch that is released; may be the same>
- `AUTO_MERGE`: <yes | no> (treated as "no" when both branches are the same)

## Deploy

- `DEPLOY_METHOD`: <what ships the code, or "none">
- `DEPLOY_ON_MERGE`: <yes | no> (does merging to PRODUCTION_BRANCH deploy automatically?)
- `GATE_CHECK`: <what must be green before release, and how to read it>
- `PROMOTE_COMMAND`: <how INTEGRATION_BRANCH gets to PRODUCTION_BRANCH, or "none">
- `HEALTH_CHECK`: <command or URL and the expected result>
- `ROLLBACK`: <how to undo a bad release>
- `NEVER`: <forbidden actions, e.g. manual changes on the production server, or "none">

## Sensitive paths

Changes here always get a full review, however small:

- Authentication and authorization
- Payments and billing
- Secrets and environment config
- Database schema and migrations
- Public API contracts
- <project-specific paths>

## Footguns

Numbered traps specific to this project. `project-reviewer` checks every one.
Format: the rule, why it exists, what to flag.

1. <none yet>

## Task routing

| Domain | Live paths | Agent type | Notes |
|--------|------------|------------|-------|
| <frontend> | <src/> | <general-purpose> | <...> |

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
