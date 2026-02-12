# 視覚体験中心カレンダーアプリ — 設計・アーキテクチャ

## 1. TL;DR

- **何を作るか**: 通知・リマインドより「見た目の心地よさ」を優先した、月表示の習慣チェック用カレンダーアプリ。
- **操作**: 日付タップでチェックON/OFF（1アクション）。毎日決まった時間の簡単な通知あり。データはローカル永続化。
- **技術**: Flutter stable / null safety / Riverpod / table_calendar / shared_preferences / flutter_local_notifications。
- **トーン**: シンプル・静か・くすみカラー・余白・ミニマル・柔らかい丸み。女性向け“っぽい”が性別限定ではない。

---

## 2. UXコンセプト整理

| キーワード | 具体的な落とし込み |
|-----------|-------------------|
| **シンプル** | 画面は「月カレンダー＋チェック」だけ。設定は通知時刻のみ。 |
| **静か** | 派手なアニメーション・サウンドなし。色数・情報量を抑える。 |
| **女性向けっぽい** | くすみピンク・セージ・ベージュ等のトーン。角丸・余白で柔らかさ。性別表記はしない。 |
| **くすみカラー** | 彩度を下げたパレット。背景はオフホワイト/クリーム、アクセントはローズダスト・セージ等。 |
| **余白** | カレンダーセル間・画面マージン・ヘッダー下を広めに。 |
| **情報量を抑える** | 数値目標・ストリーク・統計は初版では出さない。日付と「やった/やってない」だけ。 |
| **ミニマル** | ナビゲーションは1画面。ボタン・ラベルは必要最小限。 |
| **柔らかい丸み** | カード・セル・ボタンは borderRadius 12〜24。アイコンも丸やソフトな形。 |

**1アクションで完結**: 日付をタップするだけでチェック付与/解除。モード切替や長押しメニューは使わない。

---

## 3. UIデザイン案（チェックの見せ方）

### パターンA: ソフトドット（推奨・実装デフォルト）
- 日付の下に、くすみ色の小さな円を1つ表示。
- サイズは控えめ（例: 6px）。存在感はあるが騒がしくない。
- 未チェック日はドットなし。余白で「やっていない」を表現。

### パターンB: リング（輪郭のみ）
- チェック済みの日は、日付の周りに薄い円の枠（stroke only）。
- 線の太さ 1.5〜2px、色はくすみローズやセージ。塗りはしない。
- 軽い・上品な印象。

### パターンC: ソフト塗り
- チェック済みの日は、セル全体を薄い色で塗る（角丸矩形）。
- 背景色はベージュ〜ローズのごく薄いトーン。文字はそのまま読めるコントラストに。
- 「その日がハイライトされている」感。

### パターンD: スタンプ風
- チェック済みに小さなイラストや記号（例: 花、丸いスタンプ）を表示。
- くすみ色・半透明で統一。遊び心を出しつつミニマルに。

**実装方針**: 初版は **A（ソフトドット）** をデフォルトにし、設定で B/C を選べるようにする拡張を想定。コード上は `CheckMarkStyle` で enum 化しておく。

---

## 4. アーキテクチャ（Clean Architecture）

```
lib/
├── main.dart                      # エントリ + ProviderScope + DI override
├── core/                          # そのまま
│   └── theme/
│       ├── app_colors.dart
│       ├── app_typography.dart
│       └── app_theme.dart
├── domain/                        # ユースケース・エンティティ・Repository インターフェース
│   ├── entity/
│   │   └── notification_settings.dart
│   ├── repository/
│   │   ├── checked_dates_repository.dart
│   │   └── notification_settings_repository.dart
│   └── usecase/
│       ├── get_checked_dates_usecase.dart
│       ├── toggle_check_usecase.dart
│       ├── get_notification_settings_usecase.dart
│       └── set_notification_settings_usecase.dart
├── infrastructure/                # データソース・Repository 実装
│   ├── datasource/
│   │   ├── preference_datasource.dart      # SharedPreferences
│   │   └── notification_schedule_datasource.dart
│   ├── repository/
│   │   ├── checked_dates_repository_impl.dart
│   │   └── notification_settings_repository_impl.dart
│   └── di/
│       └── infrastructure_providers.dart   # Repository 等の Provider 定義
└── presentation/                  # UI と UI まわりの Provider
    ├── app.dart
    ├── di/
    │   └── presentation_providers.dart     # UseCase の Provider
    ├── providers/
    │   ├── checked_dates_provider.dart
    │   └── notification_provider.dart
    └── pages/
        └── calendar/
            ├── calendar_screen.dart
            ├── check_mark_style.dart
            └── widgets/
                ├── month_calendar.dart
                └── day_cell.dart
```

- **依存の向き**: presentation → domain ← infrastructure。Domain は Flutter/外部ライブラリに依存しない。
- **状態**: Presentation の Provider（AsyncNotifier）が UseCase を呼び出し、UseCase が Repository に委譲。Repository の実装は Infrastructure が注入。

---

## 5. 使用パッケージと理由

| パッケージ | 用途 | 理由 |
|-----------|------|------|
| **flutter_riverpod** | 状態管理 | 公式推奨に近く、テスト・分割がしやすい。AsyncNotifier で永続化と連携しやすい。 |
| **table_calendar** | 月表示カレンダー | カスタムビルダーで日付セルを完全に自作でき、くすみデザインに合わせやすい。 |
| **shared_preferences** | ローカル永続化 | 依存が少なく、Set&lt;String&gt;（日付リスト）の保存で十分。将来 Hive に差し替え可能。 |
| **flutter_local_notifications** | 毎日決まった時間の通知 | ローカルでスケジュール可能。timezone は optional（まずは端末ローカル時刻で固定で可）。 |
| **intl** | 日付フォーマット・月名 | DateFormat で「2025年2月」等の表示。locale 対応しやすい。 |

---

## 6. 最小実装コード（動く例）

※ 実際のコードは `lib/` 以下に配置。ここでは構成のみ記載。  
- `main.dart`: `runApp(ProviderScope(child: App()))`
- `app.dart`: `MaterialApp(theme: AppTheme.light, home: CalendarScreen())`
- テーマ: `AppColors` のくすみパレットを `AppTheme` に適用。
- カレンダー: `table_calendar` の `calendarBuilders` で `DayCell` を返す。`DayCell` 内でタップ→ `context.read(checkedDatesProvider.notifier).toggle(date)`。
- 永続化: `CheckedDatesRepository` が `load`/`save(Set<String>)`。Provider の init で `load`、toggle 時に `save`。

---

## 7. 永続化実装

- **形式**: `shared_preferences` にキー `checked_dates` で、カンマ区切りまたは JSON 配列の日付文字列（`yyyy-MM-dd`）を保存。
- **読み込み**: アプリ起動時（Provider の初期化時）に `load` して `Set<String>` に復元。
- **更新**: タップでトグルするたびに `Set` を更新し、即 `save`。非同期でも「先に UI を更新してから save」とすれば体感は即時。
- **将来**: 複数習慣・メモなどを扱う場合は Hive/Isar に移行し、Repository の実装だけ差し替え。

---

## 8. 通知実装

- **flutter_local_notifications** で日次繰り返しをスケジュール。
- **時刻**: ユーザーが選んだ「毎日○時○分」（端末ローカル）。初版は固定（例: 20:00）でも可。
- **手順**:  
  1) プラグイン初期化（Android: channel、iOS: 許可リクエスト）。  
  2) 時刻設定が変わったら既存スケジュールをキャンセルし、新時刻で `zonedSchedule` または Android の `repeat` で毎日発火。  
- **文言**: 短く静かめ。「今日も、少しだけ。」など1行。音・バイブはデフォルト控えめに。

---

## 9. 今後の発展案

- **複数習慣**: タブやリストで「習慣A」「習慣B」を切り替え、それぞれにチェック日セットを紐付け。
- **チェックスタイル設定**: 上記パターン B/C/D を設定画面から選択。
- **テーマ**: ダークモード・別のくすみパレット（ブルー系・グリーン系）。
- **ウィジェット**: ホーム画面に「今月のチェック数」や小さなカレンダーを表示。
- **統計（控えめに）**: 月間の「やった日数」を数字ではなく、月のカレンダー上のビジュアルだけで伝える（例: 塗り面積の割合）。
- **エクスポート**: チェック日一覧を CSV/JSON で出力。

---

## 実装ファイル対応

| 項目 | ファイル |
|------|----------|
| 永続化 | `lib/data/local_storage.dart`（SharedPreferences）、`lib/providers/checked_dates_provider.dart` |
| 通知 | `lib/features/notifications/local_notification_service.dart`、`lib/providers/notification_provider.dart`、`main.dart` で起動時スケジュール |
| チェックスタイル | `lib/features/calendar/check_mark_style.dart`、`lib/features/calendar/widgets/day_cell.dart`（dot/ring/fill） |

**補足**: `pubspec.yaml` の `sdk` は `">=3.0.0 <4.0.0"` に緩和済み（環境に合わせて `^3.10.0` に戻してよい）。
