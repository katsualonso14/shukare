// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Just a little, today.';

  @override
  String get editRecord => 'Edit record';

  @override
  String streakDays(int count, String emoji) {
    return '$count days going$emoji';
  }

  @override
  String streakStart(String emoji) {
    return 'Start here$emoji';
  }

  @override
  String get settings => 'Settings';

  @override
  String get sectionGoal => 'Goal';

  @override
  String get sectionPersonalize => 'Personalize';

  @override
  String get sectionNotification => 'Notification';

  @override
  String get sectionCalendar => 'Calendar';

  @override
  String get sectionData => 'Data';

  @override
  String get targetWakeUpTime => 'Wake-up goal';

  @override
  String get targetWakeUpTimeSubtitle =>
      'Success if within ±30 min of this time';

  @override
  String get wakeUpTimeHelpText => 'Select wake-up goal time';

  @override
  String wakeUpTimeSet(String time) {
    return 'Wake-up goal set to $time';
  }

  @override
  String get appPersonality => 'App personality';

  @override
  String get appPersonalitySubtitle =>
      'Choose gentle encouragement or tough love';

  @override
  String get personaGentle => '😊 Gentle';

  @override
  String get personaGentleDesc => 'Warm support';

  @override
  String get personaStrict => '💪 Strict';

  @override
  String get personaStrictDesc => 'Tough push';

  @override
  String get mbtiType => 'Personality type (MBTI)';

  @override
  String get mbtiNotSet => 'Not set';

  @override
  String get selectMbtiTitle => 'Select personality type';

  @override
  String get mbtiSelectSubtitle => 'Messages feel more personal with MBTI';

  @override
  String get mbtiGroupAnalyst => 'Analysts';

  @override
  String get mbtiGroupDiplomat => 'Diplomats';

  @override
  String get mbtiGroupSentinel => 'Sentinels';

  @override
  String get mbtiGroupExplorer => 'Explorers';

  @override
  String get mbtiSkip => 'Don\'t set';

  @override
  String get notificationEnable => 'Enable notifications';

  @override
  String get notificationTime => 'Notification time';

  @override
  String get weekStart => 'Week starts on';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get resetAllData => 'Reset all data';

  @override
  String get resetDataTitle => 'Reset Data';

  @override
  String get resetDataContent =>
      'This will delete all your check history.\nThis action cannot be undone. Continue?';

  @override
  String get reset => 'Reset';

  @override
  String get resetDone => 'Data has been reset';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Set';

  @override
  String get loadError => 'Failed to load';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navStats => 'Stats';

  @override
  String get weeklyRecordTitle => 'This week';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get statSuccess => 'Did it';

  @override
  String get statRest => 'Rest';

  @override
  String get statNone => 'No log';

  @override
  String dayCount(int count) {
    return '${count}d';
  }

  @override
  String get optionSuccess => 'Did it';

  @override
  String get optionRested => 'Rest day';

  @override
  String get optionAdjusted => 'Adjustment day';

  @override
  String get tapAgainToDelete => 'Tap again to remove';

  @override
  String achievementStreak(int count) {
    return '$count-day streak';
  }

  @override
  String get achievementStart => 'Day one';

  @override
  String achievementMilestone(int count) {
    return '$count days 🎉';
  }

  @override
  String get achievementWokeAt => 'Woke up';

  @override
  String achievementEarlyBy(int minutes) {
    return '$minutes min before target';
  }

  @override
  String achievementLateBy(int minutes) {
    return '$minutes min after target';
  }

  @override
  String get achievementOnTarget => 'Right on target';

  @override
  String get achievementThisMonth => 'This month';

  @override
  String get achievementClose => 'Good morning';

  @override
  String get achievementAdjusted => 'An adjusting day';

  @override
  String get achievementAdjustedClose => 'See you tomorrow';

  @override
  String weeklyReportRange(String start, String end) {
    return 'Looking back on $start - $end';
  }

  @override
  String get weeklyReportButtonGentle => 'Keep going this week!';

  @override
  String get weeklyReportButtonStrict => 'Got it';
}
