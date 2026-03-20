---
id: "20260321-weekly-review"
title: "週次レビュー"
created: 2026-03-21
updated: 2026-03-21
---

# 週次レビュー

> 毎週の振り返りに使うダッシュボード。メモの蓄積リズムを確認し、停滞を検出する。

---

## 今週作成されたメモ

```dataview
TABLE needs AS "ステータス", type AS "種別", tags AS "タグ"
FROM "inbox" OR "incubating" OR "actionable" OR "projects"
WHERE created >= date(today) - dur(7 days)
SORT created DESC
```

---

## 今週更新されたメモ

```dataview
TABLE needs AS "ステータス", type AS "種別", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating" OR "actionable" OR "projects"
WHERE updated >= date(today) - dur(7 days) AND updated != created
SORT updated DESC
```

---

## 停滞メモ（7日以上 needs 未変更）

```dataview
TABLE needs AS "ステータス", type AS "種別", dateformat(updated, "yyyy-MM-dd") AS "最終更新"
FROM "inbox" OR "incubating" OR "actionable"
WHERE needs != "done" AND needs != "dropped" AND needs != "on-hold"
  AND updated <= date(today) - dur(7 days)
SORT updated ASC
```

---

## needs 別サマリー

```dataview
TABLE length(rows) AS "件数"
FROM "inbox" OR "incubating" OR "actionable" OR "projects"
WHERE needs != "done" AND needs != "dropped"
GROUP BY needs
SORT length(rows) DESC
```

---

## 今週完了・取り下げ

```dataview
TABLE needs AS "結果", type AS "種別", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "archive"
WHERE updated >= date(today) - dur(7 days)
SORT updated DESC
```
