---
name: vault-design
description: メモから設計ドキュメントを生成し、projects/ にプロジェクトとして昇格させる。
argument-hint: "<メモのファイル名 or パス>"
---

メモから設計ドキュメントを生成する。引数 = $ARGUMENTS

## フェーズ 1: 対象メモの特定

1. $ARGUMENTS がファイルパスの場合 → そのファイルを読む
2. ファイル名のみの場合 → `inbox/`, `incubating/`, `actionable/` から検索
3. 引数なしの場合 → `needs: design` のメモ一覧を表示し選択を促す

## フェーズ 2: 内容の分析

1. メモの frontmatter と本文を読み込む
2. ブラッシュアップや調査結果があればそれも参照
3. 設計に必要な情報が不足していないか確認
   - 不足がある場合 → 「`/research` で先に調査しますか？」と提案

## フェーズ 3: 設計ドキュメント生成

`projects/<プロジェクト名>/` ディレクトリを作成し、以下のファイルを生成:

### projects/<プロジェクト名>/README.md
`templates/project-readme.md` をベースに以下を記入:
- 概要
- 目的・ゴール
- 設計（概要レベル）
- TODO リスト
- 関連メモへの Obsidian リンク `[[]]`

### projects/<プロジェクト名>/design.md
詳細な設計ドキュメント:
```markdown
# <プロジェクト名> 設計書

## 概要

## システム構成

## 技術仕様
（具体的なパラメータ・API・データ構造）

## 実装ステップ
1. ...
2. ...

## リスク・トレードオフ

## 参考
```

## フェーズ 4: 元メモの更新

1. 元メモの frontmatter を更新:
   - `needs` → `execution`
   - `updated` → 今日の日付
   - `related` に `[[projects/<プロジェクト名>/README]]` を追加
2. 元メモの末尾に追記:
   ```markdown

   ---

   ## プロジェクト昇格（YYYY-MM-DD）

   設計ドキュメントを生成しました: [[projects/<プロジェクト名>/README]]
   ```

## フェーズ 5: フォルダ移動の提案

元メモが inbox/ や incubating/ にある場合:
- `actionable/` への移動を提案（needs: execution のため）
- ユーザー承認後に `git mv` で移動

## フェーズ 6: コミット

- メッセージ例: `design: セーブ機能の設計書を生成`
- projects/ の新規ファイルと元メモの更新をまとめてコミット
- Vault コンテンツ操作なので main 直接コミット可

## 注意事項

- **メモの内容を勝手に削除しない**（追記のみ）
- **frontmatter の id, created は変更しない**
- プロジェクト名はメモの title をケバブケースに変換（例: `セーブ機能の改善案` → `save-system-improvement`）
- 設計ドキュメントはユーザーと対話しながら作成する（一方的に決めない）
