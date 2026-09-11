import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/entity/mbti.dart';
import 'package:mobile/domain/entity/persona_type.dart';
import 'package:mobile/domain/entity/wake_up_record.dart';
import 'package:mobile/domain/entity/wake_up_status.dart';
import 'package:mobile/domain/service/weekly_report_service.dart';

/// 「今週の記録」画面（進行中の週）専用ロジックのテスト。
/// 週明けの振り返り（先週分）用のメソッドとは別物であることを固定する。
void main() {
  const service = WeeklyReportService();

  // 2024-01-15(月) 〜 2024-01-21(日) の週
  final monday = DateTime(2024, 1, 15);

  /// 週の頭から [statuses] の順に記録を置く（週開始からの連続日）
  Map<String, WakeUpRecord> recordsFrom(List<WakeUpStatus> statuses) {
    final map = <String, WakeUpRecord>{};
    for (var i = 0; i < statuses.length; i++) {
      if (statuses[i] == WakeUpStatus.none) continue;
      final date = monday.add(Duration(days: i));
      final record = WakeUpRecord(date: date, status: statuses[i]);
      map[record.dateKey] = record;
    }
    return map;
  }

  /// [dayOffset] 日目（0=月曜）時点のレポート
  WeeklyReport reportOn(int dayOffset, List<WakeUpStatus> statuses) {
    return service.generateReportForWeek(
      date: monday.add(Duration(days: dayOffset)),
      allRecords: recordsFrom(statuses),
      weekStartSunday: false,
    );
  }

  const s = WakeUpStatus.success;
  const none = WakeUpStatus.none;
  const adjusted = WakeUpStatus.adjusted;

  group('getWeekProgressLevel', () {
    test('経過日をすべて達成していれば 5', () {
      expect(service.getWeekProgressLevel(reportOn(2, [s, s, s])), 5);
    });

    test('6割以上できていれば 4', () {
      // 水曜時点で 2/3 = 67%
      expect(service.getWeekProgressLevel(reportOn(2, [s, s, none])), 4);
    });

    test('1日以上できていて6割未満なら 3', () {
      // 木曜時点で 1/4 = 25%
      expect(service.getWeekProgressLevel(reportOn(3, [s, none, none, none])), 3);
    });

    test('3日以上経って達成0なら 2', () {
      expect(service.getWeekProgressLevel(reportOn(2, [none, none, adjusted])), 2);
    });

    test('週の序盤（2日以内）で達成0なら 1', () {
      expect(service.getWeekProgressLevel(reportOn(0, [none])), 1);
      expect(service.getWeekProgressLevel(reportOn(1, [none, adjusted])), 1);
    });

    test('今日の記録も分母に数える（水曜なら経過3日）', () {
      expect(reportOn(2, [s, s, none]).totalDays, 3);
    });
  });

  group('getCurrentWeekTitle', () {
    test('週の途中で達成0でも「先週」由来のタイトルにならない', () {
      final title = service.getCurrentWeekTitle(
        personaType: PersonaType.gentle,
        report: reportOn(2, [none, none, adjusted]),
      );
      expect(title, 'まだ取り返せるよ');
    });

    test('序盤は「今週はこれから」', () {
      final title = service.getCurrentWeekTitle(
        personaType: PersonaType.gentle,
        report: reportOn(0, [none]),
      );
      expect(title, '今週はこれから');
    });

    test('strict と gentle で出し分ける', () {
      final report = reportOn(4, [s, s, s, s, none]);
      expect(
        service.getCurrentWeekTitle(
            personaType: PersonaType.strict, report: report),
        '良好なペース',
      );
      expect(
        service.getCurrentWeekTitle(
            personaType: PersonaType.gentle, report: report),
        'いい調子！',
      );
    });
  });

  group('getCurrentWeekMessage', () {
    String messageOn(int dayOffset, List<WakeUpStatus> statuses,
        {PersonaType persona = PersonaType.gentle, MBTI? mbti}) {
      return service.getCurrentWeekMessage(
        personaType: persona,
        mbti: mbti,
        report: reportOn(dayOffset, statuses),
      );
    }

    test('「先週」の話をしない', () {
      for (final offset in [0, 1, 2, 3, 4, 5, 6]) {
        for (final persona in PersonaType.values) {
          final message =
              messageOn(offset, [s, none, s, none, none, none, none],
                  persona: persona);
          expect(message.contains('先週'), isFalse,
              reason: '$persona / ${offset + 1}日目: $message');
          expect(message.contains('今週'), isTrue,
              reason: '$persona / ${offset + 1}日目: $message');
        }
      }
    });

    test('できている日があるときは達成数に触れる', () {
      // 金曜時点で 2/5
      final message = messageOn(4, [s, none, s, none, none]);
      expect(message.contains('5日中2日'), isTrue, reason: message);
      expect(message.contains('悪くない'), isTrue, reason: message);
    });

    test('残り日数を添えて閉じる', () {
      // 水曜 = 経過3日 → 残り4日
      expect(messageOn(2, [s, s, s]).contains('残り4日'), isTrue);
    });

    test('日曜（残り0日）に「残り0日」と言わない', () {
      for (final persona in PersonaType.values) {
        final message = messageOn(6, [s, s, s, s, s, s, s], persona: persona);
        expect(message.contains('残り0日'), isFalse, reason: message);
        expect(message.contains('今日で'), isTrue, reason: message);
      }
    });

    test('MBTI で言い回しが変わる', () {
      final plain = messageOn(4, [s, s, s, s, none]);
      final explorer = messageOn(4, [s, s, s, s, none], mbti: MBTI.isfp);
      expect(explorer, isNot(plain));
    });

    test('英語ロケールでは日本語を出さない', () {
      final message = service.getCurrentWeekMessage(
        personaType: PersonaType.gentle,
        mbti: null,
        report: reportOn(2, [s, none, none]),
        locale: 'en',
      );
      expect(message.contains('今週'), isFalse, reason: message);
      expect(message.contains('days left'), isTrue, reason: message);
    });
  });

  group('週明けレポートは変わらない', () {
    test('generateReport 由来の文面は従来どおり「先週」を主語にする', () {
      // 2024-01-22(月)時点 → 先週は 1/15〜1/21
      final report = service.generateReport(
        now: DateTime(2024, 1, 22),
        allRecords: recordsFrom([none, none, none, none, none, none, none]),
        weekStartSunday: false,
      );
      final message = service.getFeedbackMessage(
        personaType: PersonaType.gentle,
        mbti: null,
        report: report,
      );
      expect(message.contains('先週'), isTrue, reason: message);
      expect(report.totalDays, 7);
    });
  });
}
