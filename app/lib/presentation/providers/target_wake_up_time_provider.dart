import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/target_wake_up_time.dart';
import '../di/presentation_providers.dart';

/// 目標起床時刻を管理するProvider
final targetWakeUpTimeProvider =
    AsyncNotifierProvider<TargetWakeUpTimeNotifier, TargetWakeUpTime>(
  TargetWakeUpTimeNotifier.new,
);

class TargetWakeUpTimeNotifier extends AsyncNotifier<TargetWakeUpTime> {
  @override
  Future<TargetWakeUpTime> build() async {
    final usecase = ref.read(getTargetWakeUpTimeUsecaseProvider);
    return usecase();
  }

  /// 目標時刻を更新
  Future<void> setTargetWakeUpTime(int hour, int minute) async {
    final newTime = TargetWakeUpTime(hour: hour, minute: minute);

    // 楽観的更新
    state = AsyncData(newTime);

    try {
      final usecase = ref.read(setTargetWakeUpTimeUsecaseProvider);
      await usecase(newTime);
    } catch (e) {
      // エラー時は再読み込み
      state = await AsyncValue.guard(() async {
        final usecase = ref.read(getTargetWakeUpTimeUsecaseProvider);
        return usecase();
      });
      rethrow;
    }
  }
}
