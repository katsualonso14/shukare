import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/checked_dates_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/month_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkedAsync = ref.watch(checkedDatesProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedKey = _dateKey(selectedDate);
    final today = _today();
    final todayKey = _dateKey(today);
    final isToday = selectedKey == todayKey;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 16, 16),
                      child: Row(
                        children: [
                          Text(
                            '今日も、少しだけ。',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: const MonthCalendar(),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: checkedAsync.maybeWhen(
                      data: (checked) {
                        final isChecked = checked.contains(selectedKey);
                        return _AppIconDecoration(visible: isChecked);
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            // ボタンを画面下部に固定
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: checkedAsync.when(
                data: (checked) {
                  final isChecked = checked.contains(selectedKey);
                  return _CheckButton(
                    isChecked: isChecked,
                    isToday: isToday,
                    selectedDate: selectedDate,
                    onTap: () {
                      ref.read(checkedDatesProvider.notifier).toggle(selectedKey);
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.isChecked,
    required this.isToday,
    required this.selectedDate,
    required this.onTap,
  });

  final bool isChecked;
  final bool isToday;
  final DateTime selectedDate;
  final VoidCallback onTap;

  String get _buttonText {
    if (isToday) {
      return isChecked ? 'また明日' : '今日もできた';
    } else {
      // 過去の日付
      final month = selectedDate.month;
      final day = selectedDate.day;
      return isChecked ? '$month/$day を取り消す' : '$month/$day もできた';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
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
          _buttonText,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// カレンダー下の余白にアプリアイコンを控えめに表示
class _AppIconDecoration extends StatelessWidget {
  const _AppIconDecoration({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
