import '../repository/wake_up_record_repository.dart';

/// すべての起床記録をクリアするUseCase
class ClearWakeUpRecordsUsecase {
  ClearWakeUpRecordsUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  Future<void> call() async {
    await _repository.clearAll();
  }
}
