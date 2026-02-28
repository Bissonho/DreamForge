# DreamForge

Unity AI development environment powered by OpenHands. Headless Unity sandboxes for autonomous code editing and compilation.

## Architecture

- **OpenHands** — Open source AI agent platform (MIT)
- **Unity Headless** — Batchmode compilation, no GUI/VNC
- **Docker Compose** — Isolated deployment, zero shared state with DreamCI

## Quick Start

```bash
# 1. Configure environment
cp config/.env.example .env
# Edit .env with your API keys and passwords

# 2. Copy Unity license
cp /path/to/your/license.ulf ./license.ulf

# 3. Build Unity sandbox image
docker build --build-arg UNITY_VERSION=6000.0.36f1 \
    -t dreamforge-unity:6000.0.36f1 \
    -f Dockerfile.unity-sandbox .

# 4. Start services
docker compose up -d

# 5. Access OpenHands
open http://localhost:3000
```

## Resource Budget (64GB RAM server)

| Component | RAM | CPU |
|---|---|---|
| OpenHands app + PG | ~4GB | 1 core |
| Unity sandbox (x10) | ~15GB | ~5 cores |
| OS + buffer | ~2GB | 0.5 core |
| **Available** | **~43GB** | **~5.5 cores** |

## Project Structure

```
docker-compose.yml          # OpenHands + PostgreSQL
Dockerfile.unity-sandbox    # Headless Unity image (GameCI base)
scripts/
  unity-init.sh             # Bootstrap Unity headless
  unity-compile.sh          # Batchmode compilation helper
  compile-watcher.sh        # Monitor compilation status
  deploy.sh                 # Deploy to server
microagents/
  repo.md                   # Agent instructions for Unity headless
  knowledge/
    unity-compilation.md    # Compilation errors and fixes
    unity-editor.md         # Unity CLI and batchmode
config/
  .env.example              # Environment template
```
