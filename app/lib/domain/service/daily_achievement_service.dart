import 'package:intl/intl.dart';

import '../entity/target_wake_up_time.dart';
import '../entity/wake_up_record.dart';
import '../entity/wake_up_status.dart';

/// 「今日の1日」をお披露目するための材料一式。
///
/// カレンダーのドットは AutoEvaluateWakeUpUsecase が起動時に無言で置いてしまうので、
/// ユーザーは今日の判定が下りた瞬間を目撃できない。この値オブジェクトはその瞬間を
/// 1枚のモーダルに再構成するために必要な数字だけを持つ（表示の判断は presentation 側）。
///
/// success（できた）と adjusted（調整日）の両方を運ぶ。名前は achievement のままだが、
/// 中身は「今日どうだったか」であって達成専用ではない。[status] で見分ける。
class DailyAchievement {
  const DailyAchievement({
    required this.date,
    required this.status,
    required this.streak,
    required this.weekStart,
    required this.weekStatuses,
    required this.todayIndex,
    required this.monthSuccessDays,
    this.actualWakeUpTime,
    this.diffFromTarget,
  });

  /// 対象日（＝今日）
  final DateTime date;

  /// 今日の判定。success か adjusted のどちらか
  final WakeUpStatus status;

  /// 今日を含む連続達成日数。adjusted の日は 0（＝連続は今日で途切れている）
  final int streak;

  /// 週ストリップの左端の日付
  final DateTime weekStart;

  /// 週ストリップ7日分。未記録・未来は null
  final List<WakeUpStatus?> weekStatuses;

  /// weekStatuses の中で今日が何番目か（0〜6）。ここに「ポン」と打ち込む
  final int todayIndex;

  /// 今月の success 日数
  final int monthSuccessDays;

  /// 実際に起きた時刻。自動判定を経ていない手動記録では null
  final DateTime? actualWakeUpTime;

  /// 目標時刻との差。負なら目標より早い。actualWakeUpTime が無いときは null
  final Duration? diffFromTarget;

  /// できた日か（演出の重さを分ける唯一の分岐点）
  bool get isSuccess => status == WakeUpStatus.success;

  /// 節目の日か（演出を強める）。調整日は節目にならない
  bool get isMilestone =>
      isSuccess && DailyAchievementService.isMilestone(streak);
}

/// 今日の達成モーダルを出すかどうかと、その中身を決めるサービス。
class DailyAchievementService {
  const DailyAchievementService();

  /// 特別扱いする連続日数。これ以降は100日ごと
  static const Set<int> _milestones = {3, 7, 14, 30, 50, 100};

  static bool isMilestone(int streak) {
    if (_milestones.contains(streak)) return true;
    return streak > 100 && streak % 100 == 0;
  }

  /// 今日まだ出していなければ true。
  ///
  /// 1日1回に絞る理由: 起動のたびに出ると「達成の報酬」ではなく
  /// 「起動時に出るポップアップ」になり、閉じる操作だけが習慣化する。
  bool shouldShow({required DateTime now, DateTime? lastShownDate}) {
    if (lastShownDate == null) return true;
    return !_isSameDay(now, lastShownDate);
  }

  /// モーダルを出す対象になる今日の判定。
  ///
  /// rested（🌙 ゆっくり休めた日）を外す理由: これはユーザーが自分で選んだ「休む」で、
  /// 判定が下りた出来事ではない。自分で決めたことをモーダルで報告し返す意味がない。
  static const Set<WakeUpStatus> _shownStatuses = {
    WakeUpStatus.success,
    WakeUpStatus.adjusted,
  };

  /// 今日が success か adjusted のときだけ材料を組み立てる。それ以外（休み・未記録）は null。
  DailyAchievement? build({
    required DateTime now,
    required Map<String, WakeUpRecord> allRecords,
    required TargetWakeUpTime targetTime,
    required bool weekStartSunday,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final todayRecord = allRecords[_key(today)];
    if (todayRecord == null || !_shownStatuses.contains(todayRecord.status)) {
      return null;
    }

    final weekStart = _weekStartOf(today, weekStartSunday: weekStartSunday);
    final weekStatuses = <WakeUpStatus?>[];
    for (var i = 0; i < 7; i++) {
      final d = weekStart.add(Duration(days: i));
      // 未来の日は「まだ何も起きていない」ので空欄のまま見せる
      weekStatuses.add(d.isAfter(today) ? null : allRecords[_key(d)]?.status);
    }

    final actual = todayRecord.actualWakeUpTime;
    final diff = actual?.difference(targetTime.toDateTimeOn(today));

    return DailyAchievement(
      date: today,
      status: todayRecord.status,
      streak: _streakEndingAt(today, allRecords),
      weekStart: weekStart,
      weekStatuses: weekStatuses,
      todayIndex: today.difference(weekStart).inDays,
      monthSuccessDays: _monthSuccessDays(today, allRecords),
      actualWakeUpTime: actual,
      diffFromTarget: diff,
    );
  }

  /// 指定日から過去に向かって success が途切れるまで数える
  int _streakEndingAt(DateTime from, Map<String, WakeUpRecord> allRecords) {
    var count = 0;
    var d = from;
    while (allRecords[_key(d)]?.status == WakeUpStatus.success) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  int _monthSuccessDays(DateTime day, Map<String, WakeUpRecord> allRecords) {
    final prefix = DateFormat('yyyy-MM').format(day);
    return allRecords.entries
        .where((e) =>
            e.key.startsWith(prefix) && e.value.status == WakeUpStatus.success)
        .length;
  }

  DateTime _weekStartOf(DateTime day, {required bool weekStartSunday}) {
    // DateTime.weekday は 1=月 … 7=日
    final offset =
        weekStartSunday ? day.weekday % 7 : (day.weekday - 1) % 7;
    return day.subtract(Duration(days: offset));
  }

  String _key(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
