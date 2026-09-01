import '../repository/checked_dates_repository.dart';

class ClearCheckedDatesUsecase {
  ClearCheckedDatesUsecase(this._repository);
  final CheckedDatesRepository _repository;

  Future<void> call() => _repository.clear();
}
