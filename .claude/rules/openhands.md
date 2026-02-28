---
paths:
  - "openhands/**"
---

# OpenHands Fork Rules

## Architecture
- Backend: Python (FastAPI + uvicorn) in `openhands/openhands/`
- Frontend: React (TypeScript + Vite) in `openhands/frontend/`
- App Dockerfile: `openhands/containers/app/Dockerfile`
- Runtime: sandbox management in `openhands/openhands/runtime/`

## Key Directories
- `openhands/openhands/core/` — config, main loop, schema
- `openhands/openhands/controller/` — agent controller
- `openhands/openhands/runtime/` — sandbox creation and management
- `openhands/openhands/llm/` — LLM integration
- `openhands/openhands/microagent/` — microagent loading system
- `openhands/openhands/events/` — event system (actions, observations)
- `openhands/frontend/src/components/` — React UI components
- `openhands/frontend/src/routes/` — React Router routes
- `openhands/frontend/src/services/` — API client services

## Upstream Sync
- Remote `upstream` → `https://github.com/All-Hands-AI/OpenHands.git`
- Fetch: `cd openhands && git fetch upstream`
- Merge: `git merge upstream/main` — resolve conflicts manually
- Keep customizations in separate commits for easier rebasing

## Customization Strategy
- Prefer config/env changes over code changes when possible
- For UI changes: modify existing components, don't create parallel ones
- For backend changes: extend existing endpoints, add new ones with `/dreamforge/` prefix
- Tag custom commits with `[dreamforge]` prefix in commit messages

## Anti-Patterns
- NEVER modify OpenHands core in ways that break upstream compatibility unnecessarily
- NEVER remove existing OpenHands features — only add or extend
- NEVER hardcode DreamForge-specific values in OpenHands core — use config/env vars
- NEVER skip frontend build when modifying UI (changes won't appear in Docker image)
