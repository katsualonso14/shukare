import '../../domain/entity/mbti.dart';
import '../../domain/entity/persona_type.dart';
import '../../domain/entity/user_profile.dart';
import '../../domain/repository/user_profile_repository.dart';
import '../datasource/preference_datasource.dart';

/// UserProfileRepository の実装
class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._datasource);

  final PreferenceDatasource _datasource;

  @override
  UserProfile getUserProfile() {
    final mbtiStr = _datasource.getUserMbti();
    final personaTypeStr = _datasource.getUserPersonaType();

    return UserProfile(
      mbti: MBTI.fromJson(mbtiStr),
      personaType: PersonaType.fromJson(personaTypeStr),
    );
  }

  @override
  Future<void> setMbti(MBTI? mbti) async {
    await _datasource.setUserMbti(mbti?.toJson());
  }

  @override
  Future<void> setPersonaType(PersonaType personaType) async {
    await _datasource.setUserPersonaType(personaType.toJson());
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await _datasource.setUserMbti(profile.mbti?.toJson());
    await _datasource.setUserPersonaType(profile.personaType.toJson());
  }
}
