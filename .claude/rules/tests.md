---
paths:
  - "scripts/**"
  - "Dockerfile*"
  - "docker-compose.yml"
---

# Testing & Validation Rules

## Quality Checks (before every commit)
```bash
# Shell script syntax
find scripts -name "*.sh" -exec bash -n {} \;

# Docker compose validation
docker compose config --quiet

# Dockerfile basic validation
grep -n "^FROM\|^RUN\|^COPY\|^ENV\|^WORKDIR" Dockerfile.unity-sandbox > /dev/null
```

## Shell Script Validation
- `bash -n script.sh` — syntax check (MUST pass)
- `shellcheck script.sh` — linting (when available, SHOULD pass)
- Verify all scripts are executable: `chmod +x`

## Docker Validation
- `docker compose config --quiet` — compose syntax validation
- Full image build only when explicitly requested (GameCI images are large)
- `docker compose up --dry-run` — validate service startup (if available)

## Python Validation (OpenHands fork)
- `python3 -m py_compile <file>` — syntax check for modified Python files
- `cd openhands && python -m pytest tests/ -v` — run tests (if deps installed)
- Frontend: `cd openhands/frontend && npm run lint` (if node_modules present)

## Anti-Patterns
- NEVER skip `bash -n` validation on shell scripts
- NEVER commit scripts that fail syntax checks
- NEVER require full Docker build for routine validation
- NEVER skip compose validation when docker-compose.yml changes
