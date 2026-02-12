import 'package:flutter/material.dart';

/// くすみカラー・女性向けっぽいが明示的には限定しないパレット
class AppColors {
  AppColors._();

  // 背景（静か・余白）
  static const Color background = Color(0xFFF8F6F4); // クリーム系
  static const Color surface = Color(0xFFFFFEFC);

  // テキスト（情報量を抑える）
  static const Color textPrimary = Color(0xFF5C534E);
  static const Color textSecondary = Color(0xFF8A8380);
  static const Color textMuted = Color(0xFFB5AEAA);

  // くすみアクセント
  static const Color roseDust = Color(0xFFC4A69D);   // ローズダスト
  static const Color sage = Color(0xFF9CAF88);       // セージ
  static const Color dustyBlush = Color(0xFFD4B8B0); // ダスティブラッシュ
  static const Color warmGray = Color(0xFFA89F99);

  // チェック表示用（優しい緑＝テーマ色）
  static const Color checkGreen = Color(0xFF9CAF88);       // セージ（メイン）
  static const Color checkGreenLight = Color(0xFFB5C9A0);  // 薄い緑（内側の丸用）
  static const Color checkDot = Color(0xFF9CAF88);        // ドット用（優しい緑）
  static const Color checkRing = Color(0xFF9CAF88);
  static const Color checkFill = Color(0xFFE2EBDE);       // 薄い緑の塗り

  // カレンダー
  static const Color calendarHeader = Color(0xFF5C534E);
  static const Color weekdayLabel = Color(0xFF8A8380);
  static const Color todayHighlight = Color(0xFFE8E2DE);
  static const Color selectedDay = Color(0xFFE8E2DE);
  static const Color dayCheckedCircle = Color(0xFF9CAF88);   // チェック日の丸（優しい緑）
  static const Color dayCheckedCircleInner = Color(0xFFB5C9A0); // 内側の薄い緑
}
