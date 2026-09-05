import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/haptics/app_haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entity/wake_up_record.dart';
import '../../../providers/calendar_week_start_provider.dart';
import '../../../providers/selected_date_provider.dart';
import '../../../providers/wake_up_records_provider.dart';
import '../check_mark_style.dart';
import 'day_cell.dart';

class MonthCalendar extends ConsumerWidget {
  const MonthCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wakeUpRecordsAsync = ref.watch(wakeUpRecordsProvider);
    final weekStartSunday = ref.watch(calendarWeekStartSundayProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    return wakeUpRecordsAsync.when(
      data: (records) => _CalendarBody(
        wakeUpRecords: records,
        selectedDate: selectedDate,
        startingDayOfWeek: weekStartSunday
            ? StartingDayOfWeek.sunday
            : StartingDayOfWeek.monday,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _CalendarBody extends ConsumerStatefulWidget {
  const _CalendarBody({
    required this.wakeUpRecords,
    required this.selectedDate,
    this.startingDayOfWeek = StartingDayOfWeek.monday,
  });

  final Map<String, WakeUpRecord> wakeUpRecords;
  final DateTime selectedDate;
  final StartingDayOfWeek startingDayOfWeek;

  @override
  ConsumerState<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends ConsumerState<_CalendarBody> {
  DateTime _focusedDay = DateTime.now();

  static String _dateKey(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
  }

  static DateTime _normalizeDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  void _handleDayTap(DateTime day) {
    final dayNormalized = _normalizeDate(day);
    final today = _normalizeDate(DateTime.now());

    // 未来の日付はタップ不可
    if (dayNormalized.isAfter(today)) return;

    // 反応しない未来日では鳴らさない（＝触覚が「押せた」の合図として機能する）
    AppHaptics.selection();
    ref.read(selectedDateProvider.notifier).state = dayNormalized;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      firstDay: DateTime(2000, 1, 1),
      lastDay: DateTime(2100, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: widget.startingDayOfWeek,
      rowHeight: 56,
      daysOfWeekHeight: 32,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronPadding: EdgeInsets.zero,
        rightChevronPadding: EdgeInsets.zero,
        headerPadding: const EdgeInsets.symmetric(vertical: 10),
        titleTextStyle: AppTypography.monthYear.copyWith(fontSize: 20),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: AppColors.calendarHeader,
          size: 32,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: AppColors.calendarHeader,
          size: 32,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTypography.weekday.copyWith(fontSize: 14),
        weekendStyle: AppTypography.weekday.copyWith(fontSize: 14),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        defaultTextStyle: AppTypography.dayNumber,
        weekendTextStyle: AppTypography.dayNumber,
        outsideTextStyle: AppTypography.dayNumberMuted,
        selectedDecoration: const BoxDecoration(
          color: AppColors.selectedDay,
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: AppColors.todayHighlight,
          shape: BoxShape.circle,
        ),
        markerSize: 0,
        cellMargin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        cellPadding: const EdgeInsets.symmetric(vertical: 2),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) =>
            _buildCell(context, day, focusedDay),
        selectedBuilder: (context, day, focusedDay) =>
            _buildCell(context, day, focusedDay),
        todayBuilder: (context, day, focusedDay) =>
            _buildCell(context, day, focusedDay),
        outsideBuilder: (context, day, focusedDay) =>
            _buildCell(context, day, focusedDay),
      ),
      onDaySelected: (selected, focused) {
        setState(() {
          _focusedDay = focused;
        });
        _handleDayTap(selected);
      },
      onPageChanged: (focused) {
        setState(() {
          _focusedDay = focused;
        });
      },
    );
  }

  Widget _buildCell(BuildContext context, DateTime day, DateTime focusedDay) {
    final now = DateTime.now();
    final today = _normalizeDate(now);
    final dayNormalized = _normalizeDate(day);
    final isCurrentMonth = day.month == focusedDay.month;
    final isToday = isSameDay(day, now);
    final isFuture = dayNormalized.isAfter(today);
    final key = _dateKey(day);
    final record = widget.wakeUpRecords[key];
    final isSelected = isSameDay(day, widget.selectedDate);

    return DayCell(
      date: day,
      record: record,
      isCurrentMonth: isCurrentMonth,
      isToday: isToday,
      isSelected: isSelected,
      isFuture: isFuture,
      style: CheckMarkStyle.dot,
    );
  }
}
