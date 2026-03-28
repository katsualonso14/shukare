import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/persona_type.dart';
import '../../domain/entity/user_profile.dart';
import '../../domain/entity/wake_up_record.dart';
import '../../domain/entity/wake_up_status.dart';
import 'user_profile_provider.dart';
import 'wake_up_records_provider.dart';

/// メッセージ生成のためのパラメータ
class MessageParams {
  const MessageParams({
    required this.status,
    required this.consecutiveFailureCount,
    required this.personaType,
  });

  final WakeUpStatus? status;
  final int consecutiveFailureCount;
  final PersonaType personaType;
}

/// 連続失敗日数を計算するプロバイダー
final consecutiveFailureCountProvider = Provider<int>((ref) {
  final recordsAsync = ref.watch(wakeUpRecordsProvider);
  return recordsAsync.maybeWhen(
    data: (records) => _calculateConsecutiveFailures(records),
    orElse: () => 0,
  );
});

/// 今日（または最新）のステータスから連続失敗日数を計算
int _calculateConsecutiveFailures(Map<String, WakeUpRecord> records) {
  final today = DateTime.now();
  int count = 0;
  
  for (int i = 0; i < 30; i++) {
    final date = today.subtract(Duration(days: i));
    final key = DateFormat('yyyy-MM-dd').format(date);
    final record = records[key];
    
    if (record == null) {
      count++;
    } else if (record.status == WakeUpStatus.tried) {
      count++;
    } else if (record.status == WakeUpStatus.resting) {
      continue;
    } else {
      break;
    }
  }
  
  return count;
}

/// パーソナライズされたメッセージを生成するプロバイダー
final personalizedMessageProvider = Provider.family<String, WakeUpStatus?>(
  (ref, status) {
    final profile = ref.watch(userProfileProvider);
    final consecutiveFailures = ref.watch(consecutiveFailureCountProvider);
    
    return _generateMessage(
      status: status,
      consecutiveFailureCount: consecutiveFailures,
      personaType: profile.personaType,
    );
  },
);

/// ステータスに基づいてパーソナライズされたメッセージを生成
String _generateMessage({
  required WakeUpStatus? status,
  required int consecutiveFailureCount,
  required PersonaType personaType,
}) {
  if (consecutiveFailureCount >= 3) {
    return _getAngryMessage();
  }
  
  if (status == null) {
    return _getNoRecordMessage(consecutiveFailureCount, personaType);
  }
  
  switch (status) {
    case WakeUpStatus.achieved:
      return _getAchievedMessage(personaType);
    case WakeUpStatus.nearMiss:
      return _getNearMissMessage(personaType);
    case WakeUpStatus.resting:
      return _getRestingMessage(personaType);
    case WakeUpStatus.tried:
      return _getTriedMessage(consecutiveFailureCount, personaType);
  }
}

/// 3日連続失敗時のブチギレメッセージ（パーソナに関わらず）
String _getAngryMessage() {
  final messages = [
    '3日も無視するなんて信じられない！もう知らないからね！',
    '3日連続でサボり？本当にやる気あるの？！',
    'ちょっと！3日も何してたの？信じられない！',
    '3日も放置するなんて…もう怒ったからね！',
  ];
  return messages[DateTime.now().day % messages.length];
}

/// 達成時のメッセージ
String _getAchievedMessage(PersonaType personaType) {
  switch (personaType) {
    case PersonaType.gentle:
      return 'すごい！目標時間に起きられたね！今日も頑張ろう✨';
    case PersonaType.strict:
      return '当然の結果。次も気を抜かないように。';
  }
}

/// 惜しい時のメッセージ
String _getNearMissMessage(PersonaType personaType) {
  switch (personaType) {
    case PersonaType.gentle:
      return 'おしい！あと一歩だったね。十分すごいよ！';
    case PersonaType.strict:
      return '惜しい。あと少しの努力が足りなかった。次は達成して。';
  }
}

/// 休息日のメッセージ
String _getRestingMessage(PersonaType personaType) {
  switch (personaType) {
    case PersonaType.gentle:
      return '今日は公式リフレッシュ日。ゆっくり休んでね🌙';
    case PersonaType.strict:
      return '休息も戦略のうち。明日は言い訳なしで。';
  }
}

/// 記録したけど失敗時のメッセージ
String _getTriedMessage(int consecutiveFailures, PersonaType personaType) {
  if (consecutiveFailures >= 2) {
    switch (personaType) {
      case PersonaType.gentle:
        return '2日続いちゃったね…でも記録してくれてありがとう。明日こそ！';
      case PersonaType.strict:
        return '2日連続は危険信号。明日起きなかったら本気で怒るからね。';
    }
  }
  
  switch (personaType) {
    case PersonaType.gentle:
      return 'お昼になっちゃったけど、記録してくれてありがとう。明日があるよ！';
    case PersonaType.strict:
      return '寝坊は寝坊。でも記録したのは偉い。次は言い訳なし。';
  }
}

/// 記録なし時のメッセージ
String _getNoRecordMessage(int consecutiveFailures, PersonaType personaType) {
  if (consecutiveFailures >= 2) {
    switch (personaType) {
      case PersonaType.gentle:
        return '最近会えてないね…元気にしてる？いつでも待ってるよ。';
      case PersonaType.strict:
        return '$consecutiveFailures日も記録なし？そろそろ本気出して。';
    }
  }
  
  switch (personaType) {
    case PersonaType.gentle:
      return '今日も、少しだけ。一緒に頑張ろうね🌱';
    case PersonaType.strict:
      return '記録はまだ。早く起きて報告して。';
  }
}
