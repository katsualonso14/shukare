import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/mbti.dart';
import '../../domain/entity/persona_type.dart';
import '../../domain/entity/user_profile.dart';
import '../../infrastructure/di/infrastructure_providers.dart';

/// ユーザープロフィールの状態を管理するNotifier
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(this._ref)
      : super(
          _ref.read(userProfileRepositoryProvider).getUserProfile(),
        );

  final Ref _ref;

  /// MBTIを更新
  Future<void> setMbti(MBTI? mbti) async {
    await _ref.read(userProfileRepositoryProvider).setMbti(mbti);
    state = state.copyWith(mbti: mbti, clearMbti: mbti == null);
  }

  /// パーソナタイプを更新
  Future<void> setPersonaType(PersonaType personaType) async {
    await _ref.read(userProfileRepositoryProvider).setPersonaType(personaType);
    state = state.copyWith(personaType: personaType);
  }
}

/// ユーザープロフィールのプロバイダー
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});
