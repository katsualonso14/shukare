import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../infrastructure/di/infrastructure_providers.dart';
import '../../../domain/entity/wake_up_record.dart';
import '../../../domain/entity/wake_up_status.dart';
import '../../providers/personalized_message_provider.dart';
import '../../providers/wake_up_records_provider.dart';
import '../../providers/weekly_report_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/date_detail_bottom_sheet.dart';
import 'widgets/month_calendar.dart';
import 'widgets/monthly_report_dialog.dart';
import 'widgets/weekly_report_dialog.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _hasCheckedReports = false;

  static String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  void initState() {
    super.initState();
    _checkReports();
  }

  Future<void> _checkReports() async {
    if (_hasCheckedReports) return;
    _hasCheckedReports = true;

    // auto-evaluate は wakeUpRecordsProvider.build() で完了しているので待つだけ
    await ref.read(wakeUpRecordsProvider.future);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await _checkWeeklyReport();
    if (!mounted) return;
    await _checkMonthlyReport();
  }

  Future<void> _checkWeeklyReport() async {
    final reportAsync = await ref.read(weeklyReportProvider.future);
    if (reportAsync == null) return;
    if (!mounted) return;

    final profile = ref.read(userProfileProvider);
    final title = ref.read(weeklyReportTitleProvider(reportAsync));
    final subtitle = ref.read(weeklyReportSubtitleProvider(reportAsync));
    final message = ref.read(weeklyReportMessageProvider(reportAsync));

    await ref.read(analyticsServiceProvider).logWeeklyReportViewed();
    if (!mounted) return;
    await WeeklyReportDialog.show(
      context: context,
      report: reportAsync,
      personaType: profile.personaType,
      title: title,
      subtitle: subtitle,
      message: message,
    );

    await ref.read(weeklyReportNotifierProvider.notifier).markAsShown();
  }

  Future<void> _checkMonthlyReport() async {
    final report = await ref.read(monthlyReportProvider.future);
    if (report == null) return;
    if (!mounted) return;

    final profile = ref.read(userProfileProvider);
    final title = ref.read(monthlyReportTitleProvider(report));
    final subtitle = ref.read(monthlyReportSubtitleProvider(report));
    final message = ref.read(monthlyReportMessageProvider(report));

    await ref.read(analyticsServiceProvider).logMonthlyReportViewed();
    if (!mounted) return;
    await MonthlyReportDialog.show(
      context: context,
      report: report,
      personaType: profile.personaType,
      title: title,
      subtitle: subtitle,
      message: message,
    );

    await ref.read(monthlyReportNotifierProvider.notifier).markAsShown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wakeUpRecordsAsync = ref.watch(wakeUpRecordsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedKey = _dateKey(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
                child: Row(
                  children: [
                    Text(
                      l10n.appTagline,
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
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverToBoxAdapter(child: MonthCalendar()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: wakeUpRecordsAsync.when(
                data: (records) {
                  final record = records[selectedKey];
                  final streak = _calculateStreak(selectedDate, records);
                  return _DailyFeedbackCard(
                    date: selectedDate,
                    streak: streak,
                    status: record?.status,
                  );
                },
                loading: () => const SizedBox(height: 100),
                error: (_, __) => const SizedBox(height: 100),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

int _calculateStreak(DateTime fromDate, Map<String, WakeUpRecord> records) {
  final fromStart = DateTime(fromDate.year, fromDate.month, fromDate.day);
  final todayStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  if (fromStart.isAfter(todayStart)) return 0;

  int count = 0;
  DateTime d = fromStart;

  while (true) {
    final key = DateFormat('yyyy-MM-dd').format(d);
    final record = records[key];
    if (record == null || record.status != WakeUpStatus.success) break;
    count++;
    d = d.subtract(const Duration(days: 1));
  }
  return count;
}

class _DailyFeedbackCard extends ConsumerWidget {
  const _DailyFeedbackCard({
    required this.date,
    required this.streak,
    this.status,
  });

  final DateTime date;
  final int streak;
  final WakeUpStatus? status;

  String _streakEmoji(int n) {
    if (n >= 30) return '🌳';
    if (n >= 2) return '🌿';
    return '🌱';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final personalizedMessage = ref.watch(personalizedMessageProvider(status));
    final hasRecord = status != null && status != WakeUpStatus.none;
    final displayText = hasRecord
        ? personalizedMessage
        : (streak >= 1
            ? l10n.streakDays(streak, _streakEmoji(streak))
            : l10n.streakStart(_streakEmoji(0)));

    final dateFormat = locale == 'ja' ? 'M月d日' : 'MMM d';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              DateFormat(dateFormat, locale).format(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              displayText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    letterSpacing: 0.3,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () =>
                  showDateDetailBottomSheet(context: context, date: date),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.editRecord,
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
