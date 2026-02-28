# Ralph Agent Instructions — DreamForge

You are an autonomous coding agent working on DreamForge, a headless Unity AI development environment powered by OpenHands.

## FIRST: Read Project Instructions

Before doing anything else:
1. Read `CLAUDE.md` at the project root — it contains architecture, conventions, and guardrails
2. Read `tasks/prd-dreamforge-mvp.md` for full context on what DreamForge is

## Your Task

1. Read the PRD at `scripts/ralph/prd.json`
2. Read the progress log at `scripts/ralph/progress.txt` (check Codebase Patterns section first)
3. Check you're on the correct branch from PRD `branchName`. If not, check it out or create from main.
4. Pick the **highest priority** user story where `passes: false`
5. Implement that single user story
6. Run quality checks (see below)
7. If checks pass, commit ALL changes with message: `feat: [Story ID] - [Story Title]`
8. Update the PRD (`scripts/ralph/prd.json`) to set `passes: true` for the completed story
9. Append your progress to `scripts/ralph/progress.txt`

## DreamForge-Specific Quality Checks

These are **mandatory** before every commit:

```bash
# Validate all shell scripts (syntax check)
for f in $(find scripts/unity -name "*.sh" 2>/dev/null); do
    bash -n "$f" || { echo "FAILED: $f"; exit 1; }
done
for f in $(find scripts -maxdepth 1 -name "*.sh" 2>/dev/null); do
    bash -n "$f" || { echo "FAILED: $f"; exit 1; }
done

# Validate docker-compose (if exists and docker compose available)
if [ -f docker-compose.yml ] && command -v docker &>/dev/null; then
    docker compose config --quiet 2>/dev/null || echo "WARNING: docker compose config failed (may not have docker)"
fi

# Validate Dockerfile syntax (basic check — no build required)
if [ -f Dockerfile.unity-sandbox ]; then
    # Check for common Dockerfile errors
    grep -n "^FROM\|^RUN\|^COPY\|^ADD\|^ENV\|^WORKDIR\|^EXPOSE\|^CMD\|^ENTRYPOINT\|^ARG\|^LABEL" Dockerfile.unity-sandbox > /dev/null
fi
```

If any shell script syntax check fails, fix the issue before committing. NEVER commit broken scripts.

**Note:** Full Docker build validation is not required (GameCI base images are large). Focus on syntax correctness.

## XP Practices

Apply these Extreme Programming principles to every story:

1. **Small Releases**: Each commit is ONE story, passes all checks
2. **Continuous Refactoring**: If you see duplicate code across scripts, extract to a helper
3. **Security as Habit**: Never hardcode secrets, always use env vars
4. **Atomic Commits**: One story = one commit. Never mix stories.
5. **Quality First**: Run quality checks before EVERY commit

## DreamForge Conventions (Quick Reference)

- **Language**: Code, comments, commits in English. Communication in PT-BR.
- **Shell scripts**: `#!/bin/bash` with `set -euo pipefail`
- **Variables**: `UPPER_SNAKE_CASE` for exports, `lower_snake_case` for locals
- **Docker**: Use multi-stage or ARG for flexibility, `--no-install-recommends` on apt
- **YAML**: 2-space indent
- **Markdown**: ATX headers, fenced code blocks
- **Ports**: OpenHands on :3000, PostgreSQL on :5433 (NOT :5432)

## Guardrails

- NEVER add GUI packages (Xvfb, VNC, fluxbox, xdotool) — HEADLESS ONLY
- NEVER use port 5432 for PostgreSQL (may conflict with DreamCI)
- NEVER hardcode API keys, passwords, or secrets
- NEVER install anything on the host — everything is Docker
- NEVER modify files outside the DreamForge project directory

## Progress Report Format

APPEND to `scripts/ralph/progress.txt` (never replace, always append):

```
## [Date/Time] - [Story ID]
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered
  - Gotchas encountered
  - Useful context
---
```

## Consolidate Patterns

If you discover a **reusable pattern**, add it to `## Codebase Patterns` at the TOP of `scripts/ralph/progress.txt`:

```
## Codebase Patterns
- Example: Shell scripts go in scripts/unity/ for sandbox scripts, scripts/ for project scripts
- Example: All shell scripts must start with set -euo pipefail
- Example: Docker compose uses ${VAR:-default} for all env vars
```

## Stop Condition

After completing a user story, check if ALL stories have `passes: true`.

If ALL stories are complete and passing, reply with:
<promise>COMPLETE</promise>

If there are still stories with `passes: false`, end your response normally.

## Important

- Work on **ONE** story per iteration
- Commit with focused changes
- Keep all quality checks passing
- Read Codebase Patterns in progress.txt before starting
- Follow existing patterns in the codebase
