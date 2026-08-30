import '../entity/wake_up_status.dart';

/// 早起き判定ロジックを提供するクラス
///
/// 設定時刻の前後 [toleranceMinutes] 分以内にアプリを開いた場合は成功（success）、
/// それ以外の場合は失敗（failed）、未記録の場合は none と判定する。
///
/// 純粋関数として設計されているため、過去日の再計算にも使用可能。
class WakeUpEvaluator {
  /// コンストラクタ
  const WakeUpEvaluator();

  /// 判定の閾値（分）- 設定時刻の前後この時間内なら成功
  static const int toleranceMinutes = 30;

  /// 起床ステータスを判定する（純粋関数）
  ///
  /// [scheduled] 設定された目標起床時刻
  /// [actual] 実際にアプリを開いた時刻（null の場合は未記録）
  ///
  /// - [actual] が null → [WakeUpStatus.none]
  /// - 設定時刻の前後 [toleranceMinutes] 分以内 → [WakeUpStatus.success]
  /// - それ以外 → [WakeUpStatus.failed]
  WakeUpStatus evaluate(DateTime scheduled, DateTime? actual) {
    if (actual == null) {
      return WakeUpStatus.none;
    }

    final difference = actual.difference(scheduled);
    final absoluteMinutes = difference.inMinutes.abs();

    if (absoluteMinutes <= toleranceMinutes) {
      return WakeUpStatus.success;
    } else {
      // 目標時刻を過ぎても失敗扱いにしない。ユーザーが手動で選択する
      return WakeUpStatus.none;
    }
  }
}
