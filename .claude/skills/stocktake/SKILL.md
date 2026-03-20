---
name: stocktake
description: Vault の定期的な棚卸し。指定ステータスのメモ一覧を表示し、needs の見直しを提案する。
argument-hint: "[ステータス: brainstorm|research|design|on-hold|all]"
---

Vault のメモを棚卸しする。引数 = $ARGUMENTS

## フェーズ 1: 対象の特定

1. $ARGUMENTS が指定されている場合 → そのステータスのメモのみ対象
   - `brainstorm`, `research`, `design`, `on-hold`, `execution`, `all` を受け付ける
2. 指定なしの場合 → `all`（done, dropped 以外の全メモ）
3. 対象フォルダ: inbox/, incubating/, actionable/, projects/

## フェーズ 2: メモの収集・表示

対象メモの一覧を以下のフォーマットで表示:

```
## 棚卸し — needs: <ステータス>（YYYY-MM-DD）

| # | タイトル | needs | type | 最終更新 | 経過日数 | フォルダ |
|---|---------|-------|------|---------|---------|---------|
| 1 | セーブ機能の改善案 | brainstorm | idea | 2026-03-20 | 0日 | incubating/ |
| 2 | シェーダー記事 | research | reference | 2026-03-20 | 0日 | incubating/ |

合計: N 件
```

## フェーズ 3: 分析・提案

各メモについて以下を分析:

### 停滞チェック
- `updated` から 14日以上経過 → 「停滞しています。on-hold にしますか？」
- `updated` から 30日以上経過 → 「取り下げ（dropped）を検討しますか？」

### needs 見直し提案
メモの内容を読み、現在の needs が適切か判定:
- brainstorm だが具体的なアクションがある → `research` or `design` に変更提案
- research だが調査結果が記載済み → `design` or `execution` に変更提案
- on-hold だが状況が変わった可能性がある → 再評価を提案

### フォルダ整合性チェック
needs とフォルダの対応が正しいか確認:
| needs | 期待フォルダ |
|-------|------------|
| brainstorm | inbox/ or incubating/ |
| research, design, on-hold | incubating/ |
| execution | actionable/ |

不整合がある場合はフォルダ移動を提案

## フェーズ 4: アクション実行

ユーザーの承認を得て:
1. `needs` の変更 → frontmatter を更新
2. フォルダ移動 → `git mv` で移動
3. `dropped` or `done` → archive/ に移動
4. `updated` を今日の日付に更新
5. コミット

- メッセージ例: `stocktake: 棚卸しでメモ3件のステータスを更新`
- Vault コンテンツ操作なので main 直接コミット可

## 注意事項

- **メモの内容を勝手に削除しない**
- **frontmatter の id, created は変更しない**
- 棚卸しの結果はユーザーに提示し、承認を得てから変更する
- 大量のメモがある場合は重要度順にソートして表示
