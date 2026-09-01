import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/entity/wake_up_status.dart';
import 'package:mobile/domain/service/wake_up_evaluator.dart';

void main() {
  group('WakeUpEvaluator', () {
    const evaluator = WakeUpEvaluator();

    group('evaluate', () {
      test('actual が null の場合は none を返す', () {
        final scheduled = DateTime(2024, 1, 15, 7, 0);
        expect(evaluator.evaluate(scheduled, null), WakeUpStatus.none);
      });

      group('成功（success）ケース', () {
        test('設定時刻ちょうどは success', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 7, 0);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.success);
        });

        test('設定時刻の30分前は success', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 6, 30);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.success);
        });

        test('設定時刻の30分後は success', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 7, 30);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.success);
        });

        test('設定時刻の15分前は success', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 6, 45);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.success);
        });

        test('設定時刻の15分後は success', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 7, 15);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.success);
        });
      });

      group('記録なし（none）ケース — 目標時刻外は保存しない', () {
        test('設定時刻の31分後は none を返す', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 7, 31);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.none);
        });

        test('設定時刻の31分前は none を返す', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 6, 29);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.none);
        });

        test('設定時刻の1時間後は none を返す', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 8, 0);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.none);
        });

        test('設定時刻の2時間後は none を返す', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0);
          final actual = DateTime(2024, 1, 15, 9, 0);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.none);
        });
      });

      group('境界値テスト', () {
        test('設定時刻の30分0秒後は success', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0, 0);
          final actual = DateTime(2024, 1, 15, 7, 30, 0);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.success);
        });

        test('設定時刻の30分59秒後は success（inMinutes は秒切り捨て）', () {
          final scheduled = DateTime(2024, 1, 15, 7, 0, 0);
          final actual = DateTime(2024, 1, 15, 7, 30, 59);
          expect(evaluator.evaluate(scheduled, actual), WakeUpStatus.success);
        });
      });
    });

    group('toleranceMinutes', () {
      test('デフォルトの閾値は30分', () {
        expect(WakeUpEvaluator.toleranceMinutes, 30);
      });
    });
  });

  group('WakeUpStatus', () {
    group('fromJson', () {
      test('"success" は success', () {
        expect(WakeUpStatus.fromJson('success'), WakeUpStatus.success);
      });

      test('"rested" は rested', () {
        expect(WakeUpStatus.fromJson('rested'), WakeUpStatus.rested);
      });

      test('"adjusted" は adjusted', () {
        expect(WakeUpStatus.fromJson('adjusted'), WakeUpStatus.adjusted);
      });

      test('"none" は none', () {
        expect(WakeUpStatus.fromJson('none'), WakeUpStatus.none);
      });

      test('null は none', () {
        expect(WakeUpStatus.fromJson(null), WakeUpStatus.none);
      });

      group('旧ステータスの移行', () {
        test('"achieved" → success', () {
          expect(WakeUpStatus.fromJson('achieved'), WakeUpStatus.success);
        });

        test('"failed" → adjusted（ネガティブ表示なし）', () {
          expect(WakeUpStatus.fromJson('failed'), WakeUpStatus.adjusted);
        });

        test('"nearMiss" → adjusted', () {
          expect(WakeUpStatus.fromJson('nearMiss'), WakeUpStatus.adjusted);
        });

        test('"tried" → adjusted', () {
          expect(WakeUpStatus.fromJson('tried'), WakeUpStatus.adjusted);
        });

        test('"resting" → adjusted', () {
          expect(WakeUpStatus.fromJson('resting'), WakeUpStatus.adjusted);
        });
      });
    });

    group('toJson', () {
      test('success → "success"', () {
        expect(WakeUpStatus.success.toJson(), 'success');
      });

      test('rested → "resting"', () {
        expect(WakeUpStatus.rested.toJson(), 'rested');
      });

      test('adjusted → "adjusted"', () {
        expect(WakeUpStatus.adjusted.toJson(), 'adjusted');
      });

      test('none → "none"', () {
        expect(WakeUpStatus.none.toJson(), 'none');
      });
    });

    group('emoji', () {
      test('success は ✨', () => expect(WakeUpStatus.success.emoji, '✨'));
      test('rested は 🌙', () => expect(WakeUpStatus.rested.emoji, '🌙'));
      test('adjusted は ☁️', () => expect(WakeUpStatus.adjusted.emoji, '☁️'));
      test('none は 空文字', () => expect(WakeUpStatus.none.emoji, ''));
    });

    group('label', () {
      test('success は "できた"', () => expect(WakeUpStatus.success.label, 'できた'));
      test('rested は "今日はゆっくり休めた日"', () => expect(WakeUpStatus.rested.label, '今日はゆっくり休めた日'));
      test('adjusted は "調整日"', () => expect(WakeUpStatus.adjusted.label, '調整日'));
      test('none は 空文字', () => expect(WakeUpStatus.none.label, ''));
    });
  });
}
