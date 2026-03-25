import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon'**
  String get appTitle;

  /// No description provided for @tabCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get tabCycle;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navHome;

  /// No description provided for @navSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get navSymptoms;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @phaseMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get phaseMenstruation;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular Phase'**
  String get phaseFollicular;

  /// No description provided for @phaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal Phase'**
  String get phaseLuteal;

  /// No description provided for @phaseLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get phaseLate;

  /// No description provided for @phaseShortMens.
  ///
  /// In en, this message translates to:
  /// **'MENS'**
  String get phaseShortMens;

  /// No description provided for @phaseShortFoll.
  ///
  /// In en, this message translates to:
  /// **'FOLL'**
  String get phaseShortFoll;

  /// No description provided for @phaseShortOvul.
  ///
  /// In en, this message translates to:
  /// **'OVUL'**
  String get phaseShortOvul;

  /// No description provided for @phaseShortLut.
  ///
  /// In en, this message translates to:
  /// **'LUT'**
  String get phaseShortLut;

  /// No description provided for @phaseStatusMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Time to rest & recharge'**
  String get phaseStatusMenstruation;

  /// No description provided for @phaseStatusFollicular.
  ///
  /// In en, this message translates to:
  /// **'Energy is rising'**
  String get phaseStatusFollicular;

  /// No description provided for @phaseStatusOvulation.
  ///
  /// In en, this message translates to:
  /// **'You are glowing today'**
  String get phaseStatusOvulation;

  /// No description provided for @phaseStatusLuteal.
  ///
  /// In en, this message translates to:
  /// **'Be gentle with yourself'**
  String get phaseStatusLuteal;

  /// No description provided for @dayOfCycle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayOfCycle(int day);

  /// No description provided for @editPeriod.
  ///
  /// In en, this message translates to:
  /// **'Edit Period'**
  String get editPeriod;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptoms;

  /// No description provided for @logSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptomsTitle;

  /// No description provided for @predictionText.
  ///
  /// In en, this message translates to:
  /// **'Period in {days} days'**
  String predictionText(int days);

  /// No description provided for @chanceOfPregnancy.
  ///
  /// In en, this message translates to:
  /// **'High chance'**
  String get chanceOfPregnancy;

  /// No description provided for @lowChance.
  ///
  /// In en, this message translates to:
  /// **'Low chance'**
  String get lowChance;

  /// No description provided for @wellnessHeader.
  ///
  /// In en, this message translates to:
  /// **'Wellness & Mood'**
  String get wellnessHeader;

  /// No description provided for @lblFlowAndLove.
  ///
  /// In en, this message translates to:
  /// **'Flow & Intimacy'**
  String get lblFlowAndLove;

  /// No description provided for @lblBodyMind.
  ///
  /// In en, this message translates to:
  /// **'Body & Mind'**
  String get lblBodyMind;

  /// No description provided for @btnCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get btnCheckIn;

  /// No description provided for @symptomHeader.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get symptomHeader;

  /// No description provided for @symptomSubHeader.
  ///
  /// In en, this message translates to:
  /// **'Log your symptoms for better insights.'**
  String get symptomSubHeader;

  /// No description provided for @msgSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get msgSaved;

  /// No description provided for @msgSavedNoPop.
  ///
  /// In en, this message translates to:
  /// **'Symptoms updated successfully'**
  String get msgSavedNoPop;

  /// No description provided for @catFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get catFlow;

  /// No description provided for @logFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow Intensity'**
  String get logFlow;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @catPain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get catPain;

  /// No description provided for @logPain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get logPain;

  /// No description provided for @painNone.
  ///
  /// In en, this message translates to:
  /// **'No Pain'**
  String get painNone;

  /// No description provided for @painCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get painCramps;

  /// No description provided for @painHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get painHeadache;

  /// No description provided for @painBack.
  ///
  /// In en, this message translates to:
  /// **'Back Pain'**
  String get painBack;

  /// No description provided for @catMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get catMood;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get logMood;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get moodEnergetic;

  /// No description provided for @moodIrritated.
  ///
  /// In en, this message translates to:
  /// **'Irritated'**
  String get moodIrritated;

  /// No description provided for @catSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get catSleep;

  /// No description provided for @logSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get logSleep;

  /// No description provided for @logNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get logNotes;

  /// No description provided for @hintNotes.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get hintNotes;

  /// No description provided for @logVitals.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get logVitals;

  /// No description provided for @lblTemp.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get lblTemp;

  /// No description provided for @lblWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get lblWeight;

  /// No description provided for @logSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get logSkin;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// No description provided for @logLibido.
  ///
  /// In en, this message translates to:
  /// **'Libido'**
  String get logLibido;

  /// No description provided for @lblIntimacy.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get lblIntimacy;

  /// No description provided for @hadSex.
  ///
  /// In en, this message translates to:
  /// **'Had Sex'**
  String get hadSex;

  /// No description provided for @protectedSex.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protectedSex;

  /// No description provided for @lblLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lblLifestyle;

  /// No description provided for @lblLifestyleHeader.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle Factors'**
  String get lblLifestyleHeader;

  /// No description provided for @factorStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get factorStress;

  /// No description provided for @factorAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get factorAlcohol;

  /// No description provided for @factorTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get factorTravel;

  /// No description provided for @factorSport.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get factorSport;

  /// No description provided for @lblEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get lblEnergy;

  /// No description provided for @lblMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get lblMood;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @btnStartToday.
  ///
  /// In en, this message translates to:
  /// **'Start Today'**
  String get btnStartToday;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get btnStart;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @btnOk.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get btnOk;

  /// No description provided for @tapToClose.
  ///
  /// In en, this message translates to:
  /// **'Tap to close'**
  String get tapToClose;

  /// No description provided for @btnSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get btnSaveSettings;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @legendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get legendPeriod;

  /// No description provided for @legendFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile'**
  String get legendFertile;

  /// No description provided for @legendOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get legendOvulation;

  /// No description provided for @legendFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get legendFollicular;

  /// No description provided for @legendLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get legendLuteal;

  /// No description provided for @legendPredictedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get legendPredictedPeriod;

  /// No description provided for @calendarHeader.
  ///
  /// In en, this message translates to:
  /// **'Your History'**
  String get calendarHeader;

  /// No description provided for @calendarViewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarViewMonth;

  /// No description provided for @calendarIntimacyQuickLog.
  ///
  /// In en, this message translates to:
  /// **'Intimacy Quick Log'**
  String get calendarIntimacyQuickLog;

  /// No description provided for @calendarLogUnprotectedSex.
  ///
  /// In en, this message translates to:
  /// **'Log Unprotected Sex'**
  String get calendarLogUnprotectedSex;

  /// No description provided for @calendarLogProtectedSex.
  ///
  /// In en, this message translates to:
  /// **'Log Protected Sex'**
  String get calendarLogProtectedSex;

  /// No description provided for @calendarOpenFullLogger.
  ///
  /// In en, this message translates to:
  /// **'Open Full Logger'**
  String get calendarOpenFullLogger;

  /// No description provided for @calendarIntimacyLogged.
  ///
  /// In en, this message translates to:
  /// **'Intimacy logged for {date}'**
  String calendarIntimacyLogged(String date);

  /// No description provided for @calendarIntimacyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Intimacy removed for {date}'**
  String calendarIntimacyRemoved(String date);

  /// No description provided for @calendarBasedOnRecentLogs.
  ///
  /// In en, this message translates to:
  /// **'Based on recent logs'**
  String get calendarBasedOnRecentLogs;

  /// No description provided for @calendarLoggedBreak.
  ///
  /// In en, this message translates to:
  /// **'Logged break'**
  String get calendarLoggedBreak;

  /// No description provided for @calendarLoggedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Logged period'**
  String get calendarLoggedPeriod;

  /// No description provided for @calendarPredictedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Predicted period'**
  String get calendarPredictedPeriod;

  /// No description provided for @calendarFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get calendarFertileWindow;

  /// No description provided for @calendarHasLog.
  ///
  /// In en, this message translates to:
  /// **'Has log'**
  String get calendarHasLog;

  /// No description provided for @calendarPillDay.
  ///
  /// In en, this message translates to:
  /// **'Pill Day {day}'**
  String calendarPillDay(int day);

  /// No description provided for @calendarTwoWeekWaitTtc.
  ///
  /// In en, this message translates to:
  /// **'Two Week Wait (TWW)'**
  String get calendarTwoWeekWaitTtc;

  /// No description provided for @calendarDaysToBreak.
  ///
  /// In en, this message translates to:
  /// **'~{days} days to break'**
  String calendarDaysToBreak(int days);

  /// No description provided for @calendarDaysToPeriod.
  ///
  /// In en, this message translates to:
  /// **'~{days} days to period'**
  String calendarDaysToPeriod(int days);

  /// No description provided for @calendarDaysToFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'~{days} days to fertile window'**
  String calendarDaysToFertileWindow(int days);

  /// No description provided for @calendarDaysToTestDay.
  ///
  /// In en, this message translates to:
  /// **'~{days} days to test day'**
  String calendarDaysToTestDay(int days);

  /// No description provided for @calendarWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ayla'**
  String get calendarWelcomeTitle;

  /// No description provided for @calendarTrackingPaused.
  ///
  /// In en, this message translates to:
  /// **'Tracking paused'**
  String get calendarTrackingPaused;

  /// No description provided for @calendarAddFirstPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Add first day of your period to start.'**
  String get calendarAddFirstPeriodBody;

  /// No description provided for @calendarNeedMoreTimelineData.
  ///
  /// In en, this message translates to:
  /// **'Need more data to build cycle timeline. Please log your previous periods.'**
  String get calendarNeedMoreTimelineData;

  /// No description provided for @calendarCurrentCycleTimeline.
  ///
  /// In en, this message translates to:
  /// **'Current Cycle Timeline'**
  String get calendarCurrentCycleTimeline;

  /// No description provided for @calendarNormalPhase.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get calendarNormalPhase;

  /// No description provided for @calendarTimelineDay.
  ///
  /// In en, this message translates to:
  /// **'D{day}'**
  String calendarTimelineDay(int day);

  /// No description provided for @calendarYourAverages.
  ///
  /// In en, this message translates to:
  /// **'Your Averages'**
  String get calendarYourAverages;

  /// No description provided for @calendarRecentCycles.
  ///
  /// In en, this message translates to:
  /// **'Recent Cycles'**
  String get calendarRecentCycles;

  /// No description provided for @calendarPeakOvulation.
  ///
  /// In en, this message translates to:
  /// **'Peak Ovulation'**
  String get calendarPeakOvulation;

  /// No description provided for @calendarTwoWeekWait.
  ///
  /// In en, this message translates to:
  /// **'Two Week Wait'**
  String get calendarTwoWeekWait;

  /// No description provided for @calendarTestDay.
  ///
  /// In en, this message translates to:
  /// **'Test Day'**
  String get calendarTestDay;

  /// No description provided for @calendarLoggedBleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding'**
  String get calendarLoggedBleeding;

  /// No description provided for @calendarBbtLogged.
  ///
  /// In en, this message translates to:
  /// **'BBT: {temp}'**
  String calendarBbtLogged(String temp);

  /// No description provided for @calendarOpkLogged.
  ///
  /// In en, this message translates to:
  /// **'OPK Logged'**
  String get calendarOpkLogged;

  /// No description provided for @calendarSymptomsLogged.
  ///
  /// In en, this message translates to:
  /// **'Symptoms logged'**
  String get calendarSymptomsLogged;

  /// No description provided for @calendarPrediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get calendarPrediction;

  /// No description provided for @calendarAvgShort.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get calendarAvgShort;

  /// No description provided for @lblPreviousCycle.
  ///
  /// In en, this message translates to:
  /// **'Previous Cycle'**
  String get lblPreviousCycle;

  /// No description provided for @lblNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get lblNoData;

  /// No description provided for @lblNoSymptoms.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged.'**
  String get lblNoSymptoms;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trends & Insights'**
  String get insightsTitle;

  /// No description provided for @insightsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get insightsOverview;

  /// No description provided for @insightsHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get insightsHealth;

  /// No description provided for @insightsPatterns.
  ///
  /// In en, this message translates to:
  /// **'Patterns'**
  String get insightsPatterns;

  /// No description provided for @chartCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get chartCycleLength;

  /// No description provided for @chartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get chartSubtitle;

  /// No description provided for @topSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Top Symptoms'**
  String get topSymptoms;

  /// No description provided for @patternDetected.
  ///
  /// In en, this message translates to:
  /// **'Pattern Detected'**
  String get patternDetected;

  /// No description provided for @patternBody.
  ///
  /// In en, this message translates to:
  /// **'You frequently log headaches before your period. Try hydrating more 2 days prior.'**
  String get patternBody;

  /// No description provided for @insightPhasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Phases'**
  String get insightPhasesTitle;

  /// No description provided for @insightPhasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Typical duration breakdown'**
  String get insightPhasesSubtitle;

  /// No description provided for @insightMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood by Phase'**
  String get insightMoodTitle;

  /// No description provided for @insightMoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Average mood intensity'**
  String get insightMoodSubtitle;

  /// No description provided for @insightVitals.
  ///
  /// In en, this message translates to:
  /// **'Body Vitals'**
  String get insightVitals;

  /// No description provided for @insightVitalsSub.
  ///
  /// In en, this message translates to:
  /// **'Temperature & Weight tracking'**
  String get insightVitalsSub;

  /// No description provided for @insightBodyBalance.
  ///
  /// In en, this message translates to:
  /// **'Body Balance'**
  String get insightBodyBalance;

  /// No description provided for @insightBodyBalanceSub.
  ///
  /// In en, this message translates to:
  /// **'Follicular (Purple) vs Luteal (Orange)'**
  String get insightBodyBalanceSub;

  /// No description provided for @insightMoodFlow.
  ///
  /// In en, this message translates to:
  /// **'Mood Flow'**
  String get insightMoodFlow;

  /// No description provided for @insightMoodFlowSub.
  ///
  /// In en, this message translates to:
  /// **'Recent 30 days trend'**
  String get insightMoodFlowSub;

  /// No description provided for @insightCorrelationTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Patterns'**
  String get insightCorrelationTitle;

  /// No description provided for @insightCorrelationSub.
  ///
  /// In en, this message translates to:
  /// **'How your lifestyle affects your body'**
  String get insightCorrelationSub;

  /// No description provided for @insightPatternText.
  ///
  /// In en, this message translates to:
  /// **'When you log {factor}, you experience {symptom} in {percent}% of cases.'**
  String insightPatternText(String factor, String symptom, int percent);

  /// No description provided for @insightCycleDNA.
  ///
  /// In en, this message translates to:
  /// **'Your Cycle DNA'**
  String get insightCycleDNA;

  /// No description provided for @insightDNASub.
  ///
  /// In en, this message translates to:
  /// **'Follicular vs Luteal Persona'**
  String get insightDNASub;

  /// No description provided for @insightGeneratedOffline.
  ///
  /// In en, this message translates to:
  /// **'Generated offline using your recent symptoms.'**
  String get insightGeneratedOffline;

  /// No description provided for @insightLocalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Local Analysis'**
  String get insightLocalAnalysis;

  /// No description provided for @insightTodayAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Analytics'**
  String get insightTodayAnalytics;

  /// No description provided for @insightAvgCycle.
  ///
  /// In en, this message translates to:
  /// **'Avg Cycle'**
  String get insightAvgCycle;

  /// No description provided for @insightAvgPeriod.
  ///
  /// In en, this message translates to:
  /// **'Avg Period'**
  String get insightAvgPeriod;

  /// No description provided for @unitDaysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get unitDaysShort;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @paramEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get paramEnergy;

  /// No description provided for @paramLibido.
  ///
  /// In en, this message translates to:
  /// **'Libido'**
  String get paramLibido;

  /// No description provided for @paramSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get paramSkin;

  /// No description provided for @paramFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get paramFocus;

  /// No description provided for @predTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Forecast'**
  String get predTitle;

  /// No description provided for @predSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your cycle & sleep patterns'**
  String get predSubtitle;

  /// No description provided for @recHighEnergy.
  ///
  /// In en, this message translates to:
  /// **'Great day for heavy tasks or workouts!'**
  String get recHighEnergy;

  /// No description provided for @recLowEnergy.
  ///
  /// In en, this message translates to:
  /// **'Take it easy. Prioritize rest today.'**
  String get recLowEnergy;

  /// No description provided for @recNormalEnergy.
  ///
  /// In en, this message translates to:
  /// **'Maintain a steady pace.'**
  String get recNormalEnergy;

  /// No description provided for @msgFeedback.
  ///
  /// In en, this message translates to:
  /// **'Is {metric} really {status} today?'**
  String msgFeedback(String metric, String status);

  /// No description provided for @statusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statusLow;

  /// No description provided for @statusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get statusHigh;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @stateLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get stateLow;

  /// No description provided for @stateMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get stateMedium;

  /// No description provided for @stateHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get stateHigh;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is your {metric} really {status} today?'**
  String feedbackQuestion(String metric, String status);

  /// No description provided for @btnYesCorrect.
  ///
  /// In en, this message translates to:
  /// **'Yes, correct'**
  String get btnYesCorrect;

  /// No description provided for @btnNoWrong.
  ///
  /// In en, this message translates to:
  /// **'No, it\'s wrong'**
  String get btnNoWrong;

  /// No description provided for @btnWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get btnWrong;

  /// No description provided for @btnAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get btnAdjust;

  /// No description provided for @predMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeling different?'**
  String get predMismatchTitle;

  /// No description provided for @predMismatchBody.
  ///
  /// In en, this message translates to:
  /// **'Tap an icon to adjust the advice.'**
  String get predMismatchBody;

  /// No description provided for @predInsightHormones.
  ///
  /// In en, this message translates to:
  /// **'Hormones: {hormone} is rising.'**
  String predInsightHormones(String hormone);

  /// No description provided for @hormoneEstrogen.
  ///
  /// In en, this message translates to:
  /// **'Estrogen'**
  String get hormoneEstrogen;

  /// No description provided for @hormoneProgesterone.
  ///
  /// In en, this message translates to:
  /// **'Progesterone'**
  String get hormoneProgesterone;

  /// No description provided for @hormoneReset.
  ///
  /// In en, this message translates to:
  /// **'Hormonal Reset'**
  String get hormoneReset;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGoalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'My Goal'**
  String get profileGoalSectionTitle;

  /// No description provided for @profileGoalTrackBody.
  ///
  /// In en, this message translates to:
  /// **'Standard period and ovulation tracking'**
  String get profileGoalTrackBody;

  /// No description provided for @profileGoalPreventTitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent pregnancy'**
  String get profileGoalPreventTitle;

  /// No description provided for @profileGoalPreventBody.
  ///
  /// In en, this message translates to:
  /// **'Track my birth control pill'**
  String get profileGoalPreventBody;

  /// No description provided for @profileGoalPreventPillTitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent pregnancy (Pill)'**
  String get profileGoalPreventPillTitle;

  /// No description provided for @profileGoalConceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Try to conceive'**
  String get profileGoalConceiveTitle;

  /// No description provided for @profileGoalConceiveBody.
  ///
  /// In en, this message translates to:
  /// **'Maximized fertility predictions & BBT'**
  String get profileGoalConceiveBody;

  /// No description provided for @profileGoalConceiveFromPillBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on this beautiful decision!\n\nSwitching from birth control to pregnancy planning means your natural hormones will restart. We will clear your pill history and begin a completely fresh cycle starting today. Are you ready?'**
  String get profileGoalConceiveFromPillBody;

  /// No description provided for @profileGoalConceiveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on this beautiful decision!\n\nWe will now optimize your AI predictions to pinpoint your exact fertile window and activate advanced tools like Basal Body Temperature tracking. Are you ready?'**
  String get profileGoalConceiveConfirmBody;

  /// No description provided for @profileGoalConceiveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Exciting Journey! 🎉'**
  String get profileGoalConceiveDialogTitle;

  /// No description provided for @profileGoalReadyAction.
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m ready'**
  String get profileGoalReadyAction;

  /// No description provided for @profileGoalCurrentModeBody.
  ///
  /// In en, this message translates to:
  /// **'Your current tracking mode'**
  String get profileGoalCurrentModeBody;

  /// No description provided for @profileChangeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get profileChangeAction;

  /// No description provided for @profilePackFormatBody.
  ///
  /// In en, this message translates to:
  /// **'Choose pill pack format'**
  String get profilePackFormatBody;

  /// No description provided for @profileReminderTimeBody.
  ///
  /// In en, this message translates to:
  /// **'Daily pill reminder time'**
  String get profileReminderTimeBody;

  /// No description provided for @profileAverageCycleBody.
  ///
  /// In en, this message translates to:
  /// **'Average cycle length'**
  String get profileAverageCycleBody;

  /// No description provided for @profileAverageBleedingBody.
  ///
  /// In en, this message translates to:
  /// **'Average bleeding duration'**
  String get profileAverageBleedingBody;

  /// No description provided for @profileLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileLanguageBody;

  /// No description provided for @profileNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle reminders and alerts'**
  String get profileNotificationsBody;

  /// No description provided for @profileDailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Evening symptom reminder'**
  String get profileDailyReminderBody;

  /// No description provided for @profileFaceIdPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID / PIN'**
  String get profileFaceIdPinTitle;

  /// No description provided for @profileFaceIdPinBody.
  ///
  /// In en, this message translates to:
  /// **'Protect your private health data'**
  String get profileFaceIdPinBody;

  /// No description provided for @profileSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Contact support team'**
  String get profileSupportBody;

  /// No description provided for @profilePartnerSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Share your cycle securely'**
  String get profilePartnerSyncBody;

  /// No description provided for @profileHealthSyncAppleTitle.
  ///
  /// In en, this message translates to:
  /// **'Apple Health Sync'**
  String get profileHealthSyncAppleTitle;

  /// No description provided for @profileHealthSyncGoogleTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Health Connect'**
  String get profileHealthSyncGoogleTitle;

  /// No description provided for @profileHealthSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Securely sync your cycle & BBT'**
  String get profileHealthSyncBody;

  /// No description provided for @profileHealthSyncEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sync successfully enabled! 🎉'**
  String get profileHealthSyncEnabled;

  /// No description provided for @profileHealthSyncDenied.
  ///
  /// In en, this message translates to:
  /// **'Sync access denied or unavailable.'**
  String get profileHealthSyncDenied;

  /// No description provided for @profilePdfExportBody.
  ///
  /// In en, this message translates to:
  /// **'Export health report as PDF'**
  String get profilePdfExportBody;

  /// No description provided for @profileBackupCreateBody.
  ///
  /// In en, this message translates to:
  /// **'Create local backup copy'**
  String get profileBackupCreateBody;

  /// No description provided for @profileBackupRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Restore previously saved backup'**
  String get profileBackupRestoreBody;

  /// No description provided for @profileResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset failed. Your data is still on this device.'**
  String get profileResetFailed;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get profileNameLabel;

  /// No description provided for @profileDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get profileDoneAction;

  /// No description provided for @profileHeroPremiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium member'**
  String get profileHeroPremiumMember;

  /// No description provided for @profileHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal health space'**
  String get profileHeroSubtitle;

  /// No description provided for @profileHeroPrivateChip.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get profileHeroPrivateChip;

  /// No description provided for @lblUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get lblUser;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get sectionData;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settingsData;

  /// No description provided for @sectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get sectionBackup;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @lblLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lblLanguage;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @lblNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get lblNotifications;

  /// No description provided for @settingsNotifs.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifs;

  /// No description provided for @lblBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get lblBiometrics;

  /// No description provided for @settingsBiometrics.
  ///
  /// In en, this message translates to:
  /// **'FaceID / TouchID'**
  String get settingsBiometrics;

  /// No description provided for @lblExport.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get lblExport;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Report'**
  String get settingsExport;

  /// No description provided for @lblDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get lblDeleteAccount;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get settingsReset;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get settingsTheme;

  /// No description provided for @settingsDailyLog.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in (20:00)'**
  String get settingsDailyLog;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get settingsSupport;

  /// No description provided for @btnExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Report'**
  String get btnExportPdf;

  /// No description provided for @btnBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get btnBackup;

  /// No description provided for @btnSaveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save Backup'**
  String get btnSaveBackup;

  /// No description provided for @btnRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get btnRestoreBackup;

  /// No description provided for @btnContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get btnContactSupport;

  /// No description provided for @btnRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate EviMoon'**
  String get btnRateApp;

  /// No description provided for @themeOceanic.
  ///
  /// In en, this message translates to:
  /// **'Oceanic'**
  String get themeOceanic;

  /// No description provided for @themeNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get themeNature;

  /// No description provided for @themeVelvet.
  ///
  /// In en, this message translates to:
  /// **'Velvet'**
  String get themeVelvet;

  /// No description provided for @themeDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get themeDigital;

  /// No description provided for @themeActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get themeActive;

  /// No description provided for @selectThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectThemeTitle;

  /// No description provided for @prefNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get prefNotifications;

  /// No description provided for @prefBiometrics.
  ///
  /// In en, this message translates to:
  /// **'FaceID / TouchID'**
  String get prefBiometrics;

  /// No description provided for @prefCOC.
  ///
  /// In en, this message translates to:
  /// **'Contraceptive Pill Mode'**
  String get prefCOC;

  /// No description provided for @descDelete.
  ///
  /// In en, this message translates to:
  /// **'This will permanently erase all your logs from this device.'**
  String get descDelete;

  /// No description provided for @alertDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get alertDeleteTitle;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @dialogResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything?'**
  String get dialogResetTitle;

  /// No description provided for @dialogResetBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your data permanently. This action cannot be undone.'**
  String get dialogResetBody;

  /// No description provided for @dialogResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get dialogResetConfirm;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get languageSelectionTitle;

  /// No description provided for @languageSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your app language'**
  String get languageSelectionSubtitle;

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageNameKyrgyz.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyz'**
  String get languageNameKyrgyz;

  /// No description provided for @languageNameRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageNameRussian;

  /// No description provided for @languageNameSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageNameSpanish;

  /// No description provided for @languageNameGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageNameGerman;

  /// No description provided for @languageNamePortugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get languageNamePortugueseBrazil;

  /// No description provided for @languageNameTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageNameTurkish;

  /// No description provided for @languageNamePolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languageNamePolish;

  /// No description provided for @dialogRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Data?'**
  String get dialogRestoreTitle;

  /// No description provided for @dialogRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your current data with the backup file. Are you sure?'**
  String get dialogRestoreBody;

  /// No description provided for @btnRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get btnRestore;

  /// No description provided for @msgRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully!'**
  String get msgRestoreSuccess;

  /// No description provided for @subscriptionRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get subscriptionRestoreSuccess;

  /// No description provided for @backupSubject.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Backup'**
  String get backupSubject;

  /// No description provided for @backupBody.
  ///
  /// In en, this message translates to:
  /// **'Backup data for EviMoon app created on {date}'**
  String backupBody(String date);

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetEvening;

  /// No description provided for @authLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Locked'**
  String get authLockedTitle;

  /// No description provided for @authUnlockBtn.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get authUnlockBtn;

  /// No description provided for @authReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access EviMoon'**
  String get authReason;

  /// No description provided for @authUnlockShortReason.
  ///
  /// In en, this message translates to:
  /// **'Scan to unlock Ayla'**
  String get authUnlockShortReason;

  /// No description provided for @authNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on device'**
  String get authNotAvailable;

  /// No description provided for @authBiometricsReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometrics'**
  String get authBiometricsReason;

  /// No description provided for @msgBiometricsError.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on this device'**
  String get msgBiometricsError;

  /// No description provided for @pdfReportTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Health Report'**
  String get pdfReportTitle;

  /// No description provided for @pdfReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gynecological & Cycle History'**
  String get pdfReportSubtitle;

  /// No description provided for @pdfCycleHistory.
  ///
  /// In en, this message translates to:
  /// **'Cycle History'**
  String get pdfCycleHistory;

  /// No description provided for @pdfHeaderStart.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get pdfHeaderStart;

  /// No description provided for @pdfHeaderEnd.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get pdfHeaderEnd;

  /// No description provided for @pdfHeaderLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get pdfHeaderLength;

  /// No description provided for @pdfCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get pdfCurrent;

  /// No description provided for @pdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pdfGenerated;

  /// No description provided for @pdfPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pdfPage;

  /// No description provided for @pdfPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get pdfPatient;

  /// No description provided for @pdfClinicalSummary.
  ///
  /// In en, this message translates to:
  /// **'Clinical Summary'**
  String get pdfClinicalSummary;

  /// No description provided for @pdfDetailedLogs.
  ///
  /// In en, this message translates to:
  /// **'Detailed Logs'**
  String get pdfDetailedLogs;

  /// No description provided for @pdfMedicationRegistry.
  ///
  /// In en, this message translates to:
  /// **'Active Medications & Supplements'**
  String get pdfMedicationRegistry;

  /// No description provided for @pdfAvgCycle.
  ///
  /// In en, this message translates to:
  /// **'Avg Cycle Length'**
  String get pdfAvgCycle;

  /// No description provided for @pdfAvgPeriod.
  ///
  /// In en, this message translates to:
  /// **'Avg Period'**
  String get pdfAvgPeriod;

  /// No description provided for @pdfPainReported.
  ///
  /// In en, this message translates to:
  /// **'Pain Reported'**
  String get pdfPainReported;

  /// No description provided for @pdfTableDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pdfTableDate;

  /// No description provided for @pdfTableCD.
  ///
  /// In en, this message translates to:
  /// **'CD'**
  String get pdfTableCD;

  /// No description provided for @pdfTableSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get pdfTableSymptoms;

  /// No description provided for @pdfTableBBT.
  ///
  /// In en, this message translates to:
  /// **'BBT'**
  String get pdfTableBBT;

  /// No description provided for @pdfTableNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get pdfTableNotes;

  /// No description provided for @pdfClinicalSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Clinical Symptoms'**
  String get pdfClinicalSymptoms;

  /// No description provided for @pdfMedicationShort.
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get pdfMedicationShort;

  /// No description provided for @pdfDefaultPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get pdfDefaultPatient;

  /// No description provided for @pdfPeriodRange.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} - {end}'**
  String pdfPeriodRange(String start, String end);

  /// No description provided for @pdfFlowShort.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get pdfFlowShort;

  /// No description provided for @pdfFlowMedium.
  ///
  /// In en, this message translates to:
  /// **'Med'**
  String get pdfFlowMedium;

  /// No description provided for @pdfSymptomSexProtected.
  ///
  /// In en, this message translates to:
  /// **'Sex (P)'**
  String get pdfSymptomSexProtected;

  /// No description provided for @pdfSymptomSexUnprotected.
  ///
  /// In en, this message translates to:
  /// **'Sex (U)'**
  String get pdfSymptomSexUnprotected;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// No description provided for @pdfDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'DISCLAIMER: This report is generated by EviMoon based on user-inputted data. It does not constitute a medical diagnosis.'**
  String get pdfDisclaimer;

  /// No description provided for @msgExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate PDF'**
  String get msgExportError;

  /// No description provided for @msgExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data to export.'**
  String get msgExportEmpty;

  /// No description provided for @dialogDataInsufficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Data'**
  String get dialogDataInsufficientTitle;

  /// No description provided for @dialogDataInsufficientBody.
  ///
  /// In en, this message translates to:
  /// **'To generate a clinical report, we need at least 2 days of logs.'**
  String get dialogDataInsufficientBody;

  /// No description provided for @dayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayTitle;

  /// No description provided for @insightTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip of the Day'**
  String get insightTipTitle;

  /// No description provided for @insightTipBody.
  ///
  /// In en, this message translates to:
  /// **'Energy levels drop during the luteal phase. It\'s a great time for yoga.'**
  String get insightTipBody;

  /// No description provided for @insightMenstruationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest & Reset'**
  String get insightMenstruationTitle;

  /// No description provided for @insightMenstruationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep warm, drink tea, skip heavy workouts.'**
  String get insightMenstruationSubtitle;

  /// No description provided for @insightFollicularTitle.
  ///
  /// In en, this message translates to:
  /// **'Creative Spark'**
  String get insightFollicularTitle;

  /// No description provided for @insightFollicularSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Energy is rising! Brain function is at peak.'**
  String get insightFollicularSubtitle;

  /// No description provided for @insightOvulationTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Power'**
  String get insightOvulationTitle;

  /// No description provided for @insightOvulationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Magnetic energy. High libido & confidence.'**
  String get insightOvulationSubtitle;

  /// No description provided for @insightLutealTitle.
  ///
  /// In en, this message translates to:
  /// **'Inner Focus'**
  String get insightLutealTitle;

  /// No description provided for @insightLutealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calm or irritable. Focus inward.'**
  String get insightLutealSubtitle;

  /// No description provided for @insightLateTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Calm'**
  String get insightLateTitle;

  /// No description provided for @insightLateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce stress and maintain healthy diet.'**
  String get insightLateSubtitle;

  /// No description provided for @insightProstaglandinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prostaglandins at work'**
  String get insightProstaglandinsTitle;

  /// No description provided for @insightProstaglandinsBody.
  ///
  /// In en, this message translates to:
  /// **'Uterine contractions help shed the lining. Warmth and magnesium usually help.'**
  String get insightProstaglandinsBody;

  /// No description provided for @insightWinterPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest & Restore'**
  String get insightWinterPhaseTitle;

  /// No description provided for @insightWinterPhaseBody.
  ///
  /// In en, this message translates to:
  /// **'Hormones are at their lowest. It\'s okay to slow down and recharge.'**
  String get insightWinterPhaseBody;

  /// No description provided for @insightEstrogenTitle.
  ///
  /// In en, this message translates to:
  /// **'Estrogen Rising'**
  String get insightEstrogenTitle;

  /// No description provided for @insightEstrogenBody.
  ///
  /// In en, this message translates to:
  /// **'Estrogen boosts serotonin. Great time for creative tasks and planning!'**
  String get insightEstrogenBody;

  /// No description provided for @insightMittelschmerzTitle.
  ///
  /// In en, this message translates to:
  /// **'Mittelschmerz'**
  String get insightMittelschmerzTitle;

  /// No description provided for @insightMittelschmerzBody.
  ///
  /// In en, this message translates to:
  /// **'You might be feeling the exact moment of ovulation. It is usually brief.'**
  String get insightMittelschmerzBody;

  /// No description provided for @insightFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Peak Fertility'**
  String get insightFertilityTitle;

  /// No description provided for @insightFertilityBody.
  ///
  /// In en, this message translates to:
  /// **'Nature encourages social connection now. You are magnetic!'**
  String get insightFertilityBody;

  /// No description provided for @insightWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Retention'**
  String get insightWaterTitle;

  /// No description provided for @insightWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Body holds water preparing for potential pregnancy. It will pass soon.'**
  String get insightWaterBody;

  /// No description provided for @insightProgesteroneTitle.
  ///
  /// In en, this message translates to:
  /// **'Progesterone Drop'**
  String get insightProgesteroneTitle;

  /// No description provided for @insightProgesteroneBody.
  ///
  /// In en, this message translates to:
  /// **'Brain chemicals dip before period. Be gentle with yourself today.'**
  String get insightProgesteroneBody;

  /// No description provided for @insightSkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Hormonal Skin'**
  String get insightSkinTitle;

  /// No description provided for @insightSkinBody.
  ///
  /// In en, this message translates to:
  /// **'Progesterone stimulates oil glands. Keep skincare simple.'**
  String get insightSkinBody;

  /// No description provided for @insightMetabolismTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Demands'**
  String get insightMetabolismTitle;

  /// No description provided for @insightMetabolismBody.
  ///
  /// In en, this message translates to:
  /// **'Metabolism speeds up. Choose complex carbs instead of sugar.'**
  String get insightMetabolismBody;

  /// No description provided for @insightSpottingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spotting Detected'**
  String get insightSpottingTitle;

  /// No description provided for @insightSpottingBody.
  ///
  /// In en, this message translates to:
  /// **'Light bleeding can happen during ovulation or due to stress.'**
  String get insightSpottingBody;

  /// No description provided for @symptomInsightPeakFertilityDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Peak Fertility Detected! 🎯'**
  String get symptomInsightPeakFertilityDetectedTitle;

  /// No description provided for @symptomInsightPeakFertilityDetectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your LH surge indicates ovulation will likely occur within 24-36 hours. Today and tomorrow are your best days to try to conceive.'**
  String get symptomInsightPeakFertilityDetectedBody;

  /// No description provided for @symptomInsightFertileWindowOpeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window Opening'**
  String get symptomInsightFertileWindowOpeningTitle;

  /// No description provided for @symptomInsightFertileWindowOpeningBody.
  ///
  /// In en, this message translates to:
  /// **'LH levels are rising. Start having intercourse every 1-2 days to maximize your chances as ovulation approaches.'**
  String get symptomInsightFertileWindowOpeningBody;

  /// No description provided for @symptomInsightHighlyFertileMucusTitle.
  ///
  /// In en, this message translates to:
  /// **'Highly Fertile Mucus'**
  String get symptomInsightHighlyFertileMucusTitle;

  /// No description provided for @symptomInsightHighlyFertileMucusBody.
  ///
  /// In en, this message translates to:
  /// **'Egg-white cervical mucus creates the perfect environment for sperm to survive and swim. This is a primary sign of high fertility.'**
  String get symptomInsightHighlyFertileMucusBody;

  /// No description provided for @symptomInsightBuildingUpFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Building Up Fertility'**
  String get symptomInsightBuildingUpFertilityTitle;

  /// No description provided for @symptomInsightBuildingUpFertilityBody.
  ///
  /// In en, this message translates to:
  /// **'Your cervical mucus is transitioning. As you get closer to ovulation, it will become clearer and more stretchy.'**
  String get symptomInsightBuildingUpFertilityBody;

  /// No description provided for @symptomInsightPerfectTimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Timing! ✨'**
  String get symptomInsightPerfectTimingTitle;

  /// No description provided for @symptomInsightPerfectTimingBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve logged unprotected sex during your ovulation phase. You\'ve maximized your chances for this cycle. Now, time for the Two Week Wait (TWW).'**
  String get symptomInsightPerfectTimingBody;

  /// No description provided for @symptomInsightTwoWeekWaitTitle.
  ///
  /// In en, this message translates to:
  /// **'The Two Week Wait'**
  String get symptomInsightTwoWeekWaitTitle;

  /// No description provided for @symptomInsightTwoWeekWaitBody.
  ///
  /// In en, this message translates to:
  /// **'The egg only survives 24h after ovulation. Intercourse in the luteal phase usually doesn\'t lead to conception, but it\'s great for connection!'**
  String get symptomInsightTwoWeekWaitBody;

  /// No description provided for @symptomInsightMedicalAlertPainSpottingTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Alert: Pain & Spotting'**
  String get symptomInsightMedicalAlertPainSpottingTitle;

  /// No description provided for @symptomInsightMedicalAlertPainSpottingBody.
  ///
  /// In en, this message translates to:
  /// **'Spotting accompanied by pain outside your period can indicate cysts, polyps, or hormonal issues. Consider consulting a doctor.'**
  String get symptomInsightMedicalAlertPainSpottingBody;

  /// No description provided for @symptomInsightDysmenorrheaPatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Dysmenorrhea Pattern'**
  String get symptomInsightDysmenorrheaPatternTitle;

  /// No description provided for @symptomInsightDysmenorrheaPatternBody.
  ///
  /// In en, this message translates to:
  /// **'High levels of prostaglandins are causing both severe cramps and nausea. Warmth and NSAIDs (like Ibuprofen) can help block this chemical.'**
  String get symptomInsightDysmenorrheaPatternBody;

  /// No description provided for @symptomInsightSeverePmsPmddTitle.
  ///
  /// In en, this message translates to:
  /// **'Severe PMS / PMDD Indicator'**
  String get symptomInsightSeverePmsPmddTitle;

  /// No description provided for @symptomInsightSeverePmsPmddBody.
  ///
  /// In en, this message translates to:
  /// **'Your emotional symptoms are compounding. This sharp drop in serotonin alongside progesterone is normal, but requires extreme self-care today.'**
  String get symptomInsightSeverePmsPmddBody;

  /// No description provided for @symptomInsightBiologicalPeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Biological Peak'**
  String get symptomInsightBiologicalPeakTitle;

  /// No description provided for @symptomInsightBiologicalPeakBody.
  ///
  /// In en, this message translates to:
  /// **'Estrogen and testosterone are cresting simultaneously. Your body is biologically primed for socializing, mating, and high-energy tasks.'**
  String get symptomInsightBiologicalPeakBody;

  /// No description provided for @symptomLogCycleWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Update Warning'**
  String get symptomLogCycleWarningTitle;

  /// No description provided for @symptomLogOvulationSpottingWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Light bleeding is common during ovulation. Logging this as a New Period will reset your entire cycle predictions. Do you want to start a new cycle, or log this as spotting?'**
  String get symptomLogOvulationSpottingWarningBody;

  /// No description provided for @symptomLogResetStartCycleAction.
  ///
  /// In en, this message translates to:
  /// **'Reset & Start New Cycle'**
  String get symptomLogResetStartCycleAction;

  /// No description provided for @symptomLogJustSpottingAction.
  ///
  /// In en, this message translates to:
  /// **'Just Spotting'**
  String get symptomLogJustSpottingAction;

  /// No description provided for @symptomLogShortCycleWarningBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s been less than 21 days since your last period. Logging this as a New Period will dramatically alter your cycle averages and predictions. Are you sure?'**
  String get symptomLogShortCycleWarningBody;

  /// No description provided for @symptomLogNewPeriodWarningBody.
  ///
  /// In en, this message translates to:
  /// **'This input will end your current cycle and generate new predictions for your next phases. Are you sure you want to log a New Period today?'**
  String get symptomLogNewPeriodWarningBody;

  /// No description provided for @symptomLogStartNewCycleAction.
  ///
  /// In en, this message translates to:
  /// **'Yes, start new cycle'**
  String get symptomLogStartNewCycleAction;

  /// No description provided for @symptomLogRemoveBleedingWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Removing bleeding from a logged period day will recalculate your cycle history and future predictions. Are you sure?'**
  String get symptomLogRemoveBleedingWarningBody;

  /// No description provided for @symptomLogRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove it'**
  String get symptomLogRemoveAction;

  /// No description provided for @symptomLogLhPeakAddedWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Logging an LH Peak will immediately shift your predicted ovulation day and adjust your fertile window. Proceed?'**
  String get symptomLogLhPeakAddedWarningBody;

  /// No description provided for @symptomLogConfirmShiftAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Shift'**
  String get symptomLogConfirmShiftAction;

  /// No description provided for @symptomLogLhPeakRemovedWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Removing the LH Peak will revert your ovulation predictions back to standard AI calculations. Are you sure?'**
  String get symptomLogLhPeakRemovedWarningBody;

  /// No description provided for @symptomLogFuturePredictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Future Prediction'**
  String get symptomLogFuturePredictionTitle;

  /// No description provided for @symptomLogFutureTitle.
  ///
  /// In en, this message translates to:
  /// **'The Future is Bright'**
  String get symptomLogFutureTitle;

  /// No description provided for @symptomLogFutureBody.
  ///
  /// In en, this message translates to:
  /// **'You cannot log symptoms for future dates. Select a past date to enter records.'**
  String get symptomLogFutureBody;

  /// No description provided for @symptomLogTtcAiTitle.
  ///
  /// In en, this message translates to:
  /// **'TTC AI Intelligence'**
  String get symptomLogTtcAiTitle;

  /// No description provided for @symptomLogTtcAiBody.
  ///
  /// In en, this message translates to:
  /// **'Log BBT and LH tests below to refine ovulation timing and fertile-window predictions.'**
  String get symptomLogTtcAiBody;

  /// No description provided for @symptomLogSectionBleedingTitle.
  ///
  /// In en, this message translates to:
  /// **'Bleeding & Flow'**
  String get symptomLogSectionBleedingTitle;

  /// No description provided for @symptomLogSectionBleedingBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the intensity for this day'**
  String get symptomLogSectionBleedingBody;

  /// No description provided for @symptomLogSectionBbtTitle.
  ///
  /// In en, this message translates to:
  /// **'Basal Body Temp (BBT)'**
  String get symptomLogSectionBbtTitle;

  /// No description provided for @symptomLogSectionBbtBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust daily basal temperature'**
  String get symptomLogSectionBbtBody;

  /// No description provided for @symptomLogSectionOpkTitle.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Tests (OPK)'**
  String get symptomLogSectionOpkTitle;

  /// No description provided for @symptomLogSectionOpkBody.
  ///
  /// In en, this message translates to:
  /// **'Only one LH status can be active'**
  String get symptomLogSectionOpkBody;

  /// No description provided for @symptomLogSectionMucusTitle.
  ///
  /// In en, this message translates to:
  /// **'Cervical Mucus'**
  String get symptomLogSectionMucusTitle;

  /// No description provided for @symptomLogSectionMucusBody.
  ///
  /// In en, this message translates to:
  /// **'Track the most relevant type'**
  String get symptomLogSectionMucusBody;

  /// No description provided for @symptomLogSectionIntimacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Intercourse & Libido'**
  String get symptomLogSectionIntimacyTitle;

  /// No description provided for @symptomLogSectionIntimacyTtcBody.
  ///
  /// In en, this message translates to:
  /// **'Helpful for fertility insights'**
  String get symptomLogSectionIntimacyTtcBody;

  /// No description provided for @symptomLogSectionIntimacyBody.
  ///
  /// In en, this message translates to:
  /// **'Track your intimacy and desire'**
  String get symptomLogSectionIntimacyBody;

  /// No description provided for @symptomLogSectionVitalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get symptomLogSectionVitalsTitle;

  /// No description provided for @symptomLogSectionVitalsBody.
  ///
  /// In en, this message translates to:
  /// **'Quick body check-in for the day'**
  String get symptomLogSectionVitalsBody;

  /// No description provided for @symptomLogSectionPhysicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Physical Symptoms'**
  String get symptomLogSectionPhysicalTitle;

  /// No description provided for @symptomLogSectionPhysicalBody.
  ///
  /// In en, this message translates to:
  /// **'Body discomfort and physical signs'**
  String get symptomLogSectionPhysicalBody;

  /// No description provided for @symptomLogSectionMentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Mental & Emotional'**
  String get symptomLogSectionMentalTitle;

  /// No description provided for @symptomLogSectionMentalBody.
  ///
  /// In en, this message translates to:
  /// **'Mood, focus, and emotional state'**
  String get symptomLogSectionMentalBody;

  /// No description provided for @symptomLogSectionOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Factors'**
  String get symptomLogSectionOtherTitle;

  /// No description provided for @symptomLogSectionOtherBody.
  ///
  /// In en, this message translates to:
  /// **'Context that may affect symptoms'**
  String get symptomLogSectionOtherBody;

  /// No description provided for @symptomLogMenstruationConflictRemoved.
  ///
  /// In en, this message translates to:
  /// **'Menstruation logged. Incompatible symptoms (LH Peak / Mucus) removed.'**
  String get symptomLogMenstruationConflictRemoved;

  /// No description provided for @symptomLogBbtMeasuredLabel.
  ///
  /// In en, this message translates to:
  /// **'Basal temperature'**
  String get symptomLogBbtMeasuredLabel;

  /// No description provided for @symptomLogBbtSuggestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested from recent log'**
  String get symptomLogBbtSuggestedLabel;

  /// No description provided for @symptomLogBleedingRemovedOvulationConflict.
  ///
  /// In en, this message translates to:
  /// **'Bleeding removed. Menstruation and ovulation cannot co-occur.'**
  String get symptomLogBleedingRemovedOvulationConflict;

  /// No description provided for @symptomLogBleedingRemovedMucusConflict.
  ///
  /// In en, this message translates to:
  /// **'Bleeding removed. Cervical mucus is not tracked during menstruation.'**
  String get symptomLogBleedingRemovedMucusConflict;

  /// No description provided for @healthFlagPcosTitle.
  ///
  /// In en, this message translates to:
  /// **'Irregular Cycle Pattern'**
  String get healthFlagPcosTitle;

  /// No description provided for @healthFlagPcosBody.
  ///
  /// In en, this message translates to:
  /// **'Your cycles vary significantly in length or are consistently longer than 35 days.'**
  String get healthFlagPcosBody;

  /// No description provided for @healthFlagPcosRecommendation.
  ///
  /// In en, this message translates to:
  /// **'This pattern is sometimes associated with PCOS or thyroid issues. Consider sharing this data with your gynecologist.'**
  String get healthFlagPcosRecommendation;

  /// No description provided for @healthFlagEndometriosisTitle.
  ///
  /// In en, this message translates to:
  /// **'High Pain Profile'**
  String get healthFlagEndometriosisTitle;

  /// No description provided for @healthFlagEndometriosisBody.
  ///
  /// In en, this message translates to:
  /// **'You frequently log severe pelvic pain combined with heavy flow.'**
  String get healthFlagEndometriosisBody;

  /// No description provided for @healthFlagEndometriosisRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Severe period pain that disrupts your life is not normal. This pattern can sometimes indicate endometriosis or fibroids. A doctor can help you manage this.'**
  String get healthFlagEndometriosisRecommendation;

  /// No description provided for @healthFlagLutealDefectTitle.
  ///
  /// In en, this message translates to:
  /// **'Short Luteal Phase'**
  String get healthFlagLutealDefectTitle;

  /// No description provided for @healthFlagLutealDefectBody.
  ///
  /// In en, this message translates to:
  /// **'The time between your ovulation and your next period is consistently short (< 10 days).'**
  String get healthFlagLutealDefectBody;

  /// No description provided for @healthFlagLutealDefectRecommendation.
  ///
  /// In en, this message translates to:
  /// **'A short luteal phase is often linked to low progesterone, which can make it harder to conceive. Useful to mention if you are planning a pregnancy.'**
  String get healthFlagLutealDefectRecommendation;

  /// No description provided for @healthFlagMenorrhagiaTitle.
  ///
  /// In en, this message translates to:
  /// **'Prolonged Bleeding'**
  String get healthFlagMenorrhagiaTitle;

  /// No description provided for @healthFlagMenorrhagiaBody.
  ///
  /// In en, this message translates to:
  /// **'Your periods consistently last 8 days or longer.'**
  String get healthFlagMenorrhagiaBody;

  /// No description provided for @healthFlagMenorrhagiaRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Prolonged bleeding (menorrhagia) can lead to iron deficiency and fatigue. It\'s highly recommended to check your iron levels.'**
  String get healthFlagMenorrhagiaRecommendation;

  /// No description provided for @healthFlagPolymenorrheaTitle.
  ///
  /// In en, this message translates to:
  /// **'Unusually Short Cycles'**
  String get healthFlagPolymenorrheaTitle;

  /// No description provided for @healthFlagPolymenorrheaBody.
  ///
  /// In en, this message translates to:
  /// **'Your cycles are consistently shorter than 21 days.'**
  String get healthFlagPolymenorrheaBody;

  /// No description provided for @healthFlagPolymenorrheaRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Frequent periods can cause anemia and indicate an ovulation issue. Worth discussing with a healthcare provider.'**
  String get healthFlagPolymenorrheaRecommendation;

  /// No description provided for @healthFlagPmddTitle.
  ///
  /// In en, this message translates to:
  /// **'Severe Mood Drops (Luteal)'**
  String get healthFlagPmddTitle;

  /// No description provided for @healthFlagPmddBody.
  ///
  /// In en, this message translates to:
  /// **'You consistently log very low mood, anxiety, or depression in the week before your period.'**
  String get healthFlagPmddBody;

  /// No description provided for @healthFlagPmddRecommendation.
  ///
  /// In en, this message translates to:
  /// **'This cyclic emotional drop may be PMDD (Premenstrual Dysphoric Disorder). You don\'t have to suffer through this alone—treatments are available.'**
  String get healthFlagPmddRecommendation;

  /// No description provided for @healthFlagAmenorrheaTitle.
  ///
  /// In en, this message translates to:
  /// **'Prolonged Cycle Delay'**
  String get healthFlagAmenorrheaTitle;

  /// No description provided for @healthFlagAmenorrheaBody.
  ///
  /// In en, this message translates to:
  /// **'Your current cycle has lasted over 90 days.'**
  String get healthFlagAmenorrheaBody;

  /// No description provided for @healthFlagAmenorrheaRecommendation.
  ///
  /// In en, this message translates to:
  /// **'This is known as secondary amenorrhea. If pregnancy is ruled out, it can be caused by stress, weight changes, or hormonal imbalances. Please consult a doctor.'**
  String get healthFlagAmenorrheaRecommendation;

  /// No description provided for @insightsLoadingHistoryPatterns.
  ///
  /// In en, this message translates to:
  /// **'Analyzing history and patterns...'**
  String get insightsLoadingHistoryPatterns;

  /// No description provided for @insightsFertilityStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertility Status'**
  String get insightsFertilityStatusTitle;

  /// No description provided for @insightsCycleAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Analysis'**
  String get insightsCycleAnalysisTitle;

  /// No description provided for @insightsKeySignalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Key signals from your body'**
  String get insightsKeySignalsSubtitle;

  /// No description provided for @insightsHormonalRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Hormonal Rhythm'**
  String get insightsHormonalRhythmTitle;

  /// No description provided for @insightsHormonalRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'Your symptoms correlated with estimated hormone levels'**
  String get insightsHormonalRhythmBody;

  /// No description provided for @insightsHormonalContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Hormonal Context'**
  String get insightsHormonalContextTitle;

  /// No description provided for @insightsHormonalContextBody.
  ///
  /// In en, this message translates to:
  /// **'Why you might be feeling this way today'**
  String get insightsHormonalContextBody;

  /// No description provided for @insightsMedicalInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Insights'**
  String get insightsMedicalInsightsTitle;

  /// No description provided for @insightsMedicalInsightsBody.
  ///
  /// In en, this message translates to:
  /// **'Patterns detected from your historical logs'**
  String get insightsMedicalInsightsBody;

  /// No description provided for @insightsThermalShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Thermal Shift'**
  String get insightsThermalShiftTitle;

  /// No description provided for @insightsThermalShiftBody.
  ///
  /// In en, this message translates to:
  /// **'Your temperature pattern across this cycle'**
  String get insightsThermalShiftBody;

  /// No description provided for @insightsFrequentSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequent Symptoms'**
  String get insightsFrequentSymptomsTitle;

  /// No description provided for @insightsFrequentSymptomsBody.
  ///
  /// In en, this message translates to:
  /// **'Most repeated symptoms from your recent logs'**
  String get insightsFrequentSymptomsBody;

  /// No description provided for @insightsEmptySymptomsBody.
  ///
  /// In en, this message translates to:
  /// **'Log your daily symptoms to uncover your body\'s unique patterns.'**
  String get insightsEmptySymptomsBody;

  /// No description provided for @insightsTopBarFertilityHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertility Hub'**
  String get insightsTopBarFertilityHubTitle;

  /// No description provided for @insightsTopBarFertilityHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized fertility intelligence'**
  String get insightsTopBarFertilityHubSubtitle;

  /// No description provided for @insightsTopBarDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your body\'s intelligence'**
  String get insightsTopBarDefaultSubtitle;

  /// No description provided for @insightsHeroContraceptiveModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Contraceptive Mode'**
  String get insightsHeroContraceptiveModeTitle;

  /// No description provided for @insightsHeroContraceptiveModeBody.
  ///
  /// In en, this message translates to:
  /// **'Tracking is adapted for pill-based cycles'**
  String get insightsHeroContraceptiveModeBody;

  /// No description provided for @insightsHeroOvulationConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Confirmed'**
  String get insightsHeroOvulationConfirmedTitle;

  /// No description provided for @insightsHeroOvulationConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'You are now in the two-week wait phase'**
  String get insightsHeroOvulationConfirmedBody;

  /// No description provided for @insightsHeroFertileWindowActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window Active'**
  String get insightsHeroFertileWindowActiveTitle;

  /// No description provided for @insightsHeroFertileWindowActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Conception probability is elevated'**
  String get insightsHeroFertileWindowActiveBody;

  /// No description provided for @insightsHeroTrackingFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking Fertility'**
  String get insightsHeroTrackingFertilityTitle;

  /// No description provided for @insightsHeroTrackingFertilityBody.
  ///
  /// In en, this message translates to:
  /// **'Log BBT and symptoms for precision'**
  String get insightsHeroTrackingFertilityBody;

  /// No description provided for @insightsHeroCycleIntelligenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Intelligence'**
  String get insightsHeroCycleIntelligenceTitle;

  /// No description provided for @insightsHeroCycleIntelligenceEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start logging to unlock analysis'**
  String get insightsHeroCycleIntelligenceEmptyBody;

  /// No description provided for @insightsHeroCycleIntelligenceReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Trends updated from recent logs'**
  String get insightsHeroCycleIntelligenceReadyBody;

  /// No description provided for @insightsHeroStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get insightsHeroStatusLabel;

  /// No description provided for @insightsHeroPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get insightsHeroPhaseLabel;

  /// No description provided for @insightsHeroLogsLabel.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get insightsHeroLogsLabel;

  /// No description provided for @insightsHeroCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get insightsHeroCycleLabel;

  /// No description provided for @insightsHeroPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get insightsHeroPeriodLabel;

  /// No description provided for @insightsAylaEngineTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayla AI Engine'**
  String get insightsAylaEngineTitle;

  /// No description provided for @insightsAylaReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily hormonal analysis is ready. You can also chat with Ayla anytime for personalized guidance.'**
  String get insightsAylaReadyBody;

  /// No description provided for @insightsAylaPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Wondering why you feel a certain way today? Chat with Ayla or generate your daily hormone report.'**
  String get insightsAylaPromptBody;

  /// No description provided for @insightsChatWithAylaAction.
  ///
  /// In en, this message translates to:
  /// **'Chat with Ayla'**
  String get insightsChatWithAylaAction;

  /// No description provided for @insightsViewTodaysReportAction.
  ///
  /// In en, this message translates to:
  /// **'View Today\'s Report'**
  String get insightsViewTodaysReportAction;

  /// No description provided for @insightsGenerateDailyReportAction.
  ///
  /// In en, this message translates to:
  /// **'Generate Daily Report'**
  String get insightsGenerateDailyReportAction;

  /// No description provided for @insightsAnalysisDataInsufficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Data insufficient'**
  String get insightsAnalysisDataInsufficientTitle;

  /// No description provided for @insightsAnalysisDataInsufficientBody.
  ///
  /// In en, this message translates to:
  /// **'Log more cycles to unlock insights.'**
  String get insightsAnalysisDataInsufficientBody;

  /// No description provided for @insightsAnalysisOvulationConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ovulation confirmed'**
  String get insightsAnalysisOvulationConfirmedTitle;

  /// No description provided for @insightsAnalysisOvulationConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'You are now in the two-week wait. Keep routines stable.'**
  String get insightsAnalysisOvulationConfirmedBody;

  /// No description provided for @insightsAnalysisFertileWindowOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertile window open'**
  String get insightsAnalysisFertileWindowOpenTitle;

  /// No description provided for @insightsAnalysisFertileWindowOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Chance of conception is high. Log BBT daily.'**
  String get insightsAnalysisFertileWindowOpenBody;

  /// No description provided for @insightsAnalysisTrackingPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking phase'**
  String get insightsAnalysisTrackingPhaseTitle;

  /// No description provided for @insightsAnalysisTrackingPhaseBody.
  ///
  /// In en, this message translates to:
  /// **'Monitoring inputs to predict ovulation day.'**
  String get insightsAnalysisTrackingPhaseBody;

  /// No description provided for @insightsAnalysisContraceptiveModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Contraceptive mode'**
  String get insightsAnalysisContraceptiveModeTitle;

  /// No description provided for @insightsAnalysisContraceptiveModeBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle managed by oral contraceptives. Keep taking pills.'**
  String get insightsAnalysisContraceptiveModeBody;

  /// No description provided for @insightsAnalysisDelayedCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delayed cycle'**
  String get insightsAnalysisDelayedCycleTitle;

  /// No description provided for @insightsAnalysisDelayedCycleBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle delayed >60 days. Consider clinical consultation.'**
  String get insightsAnalysisDelayedCycleBody;

  /// No description provided for @insightsAnalysisIrregularBleedingTitle.
  ///
  /// In en, this message translates to:
  /// **'Irregular bleeding'**
  String get insightsAnalysisIrregularBleedingTitle;

  /// No description provided for @insightsAnalysisIrregularBleedingBody.
  ///
  /// In en, this message translates to:
  /// **'Recent period was longer than typical. Monitor closely.'**
  String get insightsAnalysisIrregularBleedingBody;

  /// No description provided for @insightsAnalysisStableRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stable rhythm'**
  String get insightsAnalysisStableRhythmTitle;

  /// No description provided for @insightsAnalysisStableRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'Your recent cycles look highly consistent.'**
  String get insightsAnalysisStableRhythmBody;

  /// No description provided for @insightsAnalysisLearningRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning your rhythm'**
  String get insightsAnalysisLearningRhythmTitle;

  /// No description provided for @insightsAnalysisLearningRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'App is building a reliable model. Keep logging.'**
  String get insightsAnalysisLearningRhythmBody;

  /// No description provided for @insightsMetricCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle length'**
  String get insightsMetricCycleLength;

  /// No description provided for @insightsMetricPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get insightsMetricPeriod;

  /// No description provided for @insightsMetricFertility.
  ///
  /// In en, this message translates to:
  /// **'Fertility'**
  String get insightsMetricFertility;

  /// No description provided for @insightsMetricOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get insightsMetricOvulation;

  /// No description provided for @insightsMetricYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get insightsMetricYes;

  /// No description provided for @insightsMetricPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get insightsMetricPending;

  /// No description provided for @insightsBbtEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Log your morning temperature to see your thermal shift.'**
  String get insightsBbtEmptyBody;

  /// No description provided for @aylaConsultationTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayla\'s Advice'**
  String get aylaConsultationTitle;

  /// No description provided for @aylaConsultationAction.
  ///
  /// In en, this message translates to:
  /// **'Got it, Ayla'**
  String get aylaConsultationAction;

  /// No description provided for @timerPeriod.
  ///
  /// In en, this message translates to:
  /// **'PERIOD'**
  String get timerPeriod;

  /// No description provided for @timerFertileIn.
  ///
  /// In en, this message translates to:
  /// **'FERTILE IN'**
  String get timerFertileIn;

  /// No description provided for @timerFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'FERTILE WINDOW'**
  String get timerFertileWindow;

  /// No description provided for @timerOvulation.
  ///
  /// In en, this message translates to:
  /// **'OVULATION'**
  String get timerOvulation;

  /// No description provided for @timerPastOvulation.
  ///
  /// In en, this message translates to:
  /// **'PAST OVULATION'**
  String get timerPastOvulation;

  /// No description provided for @timerCycleDelay.
  ///
  /// In en, this message translates to:
  /// **'CYCLE DELAY'**
  String get timerCycleDelay;

  /// No description provided for @timerDayValue.
  ///
  /// In en, this message translates to:
  /// **'DAY {day}'**
  String timerDayValue(int day);

  /// No description provided for @timerDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{days} DAYS'**
  String timerDaysValue(int days);

  /// No description provided for @timerDpoValue.
  ///
  /// In en, this message translates to:
  /// **'{days} DPO'**
  String timerDpoValue(int days);

  /// No description provided for @timerDaysLate.
  ///
  /// In en, this message translates to:
  /// **'DAYS LATE'**
  String get timerDaysLate;

  /// No description provided for @timerPreparing.
  ///
  /// In en, this message translates to:
  /// **'PREPARING'**
  String get timerPreparing;

  /// No description provided for @timerTwwDpo.
  ///
  /// In en, this message translates to:
  /// **'TWW / DPO'**
  String get timerTwwDpo;

  /// No description provided for @tipPeriod.
  ///
  /// In en, this message translates to:
  /// **'Rest up and eat iron-rich foods.'**
  String get tipPeriod;

  /// No description provided for @tipOvulation.
  ///
  /// In en, this message translates to:
  /// **'Peak fertility! Ideal time to conceive.'**
  String get tipOvulation;

  /// No description provided for @tipLutealEarly.
  ///
  /// In en, this message translates to:
  /// **'Progesterone is rising. Stay hydrated.'**
  String get tipLutealEarly;

  /// No description provided for @tipLutealLate.
  ///
  /// In en, this message translates to:
  /// **'Implantation window. Avoid high stress.'**
  String get tipLutealLate;

  /// No description provided for @tipFollicular.
  ///
  /// In en, this message translates to:
  /// **'Energy is rising. Good for exercise.'**
  String get tipFollicular;

  /// No description provided for @tipLowEnergy.
  ///
  /// In en, this message translates to:
  /// **'Rest day valid. Try gentle yoga or a nap.'**
  String get tipLowEnergy;

  /// No description provided for @tipHighEnergy.
  ///
  /// In en, this message translates to:
  /// **'Great time for cardio or tackling complex tasks!'**
  String get tipHighEnergy;

  /// No description provided for @tipLowMood.
  ///
  /// In en, this message translates to:
  /// **'Be gentle with yourself. Chocolate helps.'**
  String get tipLowMood;

  /// No description provided for @tipHighMood.
  ///
  /// In en, this message translates to:
  /// **'Share your vibes! Socialize or create something.'**
  String get tipHighMood;

  /// No description provided for @tipLowFocus.
  ///
  /// In en, this message translates to:
  /// **'Avoid multitasking. Pick one small goal.'**
  String get tipLowFocus;

  /// No description provided for @tipHighFocus.
  ///
  /// In en, this message translates to:
  /// **'Deep work mode. Tackle the hardest project.'**
  String get tipHighFocus;

  /// No description provided for @dialogStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Cycle?'**
  String get dialogStartTitle;

  /// No description provided for @dialogStartBody.
  ///
  /// In en, this message translates to:
  /// **'Today will be marked as Day 1 of your period.'**
  String get dialogStartBody;

  /// No description provided for @dialogEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End Period?'**
  String get dialogEndTitle;

  /// No description provided for @dialogEndBody.
  ///
  /// In en, this message translates to:
  /// **'Your cycle phase will switch to follicular.'**
  String get dialogEndBody;

  /// No description provided for @btnPeriodStart.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
  String get btnPeriodStart;

  /// No description provided for @btnPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'ENDED'**
  String get btnPeriodEnd;

  /// No description provided for @dialogPeriodStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Period Started?'**
  String get dialogPeriodStartTitle;

  /// No description provided for @dialogPeriodStartBody.
  ///
  /// In en, this message translates to:
  /// **'Did your period start today or did you forget to log it?'**
  String get dialogPeriodStartBody;

  /// No description provided for @btnToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get btnToday;

  /// No description provided for @btnYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get btnYesterday;

  /// No description provided for @btnPickDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get btnPickDate;

  /// No description provided for @btnAnotherDay.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get btnAnotherDay;

  /// No description provided for @cocActivePhase.
  ///
  /// In en, this message translates to:
  /// **'Active Pill Phase'**
  String get cocActivePhase;

  /// No description provided for @cocBreakPhase.
  ///
  /// In en, this message translates to:
  /// **'Break Week'**
  String get cocBreakPhase;

  /// No description provided for @cocPredictionActive.
  ///
  /// In en, this message translates to:
  /// **'{days} active pills remaining'**
  String cocPredictionActive(int days);

  /// No description provided for @cocPredictionBreak.
  ///
  /// In en, this message translates to:
  /// **'Start new pack in {days} days'**
  String cocPredictionBreak(int days);

  /// No description provided for @btnStartNewPack.
  ///
  /// In en, this message translates to:
  /// **'Start New Pack'**
  String get btnStartNewPack;

  /// No description provided for @btnRestartPack.
  ///
  /// In en, this message translates to:
  /// **'Restart Pack'**
  String get btnRestartPack;

  /// No description provided for @dialogStartPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Pack?'**
  String get dialogStartPackTitle;

  /// No description provided for @dialogStartPackBody.
  ///
  /// In en, this message translates to:
  /// **'This will reset your cycle to Day 1. Use this when you open a fresh pack.'**
  String get dialogStartPackBody;

  /// No description provided for @dialogCOCStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Contraception?'**
  String get dialogCOCStartTitle;

  /// No description provided for @dialogCOCStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to start tracking your pill pack.'**
  String get dialogCOCStartSubtitle;

  /// No description provided for @optionFreshPack.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh Pack'**
  String get optionFreshPack;

  /// No description provided for @optionFreshPackSub.
  ///
  /// In en, this message translates to:
  /// **'Today is Day 1'**
  String get optionFreshPackSub;

  /// No description provided for @optionContinuePack.
  ///
  /// In en, this message translates to:
  /// **'Continue Current'**
  String get optionContinuePack;

  /// No description provided for @optionContinuePackSub.
  ///
  /// In en, this message translates to:
  /// **'I\'m in the middle of a pack'**
  String get optionContinuePackSub;

  /// No description provided for @labelOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get labelOr;

  /// No description provided for @cocDayInfo.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of 28'**
  String cocDayInfo(int day);

  /// No description provided for @settingsContraception.
  ///
  /// In en, this message translates to:
  /// **'Contraception'**
  String get settingsContraception;

  /// No description provided for @settingsTrackPill.
  ///
  /// In en, this message translates to:
  /// **'Track Contraceptive Pill'**
  String get settingsTrackPill;

  /// No description provided for @settingsPackType.
  ///
  /// In en, this message translates to:
  /// **'Pack Type'**
  String get settingsPackType;

  /// No description provided for @settingsPills.
  ///
  /// In en, this message translates to:
  /// **'{count} Pills'**
  String settingsPills(int count);

  /// No description provided for @settingsReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get settingsReminder;

  /// No description provided for @settingsPackSettings.
  ///
  /// In en, this message translates to:
  /// **'Pack Settings'**
  String get settingsPackSettings;

  /// No description provided for @settingsPlaceboCount.
  ///
  /// In en, this message translates to:
  /// **'Placebo Days'**
  String get settingsPlaceboCount;

  /// No description provided for @settingsBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Break Duration'**
  String get settingsBreakDuration;

  /// No description provided for @dialogPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Pack Type'**
  String get dialogPackTitle;

  /// No description provided for @dialogPackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the pill pack format you use.'**
  String get dialogPackSubtitle;

  /// No description provided for @pack21Title.
  ///
  /// In en, this message translates to:
  /// **'21 Pills'**
  String get pack21Title;

  /// No description provided for @pack21Subtitle.
  ///
  /// In en, this message translates to:
  /// **'21 Active + 7 Days Break'**
  String get pack21Subtitle;

  /// No description provided for @pack28Title.
  ///
  /// In en, this message translates to:
  /// **'28 Pills'**
  String get pack28Title;

  /// No description provided for @pack28Subtitle.
  ///
  /// In en, this message translates to:
  /// **'21 Active + 7 Placebo'**
  String get pack28Subtitle;

  /// No description provided for @pack24Title.
  ///
  /// In en, this message translates to:
  /// **'28 Pills (24+4)'**
  String get pack24Title;

  /// No description provided for @pack24Subtitle.
  ///
  /// In en, this message translates to:
  /// **'24 Active + 4 Placebo'**
  String get pack24Subtitle;

  /// No description provided for @packContinuousTitle.
  ///
  /// In en, this message translates to:
  /// **'Continuous / Mini-Pill'**
  String get packContinuousTitle;

  /// No description provided for @packContinuousSubtitle.
  ///
  /// In en, this message translates to:
  /// **'28 Active (No Break)'**
  String get packContinuousSubtitle;

  /// No description provided for @pack21.
  ///
  /// In en, this message translates to:
  /// **'21 Active + 7 Break'**
  String get pack21;

  /// No description provided for @pack28.
  ///
  /// In en, this message translates to:
  /// **'28 Active (No Break)'**
  String get pack28;

  /// No description provided for @pack24.
  ///
  /// In en, this message translates to:
  /// **'24 Active + 4 Dummy'**
  String get pack24;

  /// No description provided for @pillTaken.
  ///
  /// In en, this message translates to:
  /// **'Pill Taken'**
  String get pillTaken;

  /// No description provided for @pillTake.
  ///
  /// In en, this message translates to:
  /// **'Take Your Pill'**
  String get pillTake;

  /// No description provided for @pillMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed pill?'**
  String get pillMissed;

  /// No description provided for @pillTakeNow.
  ///
  /// In en, this message translates to:
  /// **'Take now'**
  String get pillTakeNow;

  /// No description provided for @pillScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String pillScheduled(String time);

  /// No description provided for @pillScheduledFor.
  ///
  /// In en, this message translates to:
  /// **'It was scheduled for {time}'**
  String pillScheduledFor(String time);

  /// No description provided for @blisterMyPack.
  ///
  /// In en, this message translates to:
  /// **'My Pack'**
  String get blisterMyPack;

  /// No description provided for @blisterDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} / {total}'**
  String blisterDay(int day, int total);

  /// No description provided for @blisterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Day {day} (Overdue)'**
  String blisterOverdue(int day);

  /// No description provided for @blister21.
  ///
  /// In en, this message translates to:
  /// **'21-Day Pack'**
  String get blister21;

  /// No description provided for @blister28.
  ///
  /// In en, this message translates to:
  /// **'28-Day Pack'**
  String get blister28;

  /// No description provided for @legendTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get legendTaken;

  /// No description provided for @legendActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get legendActive;

  /// No description provided for @legendPlacebo.
  ///
  /// In en, this message translates to:
  /// **'Placebo'**
  String get legendPlacebo;

  /// No description provided for @legendBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get legendBreak;

  /// No description provided for @insightCOCActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get insightCOCActiveTitle;

  /// No description provided for @insightCOCActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Active pill phase. Make sure to take your pill at the same time daily.'**
  String get insightCOCActiveBody;

  /// No description provided for @insightCOCBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Bleed'**
  String get insightCOCBreakTitle;

  /// No description provided for @insightCOCBreakBody.
  ///
  /// In en, this message translates to:
  /// **'This is the break week. Bleeding is expected due to hormone drop.'**
  String get insightCOCBreakBody;

  /// No description provided for @sectionCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Settings'**
  String get sectionCycle;

  /// No description provided for @lblCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get lblCycleLength;

  /// No description provided for @lblPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Period Length'**
  String get lblPeriodLength;

  /// No description provided for @lblAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get lblAverage;

  /// No description provided for @lblNormalRange.
  ///
  /// In en, this message translates to:
  /// **'Normal: 21-35 days'**
  String get lblNormalRange;

  /// No description provided for @emailSubject.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Feedback'**
  String get emailSubject;

  /// No description provided for @emailBody.
  ///
  /// In en, this message translates to:
  /// **'Hello EviMoon Team,\n\nI have a question/suggestion regarding the app:'**
  String get emailBody;

  /// No description provided for @msgEmailError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client. Write to: {email}'**
  String msgEmailError(String email);

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to EviMoon'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle, understand your body, and live in harmony with your natural rhythm.'**
  String get onboardBody1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Last Period Start'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In en, this message translates to:
  /// **'Please select the first day of your last menstruation to help us calibrate.'**
  String get onboardBody2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In en, this message translates to:
  /// **'How many days usually pass between periods? The average is 28 days.'**
  String get onboardBody3;

  /// No description provided for @onboardModeTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get onboardModeTitle;

  /// No description provided for @onboardModeCycle.
  ///
  /// In en, this message translates to:
  /// **'Track Cycle'**
  String get onboardModeCycle;

  /// No description provided for @onboardModeCycleDesc.
  ///
  /// In en, this message translates to:
  /// **'Predict periods & fertility window'**
  String get onboardModeCycleDesc;

  /// No description provided for @onboardModePill.
  ///
  /// In en, this message translates to:
  /// **'Track Pill (COC)'**
  String get onboardModePill;

  /// No description provided for @onboardModePillDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders & pack management'**
  String get onboardModePillDesc;

  /// No description provided for @onboardDateTitleCycle.
  ///
  /// In en, this message translates to:
  /// **'When did your last period start?'**
  String get onboardDateTitleCycle;

  /// No description provided for @onboardDateTitlePill.
  ///
  /// In en, this message translates to:
  /// **'When did you start the current pack?'**
  String get onboardDateTitlePill;

  /// No description provided for @onboardLengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get onboardLengthTitle;

  /// No description provided for @onboardPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack Type'**
  String get onboardPackTitle;

  /// No description provided for @onboardPartnerModeCta.
  ///
  /// In en, this message translates to:
  /// **'Partner mode? Enter code here.'**
  String get onboardPartnerModeCta;

  /// No description provided for @onboardProcessingSetup.
  ///
  /// In en, this message translates to:
  /// **'Setting up your AI...'**
  String get onboardProcessingSetup;

  /// No description provided for @onboardSetupError.
  ///
  /// In en, this message translates to:
  /// **'Error during setup. Please try again.'**
  String get onboardSetupError;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'EVIMOON'**
  String get splashTitle;

  /// No description provided for @splashSlogan.
  ///
  /// In en, this message translates to:
  /// **'Listen to your rhythm'**
  String get splashSlogan;

  /// No description provided for @splashBrand.
  ///
  /// In en, this message translates to:
  /// **'AYLA'**
  String get splashBrand;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'breathe & bloom'**
  String get splashTagline;

  /// No description provided for @premiumInsightLabel.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM INSIGHT'**
  String get premiumInsightLabel;

  /// No description provided for @calendarForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'CALENDAR & FORECAST'**
  String get calendarForecastTitle;

  /// No description provided for @aiForecastHigh.
  ///
  /// In en, this message translates to:
  /// **'Forecast is Accurate'**
  String get aiForecastHigh;

  /// No description provided for @aiForecastHighSub.
  ///
  /// In en, this message translates to:
  /// **'Based on your stable history'**
  String get aiForecastHighSub;

  /// No description provided for @aiForecastMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate Confidence'**
  String get aiForecastMedium;

  /// No description provided for @aiForecastMediumSub.
  ///
  /// In en, this message translates to:
  /// **'Some cycle variations detected'**
  String get aiForecastMediumSub;

  /// No description provided for @aiForecastLow.
  ///
  /// In en, this message translates to:
  /// **'Low Accuracy'**
  String get aiForecastLow;

  /// No description provided for @aiForecastLowSub.
  ///
  /// In en, this message translates to:
  /// **'Cycle length varies significantly'**
  String get aiForecastLowSub;

  /// No description provided for @aiLearning.
  ///
  /// In en, this message translates to:
  /// **'AI Learning...'**
  String get aiLearning;

  /// No description provided for @aiLearningSub.
  ///
  /// In en, this message translates to:
  /// **'Log 3 cycles to unlock forecast'**
  String get aiLearningSub;

  /// No description provided for @confidenceHighDesc.
  ///
  /// In en, this message translates to:
  /// **'Cycle is predictable and regular.'**
  String get confidenceHighDesc;

  /// No description provided for @confidenceMedDesc.
  ///
  /// In en, this message translates to:
  /// **'Forecast based on average data.'**
  String get confidenceMedDesc;

  /// No description provided for @confidenceLowDesc.
  ///
  /// In en, this message translates to:
  /// **'Predictions may vary due to irregular history.'**
  String get confidenceLowDesc;

  /// No description provided for @confidenceCalcDesc.
  ///
  /// In en, this message translates to:
  /// **'Gathering more data for better accuracy.'**
  String get confidenceCalcDesc;

  /// No description provided for @confidenceNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough history yet.'**
  String get confidenceNoData;

  /// No description provided for @factorDataNeeded.
  ///
  /// In en, this message translates to:
  /// **'Need at least 3 cycles'**
  String get factorDataNeeded;

  /// No description provided for @factorHighVar.
  ///
  /// In en, this message translates to:
  /// **'High irregularity detected'**
  String get factorHighVar;

  /// No description provided for @factorSlightVar.
  ///
  /// In en, this message translates to:
  /// **'Slight irregularity'**
  String get factorSlightVar;

  /// No description provided for @factorStable.
  ///
  /// In en, this message translates to:
  /// **'Cycle is stable'**
  String get factorStable;

  /// No description provided for @factorAnomaly.
  ///
  /// In en, this message translates to:
  /// **'Recent anomaly detected'**
  String get factorAnomaly;

  /// No description provided for @aiDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Forecast Analysis'**
  String get aiDialogTitle;

  /// No description provided for @aiDialogScore.
  ///
  /// In en, this message translates to:
  /// **'Your cycle forecast confidence score is {score}%.'**
  String aiDialogScore(int score);

  /// No description provided for @aiDialogExplanation.
  ///
  /// In en, this message translates to:
  /// **'This score is calculated locally based on your cycle history variance.'**
  String get aiDialogExplanation;

  /// No description provided for @aiDialogFactors.
  ///
  /// In en, this message translates to:
  /// **'Factors:'**
  String get aiDialogFactors;

  /// No description provided for @btnGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get btnGotIt;

  /// No description provided for @aiStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High Accuracy'**
  String get aiStatusHigh;

  /// No description provided for @aiStatusMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate Accuracy'**
  String get aiStatusMedium;

  /// No description provided for @aiStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low Accuracy'**
  String get aiStatusLow;

  /// No description provided for @aiDescHigh.
  ///
  /// In en, this message translates to:
  /// **'Your cycles are very regular. The AI prediction is likely accurate within ±1 day.'**
  String get aiDescHigh;

  /// No description provided for @aiDescMedium.
  ///
  /// In en, this message translates to:
  /// **'There is some variation in your recent cycles. The prediction might vary by ±2-3 days.'**
  String get aiDescMedium;

  /// No description provided for @aiDescLow.
  ///
  /// In en, this message translates to:
  /// **'Your cycle history is irregular or too short. AI needs more data to be precise.'**
  String get aiDescLow;

  /// No description provided for @aiConfidenceScore.
  ///
  /// In en, this message translates to:
  /// **'Confidence Score'**
  String get aiConfidenceScore;

  /// No description provided for @aiLabelHistory.
  ///
  /// In en, this message translates to:
  /// **'History Length'**
  String get aiLabelHistory;

  /// No description provided for @aiLabelVariation.
  ///
  /// In en, this message translates to:
  /// **'Cycle Variation'**
  String get aiLabelVariation;

  /// No description provided for @aiSuffixCycles.
  ///
  /// In en, this message translates to:
  /// **'cycles'**
  String get aiSuffixCycles;

  /// No description provided for @aiSuffixDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get aiSuffixDays;

  /// No description provided for @modeTTC.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Planning'**
  String get modeTTC;

  /// No description provided for @modeTTCDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable fertility tracking and ovulation focus'**
  String get modeTTCDesc;

  /// No description provided for @modeTTCActive.
  ///
  /// In en, this message translates to:
  /// **'Fertility Mode Activated'**
  String get modeTTCActive;

  /// No description provided for @modeCycle.
  ///
  /// In en, this message translates to:
  /// **'Track Cycle'**
  String get modeCycle;

  /// No description provided for @modeTrackCycle.
  ///
  /// In en, this message translates to:
  /// **'Track Cycle'**
  String get modeTrackCycle;

  /// No description provided for @modeGetPregnant.
  ///
  /// In en, this message translates to:
  /// **'Get Pregnant'**
  String get modeGetPregnant;

  /// No description provided for @dialogTTCConflict.
  ///
  /// In en, this message translates to:
  /// **'Disable Contraception?'**
  String get dialogTTCConflict;

  /// No description provided for @dialogTTCConflictBody.
  ///
  /// In en, this message translates to:
  /// **'To enable Pregnancy Planning mode, contraceptive tracking must be disabled.'**
  String get dialogTTCConflictBody;

  /// No description provided for @btnDisableAndSwitch.
  ///
  /// In en, this message translates to:
  /// **'Disable & Switch'**
  String get btnDisableAndSwitch;

  /// No description provided for @ttcStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low Chance'**
  String get ttcStatusLow;

  /// No description provided for @ttcStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High Fertility'**
  String get ttcStatusHigh;

  /// No description provided for @ttcStatusPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak Fertility'**
  String get ttcStatusPeak;

  /// No description provided for @ttcStatusOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Day'**
  String get ttcStatusOvulation;

  /// No description provided for @ttcDPO.
  ///
  /// In en, this message translates to:
  /// **'{days} DPO'**
  String ttcDPO(int days);

  /// No description provided for @ttcChance.
  ///
  /// In en, this message translates to:
  /// **'Conception Chance'**
  String get ttcChance;

  /// No description provided for @ttcChanceHigh.
  ///
  /// In en, this message translates to:
  /// **'High Chance'**
  String get ttcChanceHigh;

  /// No description provided for @ttcChancePeak.
  ///
  /// In en, this message translates to:
  /// **'Peak Fertility'**
  String get ttcChancePeak;

  /// No description provided for @ttcChanceLow.
  ///
  /// In en, this message translates to:
  /// **'Low Chance'**
  String get ttcChanceLow;

  /// No description provided for @ttcTestWait.
  ///
  /// In en, this message translates to:
  /// **'Too early to test'**
  String get ttcTestWait;

  /// No description provided for @ttcTestReady.
  ///
  /// In en, this message translates to:
  /// **'You can test today'**
  String get ttcTestReady;

  /// No description provided for @lblCycleDay.
  ///
  /// In en, this message translates to:
  /// **'Cycle Day {day}'**
  String lblCycleDay(int day);

  /// No description provided for @ttcCycleDay.
  ///
  /// In en, this message translates to:
  /// **'CYCLE DAY {day}'**
  String ttcCycleDay(int day);

  /// No description provided for @ttcBtnBBT.
  ///
  /// In en, this message translates to:
  /// **'Log BBT'**
  String get ttcBtnBBT;

  /// No description provided for @ttcBtnTest.
  ///
  /// In en, this message translates to:
  /// **'LH Test'**
  String get ttcBtnTest;

  /// No description provided for @ttcBtnSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get ttcBtnSex;

  /// No description provided for @dashboardActionLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get dashboardActionLogged;

  /// No description provided for @dashboardPeriodEndingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ending today'**
  String get dashboardPeriodEndingTitle;

  /// No description provided for @dashboardPeriodEndingBody.
  ///
  /// In en, this message translates to:
  /// **'Tap if bleeding has stopped'**
  String get dashboardPeriodEndingBody;

  /// No description provided for @dashboardPeriodDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of period'**
  String dashboardPeriodDayTitle(int day);

  /// No description provided for @dashboardPeriodDayBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage or log symptoms'**
  String get dashboardPeriodDayBody;

  /// No description provided for @dashboardStartPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Start period'**
  String get dashboardStartPeriodTitle;

  /// No description provided for @dashboardStartPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Log today, yesterday, or choose a date'**
  String get dashboardStartPeriodBody;

  /// No description provided for @dashboardShortCycleSpottingBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s been less than 21 days since your last cycle started. Is this a new period, or just spotting?'**
  String get dashboardShortCycleSpottingBody;

  /// No description provided for @dashboardNewPeriodAction.
  ///
  /// In en, this message translates to:
  /// **'New Period'**
  String get dashboardNewPeriodAction;

  /// No description provided for @dashboardPeriodStartRemoved.
  ///
  /// In en, this message translates to:
  /// **'Period start removed'**
  String get dashboardPeriodStartRemoved;

  /// No description provided for @dashboardFutureDateError.
  ///
  /// In en, this message translates to:
  /// **'Cannot log a date in the future'**
  String get dashboardFutureDateError;

  /// No description provided for @dashboardResumePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume period'**
  String get dashboardResumePeriodTitle;

  /// No description provided for @dashboardResumePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Still bleeding? Continue current period'**
  String get dashboardResumePeriodBody;

  /// No description provided for @dashboardMistakeTitle.
  ///
  /// In en, this message translates to:
  /// **'I made a mistake'**
  String get dashboardMistakeTitle;

  /// No description provided for @dashboardMistakeBody.
  ///
  /// In en, this message translates to:
  /// **'Remove period start'**
  String get dashboardMistakeBody;

  /// No description provided for @dashboardInsightCycleResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Reset'**
  String get dashboardInsightCycleResetTitle;

  /// No description provided for @dashboardInsightCycleResetBody.
  ///
  /// In en, this message translates to:
  /// **'Start fresh. Remember to take your daily folic acid or prenatal vitamins.'**
  String get dashboardInsightCycleResetBody;

  /// No description provided for @dashboardInsightPreparingOvulationTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing for Ovulation'**
  String get dashboardInsightPreparingOvulationTitle;

  /// No description provided for @dashboardInsightPreparingOvulationBody.
  ///
  /// In en, this message translates to:
  /// **'Your body is getting ready. Keep tracking BBT and watch for cervical mucus changes.'**
  String get dashboardInsightPreparingOvulationBody;

  /// No description provided for @dashboardInsightPeakFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Peak Fertility!'**
  String get dashboardInsightPeakFertilityTitle;

  /// No description provided for @dashboardInsightPeakFertilityBody.
  ///
  /// In en, this message translates to:
  /// **'This is your optimal window for conception. Log your intercourse and LH tests.'**
  String get dashboardInsightPeakFertilityBody;

  /// No description provided for @dashboardInsightTwwTitle.
  ///
  /// In en, this message translates to:
  /// **'Two Week Wait (TWW)'**
  String get dashboardInsightTwwTitle;

  /// No description provided for @dashboardInsightTwwBody.
  ///
  /// In en, this message translates to:
  /// **'Progesterone is rising. Stay relaxed, avoid hot tubs, and keep tracking BBT.'**
  String get dashboardInsightTwwBody;

  /// No description provided for @dashboardInsightTestDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Day! 🤞'**
  String get dashboardInsightTestDayTitle;

  /// No description provided for @dashboardInsightTestDayBody.
  ///
  /// In en, this message translates to:
  /// **'Your period is late. It\'s a great time to take a pregnancy test!'**
  String get dashboardInsightTestDayBody;

  /// No description provided for @dashboardInsightRestResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest & Reset'**
  String get dashboardInsightRestResetTitle;

  /// No description provided for @dashboardInsightRestResetBody.
  ///
  /// In en, this message translates to:
  /// **'Your hormones are at their lowest. Focus on hydration.'**
  String get dashboardInsightRestResetBody;

  /// No description provided for @dashboardInsightEnergyRisingTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Rising'**
  String get dashboardInsightEnergyRisingTitle;

  /// No description provided for @dashboardInsightEnergyRisingBody.
  ///
  /// In en, this message translates to:
  /// **'Estrogen is climbing. Great time for complex tasks.'**
  String get dashboardInsightEnergyRisingBody;

  /// No description provided for @dashboardInsightPeakVitalityTitle.
  ///
  /// In en, this message translates to:
  /// **'Peak Vitality'**
  String get dashboardInsightPeakVitalityTitle;

  /// No description provided for @dashboardInsightPeakVitalityBody.
  ///
  /// In en, this message translates to:
  /// **'You are glowing. Best time for high-intensity workouts.'**
  String get dashboardInsightPeakVitalityBody;

  /// No description provided for @dashboardInsightWindDownTitle.
  ///
  /// In en, this message translates to:
  /// **'Wind Down'**
  String get dashboardInsightWindDownTitle;

  /// No description provided for @dashboardInsightWindDownBody.
  ///
  /// In en, this message translates to:
  /// **'Progesterone is high. Cravings and mood swings are normal.'**
  String get dashboardInsightWindDownBody;

  /// No description provided for @dashboardInsightCycleDelayedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Delayed'**
  String get dashboardInsightCycleDelayedTitle;

  /// No description provided for @dashboardInsightCycleDelayedBody.
  ///
  /// In en, this message translates to:
  /// **'Your period is late. Stress could be a factor.'**
  String get dashboardInsightCycleDelayedBody;

  /// No description provided for @dashboardInsightAnalyzingBadge.
  ///
  /// In en, this message translates to:
  /// **'⏳ ANALYZING...'**
  String get dashboardInsightAnalyzingBadge;

  /// No description provided for @dashboardInsightLocalBadge.
  ///
  /// In en, this message translates to:
  /// **'⚡ LOCAL INSIGHT'**
  String get dashboardInsightLocalBadge;

  /// No description provided for @dashboardInsightDailyAiBadge.
  ///
  /// In en, this message translates to:
  /// **'✨ DAILY AI'**
  String get dashboardInsightDailyAiBadge;

  /// No description provided for @dashboardInsightThinkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayla is thinking...'**
  String get dashboardInsightThinkingTitle;

  /// No description provided for @dashboardInsightThinkingBody.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your latest cycle data and symptoms to generate a personalized insight...'**
  String get dashboardInsightThinkingBody;

  /// No description provided for @ttcBtnReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get ttcBtnReset;

  /// No description provided for @ttcLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Log'**
  String get ttcLogTitle;

  /// No description provided for @ttcSectionBBT.
  ///
  /// In en, this message translates to:
  /// **'Basal Body Temperature'**
  String get ttcSectionBBT;

  /// No description provided for @ttcSectionTest.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Test (LH)'**
  String get ttcSectionTest;

  /// No description provided for @ttcSectionSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get ttcSectionSex;

  /// No description provided for @lblNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative (-)'**
  String get lblNegative;

  /// No description provided for @lblPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive (+)'**
  String get lblPositive;

  /// No description provided for @lblPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get lblPeak;

  /// No description provided for @chipNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get chipNegative;

  /// No description provided for @chipPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get chipPositive;

  /// No description provided for @chipPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get chipPeak;

  /// No description provided for @valNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get valNegative;

  /// No description provided for @valPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get valPositive;

  /// No description provided for @valPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get valPeak;

  /// No description provided for @lblSexYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, we did!'**
  String get lblSexYes;

  /// No description provided for @lblSexNo.
  ///
  /// In en, this message translates to:
  /// **'Not today'**
  String get lblSexNo;

  /// No description provided for @labelSexNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get labelSexNo;

  /// No description provided for @labelSexYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get labelSexYes;

  /// No description provided for @valSexYes.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get valSexYes;

  /// No description provided for @ttcTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip'**
  String get ttcTipTitle;

  /// No description provided for @ttcTipDefault.
  ///
  /// In en, this message translates to:
  /// **'Stress affects ovulation. Try 5 min meditation today.'**
  String get ttcTipDefault;

  /// No description provided for @ttcStrategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get ttcStrategyTitle;

  /// No description provided for @ttcStrategyMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimum effort'**
  String get ttcStrategyMinimal;

  /// No description provided for @ttcStrategyMaximal.
  ///
  /// In en, this message translates to:
  /// **'Maximum chances'**
  String get ttcStrategyMaximal;

  /// No description provided for @ttcPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get ttcPlanTitle;

  /// No description provided for @ttcPlanMinimalBody.
  ///
  /// In en, this message translates to:
  /// **'During the fertile window: intimacy every other day, LH tests 2–3 days, BBT optional.'**
  String get ttcPlanMinimalBody;

  /// No description provided for @ttcPlanMaximalBody.
  ///
  /// In en, this message translates to:
  /// **'During the fertile window: intimacy daily, LH tests daily, BBT every morning.'**
  String get ttcPlanMaximalBody;

  /// No description provided for @ttcOvulationBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get ttcOvulationBadgeTitle;

  /// No description provided for @ttcOvulationEstimatedCalendar.
  ///
  /// In en, this message translates to:
  /// **'Estimated (calendar)'**
  String get ttcOvulationEstimatedCalendar;

  /// No description provided for @ttcOvulationConfirmedLH.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by LH'**
  String get ttcOvulationConfirmedLH;

  /// No description provided for @ttcOvulationConfirmedBBT.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by BBT'**
  String get ttcOvulationConfirmedBBT;

  /// No description provided for @ttcOvulationConfirmedManual.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get ttcOvulationConfirmedManual;

  /// No description provided for @dialogHighTempTitle.
  ///
  /// In en, this message translates to:
  /// **'High Temperature'**
  String get dialogHighTempTitle;

  /// No description provided for @dialogHighTempBody.
  ///
  /// In en, this message translates to:
  /// **'Temperature above 37.5°C usually indicates fever, not ovulation.'**
  String get dialogHighTempBody;

  /// No description provided for @dialogLowTempTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Temperature'**
  String get dialogLowTempTitle;

  /// No description provided for @dialogLowTempBody.
  ///
  /// In en, this message translates to:
  /// **'Temperature below 35.5°C is unusually low. Is this a typo?'**
  String get dialogLowTempBody;

  /// No description provided for @dialogPeriodLHTitle.
  ///
  /// In en, this message translates to:
  /// **'Unusual Reading'**
  String get dialogPeriodLHTitle;

  /// No description provided for @dialogPeriodLHBody.
  ///
  /// In en, this message translates to:
  /// **'Positive LH test during menstruation is rare. It might be an error.'**
  String get dialogPeriodLHBody;

  /// No description provided for @btnLogAnyway.
  ///
  /// In en, this message translates to:
  /// **'Log Anyway'**
  String get btnLogAnyway;

  /// No description provided for @insightFertilitySub.
  ///
  /// In en, this message translates to:
  /// **'How your body signals ovulation'**
  String get insightFertilitySub;

  /// No description provided for @insightLibidoHigh.
  ///
  /// In en, this message translates to:
  /// **'High Libido during fertile window'**
  String get insightLibidoHigh;

  /// No description provided for @insightPainOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation pain (Mittelschmerz) detected'**
  String get insightPainOvulation;

  /// No description provided for @insightTempShift.
  ///
  /// In en, this message translates to:
  /// **'Temperature shift detected after ovulation'**
  String get insightTempShift;

  /// No description provided for @lblDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get lblDetected;

  /// No description provided for @msgLhPeakRecorded.
  ///
  /// In en, this message translates to:
  /// **'LH Peak recorded! High fertility window active.'**
  String get msgLhPeakRecorded;

  /// No description provided for @transitionTTC.
  ///
  /// In en, this message translates to:
  /// **'The journey begins... ✨'**
  String get transitionTTC;

  /// No description provided for @transitionCOC.
  ///
  /// In en, this message translates to:
  /// **'Protection activated 🛡️'**
  String get transitionCOC;

  /// No description provided for @transitionTrack.
  ///
  /// In en, this message translates to:
  /// **'Listening to your body 🌿'**
  String get transitionTrack;

  /// No description provided for @notifPhaseFollicularTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Rising ⚡'**
  String get notifPhaseFollicularTitle;

  /// No description provided for @notifPhaseFollicularBody.
  ///
  /// In en, this message translates to:
  /// **'Great time for workouts! Your energy is going up.'**
  String get notifPhaseFollicularBody;

  /// No description provided for @notifFollTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Rising ⚡'**
  String get notifFollTitle;

  /// No description provided for @notifFollBody.
  ///
  /// In en, this message translates to:
  /// **'Great time for workouts! Your energy is going up.'**
  String get notifFollBody;

  /// No description provided for @notifPhaseOvulationTitle.
  ///
  /// In en, this message translates to:
  /// **'You are glowing 🌸'**
  String get notifPhaseOvulationTitle;

  /// No description provided for @notifPhaseOvulationBody.
  ///
  /// In en, this message translates to:
  /// **'Peak confidence and fertility today.'**
  String get notifPhaseOvulationBody;

  /// No description provided for @notifOvulationTitle.
  ///
  /// In en, this message translates to:
  /// **'You are glowing 🌸'**
  String get notifOvulationTitle;

  /// No description provided for @notifOvulationBody.
  ///
  /// In en, this message translates to:
  /// **'Peak confidence and fertility today.'**
  String get notifOvulationBody;

  /// No description provided for @notifPhaseLutealTitle.
  ///
  /// In en, this message translates to:
  /// **'Be Gentle 🌙'**
  String get notifPhaseLutealTitle;

  /// No description provided for @notifPhaseLutealBody.
  ///
  /// In en, this message translates to:
  /// **'Take it slow today, listen to your body.'**
  String get notifPhaseLutealBody;

  /// No description provided for @notifLutealTitle.
  ///
  /// In en, this message translates to:
  /// **'Be Gentle 🌙'**
  String get notifLutealTitle;

  /// No description provided for @notifLutealBody.
  ///
  /// In en, this message translates to:
  /// **'Take it slow today, listen to your body.'**
  String get notifLutealBody;

  /// No description provided for @notifPhasePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'New Cycle 🩸'**
  String get notifPhasePeriodTitle;

  /// No description provided for @notifPhasePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to log the start of your period.'**
  String get notifPhasePeriodBody;

  /// No description provided for @notifPeriodSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Period Soon 🩸'**
  String get notifPeriodSoonTitle;

  /// No description provided for @notifPeriodSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Expect your period tomorrow. Have products ready?'**
  String get notifPeriodSoonBody;

  /// No description provided for @notifPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Update'**
  String get notifPeriodTitle;

  /// No description provided for @notifPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Your period is likely to start in 2 days. Get ready!'**
  String get notifPeriodBody;

  /// No description provided for @notifLatePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Late Period?'**
  String get notifLatePeriodTitle;

  /// No description provided for @notifLatePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle is longer than usual. Log symptoms or take a test.'**
  String get notifLatePeriodBody;

  /// No description provided for @notifLateTitle.
  ///
  /// In en, this message translates to:
  /// **'Late Period?'**
  String get notifLateTitle;

  /// No description provided for @notifLateBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle is longer than usual. Don\'t worry, it happens.'**
  String get notifLateBody;

  /// No description provided for @notifLateFiveDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Period is 5 days late'**
  String get notifLateFiveDaysTitle;

  /// No description provided for @notifLateFiveDaysBody.
  ///
  /// In en, this message translates to:
  /// **'Consider taking a pregnancy test if you\'ve been sexually active.'**
  String get notifLateFiveDaysBody;

  /// No description provided for @notifLogCheckinTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you feel?'**
  String get notifLogCheckinTitle;

  /// No description provided for @notifLogCheckinBody.
  ///
  /// In en, this message translates to:
  /// **'Take a second to log your symptoms for better predictions.'**
  String get notifLogCheckinBody;

  /// No description provided for @notifCheckinTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Log 📝'**
  String get notifCheckinTitle;

  /// No description provided for @notifCheckinBody.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today? Log your symptoms.'**
  String get notifCheckinBody;

  /// No description provided for @notifPillTitle.
  ///
  /// In en, this message translates to:
  /// **'Pill Reminder 💊'**
  String get notifPillTitle;

  /// No description provided for @notifPillBody.
  ///
  /// In en, this message translates to:
  /// **'Time to take your contraception.'**
  String get notifPillBody;

  /// No description provided for @notifNewPackTitle.
  ///
  /// In en, this message translates to:
  /// **'New Pack 💊'**
  String get notifNewPackTitle;

  /// No description provided for @notifNewPackBody.
  ///
  /// In en, this message translates to:
  /// **'Time to start a new blister pack!'**
  String get notifNewPackBody;

  /// No description provided for @notifBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Break Week 🩸'**
  String get notifBreakTitle;

  /// No description provided for @notifBreakBody.
  ///
  /// In en, this message translates to:
  /// **'Active pills finished. Enjoy your break week.'**
  String get notifBreakBody;

  /// No description provided for @partnerLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Invite Code'**
  String get partnerLinkTitle;

  /// No description provided for @partnerLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask your partner to generate a 6-digit code in their Ayla app settings.'**
  String get partnerLinkSubtitle;

  /// No description provided for @partnerLinkHint.
  ///
  /// In en, this message translates to:
  /// **'000-000'**
  String get partnerLinkHint;

  /// No description provided for @partnerLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Connect to Partner'**
  String get partnerLinkButton;

  /// No description provided for @partnerLinkInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Please check and try again.'**
  String get partnerLinkInvalidCode;

  /// No description provided for @partnerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayla for Partners'**
  String get partnerDashboardTitle;

  /// No description provided for @partnerStatusTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking...'**
  String get partnerStatusTracking;

  /// No description provided for @partnerPhaseMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation (Period)'**
  String get partnerPhaseMenstruation;

  /// No description provided for @partnerPhaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular Phase'**
  String get partnerPhaseFollicular;

  /// No description provided for @partnerPhaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Phase'**
  String get partnerPhaseOvulation;

  /// No description provided for @partnerPhaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal Phase (PMS)'**
  String get partnerPhaseLuteal;

  /// No description provided for @partnerPhasePill.
  ///
  /// In en, this message translates to:
  /// **'Pill Cycle'**
  String get partnerPhasePill;

  /// No description provided for @partnerPeriodExpectedToday.
  ///
  /// In en, this message translates to:
  /// **'Period expected today'**
  String get partnerPeriodExpectedToday;

  /// No description provided for @partnerNextPeriodInDays.
  ///
  /// In en, this message translates to:
  /// **'Next period in ~{days} days'**
  String partnerNextPeriodInDays(int days);

  /// No description provided for @partnerCompanionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Companion'**
  String get partnerCompanionTitle;

  /// No description provided for @partnerCompanionLowMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Mood Detected'**
  String get partnerCompanionLowMoodTitle;

  /// No description provided for @partnerAdviceDefault.
  ///
  /// In en, this message translates to:
  /// **'Support your partner today!'**
  String get partnerAdviceDefault;

  /// No description provided for @partnerAdviceMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Energy levels might be low today. It\'s a great time to offer a heating pad, order her favorite comfort food, and keep plans low-key.'**
  String get partnerAdviceMenstruation;

  /// No description provided for @partnerAdviceFollicular.
  ///
  /// In en, this message translates to:
  /// **'Estrogen is rising! She likely has more energy and feels social. Great time for a date night or outdoor activities.'**
  String get partnerAdviceFollicular;

  /// No description provided for @partnerAdviceLuteal.
  ///
  /// In en, this message translates to:
  /// **'Progesterone is high, which can cause fatigue or PMS. Be extra patient, offer a massage, and don\'t take mood swings personally.'**
  String get partnerAdviceLuteal;

  /// No description provided for @partnerAdviceLowMood.
  ///
  /// In en, this message translates to:
  /// **'She logged a low mood today. Send a sweet message or bring her a small treat to brighten her day! 🍫'**
  String get partnerAdviceLowMood;

  /// No description provided for @partnerFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertility Window'**
  String get partnerFertilityTitle;

  /// No description provided for @partnerFertilityHigh.
  ///
  /// In en, this message translates to:
  /// **'Chance of conception is currently HIGH. 👶'**
  String get partnerFertilityHigh;

  /// No description provided for @partnerFertilityLow.
  ///
  /// In en, this message translates to:
  /// **'Chance of conception is low right now.'**
  String get partnerFertilityLow;

  /// No description provided for @partnerSendHug.
  ///
  /// In en, this message translates to:
  /// **'Send a Digital Hug 💖'**
  String get partnerSendHug;

  /// No description provided for @partnerHugSent.
  ///
  /// In en, this message translates to:
  /// **'Digital hug sent! 💖'**
  String get partnerHugSent;

  /// No description provided for @partnerDisconnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Lost'**
  String get partnerDisconnectedTitle;

  /// No description provided for @partnerDisconnectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your partner has unlinked the connection.'**
  String get partnerDisconnectedBody;

  /// No description provided for @partnerGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get partnerGoBack;

  /// No description provided for @partnerSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Sync'**
  String get partnerSyncTitle;

  /// No description provided for @partnerSyncInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Your Partner'**
  String get partnerSyncInviteTitle;

  /// No description provided for @partnerSyncInviteBody.
  ///
  /// In en, this message translates to:
  /// **'Share your cycle phase and mood so your partner knows when you need extra support, chocolate, or space.'**
  String get partnerSyncInviteBody;

  /// No description provided for @partnerSyncGenerateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Invite Code'**
  String get partnerSyncGenerateCode;

  /// No description provided for @partnerSyncPrivacyFootnote.
  ///
  /// In en, this message translates to:
  /// **'You control what they see.'**
  String get partnerSyncPrivacyFootnote;

  /// No description provided for @partnerSyncConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Connected'**
  String get partnerSyncConnectedTitle;

  /// No description provided for @partnerSyncWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Partner...'**
  String get partnerSyncWaitingTitle;

  /// No description provided for @partnerSyncConnectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your Ayla app is securely syncing data.'**
  String get partnerSyncConnectedBody;

  /// No description provided for @partnerSyncWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Ask your partner to download Ayla and enter this code during setup:'**
  String get partnerSyncWaitingBody;

  /// No description provided for @partnerSyncCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get partnerSyncCodeCopied;

  /// No description provided for @partnerSyncCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy • Expires in 24h'**
  String get partnerSyncCodeHint;

  /// No description provided for @partnerSyncPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get partnerSyncPrivacySettings;

  /// No description provided for @partnerSyncShareMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Mood & Energy'**
  String get partnerSyncShareMoodTitle;

  /// No description provided for @partnerSyncShareMoodBody.
  ///
  /// In en, this message translates to:
  /// **'Partner will see if you are tired, anxious, or happy.'**
  String get partnerSyncShareMoodBody;

  /// No description provided for @partnerSyncShareFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Fertility Window'**
  String get partnerSyncShareFertilityTitle;

  /// No description provided for @partnerSyncShareFertilityBody.
  ///
  /// In en, this message translates to:
  /// **'Partner will be notified when your conception chance is high.'**
  String get partnerSyncShareFertilityBody;

  /// No description provided for @partnerSyncUnlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink Partner?'**
  String get partnerSyncUnlinkTitle;

  /// No description provided for @partnerSyncUnlinkBody.
  ///
  /// In en, this message translates to:
  /// **'Your partner will immediately lose access to your cycle updates.'**
  String get partnerSyncUnlinkBody;

  /// No description provided for @partnerSyncUnlinkAction.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get partnerSyncUnlinkAction;

  /// No description provided for @partnerSyncUnlinkButton.
  ///
  /// In en, this message translates to:
  /// **'Unlink Partner'**
  String get partnerSyncUnlinkButton;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayla AI'**
  String get chatTitle;

  /// No description provided for @chatStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online • Cycle Intelligence Assistant'**
  String get chatStatusOnline;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Ayla!'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'I analyze your cycle, logs, and symptoms in real-time. Ask me anything about your current well-being, hormones, or fertility.'**
  String get chatEmptyBody;

  /// No description provided for @chatTyping.
  ///
  /// In en, this message translates to:
  /// **'Ayla is typing...'**
  String get chatTyping;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Ayla...'**
  String get chatInputHint;

  /// No description provided for @chatConnectionIssue.
  ///
  /// In en, this message translates to:
  /// **'I\'m having a little trouble connecting right now. Please check your internet or try again in a moment. 💜'**
  String get chatConnectionIssue;

  /// No description provided for @aiDailyInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Insight'**
  String get aiDailyInsightTitle;

  /// No description provided for @aiDailyInsightBody.
  ///
  /// In en, this message translates to:
  /// **'Listen to your body today.'**
  String get aiDailyInsightBody;

  /// No description provided for @notifAylaInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayla Insight ✨'**
  String get notifAylaInsightTitle;

  /// No description provided for @homeBrandWordmark.
  ///
  /// In en, this message translates to:
  /// **'A Y L A'**
  String get homeBrandWordmark;

  /// No description provided for @homeCocDayOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Day {current} of {total}'**
  String homeCocDayOfTotal(int current, int total);

  /// No description provided for @medicationsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading medications...'**
  String get medicationsLoading;

  /// No description provided for @medicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications & Vitamins'**
  String get medicationsTitle;

  /// No description provided for @medicationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your daily medications or supplements to track intake for the day.'**
  String get medicationsEmptyBody;

  /// No description provided for @medicationsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get medicationsAdd;

  /// No description provided for @medicationsDailyIntake.
  ///
  /// In en, this message translates to:
  /// **'Daily Intake'**
  String get medicationsDailyIntake;

  /// No description provided for @medicationsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get medicationsManage;

  /// No description provided for @medicationsProgressNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing marked as taken yet'**
  String get medicationsProgressNone;

  /// No description provided for @medicationsProgressAll.
  ///
  /// In en, this message translates to:
  /// **'All medications completed for today'**
  String get medicationsProgressAll;

  /// No description provided for @medicationsProgressSome.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} completed today'**
  String medicationsProgressSome(int taken, int total);

  /// No description provided for @medicationsTakenBadge.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get medicationsTakenBadge;

  /// No description provided for @medicationsManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Medications'**
  String get medicationsManageTitle;

  /// No description provided for @medicationsManageBody.
  ///
  /// In en, this message translates to:
  /// **'Add, remove, and organize the medications you want to track each day.'**
  String get medicationsManageBody;

  /// No description provided for @medicationsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current medications'**
  String get medicationsCurrent;

  /// No description provided for @medicationsAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add new medication'**
  String get medicationsAddNew;

  /// No description provided for @medicationsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Medication name'**
  String get medicationsNameLabel;

  /// No description provided for @medicationsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Iron, Vitamin D, Omega-3...'**
  String get medicationsNameHint;

  /// No description provided for @medicationsDosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get medicationsDosageLabel;

  /// No description provided for @medicationsDosageHint.
  ///
  /// In en, this message translates to:
  /// **'500mg, 1 pill, 2 drops...'**
  String get medicationsDosageHint;

  /// No description provided for @medicationsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get medicationsAddButton;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full potential of your cycle.'**
  String get paywallSubtitle;

  /// No description provided for @featureTimersTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Timer Designs'**
  String get featureTimersTitle;

  /// No description provided for @featureTimersDesc.
  ///
  /// In en, this message translates to:
  /// **'Unique styles for your home screen'**
  String get featureTimersDesc;

  /// No description provided for @featurePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical PDF Report'**
  String get featurePdfTitle;

  /// No description provided for @featurePdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Share symptom history with your doctor'**
  String get featurePdfDesc;

  /// No description provided for @featureAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Cycle Confidence'**
  String get featureAiTitle;

  /// No description provided for @featureAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Know how accurate your forecast is'**
  String get featureAiDesc;

  /// No description provided for @featureTtcTitle.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Planning Mode'**
  String get featureTtcTitle;

  /// No description provided for @featureTtcDesc.
  ///
  /// In en, this message translates to:
  /// **'Specialized tools for conception'**
  String get featureTtcDesc;

  /// No description provided for @paywallNoOffers.
  ///
  /// In en, this message translates to:
  /// **'No offers available'**
  String get paywallNoOffers;

  /// No description provided for @paywallSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get paywallSelectPlan;

  /// No description provided for @paywallSubscribeFor.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for {price}'**
  String paywallSubscribeFor(String price);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get paywallRestore;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get paywallTerms;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get paywallBestValue;

  /// No description provided for @msgNoSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions found'**
  String get msgNoSubscriptions;

  /// No description provided for @proStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Status'**
  String get proStatusTitle;

  /// No description provided for @proStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get proStatusActive;

  /// No description provided for @proStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'You have full access to all features.'**
  String get proStatusDesc;

  /// No description provided for @btnManageSub.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get btnManageSub;

  /// No description provided for @btnManageSubDesc.
  ///
  /// In en, this message translates to:
  /// **'Change plan or cancel in iOS Settings'**
  String get btnManageSubDesc;

  /// No description provided for @msgLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings'**
  String get msgLinkError;

  /// No description provided for @badgePro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get badgePro;

  /// No description provided for @badgeGoPro.
  ///
  /// In en, this message translates to:
  /// **'GO PRO'**
  String get badgeGoPro;

  /// No description provided for @badgePremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get badgePremium;

  /// No description provided for @debugPremiumOn.
  ///
  /// In en, this message translates to:
  /// **'DEBUG: Premium ON'**
  String get debugPremiumOn;

  /// No description provided for @debugPremiumOff.
  ///
  /// In en, this message translates to:
  /// **'DEBUG: Premium OFF'**
  String get debugPremiumOff;

  /// No description provided for @phaseNewMoon.
  ///
  /// In en, this message translates to:
  /// **'New Moon'**
  String get phaseNewMoon;

  /// No description provided for @phaseWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing Crescent'**
  String get phaseWaxingCrescent;

  /// No description provided for @phaseFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First Quarter'**
  String get phaseFirstQuarter;

  /// No description provided for @phaseFullMoon.
  ///
  /// In en, this message translates to:
  /// **'Full Moon'**
  String get phaseFullMoon;

  /// No description provided for @phaseWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning Gibbous'**
  String get phaseWaningGibbous;

  /// No description provided for @phaseWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning Crescent'**
  String get phaseWaningCrescent;

  /// No description provided for @lblTest.
  ///
  /// In en, this message translates to:
  /// **'LH Test'**
  String get lblTest;

  /// No description provided for @lblSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get lblSex;

  /// No description provided for @lblMucus.
  ///
  /// In en, this message translates to:
  /// **'Mucus'**
  String get lblMucus;

  /// No description provided for @valMeasured.
  ///
  /// In en, this message translates to:
  /// **'{temp}°'**
  String valMeasured(double temp);

  /// No description provided for @valMucusLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get valMucusLogged;

  /// No description provided for @titleInputBBT.
  ///
  /// In en, this message translates to:
  /// **'Log Temperature'**
  String get titleInputBBT;

  /// No description provided for @titleInputTest.
  ///
  /// In en, this message translates to:
  /// **'LH Test Result'**
  String get titleInputTest;

  /// No description provided for @titleInputSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy details'**
  String get titleInputSex;

  /// No description provided for @titleInputMucus.
  ///
  /// In en, this message translates to:
  /// **'Cervical Mucus'**
  String get titleInputMucus;

  /// No description provided for @mucusDry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get mucusDry;

  /// No description provided for @mucusSticky.
  ///
  /// In en, this message translates to:
  /// **'Sticky'**
  String get mucusSticky;

  /// No description provided for @mucusCreamy.
  ///
  /// In en, this message translates to:
  /// **'Creamy'**
  String get mucusCreamy;

  /// No description provided for @mucusWatery.
  ///
  /// In en, this message translates to:
  /// **'Watery'**
  String get mucusWatery;

  /// No description provided for @mucusEggWhite.
  ///
  /// In en, this message translates to:
  /// **'Egg White'**
  String get mucusEggWhite;

  /// No description provided for @ttcChartTitle.
  ///
  /// In en, this message translates to:
  /// **'BBT CHART (14 DAYS)'**
  String get ttcChartTitle;

  /// No description provided for @ttcChartPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Log temperature to see chart'**
  String get ttcChartPlaceholder;

  /// No description provided for @hintTemp.
  ///
  /// In en, this message translates to:
  /// **'36.6'**
  String get hintTemp;

  /// No description provided for @designSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer Style'**
  String get designSelectorTitle;

  /// No description provided for @designClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get designClassic;

  /// No description provided for @designMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get designMinimal;

  /// No description provided for @designLunar.
  ///
  /// In en, this message translates to:
  /// **'Lunar'**
  String get designLunar;

  /// No description provided for @designBloom.
  ///
  /// In en, this message translates to:
  /// **'Bloom'**
  String get designBloom;

  /// No description provided for @designLiquid.
  ///
  /// In en, this message translates to:
  /// **'Liquid'**
  String get designLiquid;

  /// No description provided for @designOrbit.
  ///
  /// In en, this message translates to:
  /// **'Orbit'**
  String get designOrbit;

  /// No description provided for @designZen.
  ///
  /// In en, this message translates to:
  /// **'Zen'**
  String get designZen;

  /// No description provided for @ttcHintToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ttcHintToday;

  /// No description provided for @ttcTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get ttcTimelineTitle;

  /// No description provided for @ttcTimelineOvulationEquals.
  ///
  /// In en, this message translates to:
  /// **'Ovulation = {day}'**
  String ttcTimelineOvulationEquals(int day);

  /// No description provided for @ttcDockBBT.
  ///
  /// In en, this message translates to:
  /// **'BBT'**
  String get ttcDockBBT;

  /// No description provided for @ttcDockLH.
  ///
  /// In en, this message translates to:
  /// **'LH'**
  String get ttcDockLH;

  /// No description provided for @ttcDockSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get ttcDockSex;

  /// No description provided for @ttcDockMucus.
  ///
  /// In en, this message translates to:
  /// **'Mucus'**
  String get ttcDockMucus;

  /// No description provided for @ttcShortBBT.
  ///
  /// In en, this message translates to:
  /// **'BBT'**
  String get ttcShortBBT;

  /// No description provided for @ttcShortLH.
  ///
  /// In en, this message translates to:
  /// **'LH'**
  String get ttcShortLH;

  /// No description provided for @ttcShortSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get ttcShortSex;

  /// No description provided for @ttcShortMucus.
  ///
  /// In en, this message translates to:
  /// **'Mucus'**
  String get ttcShortMucus;

  /// No description provided for @ttcMarkDone.
  ///
  /// In en, this message translates to:
  /// **'✓'**
  String get ttcMarkDone;

  /// No description provided for @ttcMarkMissing.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get ttcMarkMissing;

  /// No description provided for @ttcAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done ✓'**
  String get ttcAllDone;

  /// No description provided for @ttcMissingList.
  ///
  /// In en, this message translates to:
  /// **'Left: {items}'**
  String ttcMissingList(String items);

  /// No description provided for @ttcRemainingLeft.
  ///
  /// In en, this message translates to:
  /// **'Left: {items}'**
  String ttcRemainingLeft(String items);

  /// No description provided for @ttcCtaTestReadyBody.
  ///
  /// In en, this message translates to:
  /// **'DPO {dpo} • BBT {bbt} • LH {lh}'**
  String ttcCtaTestReadyBody(int dpo, String bbt, String lh);

  /// No description provided for @ttcCtaTestWaitBody.
  ///
  /// In en, this message translates to:
  /// **'DPO {dpo} • ~{days} day(s) until a reliable test'**
  String ttcCtaTestWaitBody(int dpo, int days);

  /// No description provided for @ttcCtaPeakBody.
  ///
  /// In en, this message translates to:
  /// **'Today/tomorrow is the peak. Log sex and test to improve accuracy.'**
  String get ttcCtaPeakBody;

  /// No description provided for @ttcCtaHighBody.
  ///
  /// In en, this message translates to:
  /// **'Fertile window is open • peak in ~{days} day(s).'**
  String ttcCtaHighBody(int days);

  /// No description provided for @ttcCtaMenstruationBody.
  ///
  /// In en, this message translates to:
  /// **'Gentle mode: sleep, water, warmth. Logging is optional — but BBT helps.'**
  String get ttcCtaMenstruationBody;

  /// No description provided for @ttcCtaLowBody.
  ///
  /// In en, this message translates to:
  /// **'Prep day • {status}'**
  String ttcCtaLowBody(String status);

  /// No description provided for @ttcDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get ttcDash;

  /// No description provided for @eduTitleBBT.
  ///
  /// In en, this message translates to:
  /// **'Why track BBT?'**
  String get eduTitleBBT;

  /// No description provided for @eduBodyBBT.
  ///
  /// In en, this message translates to:
  /// **'Basal Body Temperature (BBT) rises slightly after ovulation due to progesterone production. Tracking it confirms that ovulation has actually occurred.'**
  String get eduBodyBBT;

  /// No description provided for @eduTitleLH.
  ///
  /// In en, this message translates to:
  /// **'Why use Ovulation Tests?'**
  String get eduTitleLH;

  /// No description provided for @eduBodyLH.
  ///
  /// In en, this message translates to:
  /// **'Luteinizing Hormone (LH) surges 24-48 hours before ovulation. A positive test predicts your most fertile days before the egg is released.'**
  String get eduBodyLH;

  /// No description provided for @eduTitleSex.
  ///
  /// In en, this message translates to:
  /// **'Logging Intimacy'**
  String get eduTitleSex;

  /// No description provided for @eduBodySex.
  ///
  /// In en, this message translates to:
  /// **'Sperm can survive for up to 5 days inside the body. Logging helps you ensure you have timed intimacy within your fertile window for the best chance of conception.'**
  String get eduBodySex;

  /// No description provided for @eduTitleMucus.
  ///
  /// In en, this message translates to:
  /// **'Cervical Mucus'**
  String get eduTitleMucus;

  /// No description provided for @eduBodyMucus.
  ///
  /// In en, this message translates to:
  /// **'As ovulation approaches, estrogen makes your fluid stretchy and clear (like egg whites). This creates the perfect environment for sperm to swim and survive.'**
  String get eduBodyMucus;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'pl', 'pt', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
