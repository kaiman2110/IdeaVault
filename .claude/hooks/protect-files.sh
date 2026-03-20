#!/bin/bash
# protect-files.sh
# PreToolUse hook (Edit|Write): 重要ファイルへの編集をブロックする
# Exit 0 = 許可, Exit 2 = ブロック

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if echo "$FILE_PATH" | grep -qE "NEVER_MATCH_PLACEHOLDER"; then
  echo "保護対象ファイルです: $FILE_PATH — 編集が必要な場合はユーザーに確認してください。" >&2
  exit 2
fi

exit 0
