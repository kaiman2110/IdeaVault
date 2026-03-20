# IdeaVault

## プロジェクト概要
- 種別: Obsidian Vault + Claude Code + Git によるアイディア管理パイプライン
- リポジトリ: https://github.com/kaiman2110/IdeaVault

## アーキテクチャ原則
- **Vault コンテンツ操作は main 直接コミット可**: inbox 整理・ブラッシュアップ等の日常操作は feature ブランチ不要
- **構造変更は feature ブランチ**: スキル・テンプレート・設定の変更は `feature/issue/<N>` 経由
- **メモの内容を勝手に削除しない**: 追記・構造化のみ
- **フォルダ移動は提案→確認→実行**: 自動移動しない
- **frontmatter の id, created は変更しない**: updated のみ更新
- **Obsidian リンク記法 `[[]]` を使用**

## 既知の落とし穴

| 問題 | 対処法 |
|------|--------|
| block-push-main Hook が Vault コンテンツ操作もブロックする | Vault スキルでは main 直接コミット・push を許可（アーキテクチャ原則参照） |

## フォルダ構造
```
idea-vault/
├── inbox/                  ← メモを雑に放り込む場所
├── incubating/             ← ブラッシュアップ・調査中
├── actionable/             ← TODO化済み、実行待ち
├── projects/               ← 独立プロジェクトに昇格したもの
├── archive/                ← 完了 or 取り下げ
├── references/             ← 参考記事・リンク集
├── dashboards/             ← Dataview ダッシュボード・カンバンボード
├── templates/              ← Obsidian Templater用テンプレート
├── docs/                   ← ロードマップ・アイデアメモ
├── .claude/                ← Claude Code設定・スキル・Hook
├── .obsidian/              ← Obsidian設定
├── CLAUDE.md
└── idea-vault-design.md    ← 設計ドキュメント
```

## Vault コマンド体系

| コマンド | 説明 |
|---------|------|
| `/inbox` | inbox/ 内メモの整理（frontmatter付与・フォルダ移動提案） |
| `/brainstorm` | メモのブラッシュアップ（構造化・具体化・補足） |
| `/research` | メモの技術調査（実現可能性・選択肢・トレードオフ） |
| `/vault-design` | メモから設計ドキュメント生成（projects/ に配置） |
| `/relate` | Vault 全体スキャンで関連メモをリンク |
| `/stocktake` | 指定ステータスのメモ棚卸し |

## Frontmatter スキーマ

### needs フィールド（メモのステータス）
| 値 | 意味 | フォルダ |
|----|------|---------|
| `brainstorm` | ぼんやり。考えを広げたい | inbox/ or incubating/ |
| `research` | 調査が必要 | incubating/ |
| `design` | 設計を起こしたい | incubating/ |
| `execution` | TODO化済み、実行待ち | actionable/ |
| `on-hold` | 寝かせ中 | incubating/ |
| `done` | 完了 | archive/ |
| `dropped` | 取り下げ | archive/ |

### type フィールド（メモの種別）
| 値 | 説明 |
|----|------|
| `idea` | アイディア・思いつき |
| `task` | 具体的タスク |
| `reference` | 参考記事・リソース |
| `exploration` | 長期探求テーマ |

## タグ規約
- 小文字、ハイフン区切り（例: `game-dev`, `claude-code`）
- プロジェクト名タグ: `arpg`, `discord-bot` など
- 技術タグ: `godot`, `gdscript`, `react` など
- カテゴリタグ: `ui`, `ai`, `workflow` など

## テスト
- フレームワーク: (未設定)
- 実行コマンド: echo 'テストコマンド未設定'

## 実装時の原則
- **自律実行**: 実装→テスト→コミットを自律的に回す。途中でユーザーに聞かない
- **ステップ分割**: 一度にすべて実装しない。ステップごとに実装→テスト→コミット
- **自己検証**: エラーは自分で直す。設計判断はアーキテクチャ原則に従う
- **型ヒント**: 新規・変更コードには必ず型ヒントを付ける
- **検索は Grep/Glob 優先**: `Read` で探索的にファイルを開かない
- **MS実装指示は `/start-ms` or `/start-issue` 経由**
- **セッション終了は `/session-end`**
- **Issue完了時は必ず `/close-issue`**

## カスタムスキル

| スキル | 用途 |
|--------|------|
| `/start-ms <N>` | MS単位で全Issue一括実装 |
| `/start-issue <N>` | Issue 実装開始 → 自律実装 → 完了時のみ動作確認依頼 |
| `/close-issue <N>` | Issue 完了（PR作成・マージ・クリーンアップ） |
| `/session-start` | セッション開始時のコンテキスト自動読み込み |
| `/session-end` | セッション終了時のメモリ・ドキュメント更新・引継ぎ準備 |
| `/design <テーマ>` | 仕様の設計・実装計画の作成 |
| `/milestone-plan <テーマ>` | マイルストーン計画→Issue分割→ボード登録 |
| `/deep-analyze [focus]` | Agent teams 並列解析（構造・品質・シグナル・コンテンツ） |
| `/research-game <テーマ>` | 参考事例の設計を Deep Research → 適用案 |
| `/inbox [ファイル名]` | inbox/ 内メモの整理（frontmatter推定・付与・移動提案） |
| `/brainstorm [ファイル名]` | メモのブラッシュアップ（構造化・具体化・補足） |
| `/research [ファイル名]` | メモの技術調査（実現可能性・選択肢・トレードオフ） |
| `/vault-design [ファイル名]` | メモから設計ドキュメント生成（projects/ に配置） |
| `/relate [ファイル名]` | Vault 全体スキャンで関連メモをリンク |
| `/stocktake [ステータス]` | 指定ステータスのメモ棚卸し |
| `/idea <内容>` | アイデアを docs/ideas.md に即メモ |
| `/fix-errors` | エラーログ自動解析・修正 |
| `/review-changes` | アーキテクチャ原則に照らしたレビュー |
| `/analyze-sessions` | セッション履歴分析→改善候補特定 |
| `/parallel-refactor` | Agent teams + worktree で並列リファクタリング |
| `/sync-template [diff\|push\|pull]` | スキル・Hook・CLAUDE.md をテンプレートと比較・同期 |

## 自動 Hook

| Hook | トリガー | 動作 |
|------|---------|------|
| `block-push-main.sh` | Bash（git push） | main/master への直接 push をブロック |
| `pre-commit-check.sh` | Bash（git commit） | プロジェクト固有のコミット前チェック |
| `protect-files.sh` | Edit/Write | 保護対象ファイルの編集をブロック |
| `session-start-context.sh` | SessionStart | ブランチ・Issue・MS情報を自動表示 |
| `stop-run-tests.sh` | Stop | ソース変更時にテスト自動実行 + セッション終了リマインダー |

## セッションの流れ

```
/session-start → コンテキスト読み込み + 推奨アクション提示
  ├─ /start-ms <N> → MS全Issue一括実装（推奨）
  ├─ /start-issue <N> → 単体Issue実装
  └─ /session-end → メモリ保存 → 引継ぎ
```

## Agent teams 活用

| スキル | 並列 Agent 数 | タイミング |
|--------|-------------|-----------|
| `/start-issue` | Explore ×3 | コードベース調査 |
| `/close-issue` | ×3 | メモリ更新/次Issue分析/品質チェック |
| `/session-start` | Explore ×3 | 依存関係/健全性/設計状況 |
| `/session-end` | general-purpose ×3 | MEMORY/CLAUDE.md/知見保存 |
| `/deep-analyze` | Explore ×4 | 構造/品質/シグナル/コンテンツ |
| `/parallel-refactor` | worktree 分離 ×N | 独立リファクタを並列実行 |
