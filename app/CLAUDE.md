# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Platform

**iOS のみリリース対象。Android は未対応。** ビルド・アップロード作業は iOS（IPA）のみ行う。

## Commands

This project uses [FVM](https://fvm.app/) to pin Flutter at `3.38.2`. Prefix all Flutter/Dart commands with `fvm`:

```bash
fvm flutter run                          # run on connected device/simulator
fvm flutter run -d macos                 # run macOS desktop target
fvm flutter build ipa --release          # build iOS IPA for App Store
fvm flutter analyze                      # lint (uses flutter_lints)
fvm flutter test                         # run all tests
fvm flutter test test/domain/service/wake_up_evaluator_test.dart  # single test file
fvm flutter pub get                      # install dependencies
```

## Architecture

Clean Architecture with three layers. **Dependency direction: presentation → domain ← infrastructure.** Domain has zero Flutter/package dependencies.

```
lib/
├── core/theme/          # AppColors, AppTypography, AppTheme — design tokens only
├── domain/
│   ├── entity/          # Pure Dart value objects (WakeUpRecord, WakeUpStatus, UserProfile, …)
│   ├── repository/      # Abstract interfaces (no implementations here)
│   ├── service/         # Domain logic (WakeUpEvaluator, WeeklyReportService)
│   └── usecase/         # One public `call()` method per use case
├── infrastructure/
│   ├── datasource/      # PreferenceDatasource (SharedPreferences), NotificationScheduleDatasource
│   ├── repository/      # Concrete implementations of domain repository interfaces
│   └── di/
│       └── infrastructure_providers.dart  # Riverpod Provider definitions for repositories
├── presentation/
│   ├── di/
│   │   └── presentation_providers.dart    # Riverpod Provider definitions for use cases & services
│   ├── providers/       # AsyncNotifier / Notifier state holders (one per feature area)
│   └── pages/           # Screen widgets and their sub-widgets
└── main.dart            # ProviderScope root; SharedPreferences & notifications initialized here
```

### Dependency Injection

`sharedPreferencesProvider` in `infrastructure_providers.dart` is intentionally unimplemented — it **must** be overridden in `main.dart` via `ProviderScope(overrides: [...])`. Tests override it with a fake/mock instance.

### State Management Pattern

Providers flow: `AsyncNotifier` (presentation/providers) → UseCase (domain) → Repository interface (domain) → Repository impl (infrastructure) → datasource.

`WakeUpRecordsNotifier` is the main example: it holds `Map<String, WakeUpRecord>` keyed by `yyyy-MM-dd` date strings, and optimistically updates state after each mutation without re-fetching everything.

### Key Domain Concepts

- **WakeUpStatus** — three states: `success` (within ±30 min of target), `failed` (>30 min late), `none` (not recorded). Contains legacy `fromJson` mappings for old status names.
- **CheckMarkStyle** — enum for calendar dot rendering style (`softDot`, `ring`, `softFill`). Used in `DayCell`.
- All dates stored as `yyyy-MM-dd` strings in SharedPreferences (JSON arrays or comma-separated sets).

### Notifications

`NotificationScheduleDatasource` wraps `flutter_local_notifications` + `timezone`. It is initialized in `main()` before `runApp`, and rescheduled whenever settings change.

## Rules (Critical)

- Always run `fvm flutter analyze` after changes
- Always run `fvm flutter test` if tests are affected
- Do not import non-existing packages
- Do not create fake/mock APIs unless explicitly requested
- Follow existing architecture strictly (presentation → domain ← infrastructure)
- Do not modify unrelated files
- Keep changes minimal and focused

## Output Requirements

- Code must compile without errors
- No analyzer warnings allowed
- Respect null safety
- Use existing patterns and naming conventions
