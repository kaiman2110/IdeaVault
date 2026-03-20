---
name: idea
description: アイデアを docs/ideas.md に箇条書きで記録する。作業中に思いついたことを素早くメモ。
argument-hint: "<アイデアの内容>"
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Bash(date *)
---

アイデアを `docs/ideas.md` に追記する。引数 = $ARGUMENTS

## 手順

1. `docs/ideas.md` を読む（存在しない場合は新規作成）
2. 現在の日付を取得: `date +%Y-%m-%d`
3. 以下のフォーマットで末尾に追記する:

```markdown
- [ ] $ARGUMENTS <!-- $DATE -->
```

4. カテゴリが推測できる場合は適切なセクションに追記する:
   - `## 機能` — 新機能・改善
   - `## インフラ` — ツール・自動化・CI
   - `## コンテンツ` — データ・アセット
   - `## その他` — 上記に当てはまらないもの
5. セクションが存在しない場合は作成する

## 注意
- 1行で簡潔に書く。詳細は後で `/design` で詰める
- 重複がないか既存エントリを確認する
- コミットはしない（作業の流れを止めない）
