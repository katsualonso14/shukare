import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// デバイスの言語コードを返すプロバイダー（'ja' / 'en' など）
/// サービス層がロケール依存の文字列を生成するために使う
final currentLocaleProvider = Provider<String>((ref) {
  return PlatformDispatcher.instance.locale.languageCode;
});
