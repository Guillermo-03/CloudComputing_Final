# Token discipline (read once per session)

Better implementation for fewer tokens. Two levers matter most: **delegation** (keep
the long-lived orchestrator context small) and **model tiering**.

## Model tiering

| Work | Tier |
|------|------|
| Orchestration, intake, gate judgment, final verdict, design | Top |
| Implementation, running tests, mechanical review | Mid |
| Retrieval: grep sweeps, "where is X", excerpts | Small |

Choose by tier, not by hardcoded model name, since generations rotate. Set it per
agent with the `model` parameter; subagents otherwise inherit the session model.
Tier by task type, never as a blanket downgrade.

## Rules

1. **Thin orchestrator.** Dispatch, then read distilled returns.
2. **Distilled returns.** Ask for verdict, files and test result, not dumps.
3. **No re-reads** of files already read or edited this session.
4. **Batch independent calls** in one message.
5. **Keep early context stable.** Editing CLAUDE.md or skills mid-session, and long
   idle gaps, can cost prompt-cache misses.
6. **Right-size fan-out.** Trivial edits use no subagents.
7. **Bounded loops.** Three NO-GO iterations, then escalate.
