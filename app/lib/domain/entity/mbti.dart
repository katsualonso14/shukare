/// ユーザーのMBTI性格タイプ
enum MBTI {
  // アナリスト（分析家）
  intj('INTJ', '建築家', '想像力豊かな戦略家', 'Architect', 'Imaginative and strategic thinker'),
  intp('INTP', '論理学者', '革新的な発明家', 'Logician', 'Innovative inventor'),
  entj('ENTJ', '指揮官', '大胆なリーダー', 'Commander', 'Bold and imaginative leader'),
  entp('ENTP', '討論者', '賢いディベーター', 'Debater', 'Smart and curious thinker'),

  // 外交官
  infj('INFJ', '提唱者', '静かで神秘的な理想主義者', 'Advocate', 'Quiet and mystical idealist'),
  infp('INFP', '仲介者', '詩的で親切な利他主義者', 'Mediator', 'Poetic and kind altruist'),
  enfj('ENFJ', '主人公', 'カリスマ的なリーダー', 'Protagonist', 'Charismatic and inspiring leader'),
  enfp('ENFP', '広報運動家', '創造的で社交的な精神', 'Campaigner', 'Enthusiastic and creative free spirit'),

  // 番人
  istj('ISTJ', '管理者', '実務的で事実重視', 'Logistician', 'Practical and fact-minded'),
  isfj('ISFJ', '擁護者', '献身的で温かい守護者', 'Defender', 'Dedicated and warm protector'),
  estj('ESTJ', '幹部', '優れた管理者', 'Executive', 'Excellent administrator'),
  esfj('ESFJ', '領事官', '思いやりのある世話好き', 'Consul', 'Caring and sociable'),

  // 探検家
  istp('ISTP', '巨匠', '大胆で実践的な実験者', 'Virtuoso', 'Bold and practical experimenter'),
  isfp('ISFP', '冒険家', '柔軟で魅力的な芸術家', 'Adventurer', 'Flexible and charming artist'),
  estp('ESTP', '起業家', 'スマートでエネルギッシュ', 'Entrepreneur', 'Smart and energetic'),
  esfp('ESFP', 'エンターテイナー', '自発的でエネルギッシュ', 'Entertainer', 'Spontaneous and energetic');

  const MBTI(
    this.code,
    this.name,
    this.description,
    this.nameEn,
    this.descriptionEn,
  );

  final String code;
  final String name;
  final String description;
  final String nameEn;
  final String descriptionEn;

  String localizedName(String locale) => locale == 'ja' ? name : nameEn;
  String localizedDescription(String locale) => locale == 'ja' ? description : descriptionEn;

  String toJson() => code;

  static MBTI? fromJson(String? value) {
    if (value == null) return null;
    try {
      return MBTI.values.firstWhere((e) => e.code == value);
    } catch (_) {
      return null;
    }
  }
}
