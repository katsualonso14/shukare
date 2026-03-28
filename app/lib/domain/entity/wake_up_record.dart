import 'wake_up_status.dart';

/// 特定の日の起床記録（ステータス + 実際の起床時刻）
class WakeUpRecord {
  const WakeUpRecord({
    required this.date,
    required this.status,
    this.actualWakeUpTime,
  });

  /// 記録の対象日（yyyy-MM-dd形式の日付）
  final DateTime date;

  /// 起床ステータス
  final WakeUpStatus status;

  /// 実際に起きた時刻（resting の場合は null）
  final DateTime? actualWakeUpTime;

  /// JSON から復元
  factory WakeUpRecord.fromJson(Map<String, dynamic> json) {
    return WakeUpRecord(
      date: DateTime.parse(json['date'] as String),
      status: WakeUpStatus.fromJson(json['status'] as String?) ??
          WakeUpStatus.tried,
      actualWakeUpTime: json['actualWakeUpTime'] != null
          ? DateTime.parse(json['actualWakeUpTime'] as String)
          : null,
    );
  }

  /// JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'date': _formatDate(date),
      'status': status.toJson(),
      if (actualWakeUpTime != null)
        'actualWakeUpTime': actualWakeUpTime!.toIso8601String(),
    };
  }

  /// yyyy-MM-dd 形式の文字列に変換（キーとして使用）
  String get dateKey => _formatDate(date);

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// コピーを作成（一部のフィールドを上書き可能）
  WakeUpRecord copyWith({
    DateTime? date,
    WakeUpStatus? status,
    DateTime? actualWakeUpTime,
  }) {
    return WakeUpRecord(
      date: date ?? this.date,
      status: status ?? this.status,
      actualWakeUpTime: actualWakeUpTime ?? this.actualWakeUpTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WakeUpRecord &&
          runtimeType == other.runtimeType &&
          dateKey == other.dateKey &&
          status == other.status &&
          actualWakeUpTime == other.actualWakeUpTime;

  @override
  int get hashCode =>
      dateKey.hashCode ^ status.hashCode ^ actualWakeUpTime.hashCode;

  @override
  String toString() {
    return 'WakeUpRecord(date: $dateKey, status: $status, actualWakeUpTime: $actualWakeUpTime)';
  }
}
