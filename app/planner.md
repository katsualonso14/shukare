# App Planner

## アプリ概要

「罪悪感ゼロの早起き体験」をコンセプトにした習慣管理アプリ。  
起床時刻を記録し、カレンダーで可視化。MBTI別のパーソナライズメッセージで継続を支援する。

---

## 現在の状態（実装済み）

### Domain
- `WakeUpStatus`: `success` / `failed` / `none`（旧4状態から統合済み）
- `WakeUpRecord`: 日付 + ステータス + 実際の起床時刻
- `UserProfile`: MBTI + `PersonaType`（4種）
- Use cases: 記録・削除・クリア・目標時刻CRUD・自動判定

### Infrastructure
- `PreferenceDatasource`: SharedPreferences（JSON形式で`Map<String,WakeUpRecord>`保存）
- `NotificationScheduleDatasource`: 毎日指定時刻に通知

### Presentation
- `CalendarScreen`: 月表示カレンダー、起動時に`autoEvaluateToday()`実行
- `DayCell`: チェックマークスタイル切り替え対応（`CheckMarkStyle` enum）
- `SettingsScreen`: 通知設定・MBTI/ペルソナ設定・目標時刻設定
- `DateDetailBottomSheet`: 日付タップ時の詳細表示
- `WeeklyReportDialog`: 週次レポートダイアログ
- `PersonalizedMessageProvider`: 連続失敗日数 × ペルソナ別メッセージ

### 注意点
- `CheckedDates`（習慣チェック）と`WakeUpRecords`（起床記録）が並存している
- 最終的には`WakeUpRecords`に一本化予定だが現時点では両方を使用中

---

## 残タスク（MVP優先順）

### P0 - 動作に必須

| タスク | 変更ファイル |
|--------|-------------|
| `DayCell`にWakeUpStatusの色表示（success=緑、failed=紫、none=ドット） | `day_cell.dart` |
| カレンダー画面の「起床記録ボタン」をメインアクションとして前面に出す | `calendar_screen.dart` |

### P1 - 体験品質

| タスク | 変更ファイル |
|--------|-------------|
| `DateDetailBottomSheet`に「今日成功」「今日失敗」「お休み」ボタンを整理 | `date_detail_bottom_sheet.dart` |
| 起床記録後のフィードバックメッセージ表示（`PersonalizedMessageProvider`から取得） | `calendar_screen.dart` |
| `print()`デバッグ文の削除 | `calendar_screen.dart` |

### P2 - 後回し可

| タスク | 備考 |
|--------|------|
| `CheckedDates`を`WakeUpRecords`に統合 | 破壊的変更。データ移行ロジックが必要 |
| `widget_test.dart`の修正 | 現在のスモークテストは動かない |
| チェックスタイルをユーザーが設定から変更できるUI | `CheckMarkStyle`の設定画面への紐付け |

---

## アーキテクチャ制約（変更禁止）

- Domain層はFlutter/外部パッケージに依存しない
- `sharedPreferencesProvider`は`main.dart`でのみoverride
- 新しい永続化データは`PreferenceDatasource`に追加（datasourceを増やさない）
- 新しいUse caseは`presentation_providers.dart`にProvider登録が必要

---

## データ設計メモ

- 日付キー: `yyyy-MM-dd`文字列
- `success`判定: 目標時刻 ±30分以内
- `failed`判定: 目標時刻から30分超
- 自動判定: アプリ起動時に`AutoEvaluateWakeUpUsecase`が当日未記録なら実行
