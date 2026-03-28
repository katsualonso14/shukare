import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/wake_up_status.dart';

/// ステータスから優しいメッセージを取得するProvider
final encouragementMessageProvider = Provider.family<String, WakeUpStatus>(
  (ref, status) => status.encouragementMessage,
);

/// ステータスから絵文字を取得するProvider
final statusEmojiProvider = Provider.family<String, WakeUpStatus>(
  (ref, status) => status.emoji,
);
