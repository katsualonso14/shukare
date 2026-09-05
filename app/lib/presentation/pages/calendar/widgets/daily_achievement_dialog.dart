import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/haptics/app_haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entity/persona_type.dart';
import '../../../../domain/entity/wake_up_status.dart';
import '../../../../domain/service/daily_achievement_service.dart';

/// 「今日どうだったか」をお披露目するモーダル。
///
/// なぜ必要か: 判定は起動時に無言で走り、カレンダーには最初からそこにあった顔で
/// ドットが並ぶ。今日が決まった瞬間が誰にも目撃されないので、達成感も区切りも
/// どこにも発生しない。このモーダルは新しい情報を足すのではなく、
/// **今日のドットが置かれる瞬間だけをここへ移して見せる**（週ストリップの
/// 今日の位置が、開いた後に遅れて入る）。
///
/// できた日（success）と調整日（adjusted）の両方を出すが、**演出の重さを変える**。
/// 同じ勢いで出すと調整日が「失敗を知らせるポップアップ」になり、
/// 「目標を過ぎても失敗扱いにしない」というこのアプリの前提と正面からぶつかる:
///
/// | | できた日 | 調整日 |
/// |---|---|---|
/// | 見出しの絵文字 | 下から弾んで出る（easeOutBack） | 横からふわっと流れ込む（easeOutCubic） |
/// | 今日のドット | elasticOut で「ポン」 | フェード＋わずかな拡大で「すっ」 |
/// | 触覚 | light→medium の2段（トトン） | light 1回だけ |
/// | 色 | セージ／節目はローズダスト | ウォームグレー（主張しない） |
class DailyAchievementDialog extends StatefulWidget {
  const DailyAchievementDialog({
    super.key,
    required this.achievement,
    required this.personaType,
    required this.message,
  });

  final DailyAchievement achievement;
  final PersonaType personaType;

  /// ペルソナ別の一言（personalizedMessageProvider から受け取る）
  final String message;

  static Future<void> show({
    required BuildContext context,
    required DailyAchievement achievement,
    required PersonaType personaType,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => DailyAchievementDialog(
        achievement: achievement,
        personaType: personaType,
        message: message,
      ),
    );
  }

  @override
  State<DailyAchievementDialog> createState() => _DailyAchievementDialogState();
}

class _DailyAchievementDialogState extends State<DailyAchievementDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isSuccess => widget.achievement.isSuccess;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // 調整日はひと呼吸ぶん長く流す（弾まないぶん、速いと素っ気なく見える）
      duration: Duration(milliseconds: _isSuccess ? 1100 : 1300),
    )..forward();

    // 画面が出るのと同じ瞬間に手にも返す。目を上げる前に「今日が決まった」が届く
    if (_isSuccess) {
      AppHaptics.celebrate();
    } else {
      AppHaptics.gentle();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 既存の _DailyFeedbackCard と同じ育ち方の絵文字を使う（表現を揃える）
  String get _streakEmoji {
    final n = widget.achievement.streak;
    if (n >= 30) return '🌳';
    if (n >= 2) return '🌿';
    return '🌱';
  }

  String _headline(AppLocalizations l10n) {
    final a = widget.achievement;
    if (!_isSuccess) return l10n.achievementAdjusted;
    if (a.isMilestone) return l10n.achievementMilestone(a.streak);
    return a.streak >= 2
        ? l10n.achievementStreak(a.streak)
        : l10n.achievementStart;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final a = widget.achievement;
    final accent = !_isSuccess
        ? AppColors.warmGray
        : (a.isMilestone ? AppColors.roseDust : AppColors.primary);

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
            _Header(
              emoji: _isSuccess
                  ? (a.isMilestone ? '🎉' : _streakEmoji)
                  : WakeUpStatus.adjusted.emoji,
              headline: _headline(l10n),
              accent: accent,
              controller: _controller,
              isSuccess: _isSuccess,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
              child: Column(
                children: [
                  _WeekStrip(
                    achievement: a,
                    accent: accent,
                    controller: _controller,
                    isSuccess: _isSuccess,
                  ),
                  const SizedBox(height: 22),
                  _Stats(
                    achievement: a,
                    personaType: widget.personaType,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: accent.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isSuccess
                        ? l10n.achievementClose
                        : l10n.achievementAdjustedClose,
                    style: TextStyle(
                      color: accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.emoji,
    required this.headline,
    required this.accent,
    required this.controller,
    required this.isSuccess,
  });

  final String emoji;
  final String headline;
  final Color accent;
  final AnimationController controller;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.2),
            accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _HeaderEmoji(
            emoji: emoji,
            controller: controller,
            isSuccess: isSuccess,
          ),
          const SizedBox(height: 10),
          Text(
            headline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}

/// 見出しの絵文字の入り方。ここだけで success / adjusted の性格の差を作る
class _HeaderEmoji extends StatelessWidget {
  const _HeaderEmoji({
    required this.emoji,
    required this.controller,
    required this.isSuccess,
  });

  final String emoji;
  final AnimationController controller;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final text = Text(emoji, style: const TextStyle(fontSize: 44));

    if (isSuccess) {
      // できた日は下から弾んで出る（＝勝ち取ったものが現れる）
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
        ),
        child: text,
      );
    }

    // 調整日は雲が横から流れ込む。弾ませないのは、跳ねると「出来事」になって
    // しまうため。ここで欲しいのは出来事ではなく、静かに過ぎていく時間の側
    final drift = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: drift,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.5, 0),
          end: Offset.zero,
        ).animate(drift),
        child: text,
      ),
    );
  }
}

/// 今週7日分。今日だけが遅れて入る＝「いま置かれた」ことが分かる
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.achievement,
    required this.accent,
    required this.controller,
    required this.isSuccess,
  });

  final DailyAchievement achievement;
  final Color accent;
  final AnimationController controller;
  final bool isSuccess;

  static const _labelKeys = [
    'weekdayMon',
    'weekdayTue',
    'weekdayWed',
    'weekdayThu',
    'weekdayFri',
    'weekdaySat',
    'weekdaySun',
  ];

  String _label(AppLocalizations l10n, DateTime day) {
    // DateTime.weekday は 1=月 … 7=日
    switch (_labelKeys[day.weekday - 1]) {
      case 'weekdayMon':
        return l10n.weekdayMon;
      case 'weekdayTue':
        return l10n.weekdayTue;
      case 'weekdayWed':
        return l10n.weekdayWed;
      case 'weekdayThu':
        return l10n.weekdayThu;
      case 'weekdayFri':
        return l10n.weekdayFri;
      case 'weekdaySat':
        return l10n.weekdaySat;
      default:
        return l10n.weekdaySun;
    }
  }

  /// 今日のマークの置かれ方。できた日は弾み、調整日はすっと収まる
  Widget _placeToday(Widget dot) {
    if (isSuccess) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: controller,
          curve: const Interval(0.5, 1, curve: Curves.elasticOut),
        ),
        child: dot,
      );
    }

    final settle = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.45, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: settle,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(settle),
        child: dot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (i) {
        final day = achievement.weekStart.add(Duration(days: i));
        final isToday = i == achievement.todayIndex;
        final dot = _WeekDot(
          status: achievement.weekStatuses[i],
          accent: accent,
          isToday: isToday,
        );

        return Column(
          children: [
            Text(
              _label(l10n, day),
              style: TextStyle(
                fontSize: 11,
                color: isToday ? accent : AppColors.textMuted,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: Center(child: isToday ? _placeToday(dot) : dot),
            ),
          ],
        );
      }),
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.status,
    required this.accent,
    required this.isToday,
  });

  final WakeUpStatus? status;
  final Color accent;
  final bool isToday;

  /// 今日だけリングで囲って「ここ」を示す（大きさだけだと差が読めない）
  Widget _ringed(Widget child) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 2),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 今日だけひと回り大きく、周りにリングを立てる。
    // accent は既存のドット色と同じセージなので、色を変えるだけでは差がつかない
    // （＝「いま置かれた」ことが読めない）。大きさとリングで差をつける。
    final size = isToday ? 28.0 : 20.0;

    if (status == WakeUpStatus.success) {
      final dot = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.dayCheckedCircle
              // 今日を目立たせるため、過ぎた日はトーンを落とす
              : AppColors.dayCheckedCircle.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: isToday ? 11 : 8,
          height: isToday ? 11 : 8,
          decoration: BoxDecoration(
            color: AppColors.dayCheckedCircleInner,
            shape: BoxShape.circle,
          ),
        ),
      );

      return isToday ? _ringed(dot) : dot;
    }

    if (status == WakeUpStatus.rested || status == WakeUpStatus.adjusted) {
      final mark = SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            status!.emoji,
            style: TextStyle(fontSize: isToday ? 18 : 13),
          ),
        ),
      );

      // 今日が調整日のときはここが主役になるので、success と同じ扱いで囲む
      return isToday ? _ringed(mark) : mark;
    }

    // 未記録・未来は空欄（薄いリングだけ置いて位置を示す）
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({
    required this.achievement,
    required this.personaType,
    required this.l10n,
  });

  final DailyAchievement achievement;
  final PersonaType personaType;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final actual = achievement.actualWakeUpTime;
    final diff = achievement.diffFromTarget;

    final tiles = <Widget>[];

    // 手動で記録した日は起床時刻を持たないので、その枠ごと出さない
    if (actual != null) {
      tiles.add(_StatTile(
        label: l10n.achievementWokeAt,
        value: DateFormat.Hm(locale).format(actual),
        sub: _diffText(diff),
      ));
    }

    tiles.add(_StatTile(
      label: l10n.achievementThisMonth,
      value: l10n.dayCount(achievement.monthSuccessDays),
    ));

    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }

  /// 目標との差。ただし「遅い」は gentle では出さない。
  ///
  /// success の日は ±30分以内なので、報酬の画面で遅刻を蒸し返すと達成感を削るだけ。
  /// adjusted の日はそもそも目標から外れた日なので、分数を突きつけると
  /// 「何分の負けか」を数える画面になる。どちらも厳しめのペルソナを選んだ人にだけ返す
  /// （＝ユーザーが自分で選んだ厳しさの範囲に収める）。
  String? _diffText(Duration? diff) {
    if (diff == null) return null;
    final minutes = diff.inMinutes;
    if (minutes == 0) return l10n.achievementOnTarget;
    if (minutes < 0) return l10n.achievementEarlyBy(-minutes);
    return personaType == PersonaType.strict
        ? l10n.achievementLateBy(minutes)
        : null;
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.sub});

  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
