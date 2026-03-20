#!/bin/bash
# session-start-context.sh
# セッション開始時にコンテキスト情報を自動表示する

PROJECT_DIR="C:/Users/kaima/workspace/develop/IdeaVault"
MEMORY_DIR="$HOME/.claude/projects/C-Users-kaima-workspace-develop-IdeaVault/memory"

echo "=== セッション開始 ==="
echo ""

# ブランチ状態
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null)
echo "ブランチ: $BRANCH"

# 未コミット変更
CHANGES=$(git -C "$PROJECT_DIR" status --short 2>/dev/null)
if [ -n "$CHANGES" ]; then
  COUNT=$(echo "$CHANGES" | wc -l | tr -d ' ')
  echo "未コミット変更: ${COUNT}件"
fi

# feature ブランチなら Issue 番号を抽出
if [[ "$BRANCH" == feature/issue/* ]]; then
  ISSUE_NUM="${BRANCH##*/}"
  echo "作業中 Issue: #${ISSUE_NUM}"
fi

# 直近コミット
LAST_COMMIT=$(git -C "$PROJECT_DIR" log --oneline -1 2>/dev/null)
echo "直近コミット: $LAST_COMMIT"

# Open Issue 数
if command -v gh &>/dev/null; then
  OPEN_COUNT=$(gh issue list --repo kaiman2110/IdeaVault --state open --json number --jq 'length' 2>/dev/null)
  if [ -n "$OPEN_COUNT" ]; then
    TOP_ISSUE=$(gh issue list --repo kaiman2110/IdeaVault --state open --label "priority/high" --json number,title --jq '.[0] | "#\(.number) \(.title)"' 2>/dev/null)
    echo "Open Issues: ${OPEN_COUNT}件"
    if [ -n "$TOP_ISSUE" ] && [ "$TOP_ISSUE" != "null" ]; then
      echo "最優先: $TOP_ISSUE"
    fi
  fi
fi

# Milestone 進捗（MEMORY.md から抽出）
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  CURRENT_MS=$(grep -E "^\| [0-9]+ \|.*\| (🔄|⏸)" "$MEMORY_DIR/MEMORY.md" | head -1)
  if [ -n "$CURRENT_MS" ]; then
    echo "進行中MS: $CURRENT_MS"
  fi
fi

# スタル worktree ブランチの自動クリーンアップ
ACTIVE_WORKTREES=$(git -C "$PROJECT_DIR" worktree list --porcelain 2>/dev/null | grep "^branch " | sed 's|branch refs/heads/||')
STALE_BRANCHES=$(git -C "$PROJECT_DIR" branch --list "worktree-agent-*" 2>/dev/null | tr -d ' ')
if [ -n "$STALE_BRANCHES" ]; then
  CLEANED=0
  while IFS= read -r branch; do
    [ -z "$branch" ] && continue
    if ! echo "$ACTIVE_WORKTREES" | grep -q "^${branch}$"; then
      git -C "$PROJECT_DIR" branch -D "$branch" 2>/dev/null && CLEANED=$((CLEANED + 1))
    fi
  done <<< "$STALE_BRANCHES"
  if [ "$CLEANED" -gt 0 ]; then
    echo "worktree クリーンアップ: ${CLEANED}件のスタルブランチを削除"
  fi
fi

echo ""
echo "ルール: 日本語コミット / main直接push禁止 / ステップ分割+動作確認 / PR不要"
echo "→ MEMORY.md + Issue依存関係を自動分析し、推奨アクションを提示してください"
