---
name: setup
description: Use when setting up a local dev environment, onboarding to a project, or filling in a new CLAUDE.md from the template.
---

## Setup

### New project: fill in CLAUDE.md
If `CLAUDE.md` has placeholders, read the package manifests, CI config, Makefile and
README. Fill in what they prove, ask about the rest, and show the result. Never invent
deploy details. If `CLAUDE.md` exists without the template's sections, merge in
`.claude/CLAUDE.template.md`; keep the existing content.

### Guardrails
Fill in `.claude/guardrails.conf` from the same facts: protected branches, promotion
branches, production hosts, blocked commands, Dead paths and reminders for Sensitive
paths. Show it for approval, then run `sh .claude/hooks/test_hooks.sh`. Never loosen a
guardrail to get past a block without asking.

### Local environment
1. **Preflight:** check the required tools and versions; fix what is missing, with
   approval for system-wide installs.
2. **Install:** run the Setup command per area. Create local env files from the
   examples if absent; never overwrite them or print secrets.
3. **Run:** use the Run command.
4. **Verify:** the app responds and the Test command passes. Report evidence.

If something breaks, check the project's troubleshooting docs, then use the Debugging
rule in `CLAUDE.md`.

### Never
- Never point a local environment at production data without explicit approval.
- Never change production from setup.
