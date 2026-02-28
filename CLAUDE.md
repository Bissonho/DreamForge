# DreamForge — Claude Code Instructions

## Language
Communicate in **PT-BR**. All code, comments, commit messages, and variable names in **English**.

## Project Overview
DreamForge is a Unity AI development environment powered by OpenHands (open source, MIT).
It runs headless Unity sandboxes (batchmode, no GUI/VNC) for autonomous C# editing and compilation.
Separate from DreamCI — zero shared state, independent Docker Compose stack.

## Architecture
- **OpenHands** (forked, local build) app container on port :3000
- **PostgreSQL** container on port :5433 (DreamForge-only, isolated)
- **Unity Sandbox** containers: headless GameCI images with batchmode Unity
- **Docker Compose** orchestrates everything
- No Caddy, no reverse proxy — direct port access

## OpenHands Fork
The `openhands/` directory is a full fork of [All-Hands-AI/OpenHands](https://github.com/All-Hands-AI/OpenHands).
Built locally via `docker compose build openhands`.

### Key directories for customization:
- `openhands/frontend/src/` — React UI (TypeScript)
- `openhands/openhands/` — Python backend
- `openhands/openhands/runtime/` — Sandbox runtime logic
- `openhands/openhands/microagent/` — Microagent loading
- `openhands/containers/app/Dockerfile` — App image build

### Syncing with upstream:
```bash
cd openhands
git remote add upstream https://github.com/All-Hands-AI/OpenHands.git
git fetch upstream
git merge upstream/main  # resolve conflicts manually
```

## Project Structure
```
docker-compose.yml          → OpenHands + PostgreSQL orchestration
Dockerfile.unity-sandbox    → Custom headless Unity image (GameCI base)
openhands/                  → OpenHands fork (full source, local build)
  frontend/src/             → React UI (customizable)
  openhands/                → Python backend (API, runtime, agents)
  containers/app/           → App Dockerfile
  containers/runtime/       → Sandbox runtime
scripts/
  unity/
    unity-init.sh           → Bootstrap Unity headless (license, clone, init)
    unity-compile.sh        → Batchmode compilation helper
    compile-watcher.sh      → Monitor Editor.log, write status JSON
  deploy.sh                 → Deploy helper for Hetzner server
microagents/
  repo.md                   → Agent instructions for Unity headless work
  knowledge/
    unity-compilation.md    → C# compilation errors and fixes
    unity-editor.md         → Unity CLI/batchmode reference
config/
  .env.example              → Environment variable template
```

## Build & Validate
```bash
# Validate shell scripts
bash -n scripts/unity-init.sh
bash -n scripts/compile-watcher.sh
bash -n scripts/unity-compile.sh
bash -n scripts/deploy.sh

# Validate docker-compose
docker compose config --quiet

# Validate Dockerfile (basic)
docker build --check -f Dockerfile.unity-sandbox . 2>/dev/null || true
```

## Code Conventions
- Shell scripts: `#!/bin/bash` with `set -euo pipefail`
- Shell variable names: `UPPER_SNAKE_CASE` for exports, `lower_snake_case` for locals
- Docker labels: use `org.opencontainers.image.*` standard
- YAML: 2-space indent
- Markdown: ATX-style headers (`#`), fenced code blocks

## Critical Rules
- NEVER install packages on the host machine — everything runs in Docker
- NEVER share volumes/networks/ports with DreamCI
- NEVER use GUI packages (Xvfb, VNC, fluxbox, xdotool) — headless only
- NEVER hardcode API keys or passwords — always use environment variables
- Unity runs ONLY in batchmode: `-batchmode -nographics`
- PostgreSQL for DreamForge MUST use port 5433 (not 5432, which may be DreamCI)

## Resource Limits
- Each Unity sandbox: `--memory=2g --cpus=0.5`
- OpenHands app: `memory: 4g` limit
- Target: 10 simultaneous sessions on 64GB RAM server
- No Xvfb/VNC saves ~500MB per session
- No GUI Unity saves ~3GB per session

## Headless Optimizations
- No `DISPLAY` environment variable
- No X11 packages in Docker image
- Unity batchmode only (`-batchmode -nographics`)
- No code-server (saves ~300MB per session)
- Image ~40% smaller than GUI version

## Deploy
Server: Hetzner AX41-NVMe (65.109.80.40), 64GB RAM, Ryzen 5 3600
Deploy with: `./scripts/deploy.sh 65.109.80.40`
DreamCI already runs on this server — DO NOT interfere with existing services.

## Commit Style
```
type: short description

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

Types: feat, fix, refactor, test, docs, chore, deploy
