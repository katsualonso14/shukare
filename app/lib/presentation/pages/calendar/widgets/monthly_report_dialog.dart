import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../domain/entity/persona_type.dart';
import '../../../../domain/service/weekly_report_service.dart';

class MonthlyReportDialog extends StatelessWidget {
  const MonthlyReportDialog({
    super.key,
    required this.report,
    required this.personaType,
    required this.title,
    required this.subtitle,
    required this.message,
    this.onDismiss,
  });

  final MonthlyReport report;
  final PersonaType personaType;
  final String title;
  final String subtitle;
  final String message;
  final VoidCallback? onDismiss;

  static Future<void> show({
    required BuildContext context,
    required MonthlyReport report,
    required PersonaType personaType,
    required String title,
    required String subtitle,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => MonthlyReportDialog(
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
            _buildHeader(isStrict, level),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  _buildTitle(context, isStrict),
                  const SizedBox(height: 8),
                  _buildSubtitle(isStrict),
                  const SizedBox(height: 20),
                  _buildStats(isStrict, level),
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

  Widget _buildHeader(bool isStrict, int level) {
    final color = _getAccentColor(isStrict, level);
    final monthLabel =
        DateFormat('M月', 'ja').format(report.monthStart);

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
                  ? Icon(_getIcon(level), size: 36, color: color)
                  : Text(_getEmoji(level),
                      style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$monthLabel の振り返り',
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

  Widget _buildSubtitle(bool isStrict) {
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

  Widget _buildStats(bool isStrict, int level) {
    return Row(
      children: [
        _StatBadge(
          label: '達成',
          count: report.successDays,
          color: AppColors.primary,
          isStrict: isStrict,
          emoji: '✨',
        ),
        const SizedBox(width: 8),
        _StatBadge(
          label: 'その他',
          count: report.failedDays,
          color: AppColors.warmGray,
          isStrict: isStrict,
          emoji: '☁️',
        ),
        const SizedBox(width: 8),
        _StatBadge(
          label: '未記録',
          count: report.noneDays,
          color: AppColors.textMuted,
          isStrict: isStrict,
          emoji: '−',
        ),
      ],
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
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isStrict ? 14 : 15,
          height: 1.6,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isStrict, int level) {
    final color = _getAccentColor(isStrict, level);
    final buttonText = isStrict ? '確認した' : '今月もがんばる！';
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
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

  IconData _getIcon(int level) {
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

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.isStrict,
    required this.emoji,
  });

  final String label;
  final int count;
  final Color color;
  final bool isStrict;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              isStrict ? '$count日' : '$emoji $count日',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}
