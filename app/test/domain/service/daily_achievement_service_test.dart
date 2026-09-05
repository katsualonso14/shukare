import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/entity/target_wake_up_time.dart';
import 'package:mobile/domain/entity/wake_up_record.dart';
import 'package:mobile/domain/entity/wake_up_status.dart';
import 'package:mobile/domain/service/daily_achievement_service.dart';

void main() {
  const service = DailyAchievementService();
  const target = TargetWakeUpTime(hour: 6, minute: 0);

  // 2024-01-17 は水曜日
  final wednesday = DateTime(2024, 1, 17, 5, 52);

  Map<String, WakeUpRecord> recordsOf(Map<DateTime, WakeUpStatus> entries,
      {DateTime? actualOn, DateTime? actualTime}) {
    final map = <String, WakeUpRecord>{};
    entries.forEach((date, status) {
      final normalized = DateTime(date.year, date.month, date.day);
      final record = WakeUpRecord(
        date: normalized,
        status: status,
        actualWakeUpTime:
            actualOn != null && normalized == actualOn ? actualTime : null,
      );
      map[record.dateKey] = record;
    });
    return map;
  }

  group('shouldShow', () {
    test('一度も出していなければ出す', () {
      expect(service.shouldShow(now: wednesday, lastShownDate: null), isTrue);
    });

    test('今日すでに出していれば出さない', () {
      expect(
        service.shouldShow(
          now: wednesday,
          lastShownDate: DateTime(2024, 1, 17, 6, 30),
        ),
        isFalse,
      );
    });

    test('前日に出していれば出す', () {
      expect(
        service.shouldShow(
          now: wednesday,
          lastShownDate: DateTime(2024, 1, 16, 23, 59),
        ),
        isTrue,
      );
    });
  });

  group('isMilestone', () {
    test('節目の日数は true', () {
      for (final n in [3, 7, 14, 30, 50, 100, 200, 300]) {
        expect(DailyAchievementService.isMilestone(n), isTrue, reason: '$n');
      }
    });

    test('節目でない日数は false', () {
      for (final n in [1, 2, 8, 29, 99, 150]) {
        expect(DailyAchievementService.isMilestone(n), isFalse, reason: '$n');
      }
    });
  });

  group('build', () {
    test('今日が調整日なら組み立てる（連続は 0・節目にはしない）', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({
          DateTime(2024, 1, 14): WakeUpStatus.success,
          DateTime(2024, 1, 15): WakeUpStatus.success,
          DateTime(2024, 1, 16): WakeUpStatus.success, // ここまで3連続
          DateTime(2024, 1, 17): WakeUpStatus.adjusted, // 今日
        }),
        targetTime: target,
        weekStartSunday: false,
      );

      expect(result, isNotNull);
      expect(result!.status, WakeUpStatus.adjusted);
      expect(result.isSuccess, isFalse);
      // 今日で途切れているので 0。昨日までの3連続を持ち出して「途切れた」と
      // 見せると、調整日のモーダルが喪失の通知になる
      expect(result.streak, 0);
      expect(result.isMilestone, isFalse);
    });

    test('今日が休んだ日なら null（自分で選んだ休みは報告し返さない）', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({DateTime(2024, 1, 17): WakeUpStatus.rested}),
        targetTime: target,
        weekStartSunday: false,
      );
      expect(result, isNull);
    });

    test('今日の記録が無ければ null', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({DateTime(2024, 1, 16): WakeUpStatus.success}),
        targetTime: target,
        weekStartSunday: false,
      );
      expect(result, isNull);
    });

    test('連続日数は今日から遡って途切れるまで数える', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({
          DateTime(2024, 1, 14): WakeUpStatus.success, // 途切れの向こう側
          DateTime(2024, 1, 15): WakeUpStatus.adjusted, // ここで切れる
          DateTime(2024, 1, 16): WakeUpStatus.success,
          DateTime(2024, 1, 17): WakeUpStatus.success,
        }),
        targetTime: target,
        weekStartSunday: false,
      );
      expect(result!.streak, 2);
      expect(result.status, WakeUpStatus.success);
      expect(result.isSuccess, isTrue);
    });

    test('月曜始まりだと水曜は index 2、週は7日ぶん、未来は null', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({
          DateTime(2024, 1, 15): WakeUpStatus.success, // 月
          DateTime(2024, 1, 16): WakeUpStatus.rested, // 火
          DateTime(2024, 1, 17): WakeUpStatus.success, // 水（今日）
        }),
        targetTime: target,
        weekStartSunday: false,
      );

      expect(result!.weekStart, DateTime(2024, 1, 15));
      expect(result.todayIndex, 2);
      expect(result.weekStatuses.length, 7);
      expect(result.weekStatuses[0], WakeUpStatus.success);
      expect(result.weekStatuses[1], WakeUpStatus.rested);
      expect(result.weekStatuses[2], WakeUpStatus.success);
      // 木〜日はまだ来ていない
      expect(result.weekStatuses.sublist(3), everyElement(isNull));
    });

    test('日曜始まりだと水曜は index 3', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({DateTime(2024, 1, 17): WakeUpStatus.success}),
        targetTime: target,
        weekStartSunday: true,
      );
      expect(result!.weekStart, DateTime(2024, 1, 14));
      expect(result.todayIndex, 3);
    });

    test('今月の success だけ数える（先月は入れない）', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({
          DateTime(2023, 12, 20): WakeUpStatus.success, // 先月
          DateTime(2024, 1, 5): WakeUpStatus.success,
          DateTime(2024, 1, 6): WakeUpStatus.adjusted, // success ではない
          DateTime(2024, 1, 17): WakeUpStatus.success,
        }),
        targetTime: target,
        weekStartSunday: false,
      );
      expect(result!.monthSuccessDays, 2);
    });

    test('目標より早いと差はマイナス', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf(
          {DateTime(2024, 1, 17): WakeUpStatus.success},
          actualOn: DateTime(2024, 1, 17),
          actualTime: DateTime(2024, 1, 17, 5, 52),
        ),
        targetTime: target,
        weekStartSunday: false,
      );
      expect(result!.diffFromTarget, const Duration(minutes: -8));
    });

    test('起床時刻が無い手動記録では差は null', () {
      final result = service.build(
        now: wednesday,
        allRecords: recordsOf({DateTime(2024, 1, 17): WakeUpStatus.success}),
        targetTime: target,
        weekStartSunday: false,
      );
      expect(result!.actualWakeUpTime, isNull);
      expect(result.diffFromTarget, isNull);
    });
  });
}
