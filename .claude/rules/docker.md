---
paths:
  - "docker-compose.yml"
  - "Dockerfile*"
---

# Docker & Compose Rules

## Docker Compose
- PostgreSQL MUST use port 5433 (NOT 5432, to avoid DreamCI conflict)
- PostgreSQL MUST bind to `127.0.0.1` only — never expose to external
- OpenHands app on port 3000 (direct, no reverse proxy)
- All env vars use `${VAR:-default}` syntax
- Named volumes for persistent data (openhands-state, dreamforge-pgdata)
- Resource limits: OpenHands app 4GB, each sandbox 2GB RAM + 0.5 CPU

## Dockerfile.unity-sandbox
- Base: `unityci/editor:ubuntu-<version>-<platform>-<gameci_version>`
- Use ARG for version flexibility
- ALWAYS use `--no-install-recommends` on apt-get install
- ALWAYS `rm -rf /var/lib/apt/lists/*` after apt-get
- NEVER install GUI packages (xvfb, vnc, fluxbox, xdotool, supervisor)
- WORKDIR /workspace

## OpenHands Dockerfile (openhands/containers/app/Dockerfile)
- Multi-stage build: frontend-builder → backend-builder → openhands-app
- Python 3.13 + Node.js for frontend build
- Poetry for Python deps
- Runs as `openhands` user (UID 42420)

## Anti-Patterns
- NEVER share Docker networks/volumes with DreamCI
- NEVER use `docker system prune` without user approval
- NEVER hardcode passwords in Dockerfiles or compose
- NEVER use `latest` tag for base images in Dockerfile (pin versions)
