# Adapter層（UI・Infrastructure）実装指示

## 役割
あなたは経験豊富なソフトウェアアーキテクトです。

## タスク
`/Users/asadatomoya/Desktop/Calendar/aidlc-docs/construction/application_service_plan.md` のユースケースを実現するためのUIとインフラストラクチャを作成し、iOSアプリを完成させる。

## 作業手順

1. 作業の計画を立て、各ステップにチェックボックスを付けて `aidlc-docs/construction/adapter_plan.md` ファイルにステップを記載してください。

2. **いずれかのステップで説明が必要な場合は、[Question] タグを付けて質問を追加し、回答を記入するための空の [Answer] タグを作成してください。独自の判断や決定は行わないでください。**

3. 計画を作成したら、レビューと承認を求めてください。

4. 承認後、その計画を1ステップずつ実行できます。

5. 各ステップが完了したら、計画のチェックボックスに完了マークを付けてください。

6. また、作業内容のレビューを求めてください。

## 参照ドキュメント

- ユーザーストーリー: `/Users/asadatomoya/Desktop/Calendar/aidlc-docs/inception/user_stories.md`
- Application層計画: `/Users/asadatomoya/Desktop/Calendar/aidlc-docs/construction/application_service_plan.md`
- UIデザイン: `/Users/asadatomoya/Desktop/Calendar/Docs/Design/`
- 実装計画: `/Users/asadatomoya/Desktop/Calendar/aidlc-docs/construction/adapter_plan.md`

## 技術選定（確定済み）

| 項目 | 採用技術 |
|------|----------|
| 最小iOSバージョン | iOS 17+ |
| 永続化層 | SwiftData |
| UIアーキテクチャ | MVVM |
| ナビゲーション | NavigationStack |
| カレンダーUI | カスタム実装 |
| カレンダーエクスポート | ICS + Google Calendar API |
