import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entity/wake_up_record.dart';
import '../../../../domain/entity/wake_up_status.dart';
import '../check_mark_style.dart';

class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.date,
    this.record,
    required this.isCurrentMonth,
    required this.isToday,
    this.isSelected = false,
    this.isFuture = false,
    this.style = CheckMarkStyle.dot,
  });

  final DateTime date;
  final WakeUpRecord? record;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;
  final CheckMarkStyle style;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        isCurrentMonth ? AppTypography.dayNumber : AppTypography.dayNumberMuted;

    final effectiveTextStyle = isFuture
        ? textStyle.copyWith(color: AppColors.textMuted.withValues(alpha: 0.4))
        : textStyle;

    return ClipRect(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: _buildDecoration(),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: effectiveTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 3),
            _CheckMark(style: style, record: record),
          ],
        ),
      ),
    );
  }

  BoxDecoration? _buildDecoration() {
    if (isSelected && !isToday) {
      return BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      );
    } else if (isToday) {
      return const BoxDecoration(
        color: AppColors.todayHighlight,
        shape: BoxShape.circle,
      );
    }
    return null;
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.style, this.record});

  final CheckMarkStyle style;
  final WakeUpRecord? record;

  @override
  Widget build(BuildContext context) {
    final status = record?.status ?? WakeUpStatus.none;

    if (status == WakeUpStatus.none) {
      return const SizedBox(height: 18, width: 18);
    }

    // rested / adjusted は絵文字で表示（スタイル非依存）
    if (status == WakeUpStatus.rested || status == WakeUpStatus.adjusted) {
      return SizedBox(
        height: 16,
        width: 16,
        child: Center(
          child: Text(
            status.emoji,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    // success はスタイルに応じた色付きマーカー
    const color = AppColors.dayCheckedCircle;
    switch (style) {
      case CheckMarkStyle.dot:
        return Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      case CheckMarkStyle.ring:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        );
      case CheckMarkStyle.fill:
        return Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        );
    }
  }
}
