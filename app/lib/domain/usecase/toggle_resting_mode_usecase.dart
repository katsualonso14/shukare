import '../entity/wake_up_record.dart';
import '../entity/wake_up_status.dart';
import '../repository/wake_up_record_repository.dart';

/// 「今日は休む」モードを設定/解除するUseCase
class ToggleRestingModeUsecase {
  ToggleRestingModeUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  /// 指定した日を「お休みモード」に設定/解除する
  /// - すでにrestingなら解除（記録削除）
  /// - それ以外ならrestingに設定
  Future<WakeUpRecord?> call(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final tempRecord = WakeUpRecord(
      date: normalizedDate,
      status: WakeUpStatus.resting,
      actualWakeUpTime: null,
    );
    final dateKey = tempRecord.dateKey;
    
    final existing = await _repository.load(dateKey);
    
    if (existing?.status == WakeUpStatus.resting) {
      // すでにrestingなら解除（記録を削除）
      final all = await _repository.loadAll();
      all.remove(dateKey);
      
      // 再保存
      final raw = <String, Map<String, dynamic>>{};
      all.forEach((key, value) {
        raw[key] = value.toJson();
      });
      // NOTE: clearしてから全件保存する方が安全
      await _repository.clearAll();
      for (final record in all.values) {
        await _repository.save(record);
      }
      
      return null;
    } else {
      // resting モードに設定
      final record = WakeUpRecord(
        date: normalizedDate,
        status: WakeUpStatus.resting,
        actualWakeUpTime: null,
      );
      await _repository.save(record);
      return record;
    }
  }
}
