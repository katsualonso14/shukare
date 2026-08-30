/// カレンダーに記録できる3種類の状態
enum WakeUpStatus {
  /// ✨ できた（目標時刻の前後30分以内）
  success,

  /// 🌙 今日はゆっくり休めた日
  rested,

  /// ☁️ 調整日
  adjusted,

  /// 未記録（アプリを開いていない日）— カレンダーは空白表示
  none;

  /// カレンダー下に表示する絵文字
  String get emoji {
    switch (this) {
      case WakeUpStatus.success:
        return '✨';
      case WakeUpStatus.rested:
        return '🌙';
      case WakeUpStatus.adjusted:
        return '☁️';
      case WakeUpStatus.none:
        return '';
    }
  }

  /// ボトムシートなどに表示するラベル
  String get label {
    switch (this) {
      case WakeUpStatus.success:
        return 'できた';
      case WakeUpStatus.rested:
        return '今日はゆっくり休めた日';
      case WakeUpStatus.adjusted:
        return '調整日';
      case WakeUpStatus.none:
        return '';
    }
  }

  String toJson() => name;

  static WakeUpStatus fromJson(String? value) {
    if (value == null) return WakeUpStatus.none;
    switch (value) {
      // 旧ステータスの移行マッピング
      case 'achieved':
        return WakeUpStatus.success;
      case 'failed':
      case 'nearMiss':
      case 'tried':
      case 'resting':
        return WakeUpStatus.adjusted;
      default:
        return WakeUpStatus.values.firstWhere(
          (e) => e.name == value,
          orElse: () => WakeUpStatus.none,
        );
    }
  }
}
