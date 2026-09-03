import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Just a little, today.'**
  String get appTagline;

  /// No description provided for @editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editRecord;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days going{emoji}'**
  String streakDays(int count, String emoji);

  /// No description provided for @streakStart.
  ///
  /// In en, this message translates to:
  /// **'Start here{emoji}'**
  String streakStart(String emoji);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sectionGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get sectionGoal;

  /// No description provided for @sectionPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Personalize'**
  String get sectionPersonalize;

  /// No description provided for @sectionNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get sectionNotification;

  /// No description provided for @sectionCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get sectionCalendar;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @targetWakeUpTime.
  ///
  /// In en, this message translates to:
  /// **'Wake-up goal'**
  String get targetWakeUpTime;

  /// No description provided for @targetWakeUpTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Success if within ±30 min of this time'**
  String get targetWakeUpTimeSubtitle;

  /// No description provided for @wakeUpTimeHelpText.
  ///
  /// In en, this message translates to:
  /// **'Select wake-up goal time'**
  String get wakeUpTimeHelpText;

  /// No description provided for @wakeUpTimeSet.
  ///
  /// In en, this message translates to:
  /// **'Wake-up goal set to {time}'**
  String wakeUpTimeSet(String time);

  /// No description provided for @appPersonality.
  ///
  /// In en, this message translates to:
  /// **'App personality'**
  String get appPersonality;

  /// No description provided for @appPersonalitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose gentle encouragement or tough love'**
  String get appPersonalitySubtitle;

  /// No description provided for @personaGentle.
  ///
  /// In en, this message translates to:
  /// **'😊 Gentle'**
  String get personaGentle;

  /// No description provided for @personaGentleDesc.
  ///
  /// In en, this message translates to:
  /// **'Warm support'**
  String get personaGentleDesc;

  /// No description provided for @personaStrict.
  ///
  /// In en, this message translates to:
  /// **'💪 Strict'**
  String get personaStrict;

  /// No description provided for @personaStrictDesc.
  ///
  /// In en, this message translates to:
  /// **'Tough push'**
  String get personaStrictDesc;

  /// No description provided for @mbtiType.
  ///
  /// In en, this message translates to:
  /// **'Personality type (MBTI)'**
  String get mbtiType;

  /// No description provided for @mbtiNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get mbtiNotSet;

  /// No description provided for @selectMbtiTitle.
  ///
  /// In en, this message translates to:
  /// **'Select personality type'**
  String get selectMbtiTitle;

  /// No description provided for @mbtiSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Messages feel more personal with MBTI'**
  String get mbtiSelectSubtitle;

  /// No description provided for @mbtiGroupAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Analysts'**
  String get mbtiGroupAnalyst;

  /// No description provided for @mbtiGroupDiplomat.
  ///
  /// In en, this message translates to:
  /// **'Diplomats'**
  String get mbtiGroupDiplomat;

  /// No description provided for @mbtiGroupSentinel.
  ///
  /// In en, this message translates to:
  /// **'Sentinels'**
  String get mbtiGroupSentinel;

  /// No description provided for @mbtiGroupExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorers'**
  String get mbtiGroupExplorer;

  /// No description provided for @mbtiSkip.
  ///
  /// In en, this message translates to:
  /// **'Don\'t set'**
  String get mbtiSkip;

  /// No description provided for @notificationEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationEnable;

  /// No description provided for @notificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification time'**
  String get notificationTime;

  /// No description provided for @weekStart.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStart;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get resetAllData;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetDataTitle;

  /// No description provided for @resetDataContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your check history.\nThis action cannot be undone. Continue?'**
  String get resetDataContent;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Data has been reset'**
  String get resetDone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get confirm;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get loadError;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @weeklyRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weeklyRecordTitle;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @statSuccess.
  ///
  /// In en, this message translates to:
  /// **'Did it'**
  String get statSuccess;

  /// No description provided for @statRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get statRest;

  /// No description provided for @statNone.
  ///
  /// In en, this message translates to:
  /// **'No log'**
  String get statNone;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String dayCount(int count);

  /// No description provided for @optionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Did it'**
  String get optionSuccess;

  /// No description provided for @optionRested.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get optionRested;

  /// No description provided for @optionAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjustment day'**
  String get optionAdjusted;

  /// No description provided for @tapAgainToDelete.
  ///
  /// In en, this message translates to:
  /// **'Tap again to remove'**
  String get tapAgainToDelete;

  /// No description provided for @achievementStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String achievementStreak(int count);

  /// No description provided for @achievementStart.
  ///
  /// In en, this message translates to:
  /// **'Day one'**
  String get achievementStart;

  /// No description provided for @achievementMilestone.
  ///
  /// In en, this message translates to:
  /// **'{count} days 🎉'**
  String achievementMilestone(int count);

  /// No description provided for @achievementWokeAt.
  ///
  /// In en, this message translates to:
  /// **'Woke up'**
  String get achievementWokeAt;

  /// No description provided for @achievementEarlyBy.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before target'**
  String achievementEarlyBy(int minutes);

  /// No description provided for @achievementLateBy.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min after target'**
  String achievementLateBy(int minutes);

  /// No description provided for @achievementOnTarget.
  ///
  /// In en, this message translates to:
  /// **'Right on target'**
  String get achievementOnTarget;

  /// No description provided for @achievementThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get achievementThisMonth;

  /// No description provided for @achievementClose.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get achievementClose;

  /// No description provided for @weeklyReportRange.
  ///
  /// In en, this message translates to:
  /// **'Looking back on {start} - {end}'**
  String weeklyReportRange(String start, String end);

  /// No description provided for @weeklyReportButtonGentle.
  ///
  /// In en, this message translates to:
  /// **'Keep going this week!'**
  String get weeklyReportButtonGentle;

  /// No description provided for @weeklyReportButtonStrict.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get weeklyReportButtonStrict;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
