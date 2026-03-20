# Obsidian プラグインセットアップガイド

IdeaVault で使用するコミュニティプラグインのインストール手順と推奨設定。

## 前提条件

- Obsidian がインストール済み
- IdeaVault フォルダを Vault として開いている
- コミュニティプラグインが有効化されている（設定 → コミュニティプラグイン → 制限モードをオフ）

## プラグイン一覧

| プラグイン | 用途 | 必須 |
|-----------|------|------|
| Templater | テンプレートからメモ作成（日付・ID 自動挿入） | ○ |
| Dataview | needs 別・type 別・tag 別のメモ一覧表示 | ○ |
| Obsidian Git | Vault 内から Git 操作・自動バックアップ | ○ |
| Kanban | needs をカラムにしたカンバンボード | 任意 |

---

## 1. Templater

### インストール
1. 設定 → コミュニティプラグイン → 閲覧
2. 「Templater」で検索 → インストール → 有効化

### 推奨設定
| 設定項目 | 値 | 説明 |
|---------|-----|------|
| Template folder location | `templates` | テンプレートフォルダの指定 |
| Trigger Templater on new file creation | ON | 新規ファイル作成時に自動でテンプレート適用 |
| Enable folder templates | ON | フォルダごとにデフォルトテンプレートを指定 |

### フォルダテンプレート設定
| フォルダ | テンプレート |
|---------|------------|
| `inbox` | `templates/idea.md` |
| `references` | `templates/reference.md` |
| `projects` | `templates/project-readme.md` |

### 使い方
- `Ctrl+N` で新規メモ作成 → フォルダに応じたテンプレートが自動適用
- コマンドパレット（`Ctrl+P`）→「Templater: Create new note from template」で任意のテンプレートを選択

---

## 2. Dataview

### インストール
1. 設定 → コミュニティプラグイン → 閲覧
2. 「Dataview」で検索 → インストール → 有効化

### 推奨設定
| 設定項目 | 値 | 説明 |
|---------|-----|------|
| Enable JavaScript Queries | OFF | セキュリティのため無効（DQL で十分） |
| Enable Inline Queries | ON | インラインクエリを有効化 |
| Automatic View Refreshing | ON | メモ変更時にダッシュボードを自動更新 |
| Refresh Interval | 2500 | 更新間隔（ミリ秒） |
| Date Format | `yyyy-MM-dd` | frontmatter の日付形式に合わせる |

### 基本クエリ例

**アクティブなメモ一覧**:
```dataview
TABLE needs, tags, updated
FROM "inbox" OR "incubating" OR "actionable"
WHERE needs != "done" AND needs != "dropped"
SORT updated DESC
```

**実行待ちタスク**:
```dataview
TABLE type, needs, priority
FROM ""
WHERE needs = "execution"
SORT priority ASC
```

> 詳細なダッシュボードは `dashboards/` フォルダを参照。

---

## 3. Obsidian Git

### インストール
1. 設定 → コミュニティプラグイン → 閲覧
2. 「Obsidian Git」で検索 → インストール → 有効化

### 推奨設定
| 設定項目 | 値 | 説明 |
|---------|-----|------|
| Vault backup interval (minutes) | 0 | 自動バックアップ無効（Claude Code と競合防止） |
| Auto pull interval (minutes) | 0 | 自動プル無効 |
| Commit message | `vault: {{date}}` | 手動コミット時のメッセージ形式 |
| Push on backup | OFF | 手動プッシュ推奨 |
| Pull updates on startup | ON | Obsidian 起動時にリモートから取得 |

### 注意事項
- **Claude Code との併用**: 自動コミット・自動プッシュは無効にし、手動操作を推奨。Claude Code のコミットと競合を防ぐため。
- **手動操作**: コマンドパレット → 「Obsidian Git: Commit all changes」「Obsidian Git: Push」で実行。
- Git の認証情報（SSH キーまたは credential helper）が事前に設定されている必要がある。

---

## 4. Kanban（任意）

### インストール
1. 設定 → コミュニティプラグイン → 閲覧
2. 「Kanban」で検索 → インストール → 有効化

### 推奨設定
| 設定項目 | 値 | 説明 |
|---------|-----|------|
| New line trigger | `Enter` | Enter でカード内改行 |
| Link cards to notes | ON | カードクリックでメモを開く |
| Hide tags in card titles | ON | タグ表示をすっきりさせる |

### 使い方
- `dashboards/kanban.md` を開くとカンバンボードとして表示される
- カードのドラッグ&ドロップで needs の変更が可能

---

## トラブルシューティング

| 問題 | 対処法 |
|------|--------|
| コミュニティプラグインが見つからない | 設定 → コミュニティプラグイン → 制限モードがオフになっているか確認 |
| Templater のテンプレートが適用されない | Template folder location が `templates` に設定されているか確認 |
| Dataview のクエリが表示されない | プラグインが有効化されているか確認。ライブプレビューモードで表示される |
| Obsidian Git でプッシュできない | Git の認証設定（SSH / credential helper）を確認 |
| Kanban ボードが通常のマークダウンで表示される | Kanban プラグインが有効化されているか確認 |
