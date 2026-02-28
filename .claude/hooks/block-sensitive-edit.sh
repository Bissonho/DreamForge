#!/bin/bash
# Hook: block-sensitive-edit
# Blocks edits to sensitive files (.env, secrets, license files).
# Exit 0 = allow, Exit 2 = block (stderr message shown to user)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Block .env files
if echo "$FILE_PATH" | grep -qE '\.env($|\.)'; then
  echo "BLOCKED: Cannot edit .env files. These contain secrets and must be edited manually." >&2
  exit 2
fi

# Block Unity license files
if echo "$FILE_PATH" | grep -qE '\.ulf$'; then
  echo "BLOCKED: Cannot edit Unity license files (.ulf). These are binary/encoded credentials." >&2
  exit 2
fi

# Block auth credential files
if echo "$FILE_PATH" | grep -qE 'auth\.json$|credentials|\.secret'; then
  echo "BLOCKED: Cannot edit credential/secret files. These must be edited manually." >&2
  exit 2
fi

# Block package-lock.json (managed by npm)
if echo "$FILE_PATH" | grep -qE 'package-lock\.json$'; then
  echo "BLOCKED: Cannot edit package-lock.json directly. Use 'npm install' instead." >&2
  exit 2
fi

# Block poetry.lock (managed by poetry)
if echo "$FILE_PATH" | grep -qE 'poetry\.lock$'; then
  echo "BLOCKED: Cannot edit poetry.lock directly. Use 'poetry lock' instead." >&2
  exit 2
fi

exit 0
