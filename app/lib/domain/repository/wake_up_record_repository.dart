import '../entity/wake_up_record.dart';
import '../entity/target_wake_up_time.dart';

/// 起床記録の永続化（Domain Repository インターフェース）
abstract class WakeUpRecordRepository {
  /// すべての記録を取得（Map<日付キー, 記録>）
  Future<Map<String, WakeUpRecord>> loadAll();

  /// 特定の日の記録を取得
  Future<WakeUpRecord?> load(String dateKey);

  /// 記録を保存（上書き）
  Future<void> save(WakeUpRecord record);

  /// すべての記録をクリア
  Future<void> clearAll();

  /// 特定の日の記録を削除
  Future<void> delete(String dateKey);

  /// 目標起床時刻を取得
  Future<TargetWakeUpTime> getTargetTime();

  /// 目標起床時刻を保存
  Future<void> saveTargetTime(TargetWakeUpTime time);
}
