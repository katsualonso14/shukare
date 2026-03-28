import '../entity/user_profile.dart';
import '../entity/mbti.dart';
import '../entity/persona_type.dart';

/// ユーザープロフィールの永続化を担当するリポジトリ
abstract class UserProfileRepository {
  /// ユーザープロフィールを取得
  UserProfile getUserProfile();

  /// MBTIを設定
  Future<void> setMbti(MBTI? mbti);

  /// パーソナタイプを設定
  Future<void> setPersonaType(PersonaType personaType);

  /// プロフィール全体を更新
  Future<void> updateProfile(UserProfile profile);
}
