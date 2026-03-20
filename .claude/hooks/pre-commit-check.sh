#!/bin/bash
# pre-commit-check.sh
# PreToolUse hook (Bash): git commit 前にアーキテクチャ違反を検出する
# Exit 0 = 許可, Exit 2 = ブロック
#
# セットアップ: プロジェクト固有のチェックを下部に追加してください

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# git commit 以外はスキップ
if ! echo "$COMMAND" | grep -qE "git commit"; then
  exit 0
fi

# ステージされたファイルを取得（.js でフィルタ）
STAGED=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null | grep '.js$')
if [ -z "$STAGED" ]; then
  exit 0
fi

ERRORS=""

# === プロジェクト固有チェックをここに追加 ===
# 例: 特定パターンの検出
# HITS=$(echo "$STAGED" | xargs grep -ln 'FORBIDDEN_PATTERN' 2>/dev/null)
# if [ -n "$HITS" ]; then
#   ERRORS="${ERRORS}\n- FORBIDDEN_PATTERN 使用禁止: $HITS"
# fi

if [ -n "$ERRORS" ]; then
  echo -e "コミット前チェック失敗:$ERRORS" >&2
  exit 2
fi

exit 0
