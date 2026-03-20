---
name: analyze-sessions
description: Claude Code のセッション履歴を解析し、行動パターン・改善点・自動化候補を特定する。インクリメンタル対応。
argument-hint: "[focus: skills|hooks|patterns|all] [--full]"
allowed-tools: Bash(*), Read, Glob, Grep, Agent
---

セッション履歴を解析する。**デフォルトはインクリメンタル**（前回以降の新規セッションのみ）。

## フェーズ 0: インクリメンタル判定

1. 状態ファイルを確認: `$CLAUDE_PROJECT_DIR/.claude/state/analyze-sessions-last.json`
   ```json
   { "last_analyzed_at": "2026-03-16T15:00:00Z", "session_count": 229, "summary": "前回の主要発見..." }
   ```
2. 判定ロジック:
   - `--full` 引数あり → 全セッション分析
   - 状態ファイルなし → 全セッション分析（初回）
   - 状態ファイルあり → `last_analyzed_at` 以降の .jsonl のみ対象
3. ディレクトリ作成: `mkdir -p "$CLAUDE_PROJECT_DIR/.claude/state"`

## フェーズ 1: データ収集

1. セッションファイルの場所を特定:
   - `~/.claude/projects/` 配下のプロジェクトディレクトリ
   - 各 `.jsonl` ファイルがセッション
2. インクリメンタル時: `find ... -newer <状態ファイル>` で新規 .jsonl のみ列挙
3. 全件時: 全 .jsonl ファイルを列挙し、サイズと日付を記録
4. 各セッションから以下を抽出:
   - ユーザーメッセージ（type: "human"）
   - ツールコール種別と頻度
   - スキル呼び出し
   - エラーメッセージと修正パターン

## フェーズ 2: パターン分析

$ARGUMENTS に応じて深掘り（デフォルト: all）:

### skills（スキル候補）
- 繰り返される手動操作パターンを特定
- スキル化の ROI を評価（頻度 x 手間）

### hooks（Hook候補）
- 繰り返される事前/事後チェックを特定
- 自動化可能なガードレールを提案

### patterns（行動パターン）
- フェーズ別の行動変化を追跡
- ボトルネックとなっている操作を特定

### all（総合分析）
- 上記すべて + カテゴリ別の提案

## フェーズ 3: レポート

日本語でレポートを出力:
1. 基本統計（分析対象セッション数、期間、前回からの差分）
2. 行動パターン分析
3. カテゴリ別の改善提案（優先度付き）
4. 投資対効果の高い順にランキング

## フェーズ 4: 状態保存

分析完了後、状態ファイルを更新:
- `last_analyzed_at`: 現在時刻（ISO 8601）
- `session_count`: 累計セッション数
- `summary`: 主要な発見事項（3行以内）
