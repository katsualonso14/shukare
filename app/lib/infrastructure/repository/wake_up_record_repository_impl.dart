import '../../domain/entity/target_wake_up_time.dart';
import '../../domain/entity/wake_up_record.dart';
import '../../domain/repository/wake_up_record_repository.dart';
import '../datasource/preference_datasource.dart';

class WakeUpRecordRepositoryImpl implements WakeUpRecordRepository {
  WakeUpRecordRepositoryImpl(this._datasource);
  final PreferenceDatasource _datasource;

  @override
  Future<Map<String, WakeUpRecord>> loadAll() async {
    final raw = await _datasource.getWakeUpRecords();
    final result = <String, WakeUpRecord>{};
    
    raw.forEach((key, value) {
      try {
        result[key] = WakeUpRecord.fromJson(value);
      } catch (_) {
        // パースエラーは無視してスキップ
      }
    });
    
    return result;
  }

  @override
  Future<WakeUpRecord?> load(String dateKey) async {
    final all = await loadAll();
    return all[dateKey];
  }

  @override
  Future<void> save(WakeUpRecord record) async {
    final all = await loadAll();
    all[record.dateKey] = record;
    
    // Map<String, WakeUpRecord> -> Map<String, Map<String, dynamic>>
    final raw = <String, Map<String, dynamic>>{};
    all.forEach((key, value) {
      raw[key] = value.toJson();
    });
    
    await _datasource.setWakeUpRecords(raw);
  }

  @override
  Future<void> clearAll() async {
    await _datasource.clearAllWakeUpRecords();
  }

  @override
  Future<TargetWakeUpTime> getTargetTime() async {
    final raw = _datasource.getTargetWakeUpTime();
    return TargetWakeUpTime(
      hour: raw['hour']!,
      minute: raw['minute']!,
    );
  }

  @override
  Future<void> saveTargetTime(TargetWakeUpTime time) async {
    await _datasource.setTargetWakeUpTime(time.hour, time.minute);
  }
}
