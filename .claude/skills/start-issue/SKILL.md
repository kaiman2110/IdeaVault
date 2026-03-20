---
name: start-issue
description: Issue の実装を開始する。ブランチ作成・実装・テスト・コミットを自律的に回す。引数なしで最優先 Issue を自動選択。
argument-hint: "[issue-number]"
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *), Read, Write, Edit, Glob, Grep, Agent
---

## 引数なしの場合（$ARGUMENTS が空）

優先度順に最初の open Issue を自動選択する:

1. 以下のコマンドを順に実行し、最初にヒットした Issue 番号を使う:
   - `gh issue list --repo kaiman2110/IdeaVault --state open --label "priority/high" --json number,title --jq '.[0]'`
   - ヒットしなければ `--label "priority/medium"` で再検索
   - それもなければ `--label "priority/low"` で再検索
2. 見つかった Issue の番号とタイトルをユーザーに表示し、「この Issue を開始しますか？」と確認を求める
3. ユーザーが承認したら、下記「共通手順」へ進む

## 引数ありの場合

Issue 番号 = $ARGUMENTS として「共通手順」へ進む。

## 共通手順

### フェーズ 1: 準備
1. `gh issue view <番号> --repo kaiman2110/IdeaVault` で Issue の内容を確認する
2. Issue の概要（タイトル・仕様・依存関係）をユーザーに表示する
3. Issue のステータスを In Progress に更新:
   - ラベル: `gh issue edit <番号> --repo kaiman2110/IdeaVault --remove-label "status/todo" --add-label "status/in-progress"`
4. 現在のブランチを確認し、main でなければ `git checkout main` する
5. main を最新に更新: `git pull origin main`
6. 新しいブランチを作成: `git checkout -b feature/issue/<番号>`

### フェーズ 1.5: 並列コードベース調査（Agent teams）

Issue の内容から実装に必要な情報を **3つの Agent(Explore) を同時起動** して収集する。
**必ず1メッセージで3つの Agent tool を並列呼び出しすること。**

```
Agent(Explore) ×3 並列:
  ├─ Agent 1: 直接関連ファイル調査
  │    「Issue #N の実装に直接関係するファイルを調査。
  │     関連する既存クラス・メソッド・シグナルの実装を読み、
  │     変更が必要な箇所とその現在の実装を報告してください。」
  │
  ├─ Agent 2: 既存パターン・テスト調査
  │    「Issue #N に関連する既存の実装パターンを調査。
  │     類似機能がどう実装されているか、参考になるコードパターン、
  │     既存テストの構造、新規テストで使えるヘルパーを報告してください。」
  │
  └─ Agent 3: 影響範囲・依存関係調査
       「Issue #N の変更による影響範囲を調査。
        変更対象のシグナル・メソッドを参照している箇所、
        EventBus 経由の連携先、UI への影響を報告してください。」
```

3つの調査結果を統合して実装計画を立てる。

7. 調査結果を元に実装計画を立てる
8. **計画承認の判定**:
   - Issue が `/design` や `/milestone-plan` で事前に設計承認済みの場合（Issue body に仕様・ステップが明記されている場合）→ **承認済みとみなし、計画を表示してそのまま実装に進む**
   - Issue の仕様が曖昧・未設計の場合のみ → 実装計画をユーザーに提示し確認を求める

### フェーズ 2: 自律実装（人間の介入なし）

ユーザーの承認後、以下のループを **Issue 完了まで自律的に回す**:

```
各ステップについて:
  1. 実装
  2. テスト実行
  3. テスト失敗 → 修正 → 再テスト（3回まで）
  4. テスト通過 → 自動コミット（日本語メッセージ）
  5. 次のステップへ
```

**自律実装中のルール:**
- コミット前にユーザーに聞かない。テスト通過 = コミット可
- エラーは自分で直す。3回以上同じエラーで詰まったらアプローチを変える
- 「次に何をする？」と聞かない。Issue の仕様から逆算して進む
- 設計判断は CLAUDE.md のアーキテクチャ原則に従って自分で決める
- 新規システムにはユニットテストを追加する

### フェーズ 3: 自己検証

全ステップ完了後:
1. テスト全実行 → 全パス確認
2. `git diff main..HEAD` で全変更をセルフレビュー
3. CLAUDE.md のアーキテクチャ原則に照らしてチェック

### フェーズ 4: ユーザーに報告（ここだけ人間が介入）

1. 実装内容のサマリーを報告
2. 動作確認チェックリストを提示
3. ユーザーの動作確認 → ok を待つ
4. ok が出たら → 即座に `/close-issue <番号>` を実行
