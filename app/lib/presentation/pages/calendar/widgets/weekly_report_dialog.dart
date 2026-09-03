import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../domain/entity/persona_type.dart';
import '../../../../domain/entity/wake_up_status.dart';
import '../../../../domain/service/weekly_report_service.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// ウィークリーレポートを表示するダイアログ
///
/// PersonaType に応じて UI デザイン（色味・アイコン）と文言を切り替える
class WeeklyReportDialog extends StatelessWidget {
  const WeeklyReportDialog({
    super.key,
    required this.report,
    required this.personaType,
    required this.title,
    required this.subtitle,
    required this.message,
    this.onDismiss,
  });

  final WeeklyReport report;
  final PersonaType personaType;
  final String title;
  final String subtitle;
  final String message;
  final VoidCallback? onDismiss;

  /// ダイアログを表示する
  static Future<void> show({
    required BuildContext context,
    required WeeklyReport report,
    required PersonaType personaType,
    required String title,
    required String subtitle,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => WeeklyReportDialog(
        report: report,
        personaType: personaType,
        title: title,
        subtitle: subtitle,
        message: message,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStrict = personaType == PersonaType.strict;
    final level = report.achievementLevel;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isStrict, level),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  _buildTitle(context, isStrict),
                  const SizedBox(height: 8),
                  _buildSubtitle(context, isStrict),
                  const SizedBox(height: 20),
                  _buildWeeklyChart(context, isStrict),
                  const SizedBox(height: 20),
                  _buildMessage(context, isStrict),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildButton(context, isStrict, level),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isStrict, int level) {
    final color = _getAccentColor(isStrict, level);
    final icon = _getIcon(isStrict, level);
    final emoji = _getEmoji(level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isStrict ? 0.15 : 0.2),
            color.withValues(alpha: isStrict ? 0.08 : 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isStrict ? 0.2 : 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isStrict
                  ? Icon(icon, size: 36, color: color)
                  : Text(emoji, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getWeekRangeText(context),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isStrict) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: isStrict ? FontWeight.w600 : FontWeight.w500,
            fontSize: isStrict ? 22 : 24,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context, bool isStrict) {
    final color = _getAccentColor(isStrict, report.achievementLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        subtitle,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, bool isStrict) {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final record = report.records[index];
        final status = record?.status ?? WakeUpStatus.none;
        return _DayIndicator(
          label: weekdays[index],
          status: status,
          isStrict: isStrict,
        );
      }),
    );
  }

  Widget _buildMessage(BuildContext context, bool isStrict) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isStrict
            ? AppColors.background
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStrict
              ? AppColors.textMuted.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isStrict ? 14 : 15,
          height: 1.6,
          fontWeight: isStrict ? FontWeight.w400 : FontWeight.w400,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isStrict, int level) {
    final color = _getAccentColor(isStrict, level);
    final l10n = AppLocalizations.of(context)!;
    final buttonText =
        isStrict ? l10n.weeklyReportButtonStrict : l10n.weeklyReportButtonGentle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _getWeekRangeText(BuildContext context) {
    final startText = DateFormat('M/d').format(report.weekStartDate);
    final endText = DateFormat('M/d').format(report.weekEndDate);
    return AppLocalizations.of(context)!
        .weeklyReportRange(startText, endText);
  }

  Color _getAccentColor(bool isStrict, int level) {
    if (isStrict) {
      switch (level) {
        case 5:
          return AppColors.primary;
        case 4:
          return const Color(0xFF5B8A72);
        case 3:
          return AppColors.warmGray;
        case 2:
          return const Color(0xFFB89A78);
        default:
          return const Color(0xFFA87E6F);
      }
    } else {
      switch (level) {
        case 5:
          return AppColors.primary;
        case 4:
          return const Color(0xFF8BB88A);
        case 3:
          return const Color(0xFFAEB88A);
        case 2:
          return AppColors.dustyBlush;
        default:
          return AppColors.roseDust;
      }
    }
  }

  IconData _getIcon(bool isStrict, int level) {
    switch (level) {
      case 5:
        return Icons.emoji_events_rounded;
      case 4:
        return Icons.thumb_up_rounded;
      case 3:
        return Icons.trending_up_rounded;
      case 2:
        return Icons.trending_flat_rounded;
      default:
        return Icons.refresh_rounded;
    }
  }

  String _getEmoji(int level) {
    switch (level) {
      case 5:
        return '🏆';
      case 4:
        return '🌟';
      case 3:
        return '💪';
      case 2:
        return '🌱';
      default:
        return '🤗';
    }
  }
}

/// 各曜日の達成状況を示すインジケーター
class _DayIndicator extends StatelessWidget {
  const _DayIndicator({
    required this.label,
    required this.status,
    required this.isStrict,
  });

  final String label;
  final WakeUpStatus status;
  final bool isStrict;

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: status == WakeUpStatus.success
                ? Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.dayCheckedCircle,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.dayCheckedCircleInner,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : isStrict
                    ? Icon(icon, size: 18, color: color)
                    : Text(
                        _getStatusEmoji(),
                        style: const TextStyle(fontSize: 16),
                      ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case WakeUpStatus.success:
        return AppColors.primary;
      case WakeUpStatus.rested:
        return const Color(0xFF9BB5C4);
      case WakeUpStatus.adjusted:
        return AppColors.warmGray;
      case WakeUpStatus.none:
        return AppColors.textMuted;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case WakeUpStatus.success:
        return Icons.check_rounded;
      case WakeUpStatus.rested:
        return Icons.bedtime_outlined;
      case WakeUpStatus.adjusted:
        return Icons.cloud_outlined;
      case WakeUpStatus.none:
        return Icons.remove_rounded;
    }
  }

  String _getStatusEmoji() {
    switch (status) {
      case WakeUpStatus.success:
        return '✨';
      case WakeUpStatus.rested:
        return '🌙';
      case WakeUpStatus.adjusted:
        return '☁️';
      case WakeUpStatus.none:
        return '−';
    }
  }
}
