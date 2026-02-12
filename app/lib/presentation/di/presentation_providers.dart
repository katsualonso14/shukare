import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecase/get_checked_dates_usecase.dart';
import '../../domain/usecase/get_notification_settings_usecase.dart';
import '../../domain/usecase/set_notification_settings_usecase.dart';
import '../../domain/usecase/toggle_check_usecase.dart';
import '../../infrastructure/di/infrastructure_providers.dart';

/// UseCase の提供（Repository は infrastructure から注入）
final getCheckedDatesUsecaseProvider = Provider<GetCheckedDatesUsecase>((ref) {
  return GetCheckedDatesUsecase(ref.watch(checkedDatesRepositoryProvider));
});

final toggleCheckUsecaseProvider = Provider<ToggleCheckUsecase>((ref) {
  return ToggleCheckUsecase(ref.watch(checkedDatesRepositoryProvider));
});

final getNotificationSettingsUsecaseProvider =
    Provider<GetNotificationSettingsUsecase>((ref) {
  return GetNotificationSettingsUsecase(
    ref.watch(notificationSettingsRepositoryProvider),
  );
});

final setNotificationSettingsUsecaseProvider =
    Provider<SetNotificationSettingsUsecase>((ref) {
  return SetNotificationSettingsUsecase(
    ref.watch(notificationSettingsRepositoryProvider),
  );
});
