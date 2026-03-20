---
name: session-start
description: セッション開始時のコンテキスト読み込み。メモリ・Issue・ブランチ状態を自動把握する。
allowed-tools: Bash(git *), Bash(gh *), Read, Glob, Grep
---

新しいセッションを開始する。以下を**すべて自動実行**し、結果をまとめて報告すること。

## 1. 基本情報収集（直列 — 高速）

以下は直接ツールで即座に実行する:

- MEMORY.md を読み込む
- Git 状態: `git branch --show-current && git status --short && git log --oneline -5`
- Issue 一覧: `gh issue list --repo kaiman2110/IdeaVault --state open --json number,title,labels,milestone`

## 2. 並列コンテキスト分析（Agent teams）

基本情報収集後、**3つの Agent を同時起動** して詳細分析を並列実行する。
**必ず1メッセージで3つの Agent tool を並列呼び出しすること。**

```
Agent ×3 並列:
  ├─ Agent 1 (Explore): 依存関係分析
  │    「docs/roadmap.md を読み、open Issue の依存関係を分析。
  │     前提が全て満たされた即着手可能な Issue を優先度順にリスト化。
  │     並列実行可能な MS の組み合わせも判定してください。」
  │
  ├─ Agent 2 (Explore): プロジェクト健全性チェック
  │    「refactoring.md（memory内）の未解消項目を確認。
  │     最近の変更（git log -10 --stat）で新たな技術的負債がないかチェック。
  │     検証すべき領域を報告。」
  │
  └─ Agent 3 (Explore): 設計・コンテンツ状況
       「docs/ideas.md の未実装アイデアを確認。
        次に着手予定の MS が /design 済みかチェック。
        追加可能なコンテンツ候補を報告。」
```

## 3. 未完了作業の検出

- 現在 `feature/issue/*` ブランチにいる場合 → 該当 Issue の内容を表示し「前回の続きですか？」と確認
- `main` にいる場合 → 「次のタスクを開始しますか？」と確認
- 未コミットの変更がある場合 → 差分サマリーを表示

## 4. サマリー報告

並列分析の結果を統合して以下を簡潔に報告:
- 現在のマイルストーンと進捗
- 前回の作業状況（ブランチ・未コミット変更）
- 即着手可能な Issue リスト（依存関係クリア済みのもの）
- 並列実行の推奨（可能な場合）
- 実装以外のおすすめアクション（リファクタ・設計・コンテンツ・検証）
