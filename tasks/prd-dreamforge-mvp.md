# PRD: DreamForge MVP — Headless Unity AI Dev Environment

## Introduction

DreamForge is a standalone product that provides AI-powered Unity development environments using OpenHands (open source, MIT) as the agent platform. It runs headless Unity sandboxes (batchmode, no GUI/VNC) optimized for autonomous C# editing and compilation. Deployed via Docker Compose on a Hetzner server (65.109.80.40) alongside — but completely isolated from — DreamCI.

## Goals

- Provide a working OpenHands instance with custom Unity headless sandboxes
- Support 10+ simultaneous sessions on a 64GB RAM server
- Eliminate GUI overhead (Xvfb, VNC, fluxbox) saving ~4GB RAM per session
- Zero interference with existing DreamCI deployment on the same server
- Agent can edit C# files and compile via batchmode with real-time status feedback

## User Stories

### US-001: Create Dockerfile.unity-sandbox (headless Unity image)
**Description:** As a developer, I need a custom Docker image based on GameCI that runs Unity in headless batchmode so that sandboxes are lightweight and don't require GUI packages.

**Acceptance Criteria:**
- [ ] Dockerfile uses `unityci/editor` as base with ARG for version/platform
- [ ] NO GUI packages installed (no xvfb, vnc, fluxbox, xdotool, supervisor)
- [ ] Essential deps installed: inotify-tools, git, curl, wget, jq, unzip, python3, sudo
- [ ] Node.js 22 LTS installed (OpenHands runtime requirement)
- [ ] Unity TOS pre-accepted via JSON config file
- [ ] COPY and chmod for unity-init.sh, compile-watcher.sh, unity-compile.sh
- [ ] WORKDIR set to /workspace
- [ ] `bash -n` passes on all copied scripts
- [ ] Dockerfile syntax is valid

### US-002: Create scripts/unity-init.sh (headless bootstrap)
**Description:** As an OpenHands agent, I need a bootstrap script that initializes Unity headless so that the sandbox is ready for C# development.

**Acceptance Criteria:**
- [ ] Script starts with `#!/bin/bash` and `set -euo pipefail`
- [ ] Clones git repo if `GIT_REPO_URL` env var is set
- [ ] Activates Unity license (supports both .ulf file and UNITY_SERIAL env var)
- [ ] Runs batchmode init: `unity-editor -batchmode -nographics -projectPath /workspace -quit`
- [ ] Starts compile-watcher.sh in background
- [ ] NO Xvfb, VNC, or display-related code
- [ ] Handles errors gracefully with informative messages
- [ ] `bash -n scripts/unity/unity-init.sh` passes

### US-003: Create scripts/compile-watcher.sh (compilation monitor)
**Description:** As an OpenHands agent, I need a script that monitors Unity compilation status via Editor.log so that I can know when compilation succeeds or fails.

**Acceptance Criteria:**
- [ ] Uses `inotifywait` to watch Editor.log for changes
- [ ] Writes status to `/tmp/unity-compile-status.json`
- [ ] JSON has fields: `status` (idle/compiling/success/errors), `errors` (array), `timestamp`
- [ ] Detects compilation start, success, and error patterns from Unity log
- [ ] Runs as background daemon (infinite loop)
- [ ] `bash -n scripts/unity/compile-watcher.sh` passes

### US-004: Create scripts/unity-compile.sh (compilation helper)
**Description:** As an OpenHands agent, I need a simple helper to trigger Unity compilation and see results so that I can verify my C# changes work.

**Acceptance Criteria:**
- [ ] Runs `unity-editor -batchmode -nographics -projectPath /workspace -logFile /tmp/unity-compile.log -quit`
- [ ] Outputs compile status from `/tmp/unity-compile-status.json`
- [ ] Returns exit code 0 on success, 1 on failure
- [ ] `bash -n scripts/unity/unity-compile.sh` passes

### US-005: Create docker-compose.yml (OpenHands + PostgreSQL)
**Description:** As a developer, I need a Docker Compose configuration that orchestrates OpenHands with an isolated PostgreSQL so that the full stack runs with one command.

**Acceptance Criteria:**
- [ ] OpenHands service uses official image `docker.all-hands.dev/all-hands-ai/openhands:latest`
- [ ] OpenHands exposes port 3000 directly (no reverse proxy)
- [ ] OpenHands configured with sandbox resource limits: memory=2g, cpus=0.5
- [ ] OpenHands mounts docker.sock for sandbox creation
- [ ] PostgreSQL 16-alpine on port 5433 (NOT 5432, to avoid DreamCI conflict)
- [ ] PostgreSQL bound to 127.0.0.1 only
- [ ] PostgreSQL has healthcheck configured
- [ ] OpenHands depends on postgres with condition: service_healthy
- [ ] Named volumes for openhands-state and dreamforge-pgdata
- [ ] Environment variables use defaults with `${VAR:-default}` syntax
- [ ] `docker compose config --quiet` passes

### US-006: Create microagents/repo.md (agent instructions)
**Description:** As an OpenHands agent, I need clear instructions about the headless Unity environment so that I know how to initialize, edit, and compile Unity projects.

**Acceptance Criteria:**
- [ ] Explains that Unity runs in HEADLESS mode (no GUI)
- [ ] Documents first step: run `/unity-init.sh`
- [ ] Documents compilation workflow: edit .cs → `/unity-compile.sh` → check status
- [ ] Documents `/tmp/unity-compile-status.json` format and states
- [ ] Lists rules: C# in Assets/Scripts/, never touch Library/Temp, always compile and verify
- [ ] Clear, actionable instructions an AI agent can follow
- [ ] File is non-empty and well-structured markdown

### US-007: Create microagents/knowledge/unity-compilation.md
**Description:** As an OpenHands agent, I need knowledge about Unity C# compilation errors so that I can diagnose and fix common issues autonomously.

**Acceptance Criteria:**
- [ ] Documents trigger keywords: "compile", "error CS", "build"
- [ ] Lists common C# errors: CS0246 (missing type), CS1061 (missing member), CS0103 (undefined name)
- [ ] Explains how to read `/tmp/unity-compile-status.json`
- [ ] Provides fix patterns for each common error
- [ ] File is non-empty and well-structured markdown

### US-008: Create microagents/knowledge/unity-editor.md
**Description:** As an OpenHands agent, I need knowledge about Unity project structure and CLI commands so that I can navigate and work with Unity projects.

**Acceptance Criteria:**
- [ ] Documents trigger keywords: "editor", "unity", "scene"
- [ ] Explains Unity project structure (Assets, Library, ProjectSettings, Packages)
- [ ] Lists Unity batchmode CLI commands with examples
- [ ] Documents how to run tests via CLI (`-runTests`)
- [ ] File is non-empty and well-structured markdown

### US-009: Create scripts/deploy.sh (deployment helper)
**Description:** As a developer, I need a deployment script that syncs files to the server, builds the Unity image, and starts services so that deployment is repeatable.

**Acceptance Criteria:**
- [ ] Script starts with `#!/bin/bash` and `set -euo pipefail`
- [ ] Accepts server IP as first argument, SSH port as optional second (default 22)
- [ ] Uses rsync to sync files (excluding .git, .env, license.ulf)
- [ ] Runs docker build on server for Unity sandbox image
- [ ] Runs docker compose up -d on server
- [ ] Prints final URL (http://SERVER:3000)
- [ ] `bash -n scripts/deploy.sh` passes
- [ ] NOTE: Actual deployment will be done with human accompaniment

## Functional Requirements

- FR-1: Unity sandbox image based on GameCI, headless only (no Xvfb/VNC/fluxbox)
- FR-2: Bootstrap script initializes Unity license, clones repo, starts compile watcher
- FR-3: Compile watcher monitors Editor.log and writes JSON status file
- FR-4: Compile helper triggers batchmode compilation and reports results
- FR-5: Docker Compose orchestrates OpenHands + PostgreSQL with resource limits
- FR-6: PostgreSQL isolated on port 5433, bound to localhost only
- FR-7: Microagents provide clear instructions for AI agents working with headless Unity
- FR-8: Deploy script handles rsync + build + start in one command

## Non-Goals

- No GUI mode (Xvfb, VNC, fluxbox) — headless only for MVP
- No HTTPS/Caddy/reverse proxy — direct IP:port access
- No DreamCI integration — fully independent
- No multi-server orchestration — single Hetzner machine
- No web UI customization for OpenHands — use stock frontend
- No Unity asset store integration

## Technical Considerations

- Base image: `unityci/editor:ubuntu-<version>-<platform>-3` (GameCI)
- OpenHands requires Node.js in sandbox for runtime
- Docker socket must be mounted for OpenHands to create sandbox containers
- Resource limits enforced via Docker: 2GB RAM, 0.5 CPU per sandbox
- Port 5432 may already be used by DreamCI PostgreSQL — DreamForge uses 5433
- Unity license (.ulf) must be baked into the image or mounted

## Success Metrics

- OpenHands accessible at http://65.109.80.40:3000
- Agent can initialize Unity project via /unity-init.sh
- Agent can edit C# and compile via /unity-compile.sh with status feedback
- 10 simultaneous sessions run within 64GB RAM budget
- Zero impact on existing DreamCI services

## Open Questions

- Exact Unity version to target initially (6000.0.36f1 assumed)
- Whether to mount license.ulf at runtime or bake into image
- OpenHands sandbox config variable names may change between versions
