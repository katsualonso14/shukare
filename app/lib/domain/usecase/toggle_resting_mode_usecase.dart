import '../entity/wake_up_record.dart';
import '../entity/wake_up_status.dart';
import '../repository/wake_up_record_repository.dart';

/// 記録を切り替えるUseCase（記録あり⇔なし）
class ToggleRestingModeUsecase {
  ToggleRestingModeUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  /// 指定した日の記録を切り替える
  /// - すでに記録があれば削除（noneに戻す）
  /// - なければfailedとして記録
  Future<WakeUpRecord?> call(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final tempRecord = WakeUpRecord(
      date: normalizedDate,
      status: WakeUpStatus.none,
      actualWakeUpTime: null,
    );
    final dateKey = tempRecord.dateKey;
    
    final existing = await _repository.load(dateKey);
    
    if (existing != null && existing.status != WakeUpStatus.none) {
      // 記録があれば削除
      final all = await _repository.loadAll();
      all.remove(dateKey);
      
      await _repository.clearAll();
      for (final record in all.values) {
        await _repository.save(record);
      }
      
      return null;
    } else {
      // 記録がなければadjustedとして記録
      final record = WakeUpRecord(
        date: normalizedDate,
        status: WakeUpStatus.adjusted,
        actualWakeUpTime: null,
      );
      await _repository.save(record);
      return record;
    }
  }
}
