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

  Future<void> logDailyAchievementViewed({
    required int streak,
    required bool isMilestone,
  }) =>
      _analytics.logEvent(
        name: 'daily_achievement_viewed',
        parameters: {'streak': streak, 'is_milestone': isMilestone ? 1 : 0},
      );
}
