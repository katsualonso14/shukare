import '../entity/notification_settings.dart';

/// 通知設定の永続化・スケジュール（Domain Repository インターフェース）
abstract class NotificationSettingsRepository {
  Future<NotificationSettings> get();
  Future<void> setEnabled(bool enabled);
  Future<void> setTime(int hour, int minute);
}
