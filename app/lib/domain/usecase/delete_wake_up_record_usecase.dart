import 'package:intl/intl.dart';

import '../repository/wake_up_record_repository.dart';

/// 指定した日の起床記録を削除するUseCase
class DeleteWakeUpRecordUsecase {
  DeleteWakeUpRecordUsecase(this._repository);
  final WakeUpRecordRepository _repository;

  Future<void> call(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = DateFormat('yyyy-MM-dd').format(normalizedDate);
    await _repository.delete(dateKey);
  }
}
