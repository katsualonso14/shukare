import '../../domain/entity/notification_settings.dart';
import '../../domain/repository/notification_settings_repository.dart';
import '../datasource/notification_schedule_datasource.dart';
import '../datasource/preference_datasource.dart';

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  NotificationSettingsRepositoryImpl(
    this._preference,
    this._schedule,
  );
  final PreferenceDatasource _preference;
  final NotificationScheduleDatasource _schedule;

  @override
  Future<NotificationSettings> get() async {
    return _preference.getNotificationSettings();
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    await _preference.setNotificationEnabled(enabled);
    final settings = _preference.getNotificationSettings();
    if (enabled) {
      await _schedule.scheduleDaily(
        hour: settings.hour,
        minute: settings.minute,
      );
    } else {
      await _schedule.cancelDaily();
    }
  }

  @override
  Future<void> setTime(int hour, int minute) async {
    await _preference.setNotificationTime(hour, minute);
    final settings = _preference.getNotificationSettings();
    if (settings.enabled) {
      await _schedule.scheduleDaily(hour: hour, minute: minute);
    }
  }
}
