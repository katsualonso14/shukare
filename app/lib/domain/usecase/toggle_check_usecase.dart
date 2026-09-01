import '../repository/checked_dates_repository.dart';

class ToggleCheckUsecase {
  ToggleCheckUsecase(this._repository);
  final CheckedDatesRepository _repository;

  Future<Set<String>> call(String dateKey) async {
    final current = await _repository.load();
    final next = Set<String>.from(current);
    if (next.contains(dateKey)) {
      next.remove(dateKey);
    } else {
      next.add(dateKey);
    }
    await _repository.save(next);
    return next;
  }
}
