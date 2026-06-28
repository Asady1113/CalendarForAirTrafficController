# CalendarForAirTrafficController

航空管制官の勤務シフトを管理・カレンダー出力するiOSアプリです。  
42日サイクルの複雑な勤務体系を自動計算し、Google カレンダーへの同期や ICS ファイル出力に対応しています。

## 背景・ドメイン知識

航空管制官のシフトは以下の構造で成り立っています。

| 単位 | 内容 |
|------|------|
| **クルー** | チーム単位。全6クルーがサイクル起点を1日ずつずらして運用 |
| **セル** | クルー内の班。1クルーにつき7セル。同じセルの人は同じ勤務体系 |
| **1サイクル** | 7ラウンド（= 42日）で1周 |
| **1ラウンド** | 6日周期。夜勤ありと夜勤なしを交互に繰り返す |

**夜勤ありラウンド**: E1 → A → B → C（夜勤）→ 明け → 休み  
**夜勤なしラウンド**: 休み → A → B → E2 → 休み（B4）→ 休み

## 機能

### 1. クルー管理画面
- クルーの一覧表示・新規作成・編集・削除
- クルー名とサイクル開始日（42日サイクルの起算日）を設定

### 2. セル管理画面
- セルの一覧表示・新規作成・編集・削除
- 7ラウンドの順序と各ラウンドの種別（夜勤あり／夜勤なし／夜勤なし・B4あり）を設定

### 3. カレンダー・エクスポート画面
- 42日サイクルに基づくシフトの月次カレンダー表示
- 土日祝・勤務種別の色分け表示、当日ハイライト
- **ICS 出力**: 期間を指定してスケジュールをファイル保存
- **Google カレンダー同期**: 予定を直接登録

## 技術スタック

- **言語**: Swift
- **UIフレームワーク**: SwiftUI
- **永続化**: SwiftData
- **外部連携**:
  - Google Calendar API（クラウド同期）
  - ICS ファイル生成（`IcsGenerator.swift`）

## アーキテクチャ

クリーンアーキテクチャを採用しています。

```
App/App/
├── Domain/
│   ├── Entities/         # Crew, Cell
│   ├── ValueObjects/     # シフト種別など
│   ├── Ports/            # リポジトリ・サービスのインターフェース
│   └── Services/         # シフト計算ロジック
├── Application/          # ユースケース層
├── Infrastructure/
│   ├── Persistence/      # SwiftData 実装（CrewRepository, CellRepository）
│   ├── GoogleCalendarService.swift
│   └── IcsGenerator.swift
├── Presentation/
│   ├── ViewModels/
│   └── Views/
├── DI/                   # 依存性注入
└── Docs/
    └── Requirements/     # 要件定義・ユビキタス言語・ユースケース定義
```

## セットアップ

### 前提条件

- Xcode 15 以降
- Google Cloud Console で OAuth クライアント ID を取得済みであること

### 手順

1. リポジトリをクローン

```bash
git clone https://github.com/Asady1113/CalendarForAirTrafficController.git
cd CalendarForAirTrafficController
git checkout feature/construction
```

2. Secrets ファイルを作成

```bash
cp App/App/Secrets.swift.example App/App/Secrets.swift
```

`Secrets.swift` を開き、Google Calendar API のクライアント ID などを設定してください。

3. `App/App.xcodeproj` を Xcode で開いてビルド・実行
