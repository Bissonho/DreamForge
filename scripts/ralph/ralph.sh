#!/bin/bash
# Ralph — Autonomous AI agent loop for DreamForge
# Usage: ./ralph.sh [--tool claude|amp] [max_iterations]
# Default: claude with 10 iterations

set -e

# Parse arguments
TOOL="claude"
MAX_ITERATIONS=30

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --tool=*)
      TOOL="${1#*=}"
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

if [[ "$TOOL" != "amp" && "$TOOL" != "claude" ]]; then
  echo "Error: Invalid tool '$TOOL'. Must be 'amp' or 'claude'."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PRD_FILE="$SCRIPT_DIR/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
STATUS_FILE="$SCRIPT_DIR/status.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"

# Archive previous run if branch changed
if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    DATE=$(date +%Y-%m-%d)
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"

    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# Track current branch
if [ -f "$PRD_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
  fi
fi

# Initialize progress file if needed
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

# Status update helper
update_status() {
  local iteration="$1"
  local story_id="$2"
  local model="$3"
  local status="$4"
  local passed=$(jq '[.userStories[] | select(.passes == true)] | length' "$PRD_FILE" 2>/dev/null || echo "?")
  local total=$(jq '.userStories | length' "$PRD_FILE" 2>/dev/null || echo "?")
  local pct=$((passed * 100 / total))
  echo "${passed}/${total} (${pct}%) | ${story_id} | ${model} | ${status} | iter ${iteration}/${MAX_ITERATIONS} | $(date '+%H:%M:%S')" > "$STATUS_FILE"
}

echo "Starting Ralph - Tool: $TOOL - Max iterations: $MAX_ITERATIONS"
echo "Project dir: $PROJECT_DIR"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Ralph Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "==============================================================="

  # Extract next story info
  STORY_MODEL=$(jq -r '
    [.userStories[] | select(.passes == false)]
    | sort_by(.priority)
    | .[0].model // "sonnet"
  ' "$PRD_FILE" 2>/dev/null || echo "sonnet")

  STORY_ID=$(jq -r '
    [.userStories[] | select(.passes == false)]
    | sort_by(.priority)
    | .[0].id // "?"
  ' "$PRD_FILE" 2>/dev/null || echo "?")

  STORY_TITLE=$(jq -r '
    [.userStories[] | select(.passes == false)]
    | sort_by(.priority)
    | .[0].title // ""
  ' "$PRD_FILE" 2>/dev/null || echo "")

  # Check if all done
  if [ "$STORY_ID" = "?" ] || [ "$STORY_ID" = "null" ]; then
    update_status "$i" "-" "-" "COMPLETE"
    echo "All stories completed!"
    exit 0
  fi

  update_status "$i" "$STORY_ID" "$STORY_MODEL" "running: $STORY_TITLE"

  # Run the agent
  if [[ "$TOOL" == "amp" ]]; then
    echo "  Story: $STORY_ID | Model: $STORY_MODEL (amp)"
    OUTPUT=$(cat "$SCRIPT_DIR/RALPH.md" | amp --dangerously-allow-all 2>&1 | tee /dev/stderr) || true
  else
    # Detect provider and resolve model ID
    if [[ "$STORY_MODEL" == openrouter:* ]]; then
      OR_MODEL="${STORY_MODEL#openrouter:}"

      if [ -z "$OPENROUTER_API_KEY" ]; then
        echo "  WARNING: OPENROUTER_API_KEY not set. Falling back to claude-sonnet-4-6"
        CLAUDE_MODEL="claude-sonnet-4-6"
        echo "  Story: $STORY_ID | Model: $STORY_MODEL → $CLAUDE_MODEL (fallback)"
        OUTPUT=$(cd "$PROJECT_DIR" && env -u CLAUDECODE claude --model "$CLAUDE_MODEL" \
                 --dangerously-skip-permissions --print \
                 < "$SCRIPT_DIR/RALPH.md" 2>&1 | tee /dev/stderr) || true
      else
        echo "  Story: $STORY_ID | Model: $OR_MODEL (OpenRouter)"
        OUTPUT=$(cd "$PROJECT_DIR" && \
                 ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1" \
                 ANTHROPIC_API_KEY="$OPENROUTER_API_KEY" \
                 env -u CLAUDECODE claude --model "$OR_MODEL" \
                 --dangerously-skip-permissions --print \
                 < "$SCRIPT_DIR/RALPH.md" 2>&1 | tee /dev/stderr) || true
      fi
    else
      case "$STORY_MODEL" in
        opus)   CLAUDE_MODEL="claude-opus-4-6" ;;
        haiku)  CLAUDE_MODEL="claude-haiku-4-5-20251001" ;;
        *)      CLAUDE_MODEL="claude-sonnet-4-6" ;;
      esac

      echo "  Story: $STORY_ID | Model: $STORY_MODEL → $CLAUDE_MODEL (Claude)"
      OUTPUT=$(cd "$PROJECT_DIR" && env -u CLAUDECODE claude --model "$CLAUDE_MODEL" \
               --dangerously-skip-permissions --print \
               < "$SCRIPT_DIR/RALPH.md" 2>&1 | tee /dev/stderr) || true
    fi
  fi

  update_status "$i" "$STORY_ID" "$STORY_MODEL" "done"

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    update_status "$i" "-" "-" "COMPLETE"
    echo ""
    echo "Ralph completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

update_status "$MAX_ITERATIONS" "-" "-" "MAX_ITERATIONS_REACHED"
echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
