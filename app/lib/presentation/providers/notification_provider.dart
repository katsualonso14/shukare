import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/notification_settings.dart';
import '../di/presentation_providers.dart';

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, NotificationSettings>(
  NotificationNotifier.new,
);

class NotificationNotifier extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() async {
    final usecase = ref.read(getNotificationSettingsUsecaseProvider);
    return usecase();
  }

  Future<void> setEnabled(bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(setNotificationSettingsUsecaseProvider);
      return usecase.setEnabled(enabled);
    });
  }

  Future<void> setTime(int hour, int minute) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(setNotificationSettingsUsecaseProvider);
      return usecase.setTime(hour, minute);
    });
  }
}
