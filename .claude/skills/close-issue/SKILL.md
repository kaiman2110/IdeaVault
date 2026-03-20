---
name: close-issue
description: Issue の実装を完了しクローズする。PR 作成・マージ・パッチノート・メモリ更新を一括実行。
argument-hint: "[issue-number]"
allowed-tools: Bash(git *), Bash(gh *), Bash(node *), Read, Edit, Write, Glob, Grep, Agent
---

Issue #$ARGUMENTS の完了処理を行う。以下の手順を**すべて自動実行**すること。

## 前提条件チェック

1. 現在のブランチが `feature/issue/$ARGUMENTS` であることを確認する
2. **ユーザーが動作確認済みであること**（`/start-issue` のフェーズ 4 で ok をもらった後に呼ばれる前提）

## 未コミット変更の処理

未コミットの変更がある場合:
1. テスト実行 → 全パス確認
2. テスト通過したら自動コミット（ユーザー確認は不要 — 既に動作確認済み）

## クローズ処理

1. feature ブランチをリモートに push: `git push origin feature/issue/$ARGUMENTS`
2. PR を作成: `gh pr create --title "<適切なタイトル>" --body "<変更の要約>\n\ncloses #$ARGUMENTS" --base main --head feature/issue/$ARGUMENTS`
3. PR をマージ: `gh pr merge <PR番号> --merge --delete-branch`
4. main にチェックアウトして同期: `git checkout main && git pull origin main`
5. ローカルの feature ブランチを削除: `git branch -d feature/issue/$ARGUMENTS`（残っていれば）

## パッチノート表示（必須）

マージ完了後、**必ず**パッチノートを生成してユーザーに表示する:

### フォーマット
```
## パッチノート — #<番号> <タイトル>

### 変更点
- <プレイヤー視点でわかりやすく箇条書き>

### 変更ファイル
| ファイル | 変更内容 |
|---------|---------|
| ... | ... |

### テスト結果
- **N テスト / N 通過** (100%)

### 影響
- <将来の Issue への影響・依存関係の解放>
```

## 通知（オプション）

 が設定されている場合、パッチノートを自動送信する。
失敗してもエラーをログに残して処理を続行（通知失敗で完了処理が止まらない）。

## メモリ更新 + 次アクション分析（並列 Agent teams）

クローズ後の処理を **3つの Agent を同時起動** して並列実行する。
**必ず1メッセージで3つの Agent tool を並列呼び出しすること。**

```
Agent ×3 並列:
  ├─ Agent 1 (general-purpose): メモリ更新
  │    「MEMORY.md の Issue #N を ✅ Done に更新。
  │     Milestone 進捗を反映（全 Issue 完了なら MS を完了に）。
  │     docs/roadmap.md も必要に応じて更新。」
  │
  ├─ Agent 2 (Explore): 次 Issue の依存関係分析
  │    「gh issue list --state open で全 open Issue を取得し、
  │     docs/roadmap.md の依存関係を確認。
  │     Issue #N 完了で依存解放された Issue、
  │     同MS内の即着手可能 Issue、並列可能な別MS Issue を報告。」
  │
  └─ Agent 3 (Explore): リファクタリング・品質チェック
       「今回の変更差分（git diff main~1..main）をレビュー。
        新たな技術的負債があれば報告。
        refactoring.md に小規模な項目があれば候補として報告。」
```

3つの結果を統合して以下のフォーマットで提案する:

```
## 次アクション候補

1. [即着手可] /start-issue #XX — <タイトル>（同MS、依存なし）
2. [並列可能] /start-issue #YY — <タイトル>（別MS、独立）
3. [リファクタ] refactoring.md: <対象>（小規模、30分程度）
4. [設計先行] /design <次MS> — Issue未作成、先に仕様を固める
```
