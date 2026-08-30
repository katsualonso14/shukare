import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/persona_type.dart';
import '../../domain/entity/wake_up_status.dart';
import 'locale_provider.dart';
import 'user_profile_provider.dart';

final personalizedMessageProvider = Provider.family<String, WakeUpStatus?>(
  (ref, status) {
    final profile = ref.watch(userProfileProvider);
    final locale = ref.watch(currentLocaleProvider);
    return _generateMessage(
      status: status,
      personaType: profile.personaType,
      locale: locale,
    );
  },
);

String _generateMessage({
  required WakeUpStatus? status,
  required PersonaType personaType,
  required String locale,
}) {
  if (status == null || status == WakeUpStatus.none) {
    return _noRecordMessage(personaType, locale);
  }
  switch (status) {
    case WakeUpStatus.success:
      return _successMessage(personaType, locale);
    case WakeUpStatus.rested:
      return _restedMessage(personaType, locale);
    case WakeUpStatus.adjusted:
      return _adjustedMessage(personaType, locale);
    case WakeUpStatus.none:
      return _noRecordMessage(personaType, locale);
  }
}

String _successMessage(PersonaType personaType, String locale) {
  if (locale == 'ja') {
    switch (personaType) {
      case PersonaType.gentle:
        return 'すごい！目標時間に起きられたね✨';
      case PersonaType.strict:
        return '当然の結果。次も気を抜かないように。';
    }
  }
  switch (personaType) {
    case PersonaType.gentle:
      return 'Amazing! You woke up on time✨';
    case PersonaType.strict:
      return 'Expected. Don\'t let your guard down next time.';
  }
}

String _restedMessage(PersonaType personaType, String locale) {
  if (locale == 'ja') {
    switch (personaType) {
      case PersonaType.gentle:
        return 'ゆっくり休めた日も、大切な1日だよ 🌙';
      case PersonaType.strict:
        return '休息は次への投資だ。明日に備えよ。';
    }
  }
  switch (personaType) {
    case PersonaType.gentle:
      return 'A rest day is just as important 🌙';
    case PersonaType.strict:
      return 'Rest is an investment. Prepare for tomorrow.';
  }
}

String _adjustedMessage(PersonaType personaType, String locale) {
  if (locale == 'ja') {
    switch (personaType) {
      case PersonaType.gentle:
        return '調整しながら続けることが、いちばん大事 ☁️';
      case PersonaType.strict:
        return '調整日も立派な選択。次は本気で行け。';
    }
  }
  switch (personaType) {
    case PersonaType.gentle:
      return 'Adjusting while going — that\'s what matters most ☁️';
    case PersonaType.strict:
      return 'Adjustment is still a valid choice. Go all out next time.';
  }
}

String _noRecordMessage(PersonaType personaType, String locale) {
  if (locale == 'ja') {
    switch (personaType) {
      case PersonaType.gentle:
        return '今日も、少しだけ。一緒に頑張ろうね🌱';
      case PersonaType.strict:
        return '記録はまだ。早く起きて報告して。';
    }
  }
  switch (personaType) {
    case PersonaType.gentle:
      return 'Just a little, today. We\'ll do it together🌱';
    case PersonaType.strict:
      return 'No record yet. Wake up and report.';
  }
}
