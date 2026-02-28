#!/bin/bash
# compile-watcher.sh — Monitor Unity compilation via Editor.log
# Writes JSON status to /tmp/unity-compile-status.json
set -euo pipefail

STATUS_FILE="/tmp/unity-compile-status.json"
# Check both known Editor.log locations
EDITOR_LOG_PRIMARY="/root/.config/unity3d/Editor.log"
EDITOR_LOG_ALT="/workspace/Library/Logs/Editor.log"

# Determine active log file
find_log_file() {
    if [[ -f "${EDITOR_LOG_PRIMARY}" ]]; then
        echo "${EDITOR_LOG_PRIMARY}"
    elif [[ -f "${EDITOR_LOG_ALT}" ]]; then
        echo "${EDITOR_LOG_ALT}"
    else
        echo ""
    fi
}

# Write status JSON
write_status() {
    local status="$1"
    local errors_json="${2:-[]}"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    printf '{"status":"%s","errors":%s,"timestamp":"%s"}\n' \
        "${status}" "${errors_json}" "${timestamp}" > "${STATUS_FILE}"
}

# Extract error messages from a log snippet
extract_errors() {
    local log_file="$1"
    local errors=()
    # Read recent lines containing CS errors
    while IFS= read -r line; do
        errors+=("$(printf '%s' "${line}" | sed 's/"/\\"/g')")
    done < <(grep -o 'error CS[^)]*' "${log_file}" 2>/dev/null | tail -20)

    if [[ ${#errors[@]} -eq 0 ]]; then
        echo "[]"
        return
    fi

    local json="["
    local first=true
    for err in "${errors[@]}"; do
        if [[ "${first}" == true ]]; then
            json+="\"${err}\""
            first=false
        else
            json+=",\"${err}\""
        fi
    done
    json+="]"
    echo "${json}"
}

echo "[compile-watcher] Starting. Status file: ${STATUS_FILE}"

# Initialize with idle state
write_status "idle"

# Main watch loop — resilient to log file not existing yet
while true; do
    log_file=$(find_log_file)

    if [[ -z "${log_file}" ]]; then
        # Log doesn't exist yet — wait for it
        sleep 2
        continue
    fi

    # Watch for modifications using inotifywait
    inotifywait -q -e modify "${log_file}" 2>/dev/null || { sleep 2; continue; }

    # Log was modified — check state
    if grep -q "- Compilation started" "${log_file}" 2>/dev/null; then
        write_status "compiling"
    fi

    if grep -q "Compilation complete\|Compilation succeeded\|Finished compilation" "${log_file}" 2>/dev/null; then
        if grep -q "error CS" "${log_file}" 2>/dev/null; then
            errors_json=$(extract_errors "${log_file}")
            write_status "errors" "${errors_json}"
        else
            write_status "success"
        fi
    fi
done
