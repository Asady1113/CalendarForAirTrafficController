# Application層 実装計画

## 概要
ドメインモデル（domain_model_overview.md）を使用して、ユーザーストーリー（user_stories.md）を実現するためのApplication層を設計・実装する。

**実装言語**: Swift（iOS）
**対象ディレクトリ**: `/Users/asadatomoya/Desktop/Calendar/App/App/Application/`

---

## 前提確認

[Question] ドメインモデルのドキュメント（domain_model_*.md）は設計ドキュメントのみで、実際のTypeScript/JavaScriptコードはまだ実装されていないようです。Application層を実装する前に、ドメイン層のコードを先に実装する必要がありますか？それとも、ドメイン層とApplication層を同時に設計・実装する想定でしょうか？

[Answer]
いかに実装されているので確認してください
/Users/asadatomoya/Desktop/Calendar/App

→ 確認完了。Domain層は完全実装済み。

---

## 現状の実装状況

### 実装済み（Domain層）
| ファイル | 内容 |
|---------|------|
| `Domain/Entities/Crew.swift` | クルーエンティティ（id, name, cycleStartDate） |
| `Domain/Entities/Cell.swift` | セルエンティティ（id, name, crewId, cycleConfiguration） |
| `Domain/ValueObjects/ShiftType.swift` | 勤務種別Enum（E1, A, B, E2, C, POST_NIGHT, OFF, B4） |
| `Domain/ValueObjects/RoundType.swift` | ラウンド種別Enum（WITH_NIGHT, WITHOUT_NIGHT, WITHOUT_NIGHT_B4） |
| `Domain/ValueObjects/CycleConfiguration.swift` | サイクル構成（7ラウンドの配列） |
| `Domain/ValueObjects/WorkSchedule.swift` | 勤務予定（date, shiftType） |
| `Domain/ValueObjects/ExportPeriod.swift` | エクスポート期間（startDate, endDate） |
| `Domain/Services/ScheduleCalculator.swift` | 勤務予定計算サービス |
| `Domain/Ports/CrewRepositoryProtocol.swift` | クルーリポジトリインターフェース |
| `Domain/Ports/CellRepositoryProtocol.swift` | セルリポジトリインターフェース |

### 実装済み（Infrastructure層）
| ファイル | 内容 |
|---------|------|
| `Infrastructure/CrewRepository.swift` | クルーリポジトリ実装（インメモリ） |
| `Infrastructure/CellRepository.swift` | セルリポジトリ実装（インメモリ） |

### 実装済み（Application層）
| ファイル | 内容 |
|---------|------|
| `Application/DTOs/Requests/*.swift` | Request DTO（7ファイル） |
| `Application/DTOs/Responses/*.swift` | Response DTO（4ファイル） |
| `Application/Errors/ApplicationErrors.swift` | エラー定義 |
| `Application/Services/CrewApplicationService.swift` | クルー管理（連鎖削除含む） |
| `Application/Services/CellApplicationService.swift` | セル管理 |
| `Application/Services/ScheduleApplicationService.swift` | 勤務予定取得 |
| `Application/Services/ExportApplicationService.swift` | エクスポート機能 |
| `Domain/Ports/CalendarExportServiceProtocol.swift` | 外部カレンダー連携インターフェース |
| `Domain/Ports/IcsGeneratorProtocol.swift` | ICS生成インターフェース |
| `Infrastructure/IcsGenerator.swift` | ICSファイル生成実装 |

---

## 計画ステップ

### Phase 1: 設計

- [x] **Step 1.1**: Application Serviceの責務分割を設計する
  - CrewApplicationService（US-1.1〜US-1.4）
  - CellApplicationService（US-2.1〜US-2.4）
  - ScheduleApplicationService（US-3.1, US-3.2）
  - ExportApplicationService（US-4.1〜US-4.4）

- [x] **Step 1.2**: 各Application Serviceのメソッド定義を設計する
  - 入力（Request）の定義 → Phase 3で詳細設計済み
  - 出力（Response）の定義 → Phase 3で詳細設計済み
  - エラーハンドリング方針: Result型またはthrowsで処理

[Question] Repositoryの実装（データ永続化）は何を使用する想定ですか？（例：ローカルストレージ、IndexedDB、Firebase、PostgreSQL等）

[Answer]
Repositoryインターフェースはすでに実装されています。
今回はインターフェースさえ知っていれば実装できますので、永続化の詳細については知らなくていいです。

→ 了解。Repositoryインターフェース（`CrewRepositoryProtocol`, `CellRepositoryProtocol`）に依存する形で実装。

### Phase 2: DTO（Data Transfer Object）の設計

- [x] **Step 2.1**: Request DTOを設計する
  - `CreateCrewRequest`
  - `UpdateCrewRequest`
  - `CreateCellRequest`
  - `UpdateCellRequest`
  - `GetMonthlyScheduleRequest`
  - `ExportScheduleRequest`
  - `DeleteFromCalendarRequest`

- [x] **Step 2.2**: Response DTOを設計する
  - `CrewResponse`
  - `CellResponse`
  - `MonthlyScheduleResponse`
  - `WorkScheduleResponse`

### Phase 3: Application Service詳細設計

- [x] **Step 3.1**: CrewApplicationServiceの詳細設計
  - `listCrews() -> [CrewResponse]`: 全クルー一覧取得
  - `createCrew(request: CreateCrewRequest) -> CrewResponse`: クルー新規作成
  - `updateCrew(request: UpdateCrewRequest) -> CrewResponse`: クルー更新
  - `deleteCrew(crewId: UUID)`: クルー削除
    - **連鎖削除はApplication層で処理**（ビジネスルールとして明示）
    - CellRepositoryの`deleteByCrewId`を呼び出してからCrewを削除

- [x] **Step 3.2**: CellApplicationServiceの詳細設計
  - `listCellsByCrewId(crewId: UUID) -> [CellResponse]`: クルーに紐づくセル一覧取得
  - `createCell(request: CreateCellRequest) -> CellResponse`: セル新規作成（サイクル構成含む）
  - `updateCell(request: UpdateCellRequest) -> CellResponse`: セル更新
  - `deleteCell(cellId: UUID)`: セル削除

- [x] **Step 3.3**: ScheduleApplicationServiceの詳細設計
  - `getMonthlySchedule(request: GetMonthlyScheduleRequest) -> MonthlyScheduleResponse`: 月次勤務予定取得
  - ScheduleCalculator（DomainService）との連携

- [x] **Step 3.4**: ExportApplicationServiceの詳細設計
  - `generateIcsFile(request: ExportScheduleRequest) -> Data`: ICSファイル生成
  - `exportToCalendar(request: ExportScheduleRequest)`: 外部カレンダーエクスポート
  - `deleteFromCalendar(request: DeleteFromCalendarRequest)`: 外部カレンダーから削除

[Question] Googleカレンダー連携（US-4.3, US-4.4）について、Google Calendar APIの認証フロー（OAuth 2.0）の実装はApplication層の責務として含めるべきでしょうか？それとも別のInfrastructure層として分離すべきでしょうか？

[Answer]
Infrastrctureやな。あとドメインにはできるだけ詳細を含めない方がいい気がするので、Googleという言葉使わなくていいかも。exportToCalenderとかでもいいんじゃないかな。

→ 了解。Application層では抽象的な`CalendarExportServiceProtocol`に依存し、Google Calendar等の具体実装はInfrastructure層に配置。

### Phase 4: 実装

- [x] **Step 4.1**: Request DTOを実装する
  - `Application/DTOs/Requests/CreateCrewRequest.swift`
  - `Application/DTOs/Requests/UpdateCrewRequest.swift`
  - `Application/DTOs/Requests/CreateCellRequest.swift`
  - `Application/DTOs/Requests/UpdateCellRequest.swift`
  - `Application/DTOs/Requests/GetMonthlyScheduleRequest.swift`
  - `Application/DTOs/Requests/ExportScheduleRequest.swift`
  - `Application/DTOs/Requests/DeleteFromCalendarRequest.swift`

- [x] **Step 4.2**: Response DTOを実装する
  - `Application/DTOs/Responses/CrewResponse.swift`
  - `Application/DTOs/Responses/CellResponse.swift`
  - `Application/DTOs/Responses/MonthlyScheduleResponse.swift`
  - `Application/DTOs/Responses/WorkScheduleResponse.swift`

- [x] **Step 4.3**: CalendarExportServiceProtocolを定義する
  - `Domain/Ports/CalendarExportServiceProtocol.swift`
  - `Domain/Ports/IcsGeneratorProtocol.swift` (追加)

- [x] **Step 4.4**: CrewApplicationServiceを実装する
  - `Application/Services/CrewApplicationService.swift`
  - 連鎖削除ロジックを含む

- [x] **Step 4.5**: CellApplicationServiceを実装する
  - `Application/Services/CellApplicationService.swift`

- [x] **Step 4.6**: ScheduleApplicationServiceを実装する
  - `Application/Services/ScheduleApplicationService.swift`

- [x] **Step 4.7**: ExportApplicationServiceを実装する
  - `Application/Services/ExportApplicationService.swift`

- [x] **Step 4.8**: ICS生成ロジックを実装する
  - `Infrastructure/IcsGenerator.swift`

### Phase 5: テスト

- [ ] **Step 5.1**: 各Application Serviceのユニットテスト作成
- [ ] **Step 5.2**: 統合テスト作成

---

## ユーザーストーリーとApplication Serviceの対応表

| ユーザーストーリー | Application Service | メソッド |
|------------------|---------------------|---------|
| US-1.1: クルー一覧表示 | CrewApplicationService | listCrews() |
| US-1.2: クルー新規作成 | CrewApplicationService | createCrew() |
| US-1.3: クルー編集 | CrewApplicationService | updateCrew() |
| US-1.4: クルー削除 | CrewApplicationService | deleteCrew() |
| US-1.5: クルー選択 | （UI層で処理） | - |
| US-2.1: セル一覧表示 | CellApplicationService | listCellsByCrewId() |
| US-2.2: セル新規作成 | CellApplicationService | createCell() |
| US-2.3: セル編集 | CellApplicationService | updateCell() |
| US-2.4: セル削除 | CellApplicationService | deleteCell() |
| US-2.5: セル選択 | （UI層で処理） | - |
| US-2.6: クルー管理へ戻る | （UI層で処理） | - |
| US-3.1: 月次カレンダー表示 | ScheduleApplicationService | getMonthlySchedule() |
| US-3.2: 月切り替え | ScheduleApplicationService | getMonthlySchedule() |
| US-3.3: 当日ハイライト | （UI層で処理） | - |
| US-3.4: 勤務種別色分け | （UI層で処理） | - |
| US-3.5: セル管理へ戻る | （UI層で処理） | - |
| US-4.1: エクスポート期間設定 | （UI層で処理、ExportPeriod ValueObject） | - |
| US-4.2: ICSダウンロード | ExportApplicationService | generateIcsFile() |
| US-4.3: カレンダーエクスポート | ExportApplicationService | exportToCalendar() |
| US-4.4: カレンダーから削除 | ExportApplicationService | deleteFromCalendar() |

---

## 依存関係

```
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
├─────────────────────────────────────────────────────────────┤
│  CrewApplicationService      CellApplicationService         │
│   └─ 連鎖削除ロジック                                        │
│  ScheduleApplicationService  ExportApplicationService       │
│  DTOs (Requests, Responses)                                 │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────────┐
│ Domain Layer  │    │    Ports      │    │ Infrastructure    │
├───────────────┤    ├───────────────┤    ├───────────────────┤
│ Entities:     │    │ CrewRepo      │◀───│ CrewRepository    │
│  - Crew       │    │ Protocol      │    │ (InMemory)        │
│  - Cell       │    │               │    │                   │
│               │    │ CellRepo      │◀───│ CellRepository    │
│ ValueObjects: │    │ Protocol      │    │ (InMemory)        │
│  - ShiftType  │    │               │    │                   │
│  - RoundType  │    │ CalendarExport│◀───│ CalendarService   │
│  - Cycle...   │    │ Protocol (新規)│   │ (新規)            │
│  - Work...    │    └───────────────┘    │                   │
│  - Export...  │                         │ IcsGenerator      │
│               │                         │ (新規)            │
│ Services:     │                         └───────────────────┘
│  - Schedule   │
│    Calculator │
└───────────────┘
```

---

## ファイル構成（予定）

```
App/App/
├── Application/
│   ├── DTOs/
│   │   ├── Requests/
│   │   │   ├── CreateCrewRequest.swift
│   │   │   ├── UpdateCrewRequest.swift
│   │   │   ├── CreateCellRequest.swift
│   │   │   ├── UpdateCellRequest.swift
│   │   │   ├── GetMonthlyScheduleRequest.swift
│   │   │   ├── ExportScheduleRequest.swift
│   │   │   └── DeleteFromCalendarRequest.swift
│   │   └── Responses/
│   │       ├── CrewResponse.swift
│   │       ├── CellResponse.swift
│   │       ├── MonthlyScheduleResponse.swift
│   │       └── WorkScheduleResponse.swift
│   └── Services/
│       ├── CrewApplicationService.swift      ← 連鎖削除ロジックを含む
│       ├── CellApplicationService.swift
│       ├── ScheduleApplicationService.swift
│       └── ExportApplicationService.swift
├── Domain/
│   └── Ports/
│       └── CalendarExportServiceProtocol.swift (新規)
└── Infrastructure/
    ├── CalendarService.swift (新規・将来実装、Google等の具体実装)
    └── IcsGenerator.swift (新規)
```

---

## 備考

- 画面遷移やUIに関するユーザーストーリー（US-1.5, US-2.5, US-2.6, US-3.3, US-3.4, US-3.5, US-4.1）はUI/Presentation層の責務となるため、Application層では直接扱わない
- Application層はドメインロジックの調整役として、トランザクション境界や権限チェックなどを担当する
- **連鎖削除（クルー削除時のセル削除）はビジネスルールとしてApplication層で処理する**
- 外部カレンダー連携は`CalendarExportServiceProtocol`で抽象化し、Google Calendar等の具体実装はInfrastructure層に配置（「Google」等の具体名は使用しない）
- ICS生成はInfrastructure層に`IcsGenerator`として実装予定
- DTO構成はRequest/Response分離方式を採用