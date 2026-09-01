import '../entity/notification_settings.dart';
import '../repository/notification_settings_repository.dart';

class GetNotificationSettingsUsecase {
  GetNotificationSettingsUsecase(this._repository);
  final NotificationSettingsRepository _repository;

  Future<NotificationSettings> call() => _repository.get();
}
