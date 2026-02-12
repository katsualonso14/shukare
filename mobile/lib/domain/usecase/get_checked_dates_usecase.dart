import '../repository/checked_dates_repository.dart';

class GetCheckedDatesUsecase {
  GetCheckedDatesUsecase(this._repository);
  final CheckedDatesRepository _repository;

  Future<Set<String>> call() => _repository.load();
}
