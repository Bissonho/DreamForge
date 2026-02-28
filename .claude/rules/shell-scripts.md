---
paths:
  - "scripts/**"
---

# Shell Script Rules

## Conventions
- All scripts: `#!/bin/bash` with `set -euo pipefail`
- Export variables: `UPPER_SNAKE_CASE`
- Local variables: `lower_snake_case`
- Functions: `lower_snake_case()`
- Always quote variables: `"${var}"` (not bare $var)

## Validation
- `bash -n script.sh` MUST pass before committing
- Every script should handle missing dependencies gracefully
- Use `command -v tool &>/dev/null` to check tool availability

## Error Handling
- Use meaningful error messages: `echo "[script-name] ERROR: description" >&2`
- Exit with non-zero on failure
- Use `|| { echo "error msg" >&2; exit 1; }` pattern for critical commands
- Progress messages: `echo "[script-name] Step description..."`

## deploy.sh Specific
- ALWAYS accept server IP as first arg
- ALWAYS accept SSH port as optional second arg (default 22)
- Use rsync with `--exclude` for .git, .env, license.ulf
- SSH heredocs with `<<'EOF'` (single-quoted to prevent local expansion)

## Anti-Patterns
- NEVER use `eval` — security risk
- NEVER use bare `$var` without quotes
- NEVER use `#!/bin/sh` — use `#!/bin/bash` for consistency
- NEVER hardcode server IPs in scripts — use arguments or env vars
