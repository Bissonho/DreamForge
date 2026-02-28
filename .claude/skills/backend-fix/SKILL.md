---
description: "Diagnose and fix issues in DreamForge (OpenHands fork, Docker, scripts)"
---

# /backend-fix $ARGUMENTS

Diagnose and fix an issue in DreamForge.

## Steps

1. Understand the problem from $ARGUMENTS
2. Identify which layer is affected:
   - **OpenHands backend** (`openhands/openhands/`) — Python API, runtime, agents
   - **OpenHands frontend** (`openhands/frontend/src/`) — React UI
   - **Unity sandbox** (`Dockerfile.unity-sandbox`, `scripts/unity/`) — Docker image, shell scripts
   - **Docker Compose** (`docker-compose.yml`) — orchestration, ports, volumes
   - **Microagents** (`microagents/`) — agent instructions
   - **Deploy** (`scripts/deploy.sh`) — deployment automation

3. Read the relevant source files
4. Identify the root cause
5. Implement the fix following project conventions:
   - Shell: `set -euo pipefail`, quote variables, meaningful error messages
   - Python: type hints, proper exception handling
   - Docker: `--no-install-recommends`, clean apt cache

6. Verify:
   ```bash
   # Shell scripts
   find scripts -name "*.sh" -exec bash -n {} \;
   # Docker compose
   docker compose config --quiet
   # Python (if modified)
   python3 -m py_compile <modified_file>
   ```
