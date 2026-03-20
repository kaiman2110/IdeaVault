# Idea Vault — 設計ドキュメント

> Obsidian Vault + Claude Code + Git による、アイディア管理・実現パイプライン

## コンセプト

「思いついたことをメモするだけで、AIが構造化・調査・設計まで手伝ってくれる」仕組み。
Obsidianで書く → Claude Codeで処理 → Gitで履歴管理。

---

## Vault構造

```
idea-vault/
├── inbox/                  ← メモを雑に放り込む場所
│   ├── 2026-03-20_セーブ機能の改善.md
│   └── 2026-03-20_気になるシェーダー記事.md
├── incubating/             ← ブラッシュアップ・調査中
│   └── pixel-art-pipeline.md
├── actionable/             ← TODO化済み、実行待ち
│   └── discord-bot-rss-filter.md
├── projects/               ← 独立プロジェクトに昇格したもの
│   └── idea-vault/
│       ├── README.md
│       └── design.md
├── archive/                ← 完了 or 取り下げ
│   └── old-idea.md
├── references/             ← 参考記事・リンク集（メモから派生）
│   └── shader-tutorials.md
├── templates/              ← Obsidian Templater用
│   ├── idea.md
│   ├── reference.md
│   └── project-readme.md
├── CLAUDE.md               ← Claude Code用のVault規約・処理ルール
├── .obsidian/              ← Obsidian設定
└── .git/
```

### フォルダの役割

| フォルダ | 用途 | 誰が置く |
|---------|------|---------|
| `inbox/` | 未整理のメモ。何でも入る | 人間 |
| `incubating/` | 整理済みだがまだ実行段階ではない | Claude Code |
| `actionable/` | 具体的なTODOがあり実行可能 | Claude Code |
| `projects/` | 独立したプロジェクトとして管理 | Claude Code |
| `archive/` | 完了・取り下げ | Claude Code or 人間 |
| `references/` | 参考リンク・記事まとめ | Claude Code or 人間 |

---

## Frontmatter スキーマ

### 基本（全メモ共通）

```yaml
---
id: "20260320-143022"        # タイムスタンプベースのID
title: "セーブ機能の改善案"
created: 2026-03-20
updated: 2026-03-20
needs: brainstorm             # ← 核心：次に何が必要か
tags:
  - arpg
  - godot
type: idea                    # メモの種別
---
```

### `needs` フィールド（ステータスの代わり）

| 値 | 意味 | Claude Codeへの指示例 |
|----|------|---------------------|
| `brainstorm` | まだぼんやり。考えを広げたい | 「brainstormのメモをブラッシュアップして」 |
| `research` | やりたいことは見えてるが調査が必要 | 「researchのメモを調査して」 |
| `design` | 方向性は決まった。設計を起こしたい | 「designのメモの設計書を作って」 |
| `execution` | あとはやるだけ。TODO化済み | 「executionのTODOを確認して」 |
| `on-hold` | 意図的に寝かせている | — |
| `done` | 完了 | → archive/ へ移動 |
| `dropped` | やめた・不要になった | → archive/ へ移動 |

### `type` フィールド（メモの種別）

| 値 | 説明 | 例 |
|----|------|-----|
| `idea` | アイディア・思いつき | 「こういう機能あったらいいな」 |
| `task` | 今すぐやる具体的タスク | 「Lintルール追加する」 |
| `reference` | 気になる記事・リソース | 「このシェーダー記事試したい」 |
| `exploration` | 長期的に探求したいテーマ | 「プロシージャル生成を学びたい」 |

### 拡張フィールド（任意）

```yaml
source: "https://example.com/article"   # type: reference の場合
related:                                  # 関連するメモやプロジェクト
  - "[[pixel-art-pipeline]]"
  - "[[arpg-project]]"
project: arpg                             # 紐づく既存プロジェクト
priority: high                            # high / medium / low
due: 2026-04-01                           # 期限がある場合
todos:                                    # 抽出済みTODOリスト
  - text: "Godot 4.xのセーブAPI調査"
    done: false
  - text: "プロトタイプ実装"
    done: false
```

---

## テンプレート

### `templates/idea.md`（汎用アイディアメモ）

```markdown
---
id: "{{date:YYYYMMDDHHmmss}}"
title: "{{title}}"
created: {{date:YYYY-MM-DD}}
updated: {{date:YYYY-MM-DD}}
needs: brainstorm
tags: []
type: idea
related: []
---

## 何を思いついたか

（ここに自由に書く）

## なぜやりたいか

## 気になること・未解決の疑問

```

### `templates/reference.md`（参考記事・リンク）

```markdown
---
id: "{{date:YYYYMMDDHHmmss}}"
title: "{{title}}"
created: {{date:YYYY-MM-DD}}
updated: {{date:YYYY-MM-DD}}
needs: research
tags: []
type: reference
source: ""
related: []
---

## 概要

（何についての記事/リソースか）

## 試したいこと

## メモ

```

### `templates/project-readme.md`（プロジェクト昇格時）

```markdown
---
id: "{{date:YYYYMMDDHHmmss}}"
title: "{{title}}"
created: {{date:YYYY-MM-DD}}
updated: {{date:YYYY-MM-DD}}
needs: execution
tags: []
type: idea
origin: ""
---

# {{title}}

## 概要

## 目的・ゴール

## 設計

## TODO

- [ ]

## 関連メモ

## ログ

```

---

## CLAUDE.md（Claude Code用 処理ルール）

```markdown
# Idea Vault — Claude Code 処理ルール

## Vault構造
（上記のフォルダ構造を記載）

## コマンド体系

以下の指示パターンに対応する：

### 1. inbox整理
「inboxを整理して」「inbox見て」
- inbox/ 内の全メモを読む
- frontmatterが未設定なら付与（type, needs を推定）
- 内容からtags を推定して付与
- needs に応じてフォルダ移動を提案（移動は確認後）
- git commit

### 2. ブラッシュアップ
「brainstormのメモをブラッシュアップして」「○○についてもっと考えて」
- 対象メモの内容を読む
- アイディアを構造化・具体化・補足
- 疑問点や検討すべきポイントを追記
- needs を更新（brainstorm → research or design）
- updated を更新
- git commit

### 3. 調査
「researchのメモを調査して」「○○について調べて」
- 技術的な実現可能性を調査
- 選択肢・トレードオフを整理
- 調査結果をメモに追記
- needs を更新（research → design or execution）
- git commit

### 4. 設計
「designのメモの設計書を作って」
- 設計ドキュメントを生成
- projects/ にフォルダを作成してREADMEとdesign.mdを配置
- TODOリストを生成
- needs を execution に更新
- git commit

### 5. 関連付け
「関連するメモをリンクして」
- Vault全体をスキャンしてタグ・内容の類似性を分析
- related フィールドにObsidianリンクを追加
- git commit

### 6. 棚卸し
「棚卸しして」「on-holdを見直して」
- 指定ステータスのメモ一覧を表示
- 各メモの概要と最終更新日を提示
- needs の変更を提案

## 処理ルール
- **メモの内容を勝手に削除しない**。追記・構造化のみ。
- **フォルダ移動は提案→確認→実行** の流れ。
- **git commitは処理単位で行う**。メッセージは日本語。
- **frontmatterのid, created は変更しない**。
- **updated は処理時に更新する**。
- **Obsidianのリンク記法 [[]] を使う**。

## タグ規約
- 小文字、ハイフン区切り（例: `game-dev`, `claude-code`）
- プロジェクト名タグ: `arpg`, `discord-bot`, `dashboard` など
- 技術タグ: `godot`, `gdscript`, `react`, `python` など
- カテゴリタグ: `ui`, `ai`, `workflow`, `pixel-art` など
```

---

## Obsidian推奨プラグイン

| プラグイン | 用途 |
|-----------|------|
| Templater | テンプレートからメモ作成（日付自動挿入等） |
| Dataview | needs別・type別・tag別のメモ一覧表示 |
| Obsidian Git | Vault内からGit操作（自動コミットも可能） |
| Kanban（任意） | needs をカラムにしたカンバンボード |

### Dataview クエリ例

```dataview
TABLE needs, tags, updated
FROM "inbox" OR "incubating" OR "actionable"
WHERE needs != "done" AND needs != "dropped"
SORT updated DESC
```

```dataview
TABLE type, needs, priority
FROM ""
WHERE needs = "execution"
SORT priority ASC
```

---

## Git運用

- **ブランチ**: mainのみ（個人Vaultなので）
- **コミット単位**: Claude Codeの処理ごと
- **コミットメッセージ**: 日本語、例：
  - `inbox: セーブ機能のアイディアを整理`
  - `research: シェーダー記事の技術調査を追記`
  - `move: pixel-art-pipeline を incubating → actionable`
- **タグ（Gitタグ）**: 必要に応じてマイルストーン的に使用

---

## 今後の拡張候補

- [ ] Claude Codeのカスタムスラッシュコマンド化（`/inbox`, `/brainstorm` 等）
- [ ] Obsidian CommunityプラグインでClaude API直接連携
- [ ] inbox へのクイック投入CLI（PowerShellスクリプト）
- [ ] Dataviewダッシュボードの充実（週次レビュー用）
- [ ] 既存プロジェクトリポジトリとのクロスリファレンス