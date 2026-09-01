import '../repository/wake_up_record_repository.dart';
import '../entity/wake_up_record.dart';

/// すべての起床記録を取得するUseCase
class GetWakeUpRecordsUsecase {
  GetWakeUpRecordsUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  Future<Map<String, WakeUpRecord>> call() async {
    return _repository.loadAll();
  }
}
