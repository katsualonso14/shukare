import '../../domain/repository/checked_dates_repository.dart';
import '../datasource/preference_datasource.dart';

class CheckedDatesRepositoryImpl implements CheckedDatesRepository {
  CheckedDatesRepositoryImpl(this._datasource);
  final PreferenceDatasource _datasource;

  @override
  Future<Set<String>> load() => _datasource.getCheckedDates();

  @override
  Future<void> save(Set<String> dates) => _datasource.setCheckedDates(dates);

  @override
  Future<void> clear() => _datasource.clearAllCheckedDates();
}
