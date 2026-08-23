# ドメインモデル設計 作業計画

## 目的
ユーザーストーリー（US-1.1〜US-4.4）を実装するためのドメインモデルを設計する。
このモデルには、コンポーネント、属性、振る舞い、およびコンポーネント間の相互作用を含める。

---

## 作業ステップ

- [x] **Step 1**: ドメインモデルの主要コンポーネントを特定する
- [x] **Step 2**: 各コンポーネントの属性を定義する
- [x] **Step 3**: 各コンポーネントの振る舞い（メソッド）を定義する
- [x] **Step 4**: コンポーネント間の相互作用（関連・依存）を定義する
- [x] **Step 5**: ドメインモデルを個別のmdファイルに記載する

---

## Step 1: ドメインモデルの主要コンポーネント特定

### 分析対象ユーザーストーリー

| ユニット | ストーリー |
|----------|-----------|
| クルー管理 | US-1.1〜US-1.5 |
| セル管理 | US-2.1〜US-2.6 |
| 勤務予定表示 | US-3.1〜US-3.5 |
| エクスポート | US-4.1〜US-4.4 |

### 抽出候補コンポーネント

ユーザーストーリーから抽出した候補コンポーネント：

| コンポーネント名 | 種別 | 関連ストーリー | 説明 |
|-----------------|------|---------------|------|
| Crew（クルー） | Entity | US-1.1〜US-1.5 | 勤務サイクルの基準となるグループ |
| Cell（セル） | Entity | US-2.1〜US-2.6 | クルーに紐づく勤務パターン単位 |
| CycleConfiguration（サイクル構成） | ValueObject | US-2.2, US-2.3 | セルに紐づく7ラウンドの構成（Cellの一部） |
| Round（ラウンド） | ValueObject | US-2.2, US-2.3 | サイクル内の1ラウンド（6日間）の種別 |
| WorkSchedule（勤務予定） | ValueObject | US-3.1〜US-3.5, US-4.1〜US-4.4 | 都度計算される日ごとの勤務予定 |
| ShiftType（勤務種別） | Enum | US-3.1, US-3.4, US-4.2, US-4.3 | E1, A, B, C, E2, 明け, 休み, B4 |
| ExportPeriod（エクスポート期間） | ValueObject | US-4.1〜US-4.4 | エクスポート対象の開始日・終了日 |

[Question] コンポーネントの種別（Entity / ValueObject / DomainService）の分類について確認させてください：
- CycleConfiguration: 独立したEntityとして扱うか、Cellの一部（ValueObject）として扱うか？
- ShiftSchedule: 永続化が必要なEntityか、都度計算されるValueObjectか？

[Answer]
以下の理由です。違和感があれば指摘してください。
- CycleConfiguration: ValueObjectでいいと思っています。理由は、セルの一部であることと、サイクル構成の中身が同じであれば同値、異なれば別値であるとみなしていいからだ（ID不要）。
- ShiftSchedule: 都度計算されるValueObjectです。こちらもスケジュールの中身が同じであれば同値、違えば別値として見做していいことからも、ValueObjectに近いと思います。
---

## Step 2: 属性定義に関する確認事項

[Question] 42日サイクルの計算ロジックについて、以下の詳細を確認させてください：

### Q1: ラウンドの種別と勤務パターンの対応
「夜勤あり」「夜勤なし」「夜勤なし・B4あり」の各種別で、6日間の勤務パターン（E1, A, B, C, E2, 明け, 休み, B4の並び順）はどのようになりますか？

[Answer]
ここ見ればわかります。
/Users/asadatomoya/Desktop/Calendar/Docs/Requirements/03_Ubiquitous.md


### Q2: 勤務時間について
各勤務種別（E1, A, B, C, E2, 明け, 休み, B4）には、それぞれ固定の勤務時間がありますか？ある場合は各種別の開始時刻と終了時刻を教えてください。

[Answer]
ここ見ればわかります。
/Users/asadatomoya/Desktop/Calendar/Docs/Requirements/03_Ubiquitous.md

### Q3: 祝日データについて
US-3.4で「土曜日・日曜日・祝日が識別できる色で表示される」とありますが、祝日データはどのように取得しますか？
- a) 外部APIから取得
- b) アプリ内に固定データとして保持
- c) その他

[Answer]
あ、ごめんいらんわこの機能。Unit、UserStoryから消しておいてほしい

---

## Step 2: 各コンポーネントの属性定義

### Crew（クルー） - Entity
| 属性名 | 型 | 説明 |
|-------|-----|------|
| id | ID | 一意識別子 |
| name | String | クルー名 |
| cycleStartDate | Date | サイクル開始日（42日サイクルの起算日） |

### Cell（セル） - Entity
| 属性名 | 型 | 説明 |
|-------|-----|------|
| id | ID | 一意識別子 |
| name | String | セル名 |
| crewId | ID | 所属クルーへの参照 |
| cycleConfiguration | CycleConfiguration | サイクル構成（ValueObject） |

### CycleConfiguration（サイクル構成） - ValueObject
| 属性名 | 型 | 説明 |
|-------|-----|------|
| rounds | RoundType[7] | 7つのラウンド種別の配列（順序付き） |

### RoundType（ラウンド種別） - Enum
| 値 | 説明 | 6日間のパターン |
|----|------|----------------|
| WITH_NIGHT | 夜勤ありラウンド | E1 → A → B → C → POST_NIGHT → OFF |
| WITHOUT_NIGHT | 夜勤なしラウンド | OFF → A → B → E2 → OFF → OFF |
| WITHOUT_NIGHT_B4 | 夜勤なし・B4ありラウンド | OFF → A → B → E2 → B4 → OFF |

### ShiftType（勤務種別） - Enum
| 値 | 日本語名 | 開始時刻 | 終了時刻 |
|----|---------|---------|---------|
| E1 | 早番① | 06:45 | 15:00 |
| A | 早番② | 07:30 | 16:45 |
| B | 遅番① | 12:00 | 21:15 |
| E2 | 遅番② | 14:00 | 22:15 |
| C | 夜勤 | 19:30 | 翌08:15 |
| POST_NIGHT | 明け | - | - |
| OFF | 休み | - | - |
| B4 | 遅番①（B4） | 12:00 | 21:15 |

### WorkSchedule（勤務予定） - ValueObject
| 属性名 | 型 | 説明 |
|-------|-----|------|
| date | Date | 日付 |
| shiftType | ShiftType | 勤務種別 |

### ExportPeriod（エクスポート期間） - ValueObject
| 属性名 | 型 | 説明 |
|-------|-----|------|
| startDate | Date | エクスポート開始日 |
| endDate | Date | エクスポート終了日 |

---

## Step 3: 各コンポーネントの振る舞い定義

### Crew（クルー） - Entity
※ Entityは属性のみを持つデータ構造として実装。
※ create, update, delete 操作は CrewRepository の責務として実装する。

### Cell（セル） - Entity
※ Entityは属性のみを持つデータ構造として実装。
※ create, update, delete 操作は CellRepository の責務として実装する。

### CycleConfiguration（サイクル構成） - ValueObject
| メソッド名 | 引数 | 戻り値 | 説明 | 関連US |
|-----------|------|--------|------|--------|
| validate | - | boolean | サイクル制約を満たすか検証する（※1） ※本機能は仕様から除外（未実装） | US-2.2, US-2.3 |

**※1 サイクル制約：**
- 7ラウンド中、夜勤ありラウンドが1回だけ連続する箇所がある
- 7ラウンド中、夜勤なし・B4ありラウンドが1回だけ出現する

### RoundType（ラウンド種別） - Enum
| メソッド名 | 引数 | 戻り値 | 説明 | 関連US |
|-----------|------|--------|------|--------|
| getShiftPattern | - | ShiftType[6] | 6日間の勤務種別パターンを返す | US-3.1 |

### ShiftType（勤務種別） - Enum
| メソッド名 | 引数 | 戻り値 | 説明 | 関連US |
|-----------|------|--------|------|--------|
| getStartTime | - | Time? | 勤務開始時刻を返す（明け・休みはnull） | US-4.2, US-4.3 |
| getEndTime | - | Time? | 勤務終了時刻を返す（明け・休みはnull） | US-4.2, US-4.3 |

### WorkSchedule（勤務予定） - ValueObject
※ WorkSchedule自体は振る舞いを持たないデータ構造

### ScheduleCalculator - DomainService
| メソッド名 | 引数 | 戻り値 | 説明 | 関連US |
|-----------|------|--------|------|--------|
| calculateForMonth | cell, crew, year, month | List<WorkSchedule> | 指定月の勤務予定を計算する | US-3.1 |
| calculateForPeriod | cell, crew, period | List<WorkSchedule> | 指定期間の勤務予定を計算する | US-4.1〜US-4.4 |

**計算ロジック：**
1. 対象日とサイクル開始日の差分を計算
2. 差分を42で割った余りでサイクル内の日目を特定
3. 日目を6で割ってラウンド番号と日番号を特定
4. CycleConfigurationから該当ラウンドの種別を取得
5. RoundTypeから該当日の勤務種別を取得

### ExportPeriod（エクスポート期間） - ValueObject
| メソッド名 | 引数 | 戻り値 | 説明 | 関連US |
|-----------|------|--------|------|--------|
| validate | - | boolean | 開始日 ≤ 終了日 を検証する | US-4.1 |

---

## Step 4: コンポーネント間の相互作用

### 関連図（テキスト表現）

```
Crew (1) ─────── (0..7) Cell (1) ─────── (1) CycleConfiguration (1) ─────── (7) RoundType (1) ─────── (6) ShiftType


ScheduleCalculator ─── uses ──→ Crew (cycleStartDate)
         │
         └─── uses ──→ Cell (cycleConfiguration)
         │
         └─── produces ──→ WorkSchedule (date, shiftType)
```

### 関連の詳細

| 関連 | 多重度 | 説明 |
|-----|-------|------|
| Crew → Cell | 1 : 0..7 | 1つのクルーは最大7つのセルを持つ |
| Cell → CycleConfiguration | 1 : 1 | 1つのセルは1つのサイクル構成を持つ |
| CycleConfiguration → RoundType | 1 : 7 | サイクル構成は7つのラウンド種別を順序付きで持つ |
| RoundType → ShiftType | 1 : 6 | 各ラウンド種別は6日間の勤務種別パターンを定義する |
| WorkSchedule → ShiftType | * : 1 | 勤務予定は1つの勤務種別を持つ |

### 依存の詳細

| 依存元 | 依存先 | 説明 |
|-------|-------|------|
| ScheduleCalculator | Crew | cycleStartDateを取得 |
| ScheduleCalculator | Cell | cycleConfigurationを取得 |
| ScheduleCalculator | CycleConfiguration | ラウンド種別の配列を参照 |
| ScheduleCalculator | RoundType | 6日間のShiftTypeパターンを取得 |
| ScheduleCalculator | WorkSchedule | 計算結果として生成 |
| Cell | Crew | crewIdで所属クルーを参照 |

### 連鎖削除

| 操作 | 影響 |
|-----|------|
| CrewRepository.delete() | 所属する全Cellも削除される |

---

## Step 5: 詳細設計

コンポーネントの詳細をmdファイルに記載します。

---

## 成果物

以下のファイルを `aidlc-docs/construction/` フォルダに作成予定：

| ファイル名 | 内容 |
|-----------|------|
| `domain_model_overview.md` | ドメインモデル全体図、相互作用、エクスポート関連ValueObject |
| `domain_model_crew.md` | Crewエンティティの詳細設計 |
| `domain_model_cell.md` | Cellエンティティ、CycleConfiguration、Roundの詳細設計 |
| `domain_model_schedule.md` | WorkSchedule、ShiftTypeの詳細設計 |

**統合理由：**
- `domain_model_cycle.md` → CycleConfiguration/RoundはCellのValueObjectなので `domain_model_cell.md` に統合
- `domain_model_export.md` → ExportPeriodはシンプルなValueObjectなので `domain_model_overview.md` に統合


---

## 備考
- アーキテクチャコンポーネント（リポジトリ、コントローラー等）は含めない
- コードは生成しない
- ビジネスロジックの振る舞いのみを記載する