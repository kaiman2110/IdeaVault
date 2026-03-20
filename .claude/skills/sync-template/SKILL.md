---
name: sync-template
description: 現プロジェクトのスキル・Hook・CLAUDE.md を棚卸しし、テンプレート（~/claude-project-template/）と同期する。
argument-hint: "[diff|push|pull]"
allowed-tools: Bash(git *), Read, Write, Edit, Glob, Grep, Agent
---

現プロジェクトの Claude Code 設定をテンプレートと比較・同期する。引数 = $ARGUMENTS

## モード

- **diff**（デフォルト / 引数なし）: 現プロジェクトとテンプレートの差分を分析・レポート
- **push**: 現プロジェクトの改善をテンプレートに反映（汎用化して export）
- **pull**: テンプレートの更新を現プロジェクトに取り込み

---

## diff モード（棚卸し）

### フェーズ 1: 並列差分分析（Agent teams）

**3つの Agent を同時起動** して差分を分析する。

```
Agent(Explore) ×3 並列:
  ├─ Agent 1: スキル差分
  │    「現プロジェクト .claude/skills/ とテンプレート ~/claude-project-template/.claude/skills/ の
  │     全 SKILL.md を比較。以下を報告:
  │     - テンプレートにない現プロジェクト専用スキル
  │     - テンプレートにあるが現プロジェクトで改善されたスキル（内容差分）
  │     - テンプレートの方が新しいスキル
  │     - 汎用化できそうなプロジェクト専用スキル」
  │
  ├─ Agent 2: Hook + settings.json 差分
  │    「現プロジェクト .claude/hooks/ と settings.json を
  │     テンプレート ~/claude-project-template/.claude/hooks/ と settings.json.template と比較。
  │     - 新規 Hook / 削除された Hook
  │     - Hook ロジックの改善点
  │     - settings.json の権限やトリガー設定の差分」
  │
  └─ Agent 3: CLAUDE.md + グローバルルール差分
       「現プロジェクトの CLAUDE.md と以下を比較:
        - ~/.claude/CLAUDE.md（グローバルルール）
        - ~/claude-project-template/CLAUDE.md.template
        報告内容:
        - グローバルに昇格すべきルール（プロジェクト非依存のもの）
        - テンプレートに反映すべきセクション構造の改善
        - 陳腐化したルール（既に不要 or 変更が必要）」
```

### フェーズ 2: 棚卸しレポート

```markdown
# テンプレート棚卸しレポート（YYYY-MM-DD）

## スキル
| スキル名 | 状態 | アクション |
|---------|------|-----------|
| /xxx | 🆕 プロジェクト専用 | push 候補（汎用化可能） |
| /yyy | 📝 テンプレートより改善済み | push 推奨 |
| /zzz | ⬇️ テンプレートの方が新しい | pull 推奨 |
| /aaa | ✅ 同期済み | なし |

## Hook
| Hook | 状態 | アクション |

## CLAUDE.md
| ルール/セクション | 状態 | アクション |

## 推奨アクション
1. `push` すべき改善: ...
2. `pull` すべき更新: ...
3. 削除候補: ...
```

ユーザーに「push / pull を実行しますか？」と確認する。

---

## push モード（現プロジェクト → テンプレート）

### フェーズ 1: push 対象の特定

diff モードの結果を参照（なければ先に diff を実行）。
push 対象を一覧表示してユーザーに確認。

### フェーズ 2: 汎用化 + コピー

各ファイルについて:

1. **スキルの汎用化**:
   - プロジェクト固有のリポジトリ情報 → `kaiman2110/IdeaVault`
   - プロジェクト固有のスクリプト呼び出し → 削除 or ``
   - フレームワーク固有のテスト実行 → `echo 'テストコマンド未設定'`
   - プロジェクト固有の MCP ツール → 削除
   - Projects ボード番号 → `1`

2. **Hook の汎用化**:
   - フレームワーク固有チェック → コメントに置換
   - プロジェクト固有のボイス/通知 → 削除
   - ハードコードパス → `C:/Users/kaima/workspace/develop/IdeaVault`

3. **CLAUDE.md テンプレートの更新**:
   - 新セクション構造を反映
   - プロジェクト固有内容は `<!-- ... -->` プレースホルダーに

4. **グローバル CLAUDE.md の更新**:
   - プロジェクト非依存のルールを `~/.claude/CLAUDE.md` に追記

### フェーズ 3: setup.js の更新チェック

新しいプレースホルダーが追加された場合:
- `setup.js` の質問項目と replacements 辞書を更新
- `setup.md` のプレースホルダー一覧テーブルを更新

---

## pull モード（テンプレート → 現プロジェクト）

### フェーズ 1: pull 対象の特定

diff モードの結果を参照。pull 対象を一覧表示してユーザーに確認。

### フェーズ 2: プロジェクト固有化 + コピー

テンプレートのプレースホルダーを現プロジェクトの値に置換。
**既存ファイルは上書きせず差分を表示** → ユーザーが取り込み箇所を選択。

---

## 注意
- push 時は必ず汎用化してからテンプレートに書き込む（プロジェクト固有情報の漏洩防止）
- pull 時は既存ファイルを直接上書きしない（差分確認後にマージ）
- 新しいスキルを push する場合、setup.md のスキル一覧テーブルも更新する
