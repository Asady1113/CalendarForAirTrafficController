# ドメインモデル実装計画

## 概要
ドメインモデルのドキュメントに基づいて、シンプルで直感的な実装を生成する。

---

## 事前確認事項

[Question] 実装に使用するプログラミング言語は何ですか？
- a) TypeScript
- b) JavaScript
- c) Python
- d) その他

[Answer]
- SwiftUI

[Question] 生成するコードの出力先ディレクトリはどこですか？（例: `src/domain/`）

[Answer]
/Users/asadatomoya/Desktop/Calendar/App/App/Domain

[Question] エンティティのID生成方法はどうしますか？
- a) UUID（crypto.randomUUID()等）
- b) 連番（インメモリカウンター）
- c) 外部から渡す（ファクトリパターン）

[Answer]
- UUID

[Question] Swiftの慣例に合わせてプロパティにするか、ドキュメント通りメソッドにするか？
- a) Swiftの慣例に合わせてプロパティ（`var startTime: Time?`）
- b) ドキュメント通りメソッド（`func getStartTime() -> Time?`）

[Answer]
- プロパティ

[Question] Entityのcreate/update/deleteメソッドはどのように実装しますか？
- a) 案A: staticファクトリ + コピーメソッド
- b) 案B: イニシャライザ + mutatingメソッド
- c) 案C: シンプルなstruct（振る舞いなし、create/update/deleteはリポジトリやユースケース層の責務）

[Answer]
- 案C

---

## 実装対象コンポーネント

ドキュメントから特定したコンポーネント：

| コンポーネント | 種別 | ファイル名 |
|---------------|------|-----------|
| ShiftType | ValueObject (enum) | ValueObjects/ShiftType.swift |
| RoundType | ValueObject (enum) | ValueObjects/RoundType.swift |
| CycleConfiguration | ValueObject (struct) | ValueObjects/CycleConfiguration.swift |
| WorkSchedule | ValueObject (struct) | ValueObjects/WorkSchedule.swift |
| ExportPeriod | ValueObject (struct) | ValueObjects/ExportPeriod.swift |
| Crew | Entity (class) | Entities/Crew.swift |
| Cell | Entity (class) | Entities/Cell.swift |
| ScheduleCalculator | DomainService (struct) | Services/ScheduleCalculator.swift |
| CrewRepositoryProtocol | Port (protocol) | Ports/CrewRepositoryProtocol.swift |
| CellRepositoryProtocol | Port (protocol) | Ports/CellRepositoryProtocol.swift |
| CrewRepository | Repository (class) | Infrastructure/CrewRepository.swift |
| CellRepository | Repository (class) | Infrastructure/CellRepository.swift |

---

## 実装ステップ

### Phase 1: ValueObject
- [x] **Step 1**: ShiftType（勤務種別）の実装
  - E1, A, B, E2, C, POST_NIGHT, OFF, B4 の8種類
  - startTime, endTime プロパティ（computed property）

- [x] **Step 2**: RoundType（ラウンド種別）の実装
  - WITH_NIGHT, WITHOUT_NIGHT, WITHOUT_NIGHT_B4 の3種類
  - shiftPattern プロパティ（computed property）

- [x] **Step 3**: CycleConfiguration（サイクル構成）の実装
  - rounds: [RoundType] (7要素)
  - isValid プロパティ（computed property）

- [x] **Step 4**: WorkSchedule（勤務予定）の実装
  - date: Date, shiftType: ShiftType

- [x] **Step 5**: ExportPeriod（エクスポート期間）の実装
  - startDate: Date, endDate: Date
  - isValid プロパティ（computed property）

### Phase 2: Entity
- [x] **Step 6**: Crew（クルー）の実装
  - id: UUID, name: String, cycleStartDate: Date

- [x] **Step 7**: Cell（セル）の実装
  - id: UUID, name: String, crewId: UUID, cycleConfiguration: CycleConfiguration

### Phase 3: Port（Domain層）
- [x] **Step 8**: CrewRepositoryProtocol の定義
  - save(), findById(), findAll(), delete()

- [x] **Step 9**: CellRepositoryProtocol の定義
  - save(), findById(), findByCrewId(), findAll(), delete()
  - deleteByCrewId()

### Phase 4: Repository 実装（Infrastructure層）
- [x] **Step 10**: CrewRepository の実装
  - CrewRepositoryProtocol に準拠
  - 連鎖削除: Crew削除時にCellも削除

- [x] **Step 11**: CellRepository の実装
  - CellRepositoryProtocol に準拠

### Phase 5: DomainService
- [x] **Step 12**: ScheduleCalculator の実装
  - calculateForMonth(cell:, crew:, year:, month:) -> [WorkSchedule]
  - calculateForPeriod(cell:, crew:, period:) -> [WorkSchedule]

---

## 出力先
```
/Users/asadatomoya/Desktop/Calendar/App/App/Domain/
├── ValueObjects/
│   ├── ShiftType.swift
│   ├── RoundType.swift
│   ├── CycleConfiguration.swift
│   ├── WorkSchedule.swift
│   └── ExportPeriod.swift
├── Entities/
│   ├── Crew.swift
│   └── Cell.swift
├── Ports/
│   ├── CrewRepositoryProtocol.swift
│   └── CellRepositoryProtocol.swift
└── Services/
    └── ScheduleCalculator.swift

/Users/asadatomoya/Desktop/Calendar/App/App/Infrastructure/
├── CrewRepository.swift
└── CellRepository.swift
```

---

## 備考

- ディレクトリは種別ごとに分類（ValueObjects, Entities, Ports, Services）
- Port（protocol）はDomain層、Repository実装はInfrastructure層に配置
- Swift標準のFoundationフレームワークを使用（Date, UUID等）
- リポジトリはインメモリ実装（Dictionary使用）
- 各コンポーネントは個別ファイルに生成
- Entityはclassで実装（参照型、同一性の担保）
- ValueObjectはstructで実装（不変性の担保）
- Repositoryはclassで実装（参照型、状態保持のため）
- getterはSwift慣例に従いcomputed propertyで実装
- Entityのcreate/update/deleteはリポジトリ層の責務として実装