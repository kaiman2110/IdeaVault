---
name: milestone-plan
description: 新しいマイルストーンの計画を立案する。Issue分割・優先度付け・ボード登録まで一括実行。
argument-hint: "<milestone名 or テーマ>"
allowed-tools: Bash(git *), Bash(gh *), Read, Write, Edit, Glob, Grep
---

新しいマイルストーンを計画し、Issue 分割・登録まで行う。引数 = $ARGUMENTS

## フェーズ 1: コンテキスト収集

1. 既存のマイルストーン進捗を確認:
   - MEMORY.md の Milestone テーブル
   - `gh issue list --repo kaiman2110/IdeaVault --state open` で未完了 Issue
2. `docs/roadmap.md` を読み、将来候補・先送り課題・技術的負債を確認
3. `docs/ideas.md` を読み、関連するアイデアを収集
4. 現在のコードベースの規模感を把握（主要ディレクトリの構成）

## フェーズ 2: マイルストーン設計

ユーザーと対話しながら以下を設計:

1. **ゴール**: このマイルストーンで何を達成するか（1-2文）
2. **スコープ**: 含める機能・含めない機能の線引き
3. **Issue 分割**:
   - 各 Issue は 1 ブランチで完結する粒度
   - 依存関係と実装順序を明示
   - `docs/ideas.md` から取り込めるアイデアがあれば含める
4. **優先度**: 各 Issue に `priority/high` / `medium` / `low` を割り当て
5. **リスク**: 技術的に不確実な部分、ブロッカーになりそうな点

## フェーズ 3: Issue 作成（ユーザー承認後）

承認を得たら:

1. GitHub Milestone を作成（未作成の場合）:
   - `gh api repos/kaiman2110/IdeaVault/milestones -f title="Milestone N: <名前>" -f state="open"`
2. 各 Issue を作成:
   - `gh issue create --repo kaiman2110/IdeaVault --title "..." --label "msN,type/feature,priority/*" --milestone "Milestone N: <名前>" --body "..."`
3. MEMORY.md の Issue テーブルを更新
4. `docs/ideas.md` から取り込んだアイデアにチェックマーク `[x]` を付ける

## フェーズ 4: ロードマップ更新

Issue 作成後、`docs/roadmap.md` を更新する:

1. **現在のマイルストーン** セクションに新MSの情報を記載
2. **将来のマイルストーン候補** から今回取り込んだテーマを削除 or 更新
3. スコープ外と判断した機能を **先送り課題（Deferred）** に追加
4. **更新履歴** に記録を追加

## 注意
- フェーズ 2 ではユーザーの承認を待つ（マイルストーンの方向性は重要な判断）
- Issue 数は 5-10 個程度に抑える
- **スコープ外の機能は捨てない** — 必ず `docs/roadmap.md` の先送り課題に記録する
