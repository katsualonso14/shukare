import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/datasource/preference_datasource.dart';
import '../../infrastructure/di/infrastructure_providers.dart';

/// カレンダーの週始まり（true = 日曜、false = 月曜）
final calendarWeekStartSundayProvider =
    StateNotifierProvider<CalendarWeekStartNotifier, bool>((ref) {
  final datasource = ref.watch(preferenceDatasourceProvider);
  return CalendarWeekStartNotifier(datasource);
});

class CalendarWeekStartNotifier extends StateNotifier<bool> {
  CalendarWeekStartNotifier(this._datasource)
      : super(_datasource.getCalendarWeekStartSunday());

  final PreferenceDatasource _datasource;

  Future<void> setWeekStartSunday(bool value) async {
    await _datasource.setCalendarWeekStartSunday(value);
    state = value;
  }
}
