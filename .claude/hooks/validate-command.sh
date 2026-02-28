#!/bin/bash
# Hook: validate-command
# Blocks dangerous bash commands before execution.
# Exit 0 = allow, Exit 2 = block (stderr message shown to user)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Block dangerous patterns
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+/'; then
  echo "BLOCKED: 'rm -rf /' is too dangerous. Specify a safe path." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force'; then
  echo "BLOCKED: Force push can destroy remote history. Use --force-with-lease instead, or ask the user." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: git reset --hard discards all uncommitted changes. Ask the user first." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+branch\s+-D'; then
  echo "BLOCKED: Force-deleting branches can lose work. Use -d (safe delete) instead." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+clean\s+-f'; then
  echo "BLOCKED: git clean -f permanently removes untracked files. Ask the user first." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'docker\s+system\s+prune'; then
  echo "BLOCKED: docker system prune removes all unused images/containers. Ask the user first." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'docker\s+volume\s+rm'; then
  echo "BLOCKED: Removing Docker volumes destroys data. Ask the user first." >&2
  exit 2
fi

exit 0
