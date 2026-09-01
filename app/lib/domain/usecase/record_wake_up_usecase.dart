import '../entity/wake_up_record.dart';
import '../repository/wake_up_record_repository.dart';
import '../service/wake_up_evaluator.dart';

/// 起床を記録するUseCase（ステータス自動判定）
class RecordWakeUpUsecase {
  RecordWakeUpUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  static const _evaluator = WakeUpEvaluator();

  /// 起床を記録する
  /// - [actualTime]: 実際に起きた時刻
  /// - 目標時間との差分で自動的にステータスを判定
  Future<WakeUpRecord> call(DateTime actualTime) async {
    final targetTime = await _repository.getTargetTime();
    final targetDateTime = targetTime.toDateTimeOn(actualTime);
    
    final status = _evaluator.evaluate(targetDateTime, actualTime);
    
    final record = WakeUpRecord(
      date: DateTime(actualTime.year, actualTime.month, actualTime.day),
      status: status,
      actualWakeUpTime: actualTime,
    );
    
    await _repository.save(record);
    return record;
  }
}
