/// アプリがユーザーに接する性格タイプ
enum PersonaType {
  /// 優しく接する
  gentle('gentle', '優しい', 'やわらかい言葉で応援します'),

  /// 厳しく接する
  strict('strict', '厳しい', 'しっかりと背中を押します');

  const PersonaType(this.value, this.displayName, this.description);

  /// 保存用の値
  final String value;

  /// 表示名
  final String displayName;

  /// 説明
  final String description;

  /// JSON保存用
  String toJson() => value;

  /// JSONから復元（デフォルトはgentle）
  static PersonaType fromJson(String? value) {
    if (value == null) return PersonaType.gentle;
    try {
      return PersonaType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return PersonaType.gentle;
    }
  }
}
