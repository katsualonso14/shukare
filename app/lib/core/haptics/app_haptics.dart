import 'package:flutter/services.dart';

/// 触覚フィードバックの語彙を1箇所に集めたもの。
///
/// なぜ enum 的に分けるか: 全部を同じ振動にすると「アプリが震えた」以上の意味を持たず、
/// 達成の瞬間とただのタップが同じ手触りになる。振動の強さそのものではなく
/// **何が起きたか**で呼び分けることで、目を離していても出来事の重さが手に伝わる。
///
/// 呼び出し側は必ずこのクラス経由にする（HapticFeedback を直接叩かない）。
/// 手触りを調整したくなったとき、直す場所がここだけになるため。
class AppHaptics {
  const AppHaptics._();

  /// 選択が切り替わった（日付を選ぶ・タブを移る・設定を切り替える）。
  /// 一番軽い「コツッ」。頻度が高いので存在を主張させない。
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// 記録が確定した・消えた（＝データが動いた）。「ブルッ」と手応えを返す。
  static Future<void> commit() => HapticFeedback.mediumImpact();

  /// 今日できた。light → medium の2段で「トトン」と弾ませる。
  ///
  /// 単発の強い振動は通知の手触りで、達成感にならない。弱→強の2段にすると
  /// 「跳ねた」ように感じ、モーダルのポップと同じリズムで受け取れる。
  static Future<void> celebrate() async {
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.mediumImpact();
  }

  /// 今日は調整日。1回だけ、静かに触れる。
  ///
  /// 達成と同じ強さで返すと「失敗を知らせる振動」になる。ここは知らせるのではなく
  /// 「受け取った」ことだけを伝えるので、celebrate より軽く・弾ませない。
  static Future<void> gentle() => HapticFeedback.lightImpact();
}
