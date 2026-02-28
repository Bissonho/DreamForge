#!/bin/bash
# unity-init.sh — Bootstrap Unity headless sandbox
# Initializes license, clones repo if needed, runs batchmode init, starts compile-watcher
set -euo pipefail

UNITY_PROJECT_PATH="${UNITY_PROJECT_PATH:-/workspace}"
UNITY_EDITOR="${UNITY_EDITOR:-unity-editor}"

echo "[unity-init] Starting Unity headless initialization..."

# Clone git repository if GIT_REPO_URL is set
if [[ -n "${GIT_REPO_URL:-}" ]]; then
    branch="${GIT_BRANCH:-main}"
    echo "[unity-init] Cloning ${GIT_REPO_URL} (branch: ${branch})..."
    git clone --branch "${branch}" --single-branch "${GIT_REPO_URL}" "${UNITY_PROJECT_PATH}"
else
    echo "[unity-init] No GIT_REPO_URL set — skipping clone."
fi

# Activate Unity license
if [[ -n "${UNITY_LICENSE_FILE:-}" && -f "${UNITY_LICENSE_FILE}" ]]; then
    echo "[unity-init] Activating license from file: ${UNITY_LICENSE_FILE}"
    "${UNITY_EDITOR}" \
        -batchmode \
        -nographics \
        -manualLicenseFile "${UNITY_LICENSE_FILE}" \
        -quit || echo "[unity-init] WARNING: License activation returned non-zero (may already be active)"
elif [[ -n "${UNITY_SERIAL:-}" ]]; then
    echo "[unity-init] Activating license via serial..."
    "${UNITY_EDITOR}" \
        -batchmode \
        -nographics \
        -serial "${UNITY_SERIAL}" \
        -username "${UNITY_EMAIL:-}" \
        -password "${UNITY_PASSWORD:-}" \
        -quit || echo "[unity-init] WARNING: Serial activation returned non-zero"
else
    echo "[unity-init] No license configuration found — assuming license pre-accepted via TOS config."
fi

# Initialize Unity project in batchmode
echo "[unity-init] Running Unity batchmode initialization..."
"${UNITY_EDITOR}" \
    -batchmode \
    -nographics \
    -projectPath "${UNITY_PROJECT_PATH}" \
    -quit

echo "[unity-init] Unity initialization complete."

# Start compile-watcher in background
if [[ -f /unity-compile-watcher.sh ]]; then
    echo "[unity-init] Starting compile-watcher in background..."
    bash /unity-compile-watcher.sh &
elif [[ -f /compile-watcher.sh ]]; then
    echo "[unity-init] Starting compile-watcher in background..."
    bash /compile-watcher.sh &
else
    echo "[unity-init] WARNING: compile-watcher.sh not found — skipping."
fi

echo "[unity-init] Bootstrap complete. Sandbox is ready."
