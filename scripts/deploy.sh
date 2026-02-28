#!/bin/bash
# deploy.sh — Deploy DreamForge to remote server
set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SERVER="${1:-}"
SSH_PORT="${2:-22}"

# Usage message
if [[ -z "$SERVER" ]]; then
    echo "Usage: $0 <SERVER> [SSH_PORT]"
    echo ""
    echo "Example:"
    echo "  $0 65.109.80.40"
    echo "  $0 65.109.80.40 2222"
    echo ""
    exit 1
fi

echo "[deploy] Starting DreamForge deployment to $SERVER (SSH port: $SSH_PORT)"
echo ""

# Step 1: Sync files to server
echo "[deploy] Step 1/4: Syncing project files..."
rsync -avz \
    --delete \
    --exclude '.git' \
    --exclude '.env' \
    --exclude 'license.ulf' \
    --exclude '.claude' \
    --exclude 'node_modules' \
    --exclude '.venv' \
    -e "ssh -p $SSH_PORT" \
    "$PROJECT_DIR/" \
    "root@$SERVER:/opt/dreamforge/" || {
    echo "[deploy] ERROR: rsync failed"
    exit 1
}
echo "[deploy] ✓ Files synced"
echo ""

# Step 2: Build Unity sandbox image
echo "[deploy] Step 2/5: Building Unity sandbox Docker image on server..."
ssh -p "$SSH_PORT" "root@$SERVER" <<'EOF'
    cd /opt/dreamforge
    docker build -f Dockerfile.unity-sandbox -t dreamforge-unity-sandbox:latest . || {
        echo "[deploy] ERROR: Unity sandbox Docker build failed"
        exit 1
    }
    echo "[deploy] ✓ Unity sandbox image built"
EOF
echo "[deploy] ✓ Unity sandbox image build complete"
echo ""

# Step 3: Build OpenHands (local fork)
echo "[deploy] Step 3/5: Building OpenHands from local fork on server..."
ssh -p "$SSH_PORT" "root@$SERVER" <<'EOF'
    cd /opt/dreamforge
    docker compose build openhands || {
        echo "[deploy] ERROR: OpenHands build failed"
        exit 1
    }
    echo "[deploy] ✓ OpenHands image built"
EOF
echo "[deploy] ✓ OpenHands build complete"
echo ""

# Step 4: Start services with docker-compose
echo "[deploy] Step 4/5: Starting services with docker-compose..."
ssh -p "$SSH_PORT" "root@$SERVER" <<'EOF'
    cd /opt/dreamforge
    docker compose up -d || {
        echo "[deploy] ERROR: docker compose up failed"
        exit 1
    }
    echo "[deploy] ✓ Services started"
EOF
echo "[deploy] ✓ Docker compose started"
echo ""

# Step 5: Summary
echo "[deploy] Step 5/5: Deployment complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ DreamForge is now running at:"
echo ""
echo "    🌐 http://$SERVER:3000"
echo ""
echo "Open a browser and navigate to the URL above to access OpenHands."
echo ""
echo "Services:"
echo "  - OpenHands (port 3000): http://$SERVER:3000"
echo "  - PostgreSQL (port 5433): localhost:5433 (local only)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
