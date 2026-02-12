import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/checked_dates_provider.dart';
import '../check_mark_style.dart';
import 'date_detail_bottom_sheet.dart';
import 'day_cell.dart';

class MonthCalendar extends ConsumerWidget {
  const MonthCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkedDatesAsync = ref.watch(checkedDatesProvider);
    return checkedDatesAsync.when(
      data: (checkedSet) => _CalendarBody(checkedDates: checkedSet),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _CalendarBody extends ConsumerStatefulWidget {
  const _CalendarBody({required this.checkedDates});

  final Set<String> checkedDates;

  @override
  ConsumerState<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends ConsumerState<_CalendarBody> {
  DateTime _focusedDay = DateTime.now();
  DateTime get _selectedDay => _focusedDay;

  static String _dateKey(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      firstDay: DateTime(2000, 1, 1),
      lastDay: DateTime(2100, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronPadding: EdgeInsets.zero,
        rightChevronPadding: EdgeInsets.zero,
        headerPadding: const EdgeInsets.symmetric(vertical: 12),
        titleTextStyle: AppTypography.monthYear,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: AppColors.calendarHeader,
          size: 28,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: AppColors.calendarHeader,
          size: 28,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTypography.weekday,
        weekendStyle: AppTypography.weekday,
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
        cellMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
    final isCurrentMonth = day.month == focusedDay.month;
    final isToday = day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
    final key = _dateKey(day);
    final isChecked = widget.checkedDates.contains(key);

    return DayCell(
      date: day,
      isChecked: isChecked,
      isCurrentMonth: isCurrentMonth,
      isToday: isToday,
      style: CheckMarkStyle.dot,
      onTap: () => showDateDetailBottomSheet(
        context: context,
        ref: ref,
        date: day,
      ),
    );
  }
}
