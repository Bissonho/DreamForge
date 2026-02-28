---
description: "Review code changes for DreamForge project standards"
---

# /review-code

Review the current changes against DreamForge project standards.

## Steps

1. Run `git diff` and `git diff --cached` to see all changes
2. For each changed file, check against this checklist:

### Shell Scripts
- [ ] Starts with `#!/bin/bash` and `set -euo pipefail`
- [ ] Variables are quoted: `"${var}"` not bare `$var`
- [ ] Error messages go to stderr: `echo "error" >&2`
- [ ] `bash -n` syntax check passes
- [ ] No hardcoded secrets or server IPs

### Docker
- [ ] `--no-install-recommends` on apt-get install
- [ ] `rm -rf /var/lib/apt/lists/*` after apt-get
- [ ] No GUI packages (xvfb, vnc, fluxbox)
- [ ] PostgreSQL on port 5433 (not 5432)
- [ ] Env vars use `${VAR:-default}` syntax

### Microagents
- [ ] Clear, actionable instructions (not vague)
- [ ] No references to GUI tools
- [ ] Knowledge files have trigger keywords
- [ ] No secrets or API keys

### OpenHands (Python)
- [ ] Type hints on function signatures
- [ ] No hardcoded DreamForge values in core code
- [ ] Config via env vars, not magic strings

### Security
- [ ] No secrets in code (API keys, passwords, tokens)
- [ ] No command injection in shell scripts
- [ ] PostgreSQL bound to localhost only
- [ ] Docker socket access is intentional

3. Report findings: CRITICAL > WARNING > SUGGESTION
4. Run validation checks on modified files
