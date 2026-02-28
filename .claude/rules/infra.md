---
paths:
  - "scripts/deploy.sh"
  - "docker-compose.yml"
  - "config/**"
---

# Infrastructure & Deploy Rules

## Production Server
- Hetzner AX41-NVMe: 65.109.80.40
- 64GB RAM, Ryzen 5 3600, 2x512GB NVMe
- Ubuntu 24.04
- DreamCI already runs here — NEVER interfere with existing services

## Deploy Process
1. `rsync` project files to `/opt/dreamforge/` (exclude .git, .env, .ulf)
2. Build Unity sandbox image on server
3. Build OpenHands image on server (from local fork)
4. `docker compose up -d`

## Port Allocation
- 3000: DreamForge OpenHands (external)
- 5433: DreamForge PostgreSQL (localhost only)
- DreamCI ports: DO NOT TOUCH

## Resource Budget (64GB total)
- DreamCI: ~3GB RAM, ~2 cores
- OS: ~1GB
- OpenHands app + PG: ~4GB, 1 core
- Unity sandboxes (x10): ~15GB (1.5GB each), ~5 cores
- Buffer: ~41GB free

## Firewall
- Port 3000 must be open (UFW: `ufw allow 3000/tcp`)
- PostgreSQL 5433 is localhost only — no firewall rule needed

## Anti-Patterns
- NEVER install packages directly on the host — use Docker
- NEVER share Docker volumes/networks with DreamCI
- NEVER modify DreamCI's systemd services, env files, or ports
- NEVER deploy without human accompaniment (for MVP phase)
