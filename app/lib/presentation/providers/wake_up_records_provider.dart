import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/wake_up_record.dart';
import '../../domain/entity/wake_up_status.dart';
import '../di/presentation_providers.dart';

/// 起床記録を管理するProvider
final wakeUpRecordsProvider =
    AsyncNotifierProvider<WakeUpRecordsNotifier, Map<String, WakeUpRecord>>(
  WakeUpRecordsNotifier.new,
);

class WakeUpRecordsNotifier extends AsyncNotifier<Map<String, WakeUpRecord>> {
  @override
  Future<Map<String, WakeUpRecord>> build() async {
    final usecase = ref.read(getWakeUpRecordsUsecaseProvider);
    return usecase();
  }

  /// 起床を記録する（現在時刻で自動判定）
  Future<WakeUpRecord> recordWakeUp({DateTime? actualTime}) async {
    final now = actualTime ?? DateTime.now();
    final usecase = ref.read(recordWakeUpUsecaseProvider);

    final record = await usecase(now);

    // 状態を更新
    state = await AsyncValue.guard(() async {
      final current = state.valueOrNull ?? {};
      return {...current, record.dateKey: record};
    });

    return record;
  }

  /// 「今日は休む」モードを切り替え
  Future<void> toggleRestingMode(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final tempRecord = WakeUpRecord(
      date: normalizedDate,
      status: WakeUpStatus.resting,
      actualWakeUpTime: null,
    );
    final dateKey = tempRecord.dateKey;

    final usecase = ref.read(toggleRestingModeUsecaseProvider);
    final result = await usecase(normalizedDate);

    // 状態を更新
    state = await AsyncValue.guard(() async {
      final current = state.valueOrNull ?? {};
      final next = Map<String, WakeUpRecord>.from(current);

      if (result == null) {
        // 解除された場合は削除
        next.remove(dateKey);
      } else {
        // 設定された場合は追加
        next[dateKey] = result;
      }

      return next;
    });
  }

  /// すべての記録をクリア
  Future<void> clearAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(clearWakeUpRecordsUsecaseProvider);
      await usecase();
      return <String, WakeUpRecord>{};
    });
  }

  /// リフレッシュ
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(getWakeUpRecordsUsecaseProvider);
      return usecase();
    });
  }
}
