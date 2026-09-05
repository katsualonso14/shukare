import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  const AnalyticsService(this._analytics);
  final FirebaseAnalytics _analytics;

  Future<void> logWakeUpRecorded(String status) => _analytics.logEvent(
        name: 'wake_up_recorded',
        parameters: {'status': status},
      );

  Future<void> logWakeUpDeleted() =>
      _analytics.logEvent(name: 'wake_up_deleted');

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  Future<void> logWeeklyReportViewed() =>
      _analytics.logEvent(name: 'weekly_report_viewed');

  Future<void> logMonthlyReportViewed() =>
      _analytics.logEvent(name: 'monthly_report_viewed');

  /// 今日のモーダルを見せた。[status] は success / adjusted。
  ///
  /// status を持たせる理由: できた日と調整日で同じイベント名を使うので、
  /// これが無いと「調整日のモーダルが閉じられているだけ」なのか
  /// 「達成が続いている」のかが後から区別できない。
  Future<void> logDailyAchievementViewed({
    required String status,
    required int streak,
    required bool isMilestone,
  }) =>
      _analytics.logEvent(
        name: 'daily_achievement_viewed',
        parameters: {
          'status': status,
          'streak': streak,
          'is_milestone': isMilestone ? 1 : 0,
        },
      );
}
