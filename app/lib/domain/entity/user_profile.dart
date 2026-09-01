import 'mbti.dart';
import 'persona_type.dart';

/// ユーザーのプロフィール設定（性格・パーソナ設定）
class UserProfile {
  const UserProfile({
    this.mbti,
    this.personaType = PersonaType.gentle,
  });

  /// ユーザーが選択したMBTI（未選択の場合はnull）
  final MBTI? mbti;

  /// アプリの性格設定（優しい/厳しい）
  final PersonaType personaType;

  /// デフォルトのプロフィール
  static const UserProfile defaultProfile = UserProfile();

  /// JSON から復元
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      mbti: MBTI.fromJson(json['mbti'] as String?),
      personaType: PersonaType.fromJson(json['persona_type'] as String?),
    );
  }

  /// JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'mbti': mbti?.toJson(),
      'persona_type': personaType.toJson(),
    };
  }

  /// コピーを作成
  UserProfile copyWith({
    MBTI? mbti,
    PersonaType? personaType,
    bool clearMbti = false,
  }) {
    return UserProfile(
      mbti: clearMbti ? null : (mbti ?? this.mbti),
      personaType: personaType ?? this.personaType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          mbti == other.mbti &&
          personaType == other.personaType;

  @override
  int get hashCode => mbti.hashCode ^ personaType.hashCode;

  @override
  String toString() {
    return 'UserProfile(mbti: ${mbti?.code}, personaType: ${personaType.value})';
  }
}
