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
          _CheckMark(style: style, record: record),
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
  const _CheckMark({required this.style, this.record});

  final CheckMarkStyle style;
  final WakeUpRecord? record;

  @override
  Widget build(BuildContext context) {
    if (record == null) return const SizedBox(height: 6, width: 6);

    // ステータスに応じた色を返す
    Color _getStatusColor(WakeUpStatus status) {
      switch (status) {
        case WakeUpStatus.achieved:
          return AppColors.dayCheckedCircle; // 達成: 緑
        case WakeUpStatus.nearMiss:
          return Colors.orange.shade300; // 惜しい: オレンジ
        case WakeUpStatus.resting:
          return Colors.blue.shade300; // お休み: 青
        case WakeUpStatus.tried:
          return Colors.purple.shade200; // 記録継続: 紫
      }
    }

    final statusColor = _getStatusColor(record!.status);

    switch (style) {
      case CheckMarkStyle.dot:
        // ステータスに応じた色の二重丸
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.5),
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
            border: Border.all(color: statusColor, width: 1.5),
          ),
        );
      case CheckMarkStyle.fill:
        return Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(6),
          ),
        );
    }
  }
}
