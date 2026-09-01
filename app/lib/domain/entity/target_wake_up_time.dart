/// 目標起床時刻の設定
class TargetWakeUpTime {
  const TargetWakeUpTime({
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;

  /// デフォルト値: 朝6時
  static const TargetWakeUpTime defaultTime = TargetWakeUpTime(hour: 6, minute: 0);

  /// JSON から復元
  factory TargetWakeUpTime.fromJson(Map<String, dynamic> json) {
    return TargetWakeUpTime(
      hour: json['hour'] as int? ?? 6,
      minute: json['minute'] as int? ?? 0,
    );
  }

  /// JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  /// HH:MM 形式の文字列を返す
  String toDisplayString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// 今日の日付で DateTime を生成
  DateTime toDateTimeToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// 指定の日付で DateTime を生成
  DateTime toDateTimeOn(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TargetWakeUpTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => 'TargetWakeUpTime($hour:$minute)';
}
