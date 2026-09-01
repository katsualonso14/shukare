import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 選択中の日付（カレンダーでタップした日付）
/// デフォルトは今日
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
