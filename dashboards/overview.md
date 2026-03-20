---
id: "20260320-dashboard"
title: "ダッシュボード"
created: 2026-03-20
updated: 2026-03-20
---

# ダッシュボード

## 最近更新されたメモ

```dataview
TABLE needs AS "ステータス", type AS "種別", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating" OR "actionable" OR "projects"
WHERE needs != null
SORT updated DESC
LIMIT 10
```

---

## needs 別一覧

### brainstorm（考えを広げたい）

```dataview
TABLE type AS "種別", tags AS "タグ", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating"
WHERE needs = "brainstorm"
SORT updated DESC
```

### research（調査が必要）

```dataview
TABLE type AS "種別", tags AS "タグ", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "incubating"
WHERE needs = "research"
SORT updated DESC
```

### design（設計を起こしたい）

```dataview
TABLE type AS "種別", tags AS "タグ", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "incubating"
WHERE needs = "design"
SORT updated DESC
```

### execution（実行待ち）

```dataview
TABLE type AS "種別", priority AS "優先度", tags AS "タグ", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "actionable"
WHERE needs = "execution"
SORT priority ASC
```

### on-hold（寝かせ中）

```dataview
TABLE type AS "種別", tags AS "タグ", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "incubating"
WHERE needs = "on-hold"
SORT updated DESC
```

---

## type 別一覧

### idea（アイディア）

```dataview
TABLE needs AS "ステータス", tags AS "タグ", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating" OR "actionable"
WHERE type = "idea" AND needs != "done" AND needs != "dropped"
SORT updated DESC
```

### task（タスク）

```dataview
TABLE needs AS "ステータス", priority AS "優先度", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating" OR "actionable"
WHERE type = "task" AND needs != "done" AND needs != "dropped"
SORT priority ASC
```

### reference（参考記事）

```dataview
TABLE needs AS "ステータス", source AS "ソース", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating" OR "references"
WHERE type = "reference" AND needs != "done" AND needs != "dropped"
SORT updated DESC
```

### exploration（探求テーマ）

```dataview
TABLE needs AS "ステータス", tags AS "タグ", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "inbox" OR "incubating"
WHERE type = "exploration" AND needs != "done" AND needs != "dropped"
SORT updated DESC
```

---

## タグ別集計

```dataview
TABLE length(rows) AS "メモ数", rows.needs AS "ステータス"
FROM "inbox" OR "incubating" OR "actionable"
WHERE needs != "done" AND needs != "dropped"
FLATTEN tags AS tag
GROUP BY tag
SORT length(rows) DESC
```

---

## アーカイブ（完了・取り下げ）

```dataview
TABLE needs AS "ステータス", type AS "種別", dateformat(updated, "yyyy-MM-dd") AS "更新日"
FROM "archive"
SORT updated DESC
LIMIT 10
```
