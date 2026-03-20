#!/bin/bash
# block-push-main.sh
# PreToolUse hook: main/master への直接 push をブロックする
# Exit 0 = 許可, Exit 2 = ブロック

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

if echo "$COMMAND" | grep -qE "git push.*(origin|upstream)?\s*(main|master)"; then
  echo "main/master への直接 push はブランチルール違反です。feature/issue/<N> ブランチから作業してください。" >&2
  exit 2
fi

exit 0
