---
description: "Plan and implement a feature in DreamForge (OpenHands fork, sandbox, microagents)"
---

# /implement-feature $ARGUMENTS

Plan and implement a feature in DreamForge.

## Steps

1. **Interview**: Ask clarifying questions about requirements before starting
2. **Plan** (use Plan Mode): Identify all files that need changes:
   - OpenHands backend? (`openhands/openhands/`)
   - OpenHands frontend? (`openhands/frontend/src/`)
   - Unity sandbox image? (`Dockerfile.unity-sandbox`)
   - Sandbox scripts? (`scripts/unity/`)
   - Microagents? (`microagents/`)
   - Docker Compose? (`docker-compose.yml`)
   - Deploy script? (`scripts/deploy.sh`)

3. **Implement** in this order:
   1. Backend/API changes first (Python)
   2. Sandbox/Docker changes second (Dockerfile, scripts)
   3. Microagent updates third (markdown)
   4. Frontend UI changes last (React/TypeScript)
   5. Docker Compose/config changes if needed

4. **Validate**:
   ```bash
   # Shell scripts
   find scripts -name "*.sh" -exec bash -n {} \;
   # Docker compose
   docker compose config --quiet
   # Python (if modified)
   python3 -m py_compile <file>
   ```

5. **Document**: Update CLAUDE.md or microagents if the feature affects agent behavior
