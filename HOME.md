---
id: "20260320-home"
title: "IdeaVault Home"
created: 2026-03-20
updated: 2026-03-20
---

# IdeaVault

> 思いついたことをメモするだけで、AI が構造化・調査・設計まで手伝ってくれる仕組み。

---

## クイックアクセス

| フォルダ | 説明 |
|---------|------|
| [[inbox]] | メモを雑に放り込む場所 |
| [[incubating]] | ブラッシュアップ・調査中 |
| [[actionable]] | TODO 化済み、実行待ち |
| [[projects]] | 独立プロジェクトに昇格 |
| [[archive]] | 完了・取り下げ |
| [[references]] | 参考記事・リンク集 |

---

## ダッシュボード

- [[dashboards/overview|メモ一覧ダッシュボード]] — needs 別・type 別・タグ別の全メモ一覧
- [[dashboards/kanban|カンバンボード]] — needs をカラムにしたボード
- [[dashboards/weekly-review|週次レビュー]] — 今週の活動・停滞メモの検出

---

## 最近のメモ

```dataview
TABLE needs AS "ステータス", type AS "種別", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating" OR "actionable"
WHERE needs != "done" AND needs != "dropped"
SORT updated DESC
LIMIT 5
```

---

## スキルコマンド

| コマンド | 説明 |
|---------|------|
| `/inbox` | inbox 内メモの整理（frontmatter 付与・移動提案） |
| `/brainstorm` | メモのブラッシュアップ（構造化・具体化） |
| `/research` | メモの技術調査（実現可能性・選択肢） |
| `/vault-design` | メモから設計ドキュメント生成 |
| `/relate` | Vault 全体スキャンで関連メモをリンク |
| `/stocktake` | 指定ステータスのメモ棚卸し |

---

## ワークフロー

```
inbox/ に雑にメモ
  → /inbox で整理（frontmatter 付与）
    → /brainstorm でブラッシュアップ
      → /research で技術調査
        → /vault-design で設計書作成
          → projects/ に昇格
```
