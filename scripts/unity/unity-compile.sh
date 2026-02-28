#!/bin/bash
# unity-compile.sh — Trigger Unity compilation and report results
set -euo pipefail

UNITY_PROJECT_PATH="${UNITY_PROJECT_PATH:-/workspace}"
UNITY_EDITOR="${UNITY_EDITOR:-unity-editor}"
COMPILE_LOG="/tmp/unity-compile.log"
STATUS_FILE="/tmp/unity-compile-status.json"

echo "[unity-compile] Triggering Unity batchmode compilation..."

"${UNITY_EDITOR}" \
    -batchmode \
    -nographics \
    -projectPath "${UNITY_PROJECT_PATH}" \
    -logFile "${COMPILE_LOG}" \
    -quit

echo "[unity-compile] Unity exited. Reading status..."

# Wait briefly for compile-watcher to update status
sleep 1

if [[ -f "${STATUS_FILE}" ]]; then
    cat "${STATUS_FILE}"
    status=$(grep -o '"status":"[^"]*"' "${STATUS_FILE}" | cut -d'"' -f4)
    if [[ "${status}" == "success" || "${status}" == "idle" ]]; then
        echo "[unity-compile] Compilation succeeded."
        exit 0
    else
        echo "[unity-compile] Compilation failed or errored."
        exit 1
    fi
else
    echo "[unity-compile] WARNING: Status file not found at ${STATUS_FILE}"
    exit 1
fi
