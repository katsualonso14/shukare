import '../entity/wake_up_record.dart';
import '../entity/wake_up_status.dart';
import '../entity/target_wake_up_time.dart';
import '../repository/wake_up_record_repository.dart';

/// 起床を記録するUseCase（ステータス自動判定）
class RecordWakeUpUsecase {
  RecordWakeUpUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  /// 起床を記録する
  /// - [actualTime]: 実際に起きた時刻
  /// - 目標時間との差分で自動的にステータスを判定
  Future<WakeUpRecord> call(DateTime actualTime) async {
    final targetTime = await _repository.getTargetTime();
    final targetDateTime = targetTime.toDateTimeOn(actualTime);
    
    final status = _determineStatus(actualTime, targetDateTime);
    
    final record = WakeUpRecord(
      date: DateTime(actualTime.year, actualTime.month, actualTime.day),
      status: status,
      actualWakeUpTime: actualTime,
    );
    
    await _repository.save(record);
    return record;
  }

  /// 目標時間との差分でステータスを判定
  WakeUpStatus _determineStatus(DateTime actual, DateTime target) {
    final diff = actual.difference(target);
    
    if (diff.isNegative || diff.inMinutes == 0) {
      // 目標時間内 or 早起き
      return WakeUpStatus.achieved;
    } else if (diff.inMinutes <= 30) {
      // 30分以内の遅刻
      return WakeUpStatus.nearMiss;
    } else {
      // 30分以上の遅刻
      return WakeUpStatus.tried;
    }
  }
}
