# AI Closet

CS 686 Cloud Computing final project. A single-page app where users photograph their
clothes, AI tags each piece, and the app builds outfits from what they own. Every tier
is wired by hand, with no PaaS.

**Status:** setup only. The sections below describe the planned design; no app code or
cloud resources exist yet.

## Planned stack

| Tier | Choice |
|------|--------|
| Frontend | React + Vite on S3 |
| DNS, CDN, WAF | Cloudflare, with Turnstile |
| API | API Gateway (HTTP API) + Cognito JWT authorizer |
| Compute | AWS Lambda (Python) |
| Auth | Cognito: email/password and Google OAuth |
| Database | RDS PostgreSQL + pgvector, private |
| ML API | OpenAI |

## Planned architecture

```
Browser -> Cloudflare (DNS, CDN, HTTPS redirect, WAF, DDoS)
  app.DOMAIN -> S3 website bucket (static SPA)
  api.DOMAIN -> API Gateway HTTP API + Cognito JWT authorizer
                  -> api Lambda (in VPC)      -> RDS PostgreSQL (private)
                  -> ai Lambda (outside VPC)  -> OpenAI
S3 upload event -> SQS (+ dead-letter) -> worker Lambda (outside VPC) -> OpenAI
Browser -> Cognito (email/password; Google via OAuth code + PKCE)
Browser -> private S3 photo bucket (presigned POST/GET)
Cognito triggers -> turnstile Lambda -> Cloudflare siteverify
```

## Planned layout

```
docs/       architecture, API, demo script
cloud/      one AWS Console guide per tier, plus policies
backend/    ai_core/, functions/, db/, evals/, tests/
frontend/   React + Vite app
```

## Workflow

1. Open an issue.
2. Branch from `staging` (`feat/`, `fix/`, `chore/`, `docs/`, `refactor/`).
3. Open a PR into `staging`.
4. A human promotes `staging` to `main`.

## Agent rules

Launch Claude Code from this folder so the rules load.

- `CLAUDE.md`: project facts and rules
- `.claude/`: the live skills, agent and guardrail hooks

Test the hooks with `sh .claude/hooks/test_hooks.sh`.
