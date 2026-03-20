#!/bin/bash
# stop-run-tests.sh
# Stop hook: ソースファイルの変更があればテストを自動実行する
# + セッション終了リマインダー表示
# Exit 0 = ok, Exit 2 = テスト失敗（Claude が修正を続行）

PROJECT_DIR="C:/Users/kaima/workspace/develop/IdeaVault"

# ソースファイルの変更を確認
SRC_CHANGES=$(git -C "$PROJECT_DIR" diff --name-only 2>/dev/null | grep '.js$')
SRC_STAGED=$(git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null | grep '.js$')

TEST_EXIT=0

if [ -n "$SRC_CHANGES" ] || [ -n "$SRC_STAGED" ]; then
  # テスト実行
  OUTPUT=$(echo 'テストコマンド未設定' 2>&1)

  # 結果判定（テストフレームワークに合わせて調整）
  if echo "$OUTPUT" | grep -qiE "(All tests passed|passed|success|ok)"; then
    TEST_EXIT=0
  else
    FAILURES=$(echo "$OUTPUT" | grep -iE "(FAILED|failing|error)" | head -10)
    echo "テスト失敗: $FAILURES" >&2
    TEST_EXIT=2
  fi
fi

# セッション終了リマインダー: 未コミット変更がある場合に表示
UNCOMMITTED=$(git -C "$PROJECT_DIR" status --short 2>/dev/null)
if [ -n "$UNCOMMITTED" ]; then
  CHANGE_COUNT=$(echo "$UNCOMMITTED" | wc -l | tr -d ' ')
  echo "⚠️ [session-end リマインダー] 未コミット変更が ${CHANGE_COUNT} 件あります。セッション終了前に /session-end を必ず実行してください。"
fi

# セッション長警告
SESSION_DIR="$HOME/.claude/projects/C-Users-kaima-workspace-develop-IdeaVault"
if [ -d "$SESSION_DIR" ]; then
  LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
  if [ -n "$LATEST_SESSION" ]; then
    HUMAN_COUNT=$(grep -c '"type":"human"' "$LATEST_SESSION" 2>/dev/null || echo "0")
    SESSION_SIZE=$(wc -c < "$LATEST_SESSION" 2>/dev/null || echo "0")
    SESSION_SIZE_MB=$((SESSION_SIZE / 1048576))
    if [ "$SESSION_SIZE_MB" -ge 2 ]; then
      echo "🔴 セッションサイズが ${SESSION_SIZE_MB}MB に達しています。コンテキスト圧縮ロスのリスクがあります。/session-end で区切ってください。"
    elif [ "$HUMAN_COUNT" -ge 20 ]; then
      echo "⚠️ セッションが長くなっています（${HUMAN_COUNT} メッセージ）。/session-end で区切りを検討してください。"
    fi
  fi
fi

# exit 意図検出
HISTORY_FILE="$HOME/.claude/history.jsonl"
if [ -f "$HISTORY_FILE" ]; then
  LAST_MSG=$(tail -1 "$HISTORY_FILE" 2>/dev/null | grep -oP '"display":"[^"]*"' | head -1)
  if echo "$LAST_MSG" | grep -qiE '(exit|quit|終わり|おわり|ここまで|終了)'; then
    echo "🔴 [自動検出] セッション終了の意思を検出しました。/session-end が未実行の場合、メモリが保存されません。必ず /session-end を先に実行してください。"
  fi
fi

exit $TEST_EXIT
