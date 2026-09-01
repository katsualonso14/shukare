import '../entity/notification_settings.dart';
import '../repository/notification_settings_repository.dart';

class SetNotificationSettingsUsecase {
  SetNotificationSettingsUsecase(this._repository);
  final NotificationSettingsRepository _repository;

  Future<NotificationSettings> setEnabled(bool enabled) async {
    await _repository.setEnabled(enabled);
    return _repository.get();
  }

  Future<NotificationSettings> setTime(int hour, int minute) async {
    await _repository.setTime(hour, minute);
    return _repository.get();
  }
}
