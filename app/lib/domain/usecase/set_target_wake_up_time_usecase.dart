import '../entity/target_wake_up_time.dart';
import '../repository/wake_up_record_repository.dart';

/// 目標起床時刻を設定するUseCase
class SetTargetWakeUpTimeUsecase {
  SetTargetWakeUpTimeUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  Future<void> call(TargetWakeUpTime time) async {
    await _repository.saveTargetTime(time);
  }
}
