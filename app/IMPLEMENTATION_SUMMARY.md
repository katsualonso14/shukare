# 罪悪感ゼロの早起き体験 - 実装完了

## 📋 実装概要

「寝坊してもアプリを開きたくなる」優しい設計の早起きアプリのデータ構造とロジックを刷新しました。

## ✨ 新しい4つのステータス

### 1. **Achieved (達成)** ✨
- 目標時間内に起きられた
- メッセージ: 「すごい！目標時間に起きられたね！」

### 2. **NearMiss (惜しい)** 💪
- 目標から30分以内の遅刻
- メッセージ: 「おしい！あと一歩で完全勝利だったね！」

### 3. **Resting (公式お休み)** 🌙
- ユーザーが事前に「今日は休む」と決めた日
- メッセージ: 「今日は公式リフレッシュ日。明日からまた頑張ろう」

### 4. **Tried (記録の継続)** 🌱
- 大幅な遅刻だが、アプリを開いて記録した
- メッセージ: 「お昼だけど記録して偉い！自分と向き合えてる証拠だよ」

## 🏗️ アーキテクチャ

### Domain層
- `WakeUpStatus` (Enum): 4つのステータス定義
- `WakeUpRecord` (Entity): 日付 + ステータス + 実際の起床時刻
- `TargetWakeUpTime` (Entity): 目標起床時刻（時・分）
- `WakeUpRecordRepository`: 記録の永続化インターフェース

### UseCase層
1. `RecordWakeUpUsecase`: 起床を記録（ステータス自動判定）
2. `ToggleRestingModeUsecase`: 「お休みモード」の切り替え
3. `GetWakeUpRecordsUsecase`: すべての記録を取得
4. `ClearWakeUpRecordsUsecase`: すべての記録をクリア
5. `GetTargetWakeUpTimeUsecase`: 目標時刻を取得
6. `SetTargetWakeUpTimeUsecase`: 目標時刻を設定

### Infrastructure層
- `PreferenceDatasource`: SharedPreferencesへの保存・読み込み
- `WakeUpRecordRepositoryImpl`: Repository実装

### Presentation層
- `WakeUpRecordsNotifier`: 記録の状態管理
- `TargetWakeUpTimeNotifier`: 目標時刻の状態管理
- `encouragementMessageProvider`: ステータス別メッセージ提供

## 📊 データ構造

### JSON形式での保存例

```json
{
  "2026-03-28": {
    "date": "2026-03-28",
    "status": "achieved",
    "actualWakeUpTime": "2026-03-28T05:55:00.000"
  },
  "2026-03-27": {
    "date": "2026-03-27",
    "status": "nearMiss",
    "actualWakeUpTime": "2026-03-27T06:25:00.000"
  },
  "2026-03-26": {
    "date": "2026-03-26",
    "status": "resting",
    "actualWakeUpTime": null
  }
}
```

## 🔧 主要なAPI

### 起床を記録する

```dart
// 現在時刻で記録（自動判定）
final record = await ref.read(wakeUpRecordsProvider.notifier).recordWakeUp();

// 特定の時刻で記録
final record = await ref.read(wakeUpRecordsProvider.notifier)
    .recordWakeUp(actualTime: DateTime(2026, 3, 28, 6, 20));
```

### お休みモードを切り替える

```dart
// 今日をお休みに設定/解除
await ref.read(wakeUpRecordsProvider.notifier)
    .toggleRestingMode(DateTime.now());
```

### 目標時刻を変更する

```dart
// 目標を7:00に変更
await ref.read(targetWakeUpTimeProvider.notifier).update(7, 0);
```

### ステータスから優しいメッセージを取得

```dart
final message = ref.watch(encouragementMessageProvider(WakeUpStatus.nearMiss));
// -> 「おしい！あと一歩で完全勝利だったね！」
```

## 📁 作成されたファイル一覧

### Domain Entity
- `lib/domain/entity/wake_up_status.dart`
- `lib/domain/entity/wake_up_record.dart`
- `lib/domain/entity/target_wake_up_time.dart`

### Domain Repository
- `lib/domain/repository/wake_up_record_repository.dart`

### Domain UseCase
- `lib/domain/usecase/record_wake_up_usecase.dart`
- `lib/domain/usecase/toggle_resting_mode_usecase.dart`
- `lib/domain/usecase/get_wake_up_records_usecase.dart`
- `lib/domain/usecase/clear_wake_up_records_usecase.dart`
- `lib/domain/usecase/get_target_wake_up_time_usecase.dart`
- `lib/domain/usecase/set_target_wake_up_time_usecase.dart`

### Infrastructure
- `lib/infrastructure/repository/wake_up_record_repository_impl.dart`
- `lib/infrastructure/datasource/preference_datasource.dart` (拡張)

### Presentation
- `lib/presentation/providers/wake_up_records_provider.dart`
- `lib/presentation/providers/target_wake_up_time_provider.dart`
- `lib/presentation/providers/encouragement_provider.dart`

### DI
- `lib/infrastructure/di/infrastructure_providers.dart` (拡張)
- `lib/presentation/di/presentation_providers.dart` (拡張)

## 🎯 次のステップ（UI実装）

現在は **データ層・ロジック層** が完成しました。

次は **UI層の実装** として、以下を行う必要があります：

1. **カレンダーセルの拡張**: `DayCell` で4種類のステータスを表示
2. **ボトムシートの拡張**: 記録ボタン + お休みモード切り替えボタン
3. **メッセージ表示**: ステータスに応じた優しいメッセージの表示
4. **目標時刻設定画面**: 設定画面に目標起床時刻の設定UIを追加

既存の `CheckedDatesProvider` との共存も可能ですが、最終的には新しい `WakeUpRecordsProvider` に移行することをお勧めします。

---

実装は完了しました！UI側の実装を進める準備が整いました 🎉
