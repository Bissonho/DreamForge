---
paths:
  - "Dockerfile.unity-sandbox"
  - "scripts/unity/**"
---

# Unity Sandbox Rules

## Headless Only
- Unity runs ONLY in batchmode: `-batchmode -nographics`
- NO DISPLAY variable, NO X11, NO Xvfb, NO VNC
- Image is ~40% smaller than GUI version

## Shell Scripts
- All scripts start with `#!/bin/bash` and `set -euo pipefail`
- `unity-init.sh` — bootstrap: clone, license, batchmode init, start watcher
- `compile-watcher.sh` — monitor Editor.log via inotifywait, write JSON status
- `unity-compile.sh` — trigger batchmode compilation, output status

## Compile Watcher
- Status file: `/tmp/unity-compile-status.json`
- States: `idle` → `compiling` → `success` or `errors`
- Error extraction: grep `error CS` patterns from Editor.log
- Resilient to log file not existing yet (waits in loop)

## Editor.log Locations
- Primary: `/root/.config/unity3d/Editor.log`
- Alternative: `/workspace/Library/Logs/Editor.log`
- Check both — location varies by Unity version

## Unity License
- `.ulf` file: mount or bake into image
- Serial: via `UNITY_SERIAL` + `UNITY_EMAIL` + `UNITY_PASSWORD` env vars
- TOS pre-accepted via JSON at `/root/.config/unity3d/Unity/TOS.json`

## Anti-Patterns
- NEVER add GUI packages to the sandbox image
- NEVER hardcode Unity version — always use ARG/env var
- NEVER assume Unity exit code 0 = success — check compile status JSON
- NEVER modify `/workspace/Library/` or `/workspace/Temp/` directly
