import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../check_mark_style.dart';

class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.date,
    required this.isChecked,
    required this.isCurrentMonth,
    required this.isToday,
    this.isSelected = false,
    this.isFuture = false,
    this.style = CheckMarkStyle.dot,
  });

  final DateTime date;
  final bool isChecked;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;
  final CheckMarkStyle style;

  @override
  Widget build(BuildContext context) {
    final textStyle = isCurrentMonth
        ? AppTypography.dayNumber
        : AppTypography.dayNumberMuted;
    
    // 未来の日付はグレーアウト
    final effectiveTextStyle = isFuture
        ? textStyle.copyWith(color: AppColors.textMuted.withOpacity(0.4))
        : textStyle;

    // セルサイズを拡大（日付32 + 間隔3 + ドット18 = 53px）
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
          _CheckMark(style: style, isChecked: isChecked),
        ],
      ),
    ),
    );
  }

  BoxDecoration? _buildDecoration() {
    if (isSelected && !isToday) {
      // 選択中（今日以外）
      return BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        shape: BoxShape.circle,
      );
    } else if (isToday) {
      // 今日
      return BoxDecoration(
        color: AppColors.todayHighlight,
        shape: BoxShape.circle,
      );
    }
    return null;
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.style, required this.isChecked});

  final CheckMarkStyle style;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    if (!isChecked) return const SizedBox(height: 6, width: 6);

    switch (style) {
      case CheckMarkStyle.dot:
        // 優しい緑の二重丸（外側→内側の薄い緑）
        return Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppColors.dayCheckedCircle,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: AppColors.dayCheckedCircleInner,
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
            border: Border.all(color: AppColors.checkRing, width: 1.5),
          ),
        );
      case CheckMarkStyle.fill:
        return Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.checkFill,
            borderRadius: BorderRadius.circular(6),
          ),
        );
    }
  }
}
