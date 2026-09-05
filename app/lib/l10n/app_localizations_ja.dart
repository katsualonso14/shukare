// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTagline => '今日も、少しだけ。';

  @override
  String get editRecord => '記録を修正する';

  @override
  String streakDays(int count, String emoji) {
    return '$count日続いてる$emoji';
  }

  @override
  String streakStart(String emoji) {
    return '続きはここから$emoji';
  }

  @override
  String get settings => '設定';

  @override
  String get sectionGoal => '目標設定';

  @override
  String get sectionPersonalize => 'パーソナライズ';

  @override
  String get sectionNotification => '通知';

  @override
  String get sectionCalendar => 'カレンダー';

  @override
  String get sectionData => 'データ';

  @override
  String get targetWakeUpTime => '起床目標時間';

  @override
  String get targetWakeUpTimeSubtitle => 'この時間の前後30分以内で成功判定';

  @override
  String get wakeUpTimeHelpText => '起床目標時間を選択';

  @override
  String wakeUpTimeSet(String time) {
    return '起床目標時間を$timeに設定しました';
  }

  @override
  String get appPersonality => 'アプリの性格';

  @override
  String get appPersonalitySubtitle => '優しく励ますか、厳しく背中を押すかを選べます';

  @override
  String get personaGentle => '😊 優しい';

  @override
  String get personaGentleDesc => 'やわらかく応援';

  @override
  String get personaStrict => '💪 厳しい';

  @override
  String get personaStrictDesc => 'しっかり叱咤激励';

  @override
  String get mbtiType => '性格タイプ（MBTI）';

  @override
  String get mbtiNotSet => '未設定';

  @override
  String get selectMbtiTitle => '性格タイプを選択';

  @override
  String get mbtiSelectSubtitle => 'MBTIを選ぶとメッセージがより親しみやすくなります';

  @override
  String get mbtiGroupAnalyst => 'アナリスト（分析家）';

  @override
  String get mbtiGroupDiplomat => '外交官';

  @override
  String get mbtiGroupSentinel => '番人';

  @override
  String get mbtiGroupExplorer => '探検家';

  @override
  String get mbtiSkip => '設定しない';

  @override
  String get notificationEnable => '通知をする';

  @override
  String get notificationTime => '通知時刻';

  @override
  String get weekStart => '週の始まり';

  @override
  String get sunday => '日曜日';

  @override
  String get monday => '月曜日';

  @override
  String get resetAllData => 'データをすべてリセット';

  @override
  String get resetDataTitle => 'データのリセット';

  @override
  String get resetDataContent => 'チェックした日付データをすべて削除します。\nこの操作は取り消せません。よろしいですか？';

  @override
  String get reset => 'リセット';

  @override
  String get resetDone => 'データをリセットしました';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '設定';

  @override
  String get loadError => '読み込みに失敗しました';

  @override
  String get navCalendar => 'カレンダー';

  @override
  String get navStats => 'データ';

  @override
  String get weeklyRecordTitle => '今週の記録';

  @override
  String get weekdayMon => '月';

  @override
  String get weekdayTue => '火';

  @override
  String get weekdayWed => '水';

  @override
  String get weekdayThu => '木';

  @override
  String get weekdayFri => '金';

  @override
  String get weekdaySat => '土';

  @override
  String get weekdaySun => '日';

  @override
  String get statSuccess => 'できた';

  @override
  String get statRest => '休み・調整';

  @override
  String get statNone => '記録なし';

  @override
  String dayCount(int count) {
    return '$count日';
  }

  @override
  String get optionSuccess => 'できた';

  @override
  String get optionRested => '今日はゆっくり休めた日';

  @override
  String get optionAdjusted => '調整日';

  @override
  String get tapAgainToDelete => 'もう一度タップで削除';

  @override
  String achievementStreak(int count) {
    return '$count日連続';
  }

  @override
  String get achievementStart => 'はじめの1日';

  @override
  String achievementMilestone(int count) {
    return '$count日達成 🎉';
  }

  @override
  String get achievementWokeAt => '起床';

  @override
  String achievementEarlyBy(int minutes) {
    return '目標より$minutes分早い';
  }

  @override
  String achievementLateBy(int minutes) {
    return '目標より$minutes分遅い';
  }

  @override
  String get achievementOnTarget => '目標ぴったり';

  @override
  String get achievementThisMonth => '今月';

  @override
  String get achievementClose => '今日もいい朝';

  @override
  String get achievementAdjusted => '今日は調整日';

  @override
  String get achievementAdjustedClose => 'また明日';
}
