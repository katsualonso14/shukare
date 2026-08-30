import 'package:intl/intl.dart';

import '../entity/mbti.dart';
import '../entity/persona_type.dart';
import '../entity/wake_up_record.dart';
import '../entity/wake_up_status.dart';

/// 先月の達成状況をまとめたレポートデータ
class MonthlyReport {
  const MonthlyReport({
    required this.monthStart,
    required this.monthEnd,
    required this.totalDays,
    required this.successDays,
    required this.failedDays,
    required this.noneDays,
    required this.successRate,
  });

  final DateTime monthStart;
  final DateTime monthEnd;
  final int totalDays;
  final int successDays;
  final int failedDays;
  final int noneDays;
  final double successRate;

  int get achievementLevel {
    if (successRate >= 1.0) return 5;
    if (successRate >= 0.8) return 4;
    if (successRate >= 0.6) return 3;
    if (successRate >= 0.4) return 2;
    return 1;
  }
}

/// 先週の達成状況をまとめたレポートデータ
class WeeklyReport {
  const WeeklyReport({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.totalDays,
    required this.successDays,
    required this.failedDays,
    required this.noneDays,
    required this.successRate,
    required this.records,
  });

  /// 週の開始日
  final DateTime weekStartDate;

  /// 週の終了日
  final DateTime weekEndDate;

  /// 集計対象の日数（7日）
  final int totalDays;

  /// 成功した日数
  final int successDays;

  /// 失敗した日数
  final int failedDays;

  /// 未記録の日数
  final int noneDays;

  /// 成功率（0.0〜1.0）
  final double successRate;

  /// 先週の全記録
  final List<WakeUpRecord?> records;

  /// 達成度合いに応じたレベル（5段階）
  /// 5: 完璧（100%）
  /// 4: 素晴らしい（80%以上）
  /// 3: 良い（60%以上）
  /// 2: まあまあ（40%以上）
  /// 1: もっと頑張ろう（40%未満）
  int get achievementLevel {
    if (successRate >= 1.0) return 5;
    if (successRate >= 0.8) return 4;
    if (successRate >= 0.6) return 3;
    if (successRate >= 0.4) return 2;
    return 1;
  }

  @override
  String toString() {
    return 'WeeklyReport(${DateFormat('M/d').format(weekStartDate)}〜${DateFormat('M/d').format(weekEndDate)}, '
        'success: $successDays/$totalDays, rate: ${(successRate * 100).toStringAsFixed(0)}%)';
  }
}

/// ウィークリーレポートのロジックを提供するサービス
class WeeklyReportService {
  const WeeklyReportService();

  /// 今日の曜日を判定し、レポートを表示すべきかを返す
  ///
  /// [weekStartSunday] が true の場合は日曜始まり、false の場合は月曜始まり
  /// - 月曜始まり: 月曜日に表示
  /// - 日曜始まり: 日曜日に表示
  bool shouldShowReport({
    required DateTime now,
    required bool weekStartSunday,
    required DateTime? lastShownDate,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final weekday = now.weekday; // 1=月曜, 7=日曜

    // 表示すべき曜日を判定（週明け = 新しい週の最初の日）
    final shouldShowToday = weekStartSunday
        ? weekday == DateTime.sunday  // 日曜始まりなら日曜日
        : weekday == DateTime.monday; // 月曜始まりなら月曜日

    if (!shouldShowToday) return false;

    // 既に今日表示済みならスキップ
    if (lastShownDate != null) {
      final lastShown = DateTime(
        lastShownDate.year,
        lastShownDate.month,
        lastShownDate.day,
      );
      if (lastShown == today) return false;
    }

    return true;
  }

  /// 先週のデータを集計してレポートを生成
  ///
  /// [weekStartSunday] が true の場合は日曜始まり、false の場合は月曜始まり
  WeeklyReport generateReport({
    required DateTime now,
    required Map<String, WakeUpRecord> allRecords,
    required bool weekStartSunday,
  }) {
    final today = DateTime(now.year, now.month, now.day);

    // 先週の範囲を計算
    final (weekStart, weekEnd) = _getLastWeekRange(
      today: today,
      weekStartSunday: weekStartSunday,
    );

    // 先週の各日の記録を取得
    final List<WakeUpRecord?> weekRecords = [];
    int successCount = 0;
    int failedCount = 0;
    int noneCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final record = allRecords[key];

      weekRecords.add(record);

      if (record == null || record.status == WakeUpStatus.none) {
        noneCount++;
      } else if (record.status == WakeUpStatus.success) {
        successCount++;
      } else {
        failedCount++;
      }
    }

    final successRate = successCount / 7.0;

    return WeeklyReport(
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      totalDays: 7,
      successDays: successCount,
      failedDays: failedCount,
      noneDays: noneCount,
      successRate: successRate,
      records: weekRecords,
    );
  }

  /// 先週の開始日と終了日を取得
  (DateTime weekStart, DateTime weekEnd) _getLastWeekRange({
    required DateTime today,
    required bool weekStartSunday,
  }) {
    // 今週の開始日を計算
    late DateTime thisWeekStart;
    if (weekStartSunday) {
      // 日曜始まり: 今日が日曜(7)なら今日、それ以外は前の日曜
      final daysFromSunday = today.weekday % 7;
      thisWeekStart = today.subtract(Duration(days: daysFromSunday));
    } else {
      // 月曜始まり: 今日が月曜(1)なら今日、それ以外は前の月曜
      final daysFromMonday = (today.weekday - 1) % 7;
      thisWeekStart = today.subtract(Duration(days: daysFromMonday));
    }

    // 先週の開始日と終了日
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    return (lastWeekStart, lastWeekEnd);
  }

  /// 指定した日付を含む週のレポートを生成
  /// [date] が週の途中の場合は、その日までの経過日数を分母として達成率を計算する
  WeeklyReport generateReportForWeek({
    required DateTime date,
    required Map<String, WakeUpRecord> allRecords,
    required bool weekStartSunday,
  }) {
    final dayNorm = DateTime(date.year, date.month, date.day);

    late DateTime weekStart;
    if (weekStartSunday) {
      final daysFromSunday = dayNorm.weekday % 7;
      weekStart = dayNorm.subtract(Duration(days: daysFromSunday));
    } else {
      final daysFromMonday = (dayNorm.weekday - 1) % 7;
      weekStart = dayNorm.subtract(Duration(days: daysFromMonday));
    }
    final weekEnd = weekStart.add(const Duration(days: 6));

    // 週の開始から今日までの経過日数（1〜7）
    final elapsedDays = dayNorm.difference(weekStart).inDays + 1;

    final List<WakeUpRecord?> weekRecords = [];
    int successCount = 0;
    int failedCount = 0;
    int noneCount = 0;

    for (int i = 0; i < 7; i++) {
      final d = weekStart.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      final record = allRecords[key];
      weekRecords.add(record);

      // 経過日数分だけ集計（未来の日はカウントしない）
      if (i < elapsedDays) {
        if (record == null || record.status == WakeUpStatus.none) {
          noneCount++;
        } else if (record.status == WakeUpStatus.success) {
          successCount++;
        } else {
          failedCount++;
        }
      }
    }

    return WeeklyReport(
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      totalDays: elapsedDays,
      successDays: successCount,
      failedDays: failedCount,
      noneDays: noneCount,
      successRate: successCount / elapsedDays,
      records: weekRecords,
    );
  }

  /// パーソナタイプとMBTIに基づいたフィードバックメッセージを生成
  String getFeedbackMessage({
    required PersonaType personaType,
    required MBTI? mbti,
    required WeeklyReport report,
    String locale = 'ja',
  }) {
    final level = report.achievementLevel;
    if (personaType == PersonaType.strict) {
      return _getStrictMessage(level, mbti, report, locale);
    } else {
      return _getGentleMessage(level, mbti, report, locale);
    }
  }

  String _getStrictMessage(int level, MBTI? mbti, WeeklyReport report, String locale) {
    final rate = (report.successRate * 100).toStringAsFixed(0);
    final success = report.successDays;
    final total = report.totalDays;
    final missed = total - success;

    final isAnalyst =
        mbti != null && ['INTJ', 'INTP', 'ENTJ', 'ENTP'].contains(mbti.code);
    final isSentinel =
        mbti != null && ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'].contains(mbti.code);

    if (locale != 'ja') {
      switch (level) {
        case 5:
          if (isAnalyst) {
            return 'A perfect result. $success/$total days ($rate%). '
                'Maintain this optimized pattern.';
          }
          if (isSentinel) {
            return 'A disciplined week. $success/$total ($rate%). '
                'Consistency is the key to success.';
          }
          return 'Perfect. $success of $total days at $rate%. '
              'Keep this standard up this week too.';
        case 4:
          if (isAnalyst) {
            return 'Good results, but room to improve. $success/$total ($rate%). '
                'Analyze the $missed missed days.';
          }
          return 'Not bad. $success/$total at $rate%. '
              'But you could have done more. Don\'t get soft.';
        case 3:
          if (isSentinel) {
            return '$success/$total days ($rate%). '
                'Still room to improve. Rethink your plan and build the habit.';
          }
          return '$rate% is not enough. '
              'Getting over half is the bare minimum. Sharpen up.';
        case 2:
          return 'A $rate% rate is too low. Only $success days achieved. '
              'No excuses — start fresh tomorrow.';
        default:
          return '$rate%. Bluntly: at this rate, you won\'t form a habit. '
              'Change this week.';
      }
    }

    switch (level) {
      case 5:
        if (isAnalyst) {
          return '完璧な結果だ。$total日中$success日達成（$rate%）。'
              'この最適化されたパターンを維持せよ。';
        }
        if (isSentinel) {
          return '規律正しい1週間だった。$success/$total日達成（$rate%）。'
              'この習慣を継続することが成功の鍵だ。';
        }
        return '完璧だ。$total日中$success日達成、達成率$rate%。'
            '今週もこの水準を維持しろ。';
      case 4:
        if (isAnalyst) {
          return '良好な結果だが、改善の余地がある。$success/$total日（$rate%）。'
              '残り${total - success}日の原因を分析しろ。';
        }
        return '悪くない。$success/$total日達成で$rate%。'
            'だが、残りの日も達成できたはずだ。甘えるな。';
      case 3:
        if (isSentinel) {
          return '$success/$total日達成（$rate%）。'
              'まだ改善すべき点がある。計画を見直し、習慣化を進めろ。';
        }
        return '$rate%の達成率では不十分だ。'
            '週の半分以上を達成するのは最低ラインだ。気を引き締めろ。';
      case 2:
        return '達成率$rate%は低すぎる。$success日しか達成できていない。'
            '言い訳をせず、明日から本気を出せ。';
      default:
        return '達成率$rate%。厳しいことを言う。'
            'このままでは習慣は身につかない。今週こそ変われ。';
    }
  }

  String _getGentleMessage(int level, MBTI? mbti, WeeklyReport report, String locale) {
    final rate = (report.successRate * 100).toStringAsFixed(0);
    final success = report.successDays;
    final total = report.totalDays;

    final isDiplomat =
        mbti != null && ['INFJ', 'INFP', 'ENFJ', 'ENFP'].contains(mbti.code);
    final isExplorer =
        mbti != null && ['ISTP', 'ISFP', 'ESTP', 'ESFP'].contains(mbti.code);

    if (locale != 'ja') {
      switch (level) {
        case 5:
          if (isDiplomat) {
            return 'What an amazing week! You hit all $total days — incredible✨ '
                'You took care of yourself and kept going.';
          }
          return 'Wow, perfect! $success of $total days, $rate%! 🎉 '
              'You worked so hard. Give yourself a pat on the back!';
        case 4:
          if (isExplorer) {
            return 'You did $success days! $rate% achievement! '
                'Going at your own pace is beautiful✨';
          }
          return '$success/$total days at $rate%, great pace! '
              'Almost perfect — you\'re doing really well😊';
        case 3:
          if (isDiplomat) {
            return 'You got $success days. It doesn\'t have to be perfect. '
                'The effort is what counts💕';
          }
          return '$rate%, more than half! Don\'t rush — '
              'just keep going at your own pace🌱';
        case 2:
          return '$success days last week. Maybe it was a tough one? '
              'Don\'t push too hard — let\'s do what we can🤗';
        default:
          return 'Tough week… but that\'s okay! '
              'A new week has started — let\'s do it together💪';
      }
    }

    switch (level) {
      case 5:
        if (isDiplomat) {
          return '素晴らしい1週間だったね！$total日全部達成できたの、本当にすごい✨ '
              '自分を大切にしながら頑張れた証拠だよ。';
        }
        return 'わあ、完璧！$total日中$success日達成、$rate%！🎉 '
            '本当によく頑張ったね。自分を褒めてあげて！';
      case 4:
        if (isExplorer) {
          return '$success日も達成できたんだね！達成率$rate%！ '
              '自分のペースで続けられてるのが素敵だよ✨';
        }
        return '$success/$total日達成で$rate%、すごくいい調子！ '
            'あと少しで完璧だったけど、十分頑張ってるよ😊';
      case 3:
        if (isDiplomat) {
          return '$success日達成できたね。完璧じゃなくても大丈夫。'
              '頑張ろうとした気持ちが大切だよ💕';
        }
        return '$rate%の達成率、半分以上できてるよ！ '
            '焦らず、自分のペースで続けていこうね🌱';
      case 2:
        return '先週は$success日達成だったね。忙しかったのかな？ '
            '無理しないで、できる範囲で一緒に頑張ろう🤗';
      default:
        return '先週はちょっと難しかったかな…でも大丈夫！ '
            '新しい週が始まったし、また一緒に頑張ろうね💪';
    }
  }

  /// サブタイトル（短い要約）を生成
  String getSubtitle({
    required PersonaType personaType,
    required WeeklyReport report,
    String locale = 'ja',
  }) {
    final rate = (report.successRate * 100).toStringAsFixed(0);
    final success = report.successDays;
    final total = report.totalDays;

    if (locale != 'ja') {
      return personaType == PersonaType.strict
          ? 'Rate: $rate% ($success/$total days)'
          : '$success of $total days done! ($rate%)';
    }
    if (personaType == PersonaType.strict) {
      return '達成率: $rate%（$success/$total日）';
    } else {
      return '$total日中$success日達成！（$rate%）';
    }
  }

  /// 月初（1日）にレポートを表示すべきかを返す
  bool shouldShowMonthlyReport({
    required DateTime now,
    required DateTime? lastShownDate,
  }) {
    if (now.day != 1) return false;
    final today = DateTime(now.year, now.month, now.day);
    if (lastShownDate != null) {
      final lastShown = DateTime(
        lastShownDate.year,
        lastShownDate.month,
        lastShownDate.day,
      );
      if (lastShown == today) return false;
    }
    return true;
  }

  /// 先月のデータを集計して月次レポートを生成
  MonthlyReport generateMonthlyReport({
    required DateTime now,
    required Map<String, WakeUpRecord> allRecords,
  }) {
    // Dart の DateTime は month=0 を前月12月に正規化する
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 1)
        .subtract(const Duration(days: 1));
    final totalDays = lastMonthEnd.day;

    int successCount = 0;
    int failedCount = 0;
    int noneCount = 0;

    for (int d = 1; d <= totalDays; d++) {
      final date =
          DateTime(lastMonthStart.year, lastMonthStart.month, d);
      final key = DateFormat('yyyy-MM-dd').format(date);
      final record = allRecords[key];

      if (record == null || record.status == WakeUpStatus.none) {
        noneCount++;
      } else if (record.status == WakeUpStatus.success) {
        successCount++;
      } else {
        failedCount++;
      }
    }

    return MonthlyReport(
      monthStart: lastMonthStart,
      monthEnd: lastMonthEnd,
      totalDays: totalDays,
      successDays: successCount,
      failedDays: failedCount,
      noneDays: noneCount,
      successRate: successCount / totalDays,
    );
  }

  /// 月次レポートのタイトルを取得
  String getMonthlyTitle({
    required PersonaType personaType,
    required MonthlyReport report,
    String locale = 'ja',
  }) {
    final level = report.achievementLevel;
    if (locale != 'ja') {
      if (personaType == PersonaType.strict) {
        switch (level) {
          case 5: return 'A Perfect Month';
          case 4: return 'Good Results';
          case 3: return 'Passing Grade';
          case 2: return 'Needs Improvement';
          default: return 'Monthly Reflection';
        }
      } else {
        switch (level) {
          case 5: return 'Best Month Ever! ✨';
          case 4: return 'Well Done!';
          case 3: return 'Good Going!';
          case 2: return 'Good Job';
          default: return 'A New Month Begins';
        }
      }
    }
    if (personaType == PersonaType.strict) {
      switch (level) {
        case 5: return '完璧な1ヶ月';
        case 4: return '良好な結果';
        case 3: return '及第点';
        case 2: return '改善が必要';
        default: return '月の振り返り';
      }
    } else {
      switch (level) {
        case 5: return '最高の1ヶ月！✨';
        case 4: return 'よく頑張ったね！';
        case 3: return 'いい調子！';
        case 2: return 'お疲れさま';
        default: return '新しい月のはじまり';
      }
    }
  }

  /// 月次レポートのサブタイトルを取得
  String getMonthlySubtitle({
    required PersonaType personaType,
    required MonthlyReport report,
    String locale = 'ja',
  }) {
    final rate = (report.successRate * 100).toStringAsFixed(0);
    final success = report.successDays;
    final total = report.totalDays;
    if (locale != 'ja') {
      return personaType == PersonaType.strict
          ? 'Rate: $rate% ($success/$total days)'
          : '$success of $total days done! ($rate%)';
    }
    return personaType == PersonaType.strict
        ? '達成率: $rate%（$success/$total日）'
        : '$total日中$success日達成！（$rate%）';
  }

  /// 月次レポートのフィードバックメッセージを生成
  String getMonthlyFeedbackMessage({
    required PersonaType personaType,
    required MBTI? mbti,
    required MonthlyReport report,
    String locale = 'ja',
  }) {
    final level = report.achievementLevel;
    if (personaType == PersonaType.strict) {
      return _getStrictMonthlyMessage(level, mbti, report, locale);
    } else {
      return _getGentleMonthlyMessage(level, mbti, report, locale);
    }
  }

  String _getStrictMonthlyMessage(int level, MBTI? mbti, MonthlyReport report, String locale) {
    final rate = (report.successRate * 100).toStringAsFixed(0);
    final success = report.successDays;
    final total = report.totalDays;
    final missed = total - success;
    if (locale != 'ja') {
      switch (level) {
        case 5: return '$success of $total days ($rate%). A perfect month. Keep the habit going.';
        case 4: return '$success/$total ($rate%). Well done, but analyze the $missed missed days.';
        case 3: return '$rate%. Over half — but still room to improve. Review your plan.';
        case 2: return 'A $rate% rate is low. No excuses — go all out this month.';
        default: return '$rate%. At this rate, the habit won\'t stick. Change this month.';
      }
    }
    switch (level) {
      case 5:
        return '$total日中$success日達成（$rate%）。完璧な1ヶ月だ。'
            'この習慣を今月も維持せよ。';
      case 4:
        return '$success/$total日（$rate%）。上出来だが、'
            '残り${total - success}日の原因を分析して今月に活かせ。';
      case 3:
        return '$rate%の達成率。半分以上はできているが、'
            'まだ改善の余地がある。計画を見直せ。';
      case 2:
        return '達成率$rate%は低い。言い訳せず、今月から本気を出せ。';
      default:
        return '達成率$rate%。このままでは習慣は身につかない。'
            '今月こそ変われ。';
    }
  }

  String _getGentleMonthlyMessage(int level, MBTI? mbti, MonthlyReport report, String locale) {
    final rate = (report.successRate * 100).toStringAsFixed(0);
    final success = report.successDays;
    final total = report.totalDays;
    if (locale != 'ja') {
      switch (level) {
        case 5: return 'Wow, all $total days, $rate%! 🎉 You worked so hard. Give yourself a big reward!';
        case 4: return 'You did $success days! $rate%, amazing! Keep this up next month😊';
        case 3: return '$rate%, more than half! No rush — keep going at your own pace🌱';
        case 2: return '$success days last month. Was it busy? Don\'t push too hard — do what you can🤗';
        default: return 'A tough month… but that\'s okay! A new month has started — let\'s do it together💪';
      }
    }
    switch (level) {
      case 5:
        return 'わあ、$total日全部達成、$rate%！🎉 '
            '本当によく頑張ったね。自分を思い切り褒めてあげて！';
      case 4:
        return '$success日も達成できたんだね！達成率$rate%、すごくいい！ '
            '今月もこの調子で続けていこうね😊';
      case 3:
        return '$rate%、半分以上できてるよ！ '
            '焦らず自分のペースで。今月も一緒に頑張ろうね🌱';
      case 2:
        return '先月は$success日達成だったね。忙しかったのかな？ '
            '無理しないで、できる範囲で一緒に頑張ろう🤗';
      default:
        return '先月はちょっと難しかったかな…でも大丈夫！ '
            '新しい月が始まったし、また一緒に頑張ろうね💪';
    }
  }

  /// レポートのタイトルを取得
  String getTitle({
    required PersonaType personaType,
    required WeeklyReport report,
    String locale = 'ja',
  }) {
    final level = report.achievementLevel;
    if (locale != 'ja') {
      if (personaType == PersonaType.strict) {
        switch (level) {
          case 5: return 'A Perfect Week';
          case 4: return 'Good Results';
          case 3: return 'Passing Grade';
          case 2: return 'Needs Improvement';
          default: return 'Time to Reflect';
        }
      } else {
        switch (level) {
          case 5: return 'Amazing! Perfect✨';
          case 4: return 'Well Done!';
          case 3: return 'Good Going!';
          case 2: return 'Good Job';
          default: return 'A New Week Begins';
        }
      }
    }
    if (personaType == PersonaType.strict) {
      switch (level) {
        case 5: return '完璧な1週間';
        case 4: return '良好な結果';
        case 3: return '及第点';
        case 2: return '改善が必要';
        default: return '振り返りの時間';
      }
    } else {
      switch (level) {
        case 5: return 'すごい！完璧✨';
        case 4: return 'よく頑張ったね！';
        case 3: return 'いい調子！';
        case 2: return 'お疲れさま';
        default: return '新しい週のはじまり';
      }
    }
  }
}
