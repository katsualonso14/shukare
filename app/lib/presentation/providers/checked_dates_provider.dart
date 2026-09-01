import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/presentation_providers.dart';

final checkedDatesProvider =
    AsyncNotifierProvider<CheckedDatesNotifier, Set<String>>(
  CheckedDatesNotifier.new,
);

class CheckedDatesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final usecase = ref.read(getCheckedDatesUsecaseProvider);
    return usecase();
  }

  Future<void> toggle(String dateKey) async {
    // 楽観的更新でちらつきを防ぐ
    final previousState = state;
    state = await AsyncValue.guard(() async {
      final current = previousState.valueOrNull ?? <String>{};
      final next = Set<String>.from(current);
      if (next.contains(dateKey)) {
        next.remove(dateKey);
      } else {
        next.add(dateKey);
      }
      return next;
    });

    // バックグラウンドで永続化
    try {
      final usecase = ref.read(toggleCheckUsecaseProvider);
      await usecase(dateKey);
    } catch (e) {
      // エラー時は元に戻す
      state = previousState;
    }
  }

  /// チェック済みデータをすべて削除
  Future<void> clearAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(clearCheckedDatesUsecaseProvider);
      await usecase();
      return <String>{};
    });
  }
}
