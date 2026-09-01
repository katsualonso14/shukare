import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../domain/entity/wake_up_status.dart';
import '../../../domain/service/weekly_report_service.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/weekly_report_provider.dart';

class WeeklyStatsScreen extends ConsumerWidget {
  const WeeklyStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reportAsync = ref.watch(currentWeekReportProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.weeklyRecordTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: reportAsync.when(
        data: (report) => _StatsBody(report: report),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _StatsBody extends ConsumerWidget {
  const _StatsBody({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final message = ref.watch(weeklyReportMessageProvider(report));
    final title = ref.watch(weeklyReportTitleProvider(report));
    final subtitle = ref.watch(weeklyReportSubtitleProvider(report));
    ref.watch(userProfileProvider);

    final startText = DateFormat('M/d').format(report.weekStartDate);
    final endText = DateFormat('M/d').format(report.weekEndDate);
    final level = report.achievementLevel;
    final ratePercent = (report.successRate * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '$startText 〜 $endText',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _AchievementCard(
            level: level,
            title: title,
            subtitle: subtitle,
            ratePercent: ratePercent,
            successRate: report.successRate,
          ),
          const SizedBox(height: 20),
          _WeekChart(report: report, l10n: l10n),
          const SizedBox(height: 16),
          _StatsRow(report: report, l10n: l10n),
          const SizedBox(height: 20),
          _MessageCard(message: message),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.ratePercent,
    required this.successRate,
  });

  final int level;
  final String title;
  final String subtitle;
  final int ratePercent;
  final double successRate;

  Color _color() {
    switch (level) {
      case 5:
        return AppColors.primary;
      case 4:
        return const Color(0xFF8BB88A);
      case 3:
        return const Color(0xFFAEB88A);
      case 2:
        return AppColors.warmGray;
      default:
        return const Color(0xFFA87E6F);
    }
  }

  String _emoji() {
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

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(_emoji(), style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _DonutChart(rate: successRate, color: color, ratePercent: ratePercent),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.rate,
    required this.color,
    required this.ratePercent,
  });

  final double rate;
  final Color color;
  final int ratePercent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _DonutPainter(rate: rate, color: color),
        child: Center(
          child: Text(
            '$ratePercent%',
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.rate, required this.color});

  final double rate;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 20.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (rate > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * rate,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.rate != rate || old.color != color;
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.report, required this.l10n});

  final WeeklyReport report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (i) {
          final isFuture = i >= report.totalDays;
          final status = isFuture
              ? WakeUpStatus.none
              : (report.records[i]?.status ?? WakeUpStatus.none);
          return _DayCell(
            label: weekdays[i],
            status: status,
            isFuture: isFuture,
          );
        }),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.status,
    this.isFuture = false,
  });

  final String label;
  final WakeUpStatus status;
  final bool isFuture;

  Color _bgColor() {
    switch (status) {
      case WakeUpStatus.success:
        return AppColors.dayCheckedCircle.withValues(alpha: 0.15);
      case WakeUpStatus.rested:
        return const Color(0xFF9BB5C4).withValues(alpha: 0.15);
      case WakeUpStatus.adjusted:
        return AppColors.warmGray.withValues(alpha: 0.15);
      case WakeUpStatus.none:
        return Colors.transparent;
    }
  }

  Color _borderColor() {
    switch (status) {
      case WakeUpStatus.success:
        return AppColors.dayCheckedCircle.withValues(alpha: 0.5);
      case WakeUpStatus.rested:
        return const Color(0xFF9BB5C4).withValues(alpha: 0.4);
      case WakeUpStatus.adjusted:
        return AppColors.warmGray.withValues(alpha: 0.4);
      case WakeUpStatus.none:
        return AppColors.textMuted.withValues(alpha: 0.2);
    }
  }

  Widget _indicator() {
    switch (status) {
      case WakeUpStatus.success:
        return Container(
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
        );
      case WakeUpStatus.rested:
        return const Text('🌙', style: TextStyle(fontSize: 16));
      case WakeUpStatus.adjusted:
        return const Text('☁️', style: TextStyle(fontSize: 16));
      case WakeUpStatus.none:
        return Text('−', style: TextStyle(color: AppColors.textMuted, fontSize: 18));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimmed = isFuture ? 0.3 : 1.0;
    return Opacity(
      opacity: dimmed,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _bgColor(),
              shape: BoxShape.circle,
              border: Border.all(color: _borderColor(), width: 1.5),
            ),
            child: Center(child: _indicator()),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.report, required this.l10n});

  final WeeklyReport report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            indicator: Container(
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
            ),
            count: report.successDays,
            label: l10n.statSuccess,
            color: AppColors.dayCheckedCircle,
            l10n: l10n,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            indicator: const Text('🌙☁️', style: TextStyle(fontSize: 14)),
            count: report.failedDays,
            label: l10n.statRest,
            color: const Color(0xFF9BB5C4),
            l10n: l10n,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            indicator: Text(
              '−',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            count: report.noneDays,
            label: l10n.statNone,
            color: AppColors.textMuted,
            l10n: l10n,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.indicator,
    required this.count,
    required this.label,
    required this.color,
    required this.l10n,
  });

  final Widget indicator;
  final int count;
  final String label;
  final Color color;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          indicator,
          const SizedBox(height: 6),
          Text(
            l10n.dayCount(count),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }
}
