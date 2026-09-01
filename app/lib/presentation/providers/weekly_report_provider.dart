import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/service/weekly_report_service.dart';
import '../../infrastructure/di/infrastructure_providers.dart';
import '../di/presentation_providers.dart';
import 'calendar_week_start_provider.dart';
import 'locale_provider.dart';
import 'user_profile_provider.dart';
import 'wake_up_records_provider.dart';

// ─── Monthly Report Providers ─────────────────────────────────────────────────

final shouldShowMonthlyReportProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(weeklyReportServiceProvider);
  final datasource = ref.watch(preferenceDatasourceProvider);
  final now = DateTime.now();
  final lastShown = datasource.getMonthlyReportLastShown();
  return service.shouldShowMonthlyReport(now: now, lastShownDate: lastShown);
});

final monthlyReportProvider = FutureProvider<MonthlyReport?>((ref) async {
  final shouldShow =
      await ref.watch(shouldShowMonthlyReportProvider.future);
  if (!shouldShow) return null;
  final service = ref.watch(weeklyReportServiceProvider);
  final records = await ref.watch(wakeUpRecordsProvider.future);
  return service.generateMonthlyReport(
    now: DateTime.now(),
    allRecords: records,
  );
});

final monthlyReportTitleProvider =
    Provider.family<String, MonthlyReport>((ref, report) {
  final service = ref.watch(weeklyReportServiceProvider);
  final profile = ref.watch(userProfileProvider);
  final locale = ref.watch(currentLocaleProvider);
  return service.getMonthlyTitle(
      personaType: profile.personaType, report: report, locale: locale);
});

final monthlyReportSubtitleProvider =
    Provider.family<String, MonthlyReport>((ref, report) {
  final service = ref.watch(weeklyReportServiceProvider);
  final profile = ref.watch(userProfileProvider);
  final locale = ref.watch(currentLocaleProvider);
  return service.getMonthlySubtitle(
      personaType: profile.personaType, report: report, locale: locale);
});

final monthlyReportMessageProvider =
    Provider.family<String, MonthlyReport>((ref, report) {
  final service = ref.watch(weeklyReportServiceProvider);
  final profile = ref.watch(userProfileProvider);
  final locale = ref.watch(currentLocaleProvider);
  return service.getMonthlyFeedbackMessage(
    personaType: profile.personaType,
    mbti: profile.mbti,
    report: report,
    locale: locale,
  );
});

class MonthlyReportNotifier extends StateNotifier<DateTime?> {
  MonthlyReportNotifier(this._ref) : super(null);
  final Ref _ref;

  Future<void> markAsShown() async {
    final datasource = _ref.read(preferenceDatasourceProvider);
    final now = DateTime.now();
    await datasource.setMonthlyReportLastShown(now);
    state = now;
    _ref.invalidate(shouldShowMonthlyReportProvider);
  }
}

final monthlyReportNotifierProvider =
    StateNotifierProvider<MonthlyReportNotifier, DateTime?>((ref) {
  return MonthlyReportNotifier(ref);
});

/// ウィークリーレポートを表示すべきかどうかを判定するプロバイダー
final shouldShowWeeklyReportProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(weeklyReportServiceProvider);
  final datasource = ref.watch(preferenceDatasourceProvider);
  final weekStartSunday = ref.watch(calendarWeekStartSundayProvider);
  
  final now = DateTime.now();
  final lastShown = datasource.getWeeklyReportLastShown();
  
  return service.shouldShowReport(
    now: now,
    weekStartSunday: weekStartSunday,
    lastShownDate: lastShown,
  );
});

/// 先週のウィークリーレポートを生成するプロバイダー
final weeklyReportProvider = FutureProvider<WeeklyReport?>((ref) async {
  final shouldShow = await ref.watch(shouldShowWeeklyReportProvider.future);
  if (!shouldShow) return null;
  
  final service = ref.watch(weeklyReportServiceProvider);
  final weekStartSunday = ref.watch(calendarWeekStartSundayProvider);
  final recordsAsync = await ref.watch(wakeUpRecordsProvider.future);
  
  final now = DateTime.now();
  
  return service.generateReport(
    now: now,
    allRecords: recordsAsync,
    weekStartSunday: weekStartSunday,
  );
});

/// ウィークリーレポートのタイトルを取得するプロバイダー
final weeklyReportTitleProvider = Provider.family<String, WeeklyReport>((ref, report) {
  final service = ref.watch(weeklyReportServiceProvider);
  final profile = ref.watch(userProfileProvider);
  final locale = ref.watch(currentLocaleProvider);

  return service.getTitle(
    personaType: profile.personaType,
    report: report,
    locale: locale,
  );
});

/// ウィークリーレポートのサブタイトルを取得するプロバイダー
final weeklyReportSubtitleProvider = Provider.family<String, WeeklyReport>((ref, report) {
  final service = ref.watch(weeklyReportServiceProvider);
  final profile = ref.watch(userProfileProvider);
  final locale = ref.watch(currentLocaleProvider);

  return service.getSubtitle(
    personaType: profile.personaType,
    report: report,
    locale: locale,
  );
});

/// ウィークリーレポートのフィードバックメッセージを取得するプロバイダー
final weeklyReportMessageProvider = Provider.family<String, WeeklyReport>((ref, report) {
  final service = ref.watch(weeklyReportServiceProvider);
  final profile = ref.watch(userProfileProvider);
  final locale = ref.watch(currentLocaleProvider);

  return service.getFeedbackMessage(
    personaType: profile.personaType,
    mbti: profile.mbti,
    report: report,
    locale: locale,
  );
});

/// 今週のレポートを生成するプロバイダー（WeeklyStatsScreen 用）
final currentWeekReportProvider = FutureProvider<WeeklyReport>((ref) async {
  final service = ref.watch(weeklyReportServiceProvider);
  final weekStartSunday = ref.watch(calendarWeekStartSundayProvider);
  final records = await ref.watch(wakeUpRecordsProvider.future);

  return service.generateReportForWeek(
    date: DateTime.now(),
    allRecords: records,
    weekStartSunday: weekStartSunday,
  );
});

/// ウィークリーレポートの表示済みフラグを更新するプロバイダー
class WeeklyReportNotifier extends StateNotifier<DateTime?> {
  WeeklyReportNotifier(this._ref) : super(null);

  final Ref _ref;

  Future<void> markAsShown() async {
    final datasource = _ref.read(preferenceDatasourceProvider);
    final now = DateTime.now();
    await datasource.setWeeklyReportLastShown(now);
    state = now;
    
    // shouldShowWeeklyReportProvider を無効化して再評価させる
    _ref.invalidate(shouldShowWeeklyReportProvider);
  }
}

final weeklyReportNotifierProvider =
    StateNotifierProvider<WeeklyReportNotifier, DateTime?>((ref) {
  return WeeklyReportNotifier(ref);
});
