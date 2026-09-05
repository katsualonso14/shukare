import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/entity/persona_type.dart';
import 'package:mobile/domain/entity/wake_up_status.dart';
import 'package:mobile/domain/service/daily_achievement_service.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/pages/calendar/widgets/daily_achievement_dialog.dart';

void main() {
  // 2024-01-17 は水曜日
  final wednesday = DateTime(2024, 1, 17);
  final weekStart = DateTime(2024, 1, 15); // 月曜

  DailyAchievement achievementOf(WakeUpStatus status, {int streak = 0}) {
    return DailyAchievement(
      date: wednesday,
      status: status,
      streak: streak,
      weekStart: weekStart,
      weekStatuses: [
        WakeUpStatus.success,
        WakeUpStatus.success,
        status,
        null,
        null,
        null,
        null,
      ],
      todayIndex: 2,
      monthSuccessDays: 12,
    );
  }

  Widget hostOf(DailyAchievement achievement) {
    return MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DailyAchievementDialog(
        achievement: achievement,
        personaType: PersonaType.gentle,
        message: 'テストメッセージ',
      ),
    );
  }

  /// 週ストリップ側（＝今日）の雲を包む FadeTransition の不透明度。
  /// 見出しの雲より後ろにあるので .last で取る
  double todayCloudOpacity(WidgetTester tester) {
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text(WakeUpStatus.adjusted.emoji).last,
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    return fade.opacity.value;
  }

  testWidgets('調整日は雲の見出しと「また明日」を出す', (tester) async {
    await tester.pumpWidget(hostOf(achievementOf(WakeUpStatus.adjusted)));
    await tester.pumpAndSettle();

    expect(find.text('今日は調整日'), findsOneWidget);
    expect(find.text('また明日'), findsOneWidget);
    // できた日の見出し・ボタンは出さない
    expect(find.text('はじめの1日'), findsNothing);
    expect(find.text('今日もいい朝'), findsNothing);
    // 見出しと週ストリップの2箇所に雲が出る
    expect(find.text(WakeUpStatus.adjusted.emoji), findsNWidgets(2));
  });

  testWidgets('できた日は従来どおり達成側の文言を出す', (tester) async {
    await tester
        .pumpWidget(hostOf(achievementOf(WakeUpStatus.success, streak: 3)));
    await tester.pumpAndSettle();

    expect(find.text('3日達成 🎉'), findsOneWidget); // streak 3 は節目
    expect(find.text('今日もいい朝'), findsOneWidget);
    expect(find.text('今日は調整日'), findsNothing);
  });

  testWidgets('調整日の今日のマークは遅れて入る（開いた瞬間はまだ無い）', (tester) async {
    await tester.pumpWidget(hostOf(achievementOf(WakeUpStatus.adjusted)));

    // 見出しの雲が流れ込んでいる間、今日のマークはまだ置かれていない
    await tester.pump(const Duration(milliseconds: 100));
    expect(todayCloudOpacity(tester), 0);

    await tester.pumpAndSettle();
    expect(todayCloudOpacity(tester), 1);
  });
}
