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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(toggleCheckUsecaseProvider);
      return usecase(dateKey);
    });
  }
}
