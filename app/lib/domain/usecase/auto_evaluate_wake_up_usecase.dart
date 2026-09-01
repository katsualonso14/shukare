import 'package:intl/intl.dart';

import '../entity/wake_up_record.dart';
import '../entity/wake_up_status.dart';
import '../repository/wake_up_record_repository.dart';
import '../service/wake_up_evaluator.dart';

/// アプリ起動時に今日の早起き判定を自動で行うUseCase
class AutoEvaluateWakeUpUsecase {
  AutoEvaluateWakeUpUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  static const _evaluator = WakeUpEvaluator();

  /// 今日の記録がない場合、現在時刻で自動判定を行う
  /// - 目標時刻±30分以内 → success として保存
  /// - それ以外 → adjusted として保存
  /// - 既に記録がある場合 → 何もしない（二重判定防止）
  ///
  /// Returns: 新しく作成された記録、または記録不要の場合は null
  Future<WakeUpRecord?> call() async {
    final now = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);

    final existingRecord = await _repository.load(todayKey);
    if (existingRecord != null && existingRecord.status != WakeUpStatus.none) {
      return null;
    }

    final targetTime = await _repository.getTargetTime();
    final targetDateTime = targetTime.toDateTimeOn(now);

    final evaluatedStatus = _evaluator.evaluate(targetDateTime, now);

    // ±30分以内なら success、それ以外は adjusted として記録
    final recordStatus = evaluatedStatus == WakeUpStatus.none
        ? WakeUpStatus.adjusted
        : evaluatedStatus;

    final record = WakeUpRecord(
      date: DateTime(now.year, now.month, now.day),
      status: recordStatus,
      actualWakeUpTime: now,
    );

    await _repository.save(record);
    return record;
  }
}
