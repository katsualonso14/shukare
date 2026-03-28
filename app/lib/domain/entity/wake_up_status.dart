/// 起床記録のステータス（罪悪感ゼロ設計）
enum WakeUpStatus {
  /// 達成: 目標時間内に起きられた
  achieved,

  /// 惜しい: 目標から30分以内の遅刻
  nearMiss,

  /// 公式お休み: ユーザーが事前に「今日は休む」と決めた日
  resting,

  /// 記録の継続: 大幅な遅刻だが、アプリを開いて記録した
  tried;

  /// ステータスに応じた優しいメッセージを返す
  String get encouragementMessage {
    switch (this) {
      case WakeUpStatus.achieved:
        return 'すごい！目標時間に起きられたね！';
      case WakeUpStatus.nearMiss:
        return 'おしい！あと一歩で完全勝利だったね！';
      case WakeUpStatus.resting:
        return '今日は公式リフレッシュ日。明日からまた頑張ろう';
      case WakeUpStatus.tried:
        return 'お昼だけど記録して偉い！自分と向き合えてる証拠だよ';
    }
  }

  /// カレンダー表示用の絵文字
  String get emoji {
    switch (this) {
      case WakeUpStatus.achieved:
        return '✨';
      case WakeUpStatus.nearMiss:
        return '💪';
      case WakeUpStatus.resting:
        return '🌙';
      case WakeUpStatus.tried:
        return '🌱';
    }
  }

  /// JSON保存用の文字列に変換
  String toJson() => name;

  /// JSON読み込み時の変換（存在しない値の場合はnullを返す）
  static WakeUpStatus? fromJson(String? value) {
    if (value == null) return null;
    try {
      return WakeUpStatus.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}
