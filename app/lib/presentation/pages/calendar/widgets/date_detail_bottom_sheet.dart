import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../providers/checked_dates_provider.dart';

/// 指定日付の「X日続いてる🌱」を表示するボトムシート
void showDateDetailBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required DateTime date,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _DateDetailSheet(date: date),
    ),
  );
}

/// その日付を含めて遡った連続チェック日数（未来の日は数えない）
int streakCount(DateTime fromDate, Set<String> checkedDates) {
  final fromStart = DateTime(fromDate.year, fromDate.month, fromDate.day);
  final todayStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  if (fromStart.isAfter(todayStart)) return 0;

  int count = 0;
  DateTime d = fromStart;
  // タップした日から過去に向かって連続チェック日数を数える
  while (true) {
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (!checkedDates.contains(key)) break;
    count++;
    d = d.subtract(const Duration(days: 1));
  }
  return count;
}

/// 連続日数に応じた絵文字（1日→小さい芽、2日以上→葉っぱ、30日→木）
String streakEmoji(int streak) {
  if (streak >= 30) return '🌳';
  if (streak >= 2) return '🌿';
  return '🌱'; // 1日 or 0日（続きはここから）
}

class _DateDetailSheet extends ConsumerWidget {
  const _DateDetailSheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkedAsync = ref.watch(checkedDatesProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final isToday = normalizedDate == normalizedToday;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: checkedAsync.when(
        data: (checkedDates) {
          final streak = streakCount(date, checkedDates);
          final isChecked = checkedDates.contains(dateKey);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                DateFormat('M月d日', 'ja').format(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                streak >= 1
                    ? '$streak日続いてる${streakEmoji(streak)}'
                    : '続きはここから${streakEmoji(0)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ref.read(checkedDatesProvider.notifier).toggle(dateKey);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _getButtonText(isToday, isChecked, date),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('$e',
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  String _getButtonText(bool isToday, bool isChecked, DateTime date) {
    if (isToday) {
      return isChecked ? 'また明日' : '今日もできた';
    } else {
      final month = date.month;
      final day = date.day;
      return isChecked ? '$month/$day を取り消す' : '$month/$day もできた';
    }
  }
}
