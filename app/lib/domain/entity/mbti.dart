/// ユーザーのMBTI性格タイプ
enum MBTI {
  // アナリスト（分析家）
  intj('INTJ', '建築家', '想像力豊かな戦略家'),
  intp('INTP', '論理学者', '革新的な発明家'),
  entj('ENTJ', '指揮官', '大胆なリーダー'),
  entp('ENTP', '討論者', '賢いディベーター'),

  // 外交官
  infj('INFJ', '提唱者', '静かで神秘的な理想主義者'),
  infp('INFP', '仲介者', '詩的で親切な利他主義者'),
  enfj('ENFJ', '主人公', 'カリスマ的なリーダー'),
  enfp('ENFP', '広報運動家', '創造的で社交的な精神'),

  // 番人
  istj('ISTJ', '管理者', '実務的で事実重視'),
  isfj('ISFJ', '擁護者', '献身的で温かい守護者'),
  estj('ESTJ', '幹部', '優れた管理者'),
  esfj('ESFJ', '領事官', '思いやりのある世話好き'),

  // 探検家
  istp('ISTP', '巨匠', '大胆で実践的な実験者'),
  isfp('ISFP', '冒険家', '柔軟で魅力的な芸術家'),
  estp('ESTP', '起業家', 'スマートでエネルギッシュ'),
  esfp('ESFP', 'エンターテイナー', '自発的でエネルギッシュ');

  const MBTI(this.code, this.name, this.description);

  /// MBTIコード（例: "INTJ"）
  final String code;

  /// 日本語名（例: "建築家"）
  final String name;

  /// 簡単な説明
  final String description;

  /// JSON保存用
  String toJson() => code;

  /// JSONから復元
  static MBTI? fromJson(String? value) {
    if (value == null) return null;
    try {
      return MBTI.values.firstWhere((e) => e.code == value);
    } catch (_) {
      return null;
    }
  }
}
