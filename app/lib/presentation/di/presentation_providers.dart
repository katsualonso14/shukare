import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecase/clear_checked_dates_usecase.dart';
import '../../domain/usecase/get_checked_dates_usecase.dart';
import '../../domain/usecase/get_notification_settings_usecase.dart';
import '../../domain/usecase/set_notification_settings_usecase.dart';
import '../../domain/usecase/toggle_check_usecase.dart';
import '../../domain/usecase/record_wake_up_usecase.dart';
import '../../domain/usecase/toggle_resting_mode_usecase.dart';
import '../../domain/usecase/get_wake_up_records_usecase.dart';
import '../../domain/usecase/clear_wake_up_records_usecase.dart';
import '../../domain/usecase/delete_wake_up_record_usecase.dart';
import '../../domain/usecase/get_target_wake_up_time_usecase.dart';
import '../../domain/usecase/set_target_wake_up_time_usecase.dart';
import '../../infrastructure/di/infrastructure_providers.dart';

/// UseCase の提供（Repository は infrastructure から注入）
final getCheckedDatesUsecaseProvider = Provider<GetCheckedDatesUsecase>((ref) {
  return GetCheckedDatesUsecase(ref.watch(checkedDatesRepositoryProvider));
});

final toggleCheckUsecaseProvider = Provider<ToggleCheckUsecase>((ref) {
  return ToggleCheckUsecase(ref.watch(checkedDatesRepositoryProvider));
});

final clearCheckedDatesUsecaseProvider = Provider<ClearCheckedDatesUsecase>((ref) {
  return ClearCheckedDatesUsecase(ref.watch(checkedDatesRepositoryProvider));
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

// --- Wake Up Records UseCase Providers ---

final recordWakeUpUsecaseProvider = Provider<RecordWakeUpUsecase>((ref) {
  return RecordWakeUpUsecase(ref.watch(wakeUpRecordRepositoryProvider));
});

final toggleRestingModeUsecaseProvider = Provider<ToggleRestingModeUsecase>((ref) {
  return ToggleRestingModeUsecase(ref.watch(wakeUpRecordRepositoryProvider));
});

final getWakeUpRecordsUsecaseProvider = Provider<GetWakeUpRecordsUsecase>((ref) {
  return GetWakeUpRecordsUsecase(ref.watch(wakeUpRecordRepositoryProvider));
});

final clearWakeUpRecordsUsecaseProvider = Provider<ClearWakeUpRecordsUsecase>((ref) {
  return ClearWakeUpRecordsUsecase(ref.watch(wakeUpRecordRepositoryProvider));
});

final deleteWakeUpRecordUsecaseProvider = Provider<DeleteWakeUpRecordUsecase>((ref) {
  return DeleteWakeUpRecordUsecase(ref.watch(wakeUpRecordRepositoryProvider));
});

final getTargetWakeUpTimeUsecaseProvider = Provider<GetTargetWakeUpTimeUsecase>((ref) {
  return GetTargetWakeUpTimeUsecase(ref.watch(wakeUpRecordRepositoryProvider));
});

final setTargetWakeUpTimeUsecaseProvider = Provider<SetTargetWakeUpTimeUsecase>((ref) {
  return SetTargetWakeUpTimeUsecase(ref.watch(wakeUpRecordRepositoryProvider));
});
