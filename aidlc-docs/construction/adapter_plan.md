# Adapter層（UI・Infrastructure）実装計画

## 概要
Application層で実装されたユースケースを実現するためのUI（Presentation層）とInfrastructure層を設計・実装する。

**実装言語**: Swift（iOS）
**対象ディレクトリ**:
- UI層: `/Users/asadatomoya/Desktop/Calendar/App/App/Presentation/`
- Infrastructure層: `/Users/asadatomoya/Desktop/Calendar/App/App/Infrastructure/`

---

## 技術選定（確定）

| 項目 | 採用技術 | 理由 |
|------|----------|------|
| **最小iOSバージョン** | iOS 17+ | SwiftData対応 |
| **永続化層** | SwiftData | Apple純正、シンプル、ログイン不要 |
| **UIアーキテクチャ** | MVVM | シンプルで理解しやすい |
| **ナビゲーション** | NavigationStack | iOS 16+標準、階層的ナビゲーション |
| **カレンダーUI** | カスタム実装 | デザイン通りに実装 |
| **カレンダーエクスポート** | ICS + Google Calendar API | ユーザー要件 |

**デザイン参照**: `/Users/asadatomoya/Desktop/Calendar/Docs/Design/`

---

## 現状の実装状況

### 実装済み
| レイヤー | 内容 |
|---------|------|
| Domain層 | エンティティ、ValueObject、DomainService、Ports（完全実装済み） |
| Application層 | ApplicationService、DTO、エラー定義（完全実装済み） |
| Infrastructure層 | CrewRepository、CellRepository、IcsGenerator（インメモリ実装済み） |

### 未実装
| レイヤー | 内容 |
|---------|------|
| Application層 | Application Serviceのプロトコル（ポート）定義 |
| Presentation層 | SwiftUI Views、ViewModels、ナビゲーション |
| Infrastructure層 | SwiftData永続化、CalendarExportService（Google Calendar連携） |
| App基盤 | DI設定 |

---

## 計画ステップ

### Phase 1: 基盤設計・セットアップ

- [x] **Step 1.1**: Application Serviceプロトコル（ポート）の定義
  - UI層がApplication層に依存するためのインターフェース定義
  - 配置: `Application/Ports/`
  - 対象プロトコル:
    - `CrewApplicationServiceProtocol`
    - `CellApplicationServiceProtocol`
    - `ScheduleApplicationServiceProtocol`
    - `ExportApplicationServiceProtocol`
  - 既存のApplication Serviceがプロトコルに準拠するよう更新

- [ ] **Step 1.2**: SwiftData永続化層の実装
  - SwiftDataモデルの定義（CrewModel, CellModel）
  - 既存のDomainエンティティとの変換ロジック
  - CrewRepository、CellRepositoryのSwiftData対応

- [ ] **Step 1.3**: DIコンテナの設計・実装
  - 依存性注入の仕組みを構築
  - Application ServiceとRepositoryの初期化
  - SwiftDataのModelContainerセットアップ

- [ ] **Step 1.4**: アプリエントリポイント（AppApp.swift）の更新
  - SwiftData ModelContainer設定
  - DI設定
  - NavigationStack構造の設定

### Phase 2: Presentation層 - ViewModel設計・実装

- [ ] **Step 2.1**: CrewListViewModel の設計・実装
  - 対応US: US-1.1, US-1.2, US-1.3, US-1.4, US-1.5
  - クルー一覧取得、作成、編集、削除、選択
  - セル数の表示（デザイン参照）

- [ ] **Step 2.2**: CellListViewModel の設計・実装
  - 対応US: US-2.1, US-2.2, US-2.3, US-2.4, US-2.5, US-2.6
  - セル一覧取得、作成、編集、削除、選択
  - 7ラウンド構成の表示（デザイン参照）

- [ ] **Step 2.3**: ScheduleViewModel の設計・実装
  - 対応US: US-3.1, US-3.2, US-3.3, US-3.4, US-3.5
  - 月次カレンダー表示、月切り替え、当日ハイライト、勤務種別色分け

- [ ] **Step 2.4**: ExportViewModel の設計・実装
  - 対応US: US-4.1, US-4.2, US-4.3, US-4.4
  - エクスポート期間設定、ICSダウンロード、Googleカレンダー連携、削除

### Phase 3: Presentation層 - View設計・実装

- [ ] **Step 3.1**: クルー管理画面群の実装
  - CrewListView（クルー一覧）- デザイン: CrewList.png
    - ヘッダー「マイ スケジュール」
    - ウェルカムメッセージカード
    - クルーカード（クルー名、セル数、開始日、編集・削除アイコン）
    - 「クルーを追加」ボタン
  - CrewFormView（クルー作成・編集）- デザイン: AddCrew.png
    - クルー名入力
    - サイクル開始基準日DatePicker
    - キャンセル・保存ボタン
  - 削除確認ダイアログ

- [ ] **Step 3.2**: セル管理画面群の実装
  - CellListView（セル一覧）- デザイン: CellList.png
    - ヘッダー（クルー名、戻るボタン）
    - セルカード（セル名、カレンダーボタン、編集・削除）
    - 7ラウンド表示（R1〜R7、夜勤/B4）
    - 「新しいセルを追加」ボタン
  - CellFormView（セル作成・編集）- デザイン: AddCell.png
    - セル名入力
    - 7ラウンドのドロップダウン選択（夜勤あり/夜勤なし/夜勤なし・B4あり）
    - 完了ボタン
  - 削除確認ダイアログ

- [ ] **Step 3.3**: カレンダー表示画面の実装
  - ScheduleCalendarView（月次カレンダー）- デザイン: Calendar.png
    - ヘッダー（クルー名-セル名、戻るボタン）
    - 月表示（年月、前月・翌月ボタン）
    - 7列カレンダーグリッド（日〜土）
    - 勤務種別色分け表示（デザイン通りの配色）
    - 当日ハイライト（青枠）
    - 日曜日（赤）、土曜日（青）の日付色
  - カスタムカレンダーグリッドコンポーネント

- [ ] **Step 3.4**: エクスポート画面の実装
  - ExportView（エクスポート設定）- デザイン: Export.png
    - 「エクスポート設定」セクション
    - 開始日・終了日DatePicker
    - 「Googleカレンダーに同期」ボタン
    - 「ICSファイル(.ics)を保存」ボタン

- [ ] **Step 3.5**: 共通UIコンポーネントの実装
  - ShiftTypeColors.swift（勤務種別の色定義）
    - E1: 水色
    - A: 水色
    - B: 薄緑
    - C: 青紫（濃い）
    - E2: 薄紫
    - POST_NIGHT（明け）: 薄いグレー
    - OFF（休み）: 白/薄いグレー
    - B4: 薄紫
  - 共通ボタンスタイル
  - カードコンポーネント
  - ローディング・エラー表示

### Phase 4: Infrastructure層 - 外部連携

- [ ] **Step 4.1**: ICSファイル共有機能の実装
  - UIActivityViewController連携
  - ShareSheet対応

- [ ] **Step 4.2**: Google Calendar API連携の実装
  - Google Sign-In SDK導入
  - OAuth 2.0認証フロー
  - Google Calendar API呼び出し
  - CalendarExportServiceProtocolの実装

### Phase 5: ナビゲーション・統合

- [ ] **Step 5.1**: 画面遷移の実装
  - クルー一覧 → セル管理（クルー選択時）
  - セル管理 → カレンダー表示（セル選択時）
  - カレンダー表示内にエクスポートセクション
  - 各画面の戻る機能

- [ ] **Step 5.2**: 全画面の統合テスト
  - 一連のユーザーフローの確認
  - エラーケースの確認
  - データ永続化の確認

### Phase 6: 仕上げ

- [ ] **Step 6.1**: UIの調整・ポリッシュ
  - レイアウト調整
  - アニメーション追加
  - アクセシビリティ対応

- [ ] **Step 6.2**: テストの作成
  - ViewModelのユニットテスト
  - UIテスト（必要に応じて）

---

## ファイル構成（予定）

```
App/App/
├── AppApp.swift                          ← 更新（SwiftData, DI, Navigation）
├── Application/
│   ├── Ports/                            ← 新規（UI層向けインターフェース）
│   │   ├── CrewApplicationServiceProtocol.swift
│   │   ├── CellApplicationServiceProtocol.swift
│   │   ├── ScheduleApplicationServiceProtocol.swift
│   │   └── ExportApplicationServiceProtocol.swift
│   ├── Services/                         ← 既存（プロトコル準拠に更新）
│   │   └── ...
│   └── ...
├── Presentation/
│   ├── ViewModels/
│   │   ├── CrewListViewModel.swift
│   │   ├── CellListViewModel.swift
│   │   ├── ScheduleViewModel.swift
│   │   └── ExportViewModel.swift
│   ├── Views/
│   │   ├── Crew/
│   │   │   ├── CrewListView.swift
│   │   │   └── CrewFormView.swift
│   │   ├── Cell/
│   │   │   ├── CellListView.swift
│   │   │   └── CellFormView.swift
│   │   ├── Schedule/
│   │   │   ├── ScheduleCalendarView.swift
│   │   │   └── CalendarGridView.swift
│   │   ├── Export/
│   │   │   └── ExportView.swift
│   │   └── Common/
│   │       ├── ShiftTypeColors.swift
│   │       ├── CardView.swift
│   │       └── CommonComponents.swift
│   └── Navigation/
│       └── AppNavigationView.swift
├── Infrastructure/
│   ├── Persistence/
│   │   ├── SwiftDataModels/
│   │   │   ├── CrewModel.swift
│   │   │   └── CellModel.swift
│   │   ├── SwiftDataCrewRepository.swift
│   │   └── SwiftDataCellRepository.swift
│   ├── GoogleCalendarService.swift       ← 新規
│   ├── IcsGenerator.swift                ← 既存
│   └── ...（既存ファイル）
└── DI/
    └── DIContainer.swift                 ← 新規
```

---

## ユーザーストーリーとView/ViewModelの対応表

| ユーザーストーリー | ViewModel | View |
|------------------|-----------|------|
| US-1.1: クルー一覧表示 | CrewListViewModel | CrewListView |
| US-1.2: クルー新規作成 | CrewListViewModel | CrewFormView |
| US-1.3: クルー編集 | CrewListViewModel | CrewFormView |
| US-1.4: クルー削除 | CrewListViewModel | CrewListView（ダイアログ） |
| US-1.5: クルー選択 | CrewListViewModel | CrewListView |
| US-2.1: セル一覧表示 | CellListViewModel | CellListView |
| US-2.2: セル新規作成 | CellListViewModel | CellFormView |
| US-2.3: セル編集 | CellListViewModel | CellFormView |
| US-2.4: セル削除 | CellListViewModel | CellListView（ダイアログ） |
| US-2.5: セル選択 | CellListViewModel | CellListView |
| US-2.6: クルー管理へ戻る | - | NavigationStack |
| US-3.1: 月次カレンダー表示 | ScheduleViewModel | ScheduleCalendarView |
| US-3.2: 月切り替え | ScheduleViewModel | ScheduleCalendarView |
| US-3.3: 当日ハイライト | ScheduleViewModel | ScheduleCalendarView |
| US-3.4: 勤務種別色分け | ScheduleViewModel | ScheduleCalendarView |
| US-3.5: セル管理へ戻る | - | NavigationStack |
| US-4.1: エクスポート期間設定 | ExportViewModel | ExportView |
| US-4.2: ICSダウンロード | ExportViewModel | ExportView |
| US-4.3: Googleカレンダーエクスポート | ExportViewModel | ExportView |
| US-4.4: カレンダーから削除 | ExportViewModel | ExportView |

---

## デザイン参照

| 画面 | デザインファイル |
|------|------------------|
| クルー一覧 | CrewList.png |
| クルー追加 | AddCrew.png |
| セル一覧 | CellList.png |
| セル追加 | AddCell.png |
| カレンダー | Calendar.png |
| エクスポート | Export.png |

---

## 備考

- 各ステップは順次実行し、完了後にチェックボックスに完了マークを付けます
- 実装中に追加の質問が発生した場合は、都度確認させていただきます
- Google Calendar API連携にはGoogle Cloud Consoleでのプロジェクト設定が必要です