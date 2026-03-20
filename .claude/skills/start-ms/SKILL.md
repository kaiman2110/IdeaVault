---
name: start-ms
description: マイルストーン単位で全Issueを依存関係順に一括実装する。MS番号を指定して全Issueを自律的に完了させる。
argument-hint: "<ms-number>"
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *), Read, Write, Edit, Glob, Grep, Agent, Skill
---

マイルストーン単位で全 Issue を一括実装する。

## 引数なしの場合

次に実施すべき MS を自動判定する:
1. MEMORY.md の Milestone 進捗テーブルを読み、最初の未完了 MS を特定
2. ユーザーに「MS<N>（<テーマ>）を開始しますか？」と確認

## 引数ありの場合

MS番号 = $ARGUMENTS として以下へ進む。

## フェーズ 1: MS全体の把握

1. `gh issue list --repo kaiman2110/IdeaVault --state open --label "ms<N>" --json number,title,body,labels --jq '.[] | {number, title, labels: [.labels[].name]}'` で対象 Issue を一覧取得
2. 各 Issue の body から依存関係を抽出（`#N依存`、`depends on #N` 等）
3. 依存関係グラフを構築し、**実行順序**を決定:
   - 依存なし → 最初に実行
   - 依存ありは依存先の完了後
   - 同じ依存レベルの Issue は priority/high → medium → low の順
4. 実行順序をユーザーに表示:
   ```
   === MS<N>: <テーマ> 実行計画 ===
   1. #<A> <タイトル> [priority/high] ← 依存なし
   2. #<B> <タイトル> [priority/high] ← 依存なし
   3. #<C> <タイトル> [priority/high] ← #A 依存
   ```
5. ユーザーの承認を待つ（順序変更・スキップの指示があれば反映）

## フェーズ 2: 順次実装

承認後、各 Issue を順番に `/start-issue <番号>` で実行する:

```
for each issue in execution_order:
  1. /start-issue <issue番号>
     └─ 自律実装（フェーズ1〜3は自動）
     └─ フェーズ4: ユーザー動作確認 → ok → /close-issue
  2. 次の Issue へ
```

**Issue 間のルール:**
- 各 Issue 完了後に `/close-issue` まで完走する
- 次の Issue 開始前に main を最新に pull する
- Issue 間で「次の Issue #<N> に進みます」と表示する
- ユーザーが「ストップ」「ここまで」と言ったらループを中断し `/session-end` を実行

## フェーズ 3: MS完了

全 Issue 完了後:
1. `gh issue list --state open --label "ms<N>"` で残 Issue がないことを確認
2. MS完了サマリーを表示:
   ```
   === MS<N>: <テーマ> 完了 ===
   完了 Issue: #A, #B, #C, #D, #E（計 N 件）
   主な変更:
   - ...
   次の推奨アクション:
   - MS<M> の実施
   - /session-end でメモリ保存
   ```
