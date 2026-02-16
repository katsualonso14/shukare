import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/checked_dates_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/date_detail_bottom_sheet.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    sliver: SliverToBoxAdapter(
                      child: const MonthCalendar(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  SliverToBoxAdapter(
                    child: checkedAsync.when(
                      data: (checked) {
                        final streak = streakCount(selectedDate, checked);
                        return _StreakCard(
                          date: selectedDate,
                          streak: streak,
                        );
                      },
                      loading: () => const SizedBox(height: 100),
                      error: (_, __) => const SizedBox(height: 100),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                ],
              ),
            ),
            // ボタンを画面下部に固定
            Container(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textMuted.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: checkedAsync.when(
                data: (checked) {
                  final isChecked = checked.contains(selectedKey);
                  return _CheckButton(
                    date: selectedDate,
                    isToday: isToday,
                    isChecked: isChecked,
                    onTap: () {
                      ref.read(checkedDatesProvider.notifier).toggle(selectedKey);
                    },
                  );
                },
                loading: () => const SizedBox(height: 56),
                error: (_, __) => const SizedBox(height: 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// カレンダー下のチェックセクション（連続日数とボタン）
class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.date,
    required this.streak,
  });

  final DateTime date;
  final int streak;

  String get _streakText {
    if (streak >= 1) {
      return '$streak日続いてる${_streakEmoji(streak)}';
    } else {
      return '続きはここから${_streakEmoji(0)}';
    }
  }

  String _streakEmoji(int streak) {
    if (streak >= 30) return '🌳';
    if (streak >= 2) return '🌿';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.primary.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              DateFormat('M月d日', 'ja').format(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              _streakText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    letterSpacing: 0.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// チェックボタン
class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.date,
    required this.isToday,
    required this.isChecked,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isChecked;
  final VoidCallback onTap;

  String get _buttonText {
    if (isToday) {
      return isChecked ? 'また明日' : '今日もできた';
    } else {
      final month = date.month;
      final day = date.day;
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
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
