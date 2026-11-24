# Claude_Rules

A reusable Claude Code setup for any project. **Skills hold the process; each
project's `CLAUDE.md` holds the facts.** You fill in one file and leave the skills alone.

## Install in a project

1. Copy this whole folder into the project's root (the folder you launch Claude from).
2. From that root, run `sh Claude_Rules/install.sh`. If the root has no `.git`, or you
   want another target, name it: `sh Claude_Rules/install.sh /path/to/project`.
3. Restart Claude Code and run `/setup` to fill in `CLAUDE.md` and
   `.claude/guardrails.conf`. Check Branches and Deploy yourself.
4. Delete the copied `Claude_Rules` folder, or keep it out of git.

The installer puts everything in `.claude/`, keeps files you already have, and merges
its hooks into an existing `settings.json` after making a backup. Rerunning it is safe.

## The loop

```
INTAKE → PLAN → IMPLEMENT(TDD) → VALIDATE → SELF-REVIEW → PR → ⟦HUMAN GATE⟧ → SHIP → LEARN
```

## Skills

| Skill | Use it when |
|-------|-------------|
| `/flow` | Default for any feature, bug or change |
| `/self-review` | Before a PR: GO / NO-GO on your diff |
| `/pr` | Opening a PR to the integration branch |
| `/review-prs` | Reviewing open PRs |
| `/ship` | Releasing, after a human says so |
| `/debug-parallel` | Fixing a bug, one hypothesis per subagent |
| `/build` | Large feature with independent tracks |
| `/route` | Single-domain task for a specialist agent |
| `/setup` | Local environment, or filling in `CLAUDE.md` |

Agent: `project-reviewer`, a read-only reviewer that reads Footguns from `CLAUDE.md`.

## Guardrail hooks

| Hook | What it does |
|------|--------------|
| `block-protected-branches` | No direct pushes to protected branches or PRs into promotion-only ones |
| `block-prod-access` | No ssh/scp/rsync/remote Docker to production hosts; no listed commands |
| `block-dead-paths` | No edits to legacy, generated or vendored files |
| `remind-on-edit` | Non-blocking reminder after editing chosen paths |

Until you edit the config, only pushes to `main`/`master` and edits in `node_modules`
are blocked. In a new repo, do the first push to `main` yourself.
Test with `sh .claude/hooks/test_hooks.sh`.

## Limits

- Hooks catch mistakes, not every workaround: they read command text, allow anything
  they cannot parse, and dead paths cover edit tools, not shell writes. Branch
  protection on GitHub is the real boundary.
- Hooks apply to Claude only, not to your own terminal. They need `jq` or `python3`.
- `/pr`, `/review-prs` and `/ship` assume GitHub and the `gh` CLI.
- Installed copies do not update when this folder changes.
