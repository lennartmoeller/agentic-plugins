#!/bin/sh
set -eu
dir=$(dirname "$0")/instructions
case $1 in
  SessionStart) own=session ;;
  SubagentStart) own=subagent ;;
esac
list=$(cat "$dir/$own.md" "$dir/shared.md")
context=$(printf '%s\n' "$list" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk '{printf "%s\\n", $0}')
# Copilot CLI reads the top-level field, Claude Code the nested one.
printf '{"additionalContext":"%s","hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "$context" "$1" "$context"
