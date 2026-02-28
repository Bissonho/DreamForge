---
name: xp-practices
description: "Apply XP practices (Akita) to DreamForge: TDD, small releases, refactoring, guardrails"
user-invocable: true
---

# /xp-practices

Apply XP (Extreme Programming) practices to DreamForge development.

## The 8 Principles (adapted for DreamForge)

### 1. Validation is MORE important with AI, not less
- Every shell script MUST pass `bash -n` before committing
- Every docker-compose change MUST pass `docker compose config --quiet`
- If modified a script → validation MUST exist
- If fixed a bug → validation reproducing the bug MUST exist

### 2. Small Releases — CI per commit
Every commit passes all checks:
```bash
find scripts -name "*.sh" -exec bash -n {} \;
docker compose config --quiet
```

### 3. Continuous Refactoring
- Script > 200 lines → extract functions or split
- Duplicate code in 2+ scripts → extract to helper
- Separate commit for refactoring: `refactor: <what>`

### 4. Human decides WHAT, agent decides HOW
- Don't over-engineer Docker configs
- 3 similar lines is better than premature abstraction
- If solution needs "factory pattern" → SIMPLIFY

### 5. CLAUDE.md as Living Spec
Document EVERY discovery, hurdle, pattern in CLAUDE.md.

### 6. Rules Are the Brake
Hooks and rules enforce constraints automatically.

### 7. Security is Habit, Not Phase
- Zero hardcoded secrets
- PostgreSQL localhost only
- Docker socket access is intentional and documented
- No command injection in shell scripts

### 8. Atomic and Descriptive Commits
- `feat:` — new feature
- `fix:` — bug fix
- `refactor:` — no behavior change
- `docs:` — documentation
- `chore:` — maintenance
- `deploy:` — infrastructure
