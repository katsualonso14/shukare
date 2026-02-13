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
}
