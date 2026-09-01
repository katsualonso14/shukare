import '../entity/target_wake_up_time.dart';
import '../repository/wake_up_record_repository.dart';

/// 目標起床時刻を取得するUseCase
class GetTargetWakeUpTimeUsecase {
  GetTargetWakeUpTimeUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  Future<TargetWakeUpTime> call() async {
    return _repository.getTargetTime();
  }
}
