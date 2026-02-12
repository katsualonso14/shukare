import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repository/checked_dates_repository.dart';
import '../../domain/repository/notification_settings_repository.dart';
import '../datasource/notification_schedule_datasource.dart';
import '../datasource/preference_datasource.dart';
import '../repository/checked_dates_repository_impl.dart';
import '../repository/notification_settings_repository_impl.dart';

/// 永続化の注入用。main で override すること。
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

final preferenceDatasourceProvider = Provider<PreferenceDatasource>((ref) {
  return PreferenceDatasource(ref.watch(sharedPreferencesProvider));
});

final notificationScheduleDatasourceProvider =
    Provider<NotificationScheduleDatasource>((ref) {
  return NotificationScheduleDatasource();
});

final checkedDatesRepositoryProvider = Provider<CheckedDatesRepository>((ref) {
  return CheckedDatesRepositoryImpl(ref.watch(preferenceDatasourceProvider));
});

final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepositoryImpl(
    ref.watch(preferenceDatasourceProvider),
    ref.watch(notificationScheduleDatasourceProvider),
  );
});
