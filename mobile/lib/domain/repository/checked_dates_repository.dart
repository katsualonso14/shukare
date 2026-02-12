/// チェック済み日付の永続化（Domain Repository インターフェース）
abstract class CheckedDatesRepository {
  Future<Set<String>> load();
  Future<void> save(Set<String> dates);
}
