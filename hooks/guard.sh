#!/bin/sh
if grep -Eq '"(file_path|notebook_path|path)" *: *"([^"]*/)?docs/context/'; then
  echo "Agents write docs/context/ only through sh \"$(cd "$(dirname "$0")/.." && pwd)/skills/context-authoring/scripts/context.sh\", as the agentic:context-authoring skill describes." >&2
  exit 2
fi
