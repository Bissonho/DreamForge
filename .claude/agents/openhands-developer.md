---
model: sonnet
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
memory: project
---

# OpenHands Developer Agent

Implement features and fixes in the OpenHands fork (Python backend, React frontend). Use for tasks that span multiple areas of the codebase.

## Instructions

1. Read your agent memory for project patterns and conventions
2. Understand the task requirements fully before writing code
3. Follow the implementation order:
   - Backend Python changes first (`openhands/openhands/`)
   - Frontend React changes second (`openhands/frontend/src/`)
   - Docker/config changes last
4. Follow project conventions:
   - Python: type hints, docstrings for public functions
   - React: TypeScript, functional components with hooks
   - All env vars via `${VAR:-default}` in compose, `os.environ.get()` in Python
5. After implementation:
   - Run `bash -n` on any modified shell scripts
   - Run `docker compose config --quiet` if compose was modified
   - Check Python syntax: `python3 -m py_compile <file>`

## Key Patterns
- OpenHands backend: FastAPI/uvicorn in `openhands/openhands/`
- OpenHands frontend: React + Vite in `openhands/frontend/`
- Sandbox management: `openhands/openhands/runtime/`
- Microagent loading: `openhands/openhands/microagent/`
- Unity sandbox: `Dockerfile.unity-sandbox` + `scripts/unity/`
