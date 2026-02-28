# ドメインモデル概要

## コンポーネント一覧

| コンポーネント名 | 種別 | 関連ストーリー | 説明 |
|-----------------|------|---------------|------|
| Crew（クルー） | Entity | US-1.1〜US-1.5 | 勤務サイクルの基準となるグループ |
| Cell（セル） | Entity | US-2.1〜US-2.6 | クルーに紐づく勤務パターン単位 |
| CycleConfiguration（サイクル構成） | ValueObject | US-2.2, US-2.3 | セルに紐づく7ラウンドの構成（Cellの一部） |
| Round（ラウンド） | ValueObject | US-2.2, US-2.3 | サイクル内の1ラウンド（6日間）の種別 |
| WorkSchedule（勤務予定） | ValueObject | US-3.1〜US-3.5, US-4.1〜US-4.4 | 都度計算される日ごとの勤務予定 |
| ShiftType（勤務種別） | Enum | US-3.1, US-3.4, US-4.2, US-4.3 | E1, A, B, C, E2, 明け, 休み, B4 |
| ExportPeriod（エクスポート期間） | ValueObject | US-4.1〜US-4.4 | エクスポート対象の開始日・終了日 |
| ScheduleCalculator | DomainService | US-3.1, US-4.1〜US-4.4 | 勤務予定の計算 |

---

## 関連図（テキスト表現）

```
Crew (1) ─────── (0..7) Cell (1) ─────── (1) CycleConfiguration (1) ─────── (7) RoundType (1) ─────── (6) ShiftType


ScheduleCalculator ─── uses ──→ Crew (cycleStartDate)
         │
         └─── uses ──→ Cell (cycleConfiguration)
         │
         └─── produces ──→ WorkSchedule (date, shiftType)
```

---

## 関連の詳細

| 関連 | 多重度 | 説明 |
|-----|-------|------|
| Crew → Cell | 1 : 0..7 | 1つのクルーは最大7つのセルを持つ |
| Cell → CycleConfiguration | 1 : 1 | 1つのセルは1つのサイクル構成を持つ |
| CycleConfiguration → RoundType | 1 : 7 | サイクル構成は7つのラウンド種別を順序付きで持つ |
| RoundType → ShiftType | 1 : 6 | 各ラウンド種別は6日間の勤務種別パターンを定義する |
| WorkSchedule → ShiftType | * : 1 | 勤務予定は1つの勤務種別を持つ |

---

## 依存の詳細

| 依存元 | 依存先 | 説明 |
|-------|-------|------|
| ScheduleCalculator | Crew | cycleStartDateを取得 |
| ScheduleCalculator | Cell | cycleConfigurationを取得 |
| ScheduleCalculator | CycleConfiguration | ラウンド種別の配列を参照 |
| ScheduleCalculator | RoundType | 6日間のShiftTypeパターンを取得 |
| ScheduleCalculator | WorkSchedule | 計算結果として生成 |
| Cell | Crew | crewIdで所属クルーを参照 |

---

## 連鎖削除

| 操作 | 影響 |
|-----|------|
| CrewRepository.delete() | 所属する全Cellも削除される |

---

## ExportPeriod（エクスポート期間） - ValueObject

### 属性
| 属性名 | 型 | 説明 |
|-------|-----|------|
| startDate | Date | エクスポート開始日 |
| endDate | Date | エクスポート終了日 |

### 振る舞い
| メソッド名 | 引数 | 戻り値 | 説明 | 関連US |
|-----------|------|--------|------|--------|
| validate | - | boolean | 開始日 ≤ 終了日 を検証する | US-4.1 |