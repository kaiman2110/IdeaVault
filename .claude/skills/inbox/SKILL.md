---
name: inbox
description: inbox/ 内メモの自動整理。frontmatter 推定・付与、フォルダ移動提案を行う。
argument-hint: "[ファイル名（省略時は inbox/ 全体）]"
---

inbox/ 内のメモを整理する。引数 = $ARGUMENTS

## フェーズ 1: メモの読み込み

1. $ARGUMENTS が指定されている場合はそのファイルのみ対象
2. 指定なしの場合は `inbox/` 内の全 `.md` ファイルを対象（`.gitkeep` は除外）
3. 各メモの内容を読み込む

## フェーズ 2: Frontmatter の分析・付与

各メモについて以下を実行:

### frontmatter が存在しない場合
1. メモの内容から以下を推定:
   - **id**: 現在のタイムスタンプ（`YYYYMMDDHHmmss` 形式）
   - **title**: 見出し（`#` 行）またはファイル名から推定
   - **created**: ファイルの作成日、不明なら今日の日付
   - **updated**: 今日の日付
   - **needs**: 内容から推定
     - 具体的なTODOやコードがある → `execution`
     - 技術名や「調べたい」「試したい」がある → `research`
     - URL やリンクが主体 → `research`（type: reference）
     - ぼんやりしたアイディア → `brainstorm`
   - **tags**: 内容に出てくるキーワードから推定（タグ規約に従う）
   - **type**: 内容から推定
     - アイディア・思いつき → `idea`
     - 具体的タスク → `task`
     - 記事・URL紹介 → `reference`
     - 長期テーマ → `exploration`
   - **related**: 空配列 `[]`
2. 推定した frontmatter をメモの先頭に挿入
3. 元の内容は**一切削除・変更しない**（frontmatter 追加のみ）

### frontmatter が存在する場合
1. 必須フィールド（id, title, created, updated, needs, tags, type）の欠落をチェック
2. 欠落があれば内容から推定して補完
3. **既存の値は変更しない**

## フェーズ 3: 構造化（任意）

frontmatter 付与後、メモの本文が未構造化の場合:
1. 適切な見出し（`##`）を提案して追記
2. 箇条書きへの変換など、読みやすさの改善を追記
3. **元の文章は削除しない** — 構造化は追記で行う

## フェーズ 4: コミット

frontmatter 付与・構造化が完了したメモをコミット:
- メッセージ例: `inbox: セーブ機能のアイディアを整理`
- **Vault コンテンツ操作なので main 直接コミット可**
- ただし現在 feature ブランチにいる場合はそのブランチでコミット

## フェーズ 5: フォルダ移動の提案

全メモの処理後、needs に基づいてフォルダ移動を提案:

| needs | 移動先 |
|-------|--------|
| `brainstorm` | そのまま inbox/ に留置 or incubating/ |
| `research` | incubating/ |
| `design` | incubating/ |
| `execution` | actionable/ |
| `on-hold` | incubating/ |
| `done` | archive/ |
| `dropped` | archive/ |

提案フォーマット:
```
## フォルダ移動の提案

| メモ | 現在 | 提案先 | 理由 |
|------|------|--------|------|
| セーブ機能の改善案 | inbox/ | incubating/ | needs: brainstorm → 整理後さらに検討 |
| シェーダー記事 | inbox/ | incubating/ | needs: research → 調査が必要 |

移動しますか？（yes / 個別選択 / no）
```

- **ユーザーが承認するまで移動しない**
- 承認後、`git mv` でファイルを移動し、コミット
- コミットメッセージ例: `move: シェーダー記事を inbox → incubating`

## 注意事項

- **メモの内容を勝手に削除しない**（アーキテクチャ原則）
- **frontmatter の id, created は一度設定したら変更しない**
- **タグ規約**: 小文字、ハイフン区切り
- **Obsidian リンク記法 `[[]]`** を使用
