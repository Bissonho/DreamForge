---
description: "Deploy DreamForge to the Hetzner server"
disable-model-invocation: true
---

# /deploy $ARGUMENTS

Deploy DreamForge to the Hetzner server. $ARGUMENTS: optional flags.

## Server
- Hetzner AX41-NVMe: 65.109.80.40
- DreamCI already runs here — DO NOT interfere

## Steps

1. Confirm with user before proceeding (deploy requires human accompaniment)
2. Validate locally:
   ```bash
   find scripts -name "*.sh" -exec bash -n {} \;
   docker compose config --quiet
   ```
3. Run deploy:
   ```bash
   ./scripts/deploy.sh 65.109.80.40
   ```
   This will:
   - rsync files to `/opt/dreamforge/`
   - Build Unity sandbox image on server
   - Build OpenHands image on server (from fork)
   - Start services with docker compose

4. Verify:
   ```bash
   curl http://65.109.80.40:3000
   ```

## CRITICAL
- ALWAYS validate scripts locally before deploying
- ALWAYS confirm with user before running deploy
- NEVER interfere with DreamCI services on the same server
- NEVER deploy without human accompaniment (MVP phase)
