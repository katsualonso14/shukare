import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/service/daily_achievement_service.dart';
import '../../infrastructure/di/infrastructure_providers.dart';
import '../di/presentation_providers.dart';
import 'calendar_week_start_provider.dart';
import 'target_wake_up_time_provider.dart';
import 'wake_up_records_provider.dart';

/// 今日のぶんをまだ出していないか
final shouldShowDailyAchievementProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(dailyAchievementServiceProvider);
  final datasource = ref.watch(preferenceDatasourceProvider);
  return service.shouldShow(
    now: DateTime.now(),
    lastShownDate: datasource.getDailyAchievementLastShown(),
  );
});

/// 出す条件を満たしていれば材料を返す。出さないなら null。
final dailyAchievementProvider =
    FutureProvider<DailyAchievement?>((ref) async {
  final shouldShow = await ref.watch(shouldShowDailyAchievementProvider.future);
  if (!shouldShow) return null;

  final service = ref.watch(dailyAchievementServiceProvider);
  final records = await ref.watch(wakeUpRecordsProvider.future);
  final targetTime = await ref.watch(targetWakeUpTimeProvider.future);
  final weekStartSunday = ref.watch(calendarWeekStartSundayProvider);

  return service.build(
    now: DateTime.now(),
    allRecords: records,
    targetTime: targetTime,
    weekStartSunday: weekStartSunday,
  );
});

class DailyAchievementNotifier extends StateNotifier<DateTime?> {
  DailyAchievementNotifier(this._ref) : super(null);
  final Ref _ref;

  Future<void> markAsShown() async {
    final datasource = _ref.read(preferenceDatasourceProvider);
    final now = DateTime.now();
    await datasource.setDailyAchievementLastShown(now);
    state = now;
    _ref.invalidate(shouldShowDailyAchievementProvider);
  }
}

final dailyAchievementNotifierProvider =
    StateNotifierProvider<DailyAchievementNotifier, DateTime?>((ref) {
  return DailyAchievementNotifier(ref);
});
