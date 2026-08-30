import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entity/notification_settings.dart';

/// ローカルキーバリュー保存（SharedPreferences）のデータソース
class PreferenceDatasource {
  PreferenceDatasource(this._prefs);
  final SharedPreferences _prefs;

  static const String _keyCheckedDates = 'checked_dates';
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyNotificationHour = 'notification_hour';
  static const String _keyNotificationMinute = 'notification_minute';
  static const String _keyCalendarWeekStartSunday = 'calendar_week_start_sunday';
  static const String _keyWakeUpRecords = 'wake_up_records';
  static const String _keyTargetWakeUpHour = 'target_wake_up_hour';
  static const String _keyTargetWakeUpMinute = 'target_wake_up_minute';
  static const String _keyUserMbti = 'user_mbti';
  static const String _keyUserPersonaType = 'user_persona_type';
  static const String _keyWeeklyReportLastShown = 'weekly_report_last_shown';
  static const String _keyMonthlyReportLastShown = 'monthly_report_last_shown';

  // --- Checked dates ---
  Future<Set<String>> getCheckedDates() async {
    final raw = _prefs.getString(_keyCheckedDates);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      return (list ?? [])
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> setCheckedDates(Set<String> dates) async {
    final list = dates.toList()..sort();
    await _prefs.setString(_keyCheckedDates, jsonEncode(list));
  }

  // --- Notification settings ---
  NotificationSettings getNotificationSettings() {
    final enabled = _prefs.getBool(_keyNotificationEnabled) ?? true;
    final hour = _prefs.getInt(_keyNotificationHour) ?? 20;
    final minute = _prefs.getInt(_keyNotificationMinute) ?? 0;
    return NotificationSettings(enabled: enabled, hour: hour, minute: minute);
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationEnabled, enabled);
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    await _prefs.setInt(_keyNotificationHour, hour);
    await _prefs.setInt(_keyNotificationMinute, minute);
  }

  // --- Calendar week start (true = 日曜始まり, false = 月曜始まり) ---
  bool getCalendarWeekStartSunday() =>
      _prefs.getBool(_keyCalendarWeekStartSunday) ?? false;

  Future<void> setCalendarWeekStartSunday(bool value) async {
    await _prefs.setBool(_keyCalendarWeekStartSunday, value);
  }

  /// チェック済み日付をすべて削除（データの全リセット）
  Future<void> clearAllCheckedDates() async {
    await _prefs.remove(_keyCheckedDates);
  }

  // --- Wake Up Records (新しいステータスベースの記録) ---
  
  /// すべての起床記録を取得
  Future<Map<String, Map<String, dynamic>>> getWakeUpRecords() async {
    final raw = _prefs.getString(_keyWakeUpRecords);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>?;
      if (decoded == null) return {};
      
      final result = <String, Map<String, dynamic>>{};
      decoded.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          result[key] = value;
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  /// すべての起床記録を保存
  Future<void> setWakeUpRecords(Map<String, Map<String, dynamic>> records) async {
    await _prefs.setString(_keyWakeUpRecords, jsonEncode(records));
  }

  /// すべての起床記録をクリア
  Future<void> clearAllWakeUpRecords() async {
    await _prefs.remove(_keyWakeUpRecords);
  }

  // --- Target Wake Up Time (目標起床時刻) ---

  /// 目標起床時刻を取得（デフォルト: 6:00）
  Map<String, int> getTargetWakeUpTime() {
    final hour = _prefs.getInt(_keyTargetWakeUpHour) ?? 6;
    final minute = _prefs.getInt(_keyTargetWakeUpMinute) ?? 0;
    return {'hour': hour, 'minute': minute};
  }

  /// 目標起床時刻を保存
  Future<void> setTargetWakeUpTime(int hour, int minute) async {
    await _prefs.setInt(_keyTargetWakeUpHour, hour);
    await _prefs.setInt(_keyTargetWakeUpMinute, minute);
  }

  // --- User Profile (MBTI & PersonaType) ---

  /// MBTIを取得（未設定の場合はnull）
  String? getUserMbti() => _prefs.getString(_keyUserMbti);

  /// MBTIを保存
  Future<void> setUserMbti(String? mbti) async {
    if (mbti == null) {
      await _prefs.remove(_keyUserMbti);
    } else {
      await _prefs.setString(_keyUserMbti, mbti);
    }
  }

  /// パーソナタイプを取得（デフォルト: gentle）
  String getUserPersonaType() =>
      _prefs.getString(_keyUserPersonaType) ?? 'gentle';

  /// パーソナタイプを保存
  Future<void> setUserPersonaType(String personaType) async {
    await _prefs.setString(_keyUserPersonaType, personaType);
  }

  // --- Weekly Report (ウィークリーレポート表示済みフラグ) ---

  /// ウィークリーレポートの最終表示日を取得
  DateTime? getWeeklyReportLastShown() {
    final raw = _prefs.getString(_keyWeeklyReportLastShown);
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// ウィークリーレポートの最終表示日を保存
  Future<void> setWeeklyReportLastShown(DateTime date) async {
    await _prefs.setString(_keyWeeklyReportLastShown, date.toIso8601String());
  }

  // --- Monthly Report ---

  DateTime? getMonthlyReportLastShown() {
    final raw = _prefs.getString(_keyMonthlyReportLastShown);
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> setMonthlyReportLastShown(DateTime date) async {
    await _prefs.setString(
        _keyMonthlyReportLastShown, date.toIso8601String());
  }
}
