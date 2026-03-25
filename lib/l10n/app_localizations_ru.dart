// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'EviMoon';

  @override
  String get tabCycle => 'Цикл';

  @override
  String get tabCalendar => 'Календарь';

  @override
  String get tabInsights => 'Аналитика';

  @override
  String get tabLearn => 'Советы';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get navHome => 'Сегодня';

  @override
  String get navSymptoms => 'Симптомы';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navProfile => 'Профиль';

  @override
  String get phaseMenstruation => 'Менструация';

  @override
  String get phaseFollicular => 'Фолликулярная фаза';

  @override
  String get phaseOvulation => 'Овуляция';

  @override
  String get phaseLuteal => 'Лютеиновая фаза';

  @override
  String get phaseLate => 'Задержка';

  @override
  String get phaseShortMens => 'МЕНС';

  @override
  String get phaseShortFoll => 'ФОЛЛ';

  @override
  String get phaseShortOvul => 'ОВУЛ';

  @override
  String get phaseShortLut => 'ЛЮТ';

  @override
  String get phaseStatusMenstruation => 'Время для отдыха и заботы';

  @override
  String get phaseStatusFollicular => 'Энергия растет';

  @override
  String get phaseStatusOvulation => 'Вы сегодня сияете';

  @override
  String get phaseStatusLuteal => 'Будьте бережны к себе';

  @override
  String dayOfCycle(int day) {
    return 'День $day';
  }

  @override
  String get editPeriod => 'Отметить';

  @override
  String get logSymptoms => 'Симптомы';

  @override
  String get logSymptomsTitle => 'Отметить симптомы';

  @override
  String predictionText(int days) {
    return 'Месячные через $days дн.';
  }

  @override
  String get chanceOfPregnancy => 'Высокая вероятность';

  @override
  String get lowChance => 'Низкая вероятность';

  @override
  String get wellnessHeader => 'Самочувствие и настроение';

  @override
  String get lblFlowAndLove => 'Выделения и Близость';

  @override
  String get lblBodyMind => 'Тело и Разум';

  @override
  String get btnCheckIn => 'Отметить состояние';

  @override
  String get symptomHeader => 'Как самочувствие?';

  @override
  String get symptomSubHeader => 'Отметьте симптомы для точного прогноза.';

  @override
  String get msgSaved => 'Сохранено!';

  @override
  String get msgSavedNoPop => 'Симптомы обновлены';

  @override
  String get catFlow => 'Выделения';

  @override
  String get logFlow => 'Выделения';

  @override
  String get flowLight => 'Лёгкие';

  @override
  String get flowMedium => 'Умеренные';

  @override
  String get flowHeavy => 'Обильные';

  @override
  String get catPain => 'Болевые ощущения';

  @override
  String get logPain => 'Боль';

  @override
  String get painNone => 'Нет боли';

  @override
  String get painCramps => 'Спазмы';

  @override
  String get painHeadache => 'Голова';

  @override
  String get painBack => 'Спина';

  @override
  String get catMood => 'Настроение';

  @override
  String get logMood => 'Настроение';

  @override
  String get moodHappy => 'Радость';

  @override
  String get moodSad => 'Грусть';

  @override
  String get moodAnxious => 'Тревога';

  @override
  String get moodEnergetic => 'Энергия';

  @override
  String get moodIrritated => 'Раздражение';

  @override
  String get catSleep => 'Сон';

  @override
  String get logSleep => 'Сон';

  @override
  String get logNotes => 'Заметки';

  @override
  String get hintNotes => 'Что-то еще произошло?';

  @override
  String get logVitals => 'Показатели';

  @override
  String get lblTemp => 'Температура';

  @override
  String get lblWeight => 'Вес (кг)';

  @override
  String get logSkin => 'Кожа';

  @override
  String get symptomAcne => 'Акне';

  @override
  String get symptomNausea => 'Тошнота';

  @override
  String get symptomBloating => 'Вздутие';

  @override
  String get logLibido => 'Либидо';

  @override
  String get lblIntimacy => 'Интим';

  @override
  String get hadSex => 'Секс';

  @override
  String get protectedSex => 'Защищенный';

  @override
  String get lblLifestyle => 'Образ жизни';

  @override
  String get lblLifestyleHeader => 'Образ жизни';

  @override
  String get factorStress => 'Стресс';

  @override
  String get factorAlcohol => 'Алкоголь';

  @override
  String get factorTravel => 'Поездки';

  @override
  String get factorSport => 'Спорт';

  @override
  String get lblEnergy => 'Энергия';

  @override
  String get lblMood => 'Настроение';

  @override
  String get btnSave => 'Сохранить';

  @override
  String get btnCancel => 'Отмена';

  @override
  String get btnConfirm => 'Подтвердить';

  @override
  String get btnStartToday => 'Start Today';

  @override
  String get btnNext => 'Далее';

  @override
  String get btnStart => 'Начать';

  @override
  String get btnDelete => 'Удалить';

  @override
  String get btnOk => 'Понятно';

  @override
  String get tapToClose => 'Нажмите, чтобы закрыть';

  @override
  String get btnSaveSettings => 'Сохранить настройки';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get legendPeriod => 'Месячные';

  @override
  String get legendFertile => 'Фертильность';

  @override
  String get legendOvulation => 'Овуляция';

  @override
  String get legendFollicular => 'Фолликул.';

  @override
  String get legendLuteal => 'Лютеин.';

  @override
  String get legendPredictedPeriod => 'Прогноз';

  @override
  String get calendarHeader => 'История циклов';

  @override
  String get calendarViewMonth => 'Month';

  @override
  String get calendarIntimacyQuickLog => 'Intimacy Quick Log';

  @override
  String get calendarLogUnprotectedSex => 'Log Unprotected Sex';

  @override
  String get calendarLogProtectedSex => 'Log Protected Sex';

  @override
  String get calendarOpenFullLogger => 'Open Full Logger';

  @override
  String calendarIntimacyLogged(String date) {
    return 'Intimacy logged for $date';
  }

  @override
  String calendarIntimacyRemoved(String date) {
    return 'Intimacy removed for $date';
  }

  @override
  String get calendarBasedOnRecentLogs => 'Based on recent logs';

  @override
  String get calendarLoggedBreak => 'Logged break';

  @override
  String get calendarLoggedPeriod => 'Logged period';

  @override
  String get calendarPredictedPeriod => 'Predicted period';

  @override
  String get calendarFertileWindow => 'Fertile window';

  @override
  String get calendarHasLog => 'Has log';

  @override
  String calendarPillDay(int day) {
    return 'Pill Day $day';
  }

  @override
  String get calendarTwoWeekWaitTtc => 'Two Week Wait (TWW)';

  @override
  String calendarDaysToBreak(int days) {
    return '~$days days to break';
  }

  @override
  String calendarDaysToPeriod(int days) {
    return '~$days days to period';
  }

  @override
  String calendarDaysToFertileWindow(int days) {
    return '~$days days to fertile window';
  }

  @override
  String calendarDaysToTestDay(int days) {
    return '~$days days to test day';
  }

  @override
  String get calendarWelcomeTitle => 'Welcome to Ayla';

  @override
  String get calendarTrackingPaused => 'Tracking paused';

  @override
  String get calendarAddFirstPeriodBody => 'Add first day of your period to start.';

  @override
  String get calendarNeedMoreTimelineData => 'Need more data to build cycle timeline. Please log your previous periods.';

  @override
  String get calendarCurrentCycleTimeline => 'Current Cycle Timeline';

  @override
  String get calendarNormalPhase => 'Normal';

  @override
  String calendarTimelineDay(int day) {
    return 'D$day';
  }

  @override
  String get calendarYourAverages => 'Your Averages';

  @override
  String get calendarRecentCycles => 'Recent Cycles';

  @override
  String get calendarPeakOvulation => 'Peak Ovulation';

  @override
  String get calendarTwoWeekWait => 'Two Week Wait';

  @override
  String get calendarTestDay => 'Test Day';

  @override
  String get calendarLoggedBleeding => 'Bleeding';

  @override
  String calendarBbtLogged(String temp) {
    return 'BBT: $temp';
  }

  @override
  String get calendarOpkLogged => 'OPK Logged';

  @override
  String get calendarSymptomsLogged => 'Symptoms logged';

  @override
  String get calendarPrediction => 'Prediction';

  @override
  String get calendarAvgShort => 'Avg';

  @override
  String get lblPreviousCycle => 'Прошлый цикл';

  @override
  String get lblNoData => 'Нет данных';

  @override
  String get lblNoSymptoms => 'Симптомы не отмечены.';

  @override
  String get insightsTitle => 'Тренды и Анализ';

  @override
  String get insightsOverview => 'Обзор';

  @override
  String get insightsHealth => 'Здоровье';

  @override
  String get insightsPatterns => 'Паттерны';

  @override
  String get chartCycleLength => 'Длина цикла';

  @override
  String get chartSubtitle => 'Последние 6 месяцев';

  @override
  String get topSymptoms => 'Топ симптомов';

  @override
  String get patternDetected => 'Найден паттерн';

  @override
  String get patternBody => 'У вас часто болит голова перед началом цикла. Попробуйте пить больше воды за 2 дня до начала.';

  @override
  String get insightPhasesTitle => 'Фазы цикла';

  @override
  String get insightPhasesSubtitle => 'Распределение по длительности';

  @override
  String get insightMoodTitle => 'Эмоции по фазам';

  @override
  String get insightMoodSubtitle => 'Средний уровень настроения';

  @override
  String get insightVitals => 'Динамика тела';

  @override
  String get insightVitalsSub => 'График температуры и веса';

  @override
  String get insightBodyBalance => 'Баланс Тела';

  @override
  String get insightBodyBalanceSub => 'Фолликулярная (Фиол.) vs Лютеиновая (Оранж.)';

  @override
  String get insightMoodFlow => 'Поток Настроения';

  @override
  String get insightMoodFlowSub => 'Тренд за последние 30 дней';

  @override
  String get insightCorrelationTitle => 'Умные паттерны';

  @override
  String get insightCorrelationSub => 'Влияние образа жизни на тело';

  @override
  String insightPatternText(String factor, String symptom, int percent) {
    return 'При факторе $factor, симптом $symptom возникает в $percent% случаев.';
  }

  @override
  String get insightCycleDNA => 'ДНК Цикла';

  @override
  String get insightDNASub => 'Портрет фаз';

  @override
  String get insightGeneratedOffline => 'Generated offline using your recent symptoms.';

  @override
  String get insightLocalAnalysis => 'Local Analysis';

  @override
  String get insightTodayAnalytics => 'Today\'s Analytics';

  @override
  String get insightAvgCycle => 'Длина цикла';

  @override
  String get insightAvgPeriod => 'Длина месячных';

  @override
  String get unitDaysShort => 'д';

  @override
  String get daysUnit => 'дн.';

  @override
  String get paramEnergy => 'Энергия';

  @override
  String get paramLibido => 'Либидо';

  @override
  String get paramSkin => 'Кожа';

  @override
  String get paramFocus => 'Фокус';

  @override
  String get predTitle => 'Прогноз на день';

  @override
  String get predSubtitle => 'На основе цикла и качества сна';

  @override
  String get recHighEnergy => 'Отличный день для спорта и задач!';

  @override
  String get recLowEnergy => 'Не перегружайся. Сегодня нужен отдых.';

  @override
  String get recNormalEnergy => 'Держи привычный темп.';

  @override
  String msgFeedback(String metric, String status) {
    return 'Правда ли $metric сегодня $status?';
  }

  @override
  String get statusLow => 'Низкий';

  @override
  String get statusHigh => 'Высокий';

  @override
  String get statusNormal => 'Норма';

  @override
  String get stateLow => 'Низкий';

  @override
  String get stateMedium => 'Средний';

  @override
  String get stateHigh => 'Высокий';

  @override
  String get feedbackTitle => 'Уточнение прогноза';

  @override
  String feedbackQuestion(String metric, String status) {
    return 'Твой показатель «$metric» сегодня действительно «$status»?';
  }

  @override
  String get btnYesCorrect => 'Да, всё верно';

  @override
  String get btnNoWrong => 'Нет, ошибка';

  @override
  String get btnWrong => 'Не так';

  @override
  String get btnAdjust => 'Изменить';

  @override
  String get predMismatchTitle => 'Чувствуете себя иначе?';

  @override
  String get predMismatchBody => 'Нажмите на иконку, чтобы изменить совет.';

  @override
  String predInsightHormones(String hormone) {
    return 'Гормоны: $hormone повышается.';
  }

  @override
  String get hormoneEstrogen => 'Эстроген';

  @override
  String get hormoneProgesterone => 'Прогестерон';

  @override
  String get hormoneReset => 'Гормональная перезагрузка';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileGoalSectionTitle => 'My Goal';

  @override
  String get profileGoalTrackBody => 'Standard period and ovulation tracking';

  @override
  String get profileGoalPreventTitle => 'Prevent pregnancy';

  @override
  String get profileGoalPreventBody => 'Track my birth control pill';

  @override
  String get profileGoalPreventPillTitle => 'Prevent pregnancy (Pill)';

  @override
  String get profileGoalConceiveTitle => 'Try to conceive';

  @override
  String get profileGoalConceiveBody => 'Maximized fertility predictions & BBT';

  @override
  String get profileGoalConceiveFromPillBody => 'Congratulations on this beautiful decision!\n\nSwitching from birth control to pregnancy planning means your natural hormones will restart. We will clear your pill history and begin a completely fresh cycle starting today. Are you ready?';

  @override
  String get profileGoalConceiveConfirmBody => 'Congratulations on this beautiful decision!\n\nWe will now optimize your AI predictions to pinpoint your exact fertile window and activate advanced tools like Basal Body Temperature tracking. Are you ready?';

  @override
  String get profileGoalConceiveDialogTitle => 'Exciting Journey! 🎉';

  @override
  String get profileGoalReadyAction => 'Yes, I\'m ready';

  @override
  String get profileGoalCurrentModeBody => 'Your current tracking mode';

  @override
  String get profileChangeAction => 'Change';

  @override
  String get profilePackFormatBody => 'Choose pill pack format';

  @override
  String get profileReminderTimeBody => 'Daily pill reminder time';

  @override
  String get profileAverageCycleBody => 'Average cycle length';

  @override
  String get profileAverageBleedingBody => 'Average bleeding duration';

  @override
  String get profileLanguageBody => 'App language';

  @override
  String get profileNotificationsBody => 'Cycle reminders and alerts';

  @override
  String get profileDailyReminderBody => 'Evening symptom reminder';

  @override
  String get profileFaceIdPinTitle => 'Face ID / PIN';

  @override
  String get profileFaceIdPinBody => 'Protect your private health data';

  @override
  String get profileSupportBody => 'Contact support team';

  @override
  String get profilePartnerSyncBody => 'Share your cycle securely';

  @override
  String get profileHealthSyncAppleTitle => 'Apple Health Sync';

  @override
  String get profileHealthSyncGoogleTitle => 'Google Health Connect';

  @override
  String get profileHealthSyncBody => 'Securely sync your cycle & BBT';

  @override
  String get profileHealthSyncEnabled => 'Sync successfully enabled! 🎉';

  @override
  String get profileHealthSyncDenied => 'Sync access denied or unavailable.';

  @override
  String get profilePdfExportBody => 'Export health report as PDF';

  @override
  String get profileBackupCreateBody => 'Create local backup copy';

  @override
  String get profileBackupRestoreBody => 'Restore previously saved backup';

  @override
  String get profileResetFailed => 'Reset failed. Your data is still on this device.';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileNameLabel => 'Your Name';

  @override
  String get profileDoneAction => 'Done';

  @override
  String get profileHeroPremiumMember => 'Premium member';

  @override
  String get profileHeroSubtitle => 'Your personal health space';

  @override
  String get profileHeroPrivateChip => 'Private';

  @override
  String get lblUser => 'Пользователь';

  @override
  String get sectionGeneral => 'ОСНОВНЫЕ';

  @override
  String get settingsGeneral => 'Общие';

  @override
  String get sectionSecurity => 'Безопасность';

  @override
  String get sectionData => 'УПРАВЛЕНИЕ ДАННЫМИ';

  @override
  String get settingsData => 'Управление данными';

  @override
  String get sectionBackup => 'Резервное копирование';

  @override
  String get sectionAbout => 'О ПРИЛОЖЕНИИ';

  @override
  String get lblLanguage => 'Язык приложения';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get lblNotifications => 'Уведомления';

  @override
  String get settingsNotifs => 'Уведомления';

  @override
  String get lblBiometrics => 'Вход по биометрии';

  @override
  String get settingsBiometrics => 'Вход по FaceID';

  @override
  String get lblExport => 'Экспорт данных (PDF)';

  @override
  String get settingsExport => 'Скачать отчет (PDF)';

  @override
  String get lblDeleteAccount => 'Удалить все данные';

  @override
  String get settingsReset => 'Сбросить все данные';

  @override
  String get settingsTheme => 'Оформление';

  @override
  String get settingsDailyLog => 'Вечерний отчет (20:00)';

  @override
  String get settingsSupport => 'Поддержка и Отзывы';

  @override
  String get btnExportPdf => 'Скачать отчет (PDF)';

  @override
  String get btnBackup => 'Резервная копия';

  @override
  String get btnSaveBackup => 'Сохранить бекап';

  @override
  String get btnRestoreBackup => 'Восстановить из файла';

  @override
  String get btnContactSupport => 'Написать в поддержку';

  @override
  String get btnRateApp => 'Оценить приложение';

  @override
  String get themeOceanic => 'Океан';

  @override
  String get themeNature => 'Природа';

  @override
  String get themeVelvet => 'Бархат';

  @override
  String get themeDigital => 'Диджитал';

  @override
  String get themeActive => 'Активна';

  @override
  String get selectThemeTitle => 'Выберите тему';

  @override
  String get prefNotifications => 'Уведомления';

  @override
  String get prefBiometrics => 'Вход по FaceID';

  @override
  String get prefCOC => 'Режим КОК (Таблетки)';

  @override
  String get descDelete => 'Это действие необратимо удалит все записи с устройства.';

  @override
  String get alertDeleteTitle => 'Вы уверены?';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get dialogResetTitle => 'Сбросить всё?';

  @override
  String get dialogResetBody => 'Это действие удалит все ваши данные безвозвратно.';

  @override
  String get dialogResetConfirm => 'Сбросить';

  @override
  String get languageSelectionTitle => 'Choose Language';

  @override
  String get languageSelectionSubtitle => 'Select your app language';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameKyrgyz => 'Kyrgyz';

  @override
  String get languageNameRussian => 'Russian';

  @override
  String get languageNameSpanish => 'Spanish';

  @override
  String get languageNameGerman => 'German';

  @override
  String get languageNamePortugueseBrazil => 'Portuguese (Brazil)';

  @override
  String get languageNameTurkish => 'Turkish';

  @override
  String get languageNamePolish => 'Polish';

  @override
  String get dialogRestoreTitle => 'Восстановить данные?';

  @override
  String get dialogRestoreBody => 'Это действие перезапишет ваши текущие данные данными из файла. Вы уверены?';

  @override
  String get btnRestore => 'Восстановить';

  @override
  String get msgRestoreSuccess => 'Данные успешно восстановлены!';

  @override
  String get subscriptionRestoreSuccess => 'Purchases restored successfully!';

  @override
  String get backupSubject => 'Резервная копия EviMoon';

  @override
  String backupBody(String date) {
    return 'Резервная копия данных EviMoon от $date';
  }

  @override
  String get greetMorning => 'Доброе утро';

  @override
  String get greetAfternoon => 'Добрый день';

  @override
  String get greetEvening => 'Добрый вечер';

  @override
  String get authLockedTitle => 'EviMoon Заблокирован';

  @override
  String get authUnlockBtn => 'Разблокировать';

  @override
  String get authReason => 'Подтвердите личность для входа';

  @override
  String get authUnlockShortReason => 'Scan to unlock Ayla';

  @override
  String get authNotAvailable => 'Биометрия недоступна на устройстве';

  @override
  String get authBiometricsReason => 'Подтвердите включение биометрии';

  @override
  String get msgBiometricsError => 'Биометрия недоступна на этом устройстве';

  @override
  String get pdfReportTitle => 'Медицинский Отчет EviMoon';

  @override
  String get pdfReportSubtitle => 'Гинекологический анамнез и история циклов';

  @override
  String get pdfCycleHistory => 'История циклов';

  @override
  String get pdfHeaderStart => 'Начало';

  @override
  String get pdfHeaderEnd => 'Конец';

  @override
  String get pdfHeaderLength => 'Длительность';

  @override
  String get pdfCurrent => 'Текущий';

  @override
  String get pdfGenerated => 'Дата';

  @override
  String get pdfPage => 'Страница';

  @override
  String get pdfPatient => 'Пациент';

  @override
  String get pdfClinicalSummary => 'Клиническая Сводка';

  @override
  String get pdfDetailedLogs => 'Детальный Журнал';

  @override
  String get pdfMedicationRegistry => 'Active Medications & Supplements';

  @override
  String get pdfAvgCycle => 'Ср. Цикл';

  @override
  String get pdfAvgPeriod => 'Ср. Менструация';

  @override
  String get pdfPainReported => 'Дни с болью';

  @override
  String get pdfTableDate => 'Дата';

  @override
  String get pdfTableCD => 'ДЦ';

  @override
  String get pdfTableSymptoms => 'Симптомы';

  @override
  String get pdfTableBBT => 'ББТ';

  @override
  String get pdfTableNotes => 'Заметки';

  @override
  String get pdfClinicalSymptoms => 'Clinical Symptoms';

  @override
  String get pdfMedicationShort => 'Meds';

  @override
  String get pdfDefaultPatient => 'Patient';

  @override
  String pdfPeriodRange(String start, String end) {
    return 'Period: $start - $end';
  }

  @override
  String get pdfFlowShort => 'Выд.';

  @override
  String get pdfFlowMedium => 'Med';

  @override
  String get pdfSymptomSexProtected => 'Sex (P)';

  @override
  String get pdfSymptomSexUnprotected => 'Sex (U)';

  @override
  String get unitDays => 'дн.';

  @override
  String get pdfDisclaimer => 'ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: Этот отчет сгенерирован приложением на основе данных пользователя. Он не является медицинским диагнозом.';

  @override
  String get msgExportError => 'Не удалось создать PDF';

  @override
  String get msgExportEmpty => 'Нет данных для экспорта.';

  @override
  String get dialogDataInsufficientTitle => 'Недостаточно данных';

  @override
  String get dialogDataInsufficientBody => 'Для формирования отчета необходимо минимум 2 дня наблюдений.';

  @override
  String get dayTitle => 'День';

  @override
  String get insightTipTitle => 'Совет дня';

  @override
  String get insightTipBody => 'В лютеиновой фазе уровень энергии падает. Это отличное время для йоги.';

  @override
  String get insightMenstruationTitle => 'Отдых и Перезагрузка';

  @override
  String get insightMenstruationSubtitle => 'Держитесь в тепле, пейте чай, избегайте нагрузок.';

  @override
  String get insightFollicularTitle => 'Творческая Искра';

  @override
  String get insightFollicularSubtitle => 'Энергия растет! Мозг работает на пике.';

  @override
  String get insightOvulationTitle => 'Суперсила';

  @override
  String get insightOvulationSubtitle => 'Вы магнит для окружающих. Высокое либидо.';

  @override
  String get insightLutealTitle => 'Внутренний Фокус';

  @override
  String get insightLutealSubtitle => 'Спокойствие или раздражение. Фокус внутрь себя.';

  @override
  String get insightLateTitle => 'Сохраняйте спокойствие';

  @override
  String get insightLateSubtitle => 'Снизьте стресс и следите за питанием.';

  @override
  String get insightProstaglandinsTitle => 'Работают простагландины';

  @override
  String get insightProstaglandinsBody => 'Сокращения матки помогают обновлению. Тепло и магний облегчат состояние.';

  @override
  String get insightWinterPhaseTitle => 'Время восстановления';

  @override
  String get insightWinterPhaseBody => 'Уровень гормонов минимален. Это нормально — замедлиться и отдохнуть.';

  @override
  String get insightEstrogenTitle => 'Рост эстрогена';

  @override
  String get insightEstrogenBody => 'Эстроген повышает серотонин. Отличное время для креатива и планов!';

  @override
  String get insightMittelschmerzTitle => 'Овуляторный синдром';

  @override
  String get insightMittelschmerzBody => 'Возможно, вы чувствуете сам момент овуляции. Обычно это быстро проходит.';

  @override
  String get insightFertilityTitle => 'Пик фертильности';

  @override
  String get insightFertilityBody => 'Природа подталкивает к общению. Сейчас вы особенно притягательны!';

  @override
  String get insightWaterTitle => 'Задержка воды';

  @override
  String get insightWaterBody => 'Организм запасает воду перед возможной беременностью. Это скоро пройдет.';

  @override
  String get insightProgesteroneTitle => 'Спад прогестерона';

  @override
  String get insightProgesteroneBody => 'Химия мозга меняется перед циклом. Будьте бережны к себе сегодня.';

  @override
  String get insightSkinTitle => 'Гормональная кожа';

  @override
  String get insightSkinBody => 'Прогестерон активирует сальные железы. Используйте мягкий уход.';

  @override
  String get insightMetabolismTitle => 'Тяга к сладкому';

  @override
  String get insightMetabolismBody => 'Метаболизм ускоряется. Лучше выбрать сложные углеводы вместо сахара.';

  @override
  String get insightSpottingTitle => 'Замечены выделения';

  @override
  String get insightSpottingBody => 'Небольшие выделения бывают при овуляции или стрессе.';

  @override
  String get symptomInsightPeakFertilityDetectedTitle => 'Peak Fertility Detected! 🎯';

  @override
  String get symptomInsightPeakFertilityDetectedBody => 'Your LH surge indicates ovulation will likely occur within 24-36 hours. Today and tomorrow are your best days to try to conceive.';

  @override
  String get symptomInsightFertileWindowOpeningTitle => 'Fertile Window Opening';

  @override
  String get symptomInsightFertileWindowOpeningBody => 'LH levels are rising. Start having intercourse every 1-2 days to maximize your chances as ovulation approaches.';

  @override
  String get symptomInsightHighlyFertileMucusTitle => 'Highly Fertile Mucus';

  @override
  String get symptomInsightHighlyFertileMucusBody => 'Egg-white cervical mucus creates the perfect environment for sperm to survive and swim. This is a primary sign of high fertility.';

  @override
  String get symptomInsightBuildingUpFertilityTitle => 'Building Up Fertility';

  @override
  String get symptomInsightBuildingUpFertilityBody => 'Your cervical mucus is transitioning. As you get closer to ovulation, it will become clearer and more stretchy.';

  @override
  String get symptomInsightPerfectTimingTitle => 'Perfect Timing! ✨';

  @override
  String get symptomInsightPerfectTimingBody => 'You\'ve logged unprotected sex during your ovulation phase. You\'ve maximized your chances for this cycle. Now, time for the Two Week Wait (TWW).';

  @override
  String get symptomInsightTwoWeekWaitTitle => 'The Two Week Wait';

  @override
  String get symptomInsightTwoWeekWaitBody => 'The egg only survives 24h after ovulation. Intercourse in the luteal phase usually doesn\'t lead to conception, but it\'s great for connection!';

  @override
  String get symptomInsightMedicalAlertPainSpottingTitle => 'Medical Alert: Pain & Spotting';

  @override
  String get symptomInsightMedicalAlertPainSpottingBody => 'Spotting accompanied by pain outside your period can indicate cysts, polyps, or hormonal issues. Consider consulting a doctor.';

  @override
  String get symptomInsightDysmenorrheaPatternTitle => 'Dysmenorrhea Pattern';

  @override
  String get symptomInsightDysmenorrheaPatternBody => 'High levels of prostaglandins are causing both severe cramps and nausea. Warmth and NSAIDs (like Ibuprofen) can help block this chemical.';

  @override
  String get symptomInsightSeverePmsPmddTitle => 'Severe PMS / PMDD Indicator';

  @override
  String get symptomInsightSeverePmsPmddBody => 'Your emotional symptoms are compounding. This sharp drop in serotonin alongside progesterone is normal, but requires extreme self-care today.';

  @override
  String get symptomInsightBiologicalPeakTitle => 'Biological Peak';

  @override
  String get symptomInsightBiologicalPeakBody => 'Estrogen and testosterone are cresting simultaneously. Your body is biologically primed for socializing, mating, and high-energy tasks.';

  @override
  String get symptomLogCycleWarningTitle => 'Cycle Update Warning';

  @override
  String get symptomLogOvulationSpottingWarningBody => 'Light bleeding is common during ovulation. Logging this as a New Period will reset your entire cycle predictions. Do you want to start a new cycle, or log this as spotting?';

  @override
  String get symptomLogResetStartCycleAction => 'Reset & Start New Cycle';

  @override
  String get symptomLogJustSpottingAction => 'Just Spotting';

  @override
  String get symptomLogShortCycleWarningBody => 'It\'s been less than 21 days since your last period. Logging this as a New Period will dramatically alter your cycle averages and predictions. Are you sure?';

  @override
  String get symptomLogNewPeriodWarningBody => 'This input will end your current cycle and generate new predictions for your next phases. Are you sure you want to log a New Period today?';

  @override
  String get symptomLogStartNewCycleAction => 'Yes, start new cycle';

  @override
  String get symptomLogRemoveBleedingWarningBody => 'Removing bleeding from a logged period day will recalculate your cycle history and future predictions. Are you sure?';

  @override
  String get symptomLogRemoveAction => 'Remove it';

  @override
  String get symptomLogLhPeakAddedWarningBody => 'Logging an LH Peak will immediately shift your predicted ovulation day and adjust your fertile window. Proceed?';

  @override
  String get symptomLogConfirmShiftAction => 'Confirm Shift';

  @override
  String get symptomLogLhPeakRemovedWarningBody => 'Removing the LH Peak will revert your ovulation predictions back to standard AI calculations. Are you sure?';

  @override
  String get symptomLogFuturePredictionTitle => 'Future Prediction';

  @override
  String get symptomLogFutureTitle => 'The Future is Bright';

  @override
  String get symptomLogFutureBody => 'You cannot log symptoms for future dates. Select a past date to enter records.';

  @override
  String get symptomLogTtcAiTitle => 'TTC AI Intelligence';

  @override
  String get symptomLogTtcAiBody => 'Log BBT and LH tests below to refine ovulation timing and fertile-window predictions.';

  @override
  String get symptomLogSectionBleedingTitle => 'Bleeding & Flow';

  @override
  String get symptomLogSectionBleedingBody => 'Choose the intensity for this day';

  @override
  String get symptomLogSectionBbtTitle => 'Basal Body Temp (BBT)';

  @override
  String get symptomLogSectionBbtBody => 'Adjust daily basal temperature';

  @override
  String get symptomLogSectionOpkTitle => 'Ovulation Tests (OPK)';

  @override
  String get symptomLogSectionOpkBody => 'Only one LH status can be active';

  @override
  String get symptomLogSectionMucusTitle => 'Cervical Mucus';

  @override
  String get symptomLogSectionMucusBody => 'Track the most relevant type';

  @override
  String get symptomLogSectionIntimacyTitle => 'Intercourse & Libido';

  @override
  String get symptomLogSectionIntimacyTtcBody => 'Helpful for fertility insights';

  @override
  String get symptomLogSectionIntimacyBody => 'Track your intimacy and desire';

  @override
  String get symptomLogSectionVitalsTitle => 'Vitals';

  @override
  String get symptomLogSectionVitalsBody => 'Quick body check-in for the day';

  @override
  String get symptomLogSectionPhysicalTitle => 'Physical Symptoms';

  @override
  String get symptomLogSectionPhysicalBody => 'Body discomfort and physical signs';

  @override
  String get symptomLogSectionMentalTitle => 'Mental & Emotional';

  @override
  String get symptomLogSectionMentalBody => 'Mood, focus, and emotional state';

  @override
  String get symptomLogSectionOtherTitle => 'Other Factors';

  @override
  String get symptomLogSectionOtherBody => 'Context that may affect symptoms';

  @override
  String get symptomLogMenstruationConflictRemoved => 'Menstruation logged. Incompatible symptoms (LH Peak / Mucus) removed.';

  @override
  String get symptomLogBbtMeasuredLabel => 'Basal temperature';

  @override
  String get symptomLogBbtSuggestedLabel => 'Suggested from recent log';

  @override
  String get symptomLogBleedingRemovedOvulationConflict => 'Bleeding removed. Menstruation and ovulation cannot co-occur.';

  @override
  String get symptomLogBleedingRemovedMucusConflict => 'Bleeding removed. Cervical mucus is not tracked during menstruation.';

  @override
  String get healthFlagPcosTitle => 'Irregular Cycle Pattern';

  @override
  String get healthFlagPcosBody => 'Your cycles vary significantly in length or are consistently longer than 35 days.';

  @override
  String get healthFlagPcosRecommendation => 'This pattern is sometimes associated with PCOS or thyroid issues. Consider sharing this data with your gynecologist.';

  @override
  String get healthFlagEndometriosisTitle => 'High Pain Profile';

  @override
  String get healthFlagEndometriosisBody => 'You frequently log severe pelvic pain combined with heavy flow.';

  @override
  String get healthFlagEndometriosisRecommendation => 'Severe period pain that disrupts your life is not normal. This pattern can sometimes indicate endometriosis or fibroids. A doctor can help you manage this.';

  @override
  String get healthFlagLutealDefectTitle => 'Short Luteal Phase';

  @override
  String get healthFlagLutealDefectBody => 'The time between your ovulation and your next period is consistently short (< 10 days).';

  @override
  String get healthFlagLutealDefectRecommendation => 'A short luteal phase is often linked to low progesterone, which can make it harder to conceive. Useful to mention if you are planning a pregnancy.';

  @override
  String get healthFlagMenorrhagiaTitle => 'Prolonged Bleeding';

  @override
  String get healthFlagMenorrhagiaBody => 'Your periods consistently last 8 days or longer.';

  @override
  String get healthFlagMenorrhagiaRecommendation => 'Prolonged bleeding (menorrhagia) can lead to iron deficiency and fatigue. It\'s highly recommended to check your iron levels.';

  @override
  String get healthFlagPolymenorrheaTitle => 'Unusually Short Cycles';

  @override
  String get healthFlagPolymenorrheaBody => 'Your cycles are consistently shorter than 21 days.';

  @override
  String get healthFlagPolymenorrheaRecommendation => 'Frequent periods can cause anemia and indicate an ovulation issue. Worth discussing with a healthcare provider.';

  @override
  String get healthFlagPmddTitle => 'Severe Mood Drops (Luteal)';

  @override
  String get healthFlagPmddBody => 'You consistently log very low mood, anxiety, or depression in the week before your period.';

  @override
  String get healthFlagPmddRecommendation => 'This cyclic emotional drop may be PMDD (Premenstrual Dysphoric Disorder). You don\'t have to suffer through this alone—treatments are available.';

  @override
  String get healthFlagAmenorrheaTitle => 'Prolonged Cycle Delay';

  @override
  String get healthFlagAmenorrheaBody => 'Your current cycle has lasted over 90 days.';

  @override
  String get healthFlagAmenorrheaRecommendation => 'This is known as secondary amenorrhea. If pregnancy is ruled out, it can be caused by stress, weight changes, or hormonal imbalances. Please consult a doctor.';

  @override
  String get insightsLoadingHistoryPatterns => 'Analyzing history and patterns...';

  @override
  String get insightsFertilityStatusTitle => 'Fertility Status';

  @override
  String get insightsCycleAnalysisTitle => 'Cycle Analysis';

  @override
  String get insightsKeySignalsSubtitle => 'Key signals from your body';

  @override
  String get insightsHormonalRhythmTitle => 'Hormonal Rhythm';

  @override
  String get insightsHormonalRhythmBody => 'Your symptoms correlated with estimated hormone levels';

  @override
  String get insightsHormonalContextTitle => 'Hormonal Context';

  @override
  String get insightsHormonalContextBody => 'Why you might be feeling this way today';

  @override
  String get insightsMedicalInsightsTitle => 'Medical Insights';

  @override
  String get insightsMedicalInsightsBody => 'Patterns detected from your historical logs';

  @override
  String get insightsThermalShiftTitle => 'Thermal Shift';

  @override
  String get insightsThermalShiftBody => 'Your temperature pattern across this cycle';

  @override
  String get insightsFrequentSymptomsTitle => 'Frequent Symptoms';

  @override
  String get insightsFrequentSymptomsBody => 'Most repeated symptoms from your recent logs';

  @override
  String get insightsEmptySymptomsBody => 'Log your daily symptoms to uncover your body\'s unique patterns.';

  @override
  String get insightsTopBarFertilityHubTitle => 'Fertility Hub';

  @override
  String get insightsTopBarFertilityHubSubtitle => 'Personalized fertility intelligence';

  @override
  String get insightsTopBarDefaultSubtitle => 'Your body\'s intelligence';

  @override
  String get insightsHeroContraceptiveModeTitle => 'Contraceptive Mode';

  @override
  String get insightsHeroContraceptiveModeBody => 'Tracking is adapted for pill-based cycles';

  @override
  String get insightsHeroOvulationConfirmedTitle => 'Ovulation Confirmed';

  @override
  String get insightsHeroOvulationConfirmedBody => 'You are now in the two-week wait phase';

  @override
  String get insightsHeroFertileWindowActiveTitle => 'Fertile Window Active';

  @override
  String get insightsHeroFertileWindowActiveBody => 'Conception probability is elevated';

  @override
  String get insightsHeroTrackingFertilityTitle => 'Tracking Fertility';

  @override
  String get insightsHeroTrackingFertilityBody => 'Log BBT and symptoms for precision';

  @override
  String get insightsHeroCycleIntelligenceTitle => 'Cycle Intelligence';

  @override
  String get insightsHeroCycleIntelligenceEmptyBody => 'Start logging to unlock analysis';

  @override
  String get insightsHeroCycleIntelligenceReadyBody => 'Trends updated from recent logs';

  @override
  String get insightsHeroStatusLabel => 'Status';

  @override
  String get insightsHeroPhaseLabel => 'Phase';

  @override
  String get insightsHeroLogsLabel => 'Logs';

  @override
  String get insightsHeroCycleLabel => 'Cycle';

  @override
  String get insightsHeroPeriodLabel => 'Period';

  @override
  String get insightsAylaEngineTitle => 'Ayla AI Engine';

  @override
  String get insightsAylaReadyBody => 'Your daily hormonal analysis is ready. You can also chat with Ayla anytime for personalized guidance.';

  @override
  String get insightsAylaPromptBody => 'Wondering why you feel a certain way today? Chat with Ayla or generate your daily hormone report.';

  @override
  String get insightsChatWithAylaAction => 'Chat with Ayla';

  @override
  String get insightsViewTodaysReportAction => 'View Today\'s Report';

  @override
  String get insightsGenerateDailyReportAction => 'Generate Daily Report';

  @override
  String get insightsAnalysisDataInsufficientTitle => 'Data insufficient';

  @override
  String get insightsAnalysisDataInsufficientBody => 'Log more cycles to unlock insights.';

  @override
  String get insightsAnalysisOvulationConfirmedTitle => 'Ovulation confirmed';

  @override
  String get insightsAnalysisOvulationConfirmedBody => 'You are now in the two-week wait. Keep routines stable.';

  @override
  String get insightsAnalysisFertileWindowOpenTitle => 'Fertile window open';

  @override
  String get insightsAnalysisFertileWindowOpenBody => 'Chance of conception is high. Log BBT daily.';

  @override
  String get insightsAnalysisTrackingPhaseTitle => 'Tracking phase';

  @override
  String get insightsAnalysisTrackingPhaseBody => 'Monitoring inputs to predict ovulation day.';

  @override
  String get insightsAnalysisContraceptiveModeTitle => 'Contraceptive mode';

  @override
  String get insightsAnalysisContraceptiveModeBody => 'Cycle managed by oral contraceptives. Keep taking pills.';

  @override
  String get insightsAnalysisDelayedCycleTitle => 'Delayed cycle';

  @override
  String get insightsAnalysisDelayedCycleBody => 'Cycle delayed >60 days. Consider clinical consultation.';

  @override
  String get insightsAnalysisIrregularBleedingTitle => 'Irregular bleeding';

  @override
  String get insightsAnalysisIrregularBleedingBody => 'Recent period was longer than typical. Monitor closely.';

  @override
  String get insightsAnalysisStableRhythmTitle => 'Stable rhythm';

  @override
  String get insightsAnalysisStableRhythmBody => 'Your recent cycles look highly consistent.';

  @override
  String get insightsAnalysisLearningRhythmTitle => 'Learning your rhythm';

  @override
  String get insightsAnalysisLearningRhythmBody => 'App is building a reliable model. Keep logging.';

  @override
  String get insightsMetricCycleLength => 'Cycle length';

  @override
  String get insightsMetricPeriod => 'Period';

  @override
  String get insightsMetricFertility => 'Fertility';

  @override
  String get insightsMetricOvulation => 'Ovulation';

  @override
  String get insightsMetricYes => 'Yes';

  @override
  String get insightsMetricPending => 'Pending';

  @override
  String get insightsBbtEmptyBody => 'Log your morning temperature to see your thermal shift.';

  @override
  String get aylaConsultationTitle => 'Ayla\'s Advice';

  @override
  String get aylaConsultationAction => 'Got it, Ayla';

  @override
  String get timerPeriod => 'PERIOD';

  @override
  String get timerFertileIn => 'FERTILE IN';

  @override
  String get timerFertileWindow => 'FERTILE WINDOW';

  @override
  String get timerOvulation => 'OVULATION';

  @override
  String get timerPastOvulation => 'PAST OVULATION';

  @override
  String get timerCycleDelay => 'CYCLE DELAY';

  @override
  String timerDayValue(int day) {
    return 'DAY $day';
  }

  @override
  String timerDaysValue(int days) {
    return '$days DAYS';
  }

  @override
  String timerDpoValue(int days) {
    return '$days DPO';
  }

  @override
  String get timerDaysLate => 'DAYS LATE';

  @override
  String get timerPreparing => 'PREPARING';

  @override
  String get timerTwwDpo => 'TWW / DPO';

  @override
  String get tipPeriod => 'Больше отдыхайте, ешьте продукты с железом.';

  @override
  String get tipOvulation => 'Пик фертильности! Идеальное время.';

  @override
  String get tipLutealEarly => 'Прогестерон растет. Пейте больше воды.';

  @override
  String get tipLutealLate => 'Окно имплантации. Избегайте стресса.';

  @override
  String get tipFollicular => 'Энергия растет. Хорошее время для спорта.';

  @override
  String get tipLowEnergy => 'День отдыха. Попробуйте йогу или короткий сон.';

  @override
  String get tipHighEnergy => 'Отличное время для кардио или сложных задач!';

  @override
  String get tipLowMood => 'Будьте бережны к себе. Шоколад помогает.';

  @override
  String get tipHighMood => 'Делитесь настроением! Творите и общайтесь.';

  @override
  String get tipLowFocus => 'Избегайте многозадачности. Выберите одну мелкую цель.';

  @override
  String get tipHighFocus => 'Режим глубокой работы. Беритесь за сложное.';

  @override
  String get dialogStartTitle => 'Начать новый цикл?';

  @override
  String get dialogStartBody => 'Сегодняшний день будет отмечен как 1-й день месячных.';

  @override
  String get dialogEndTitle => 'Месячные закончились?';

  @override
  String get dialogEndBody => 'Текущая фаза сменится на фолликулярную.';

  @override
  String get btnPeriodStart => 'НАЧАЛИСЬ';

  @override
  String get btnPeriodEnd => 'ЗАКОНЧИЛИСЬ';

  @override
  String get dialogPeriodStartTitle => 'Когда начались месячные?';

  @override
  String get dialogPeriodStartBody => 'Они начались сегодня или вы забыли отметить раньше?';

  @override
  String get btnToday => 'Сегодня';

  @override
  String get btnYesterday => 'Вчера';

  @override
  String get btnPickDate => 'Выбрать дату';

  @override
  String get btnAnotherDay => 'Выбрать дату';

  @override
  String get cocActivePhase => 'Активные таблетки';

  @override
  String get cocBreakPhase => 'Неделя перерыва';

  @override
  String cocPredictionActive(int days) {
    return 'Осталось $days активных';
  }

  @override
  String cocPredictionBreak(int days) {
    return 'Новая пачка через $days дн.';
  }

  @override
  String get btnStartNewPack => 'Начать новую пачку';

  @override
  String get btnRestartPack => 'Перезапуск';

  @override
  String get dialogStartPackTitle => 'Начать новую пачку?';

  @override
  String get dialogStartPackBody => 'Это сбросит цикл на День 1. Используйте, когда открываете новую упаковку.';

  @override
  String get dialogCOCStartTitle => 'Режим КОК';

  @override
  String get dialogCOCStartSubtitle => 'Как вы хотите начать отслеживание таблеток?';

  @override
  String get optionFreshPack => 'Новая пачка';

  @override
  String get optionFreshPackSub => 'Я начинаю новую упаковку сегодня';

  @override
  String get optionContinuePack => 'Продолжить текущую';

  @override
  String get optionContinuePackSub => 'Я уже начала пачку ранее';

  @override
  String get labelOr => 'ИЛИ';

  @override
  String cocDayInfo(int day) {
    return 'День $day из 28';
  }

  @override
  String get settingsContraception => 'Контрацепция';

  @override
  String get settingsTrackPill => 'Отслеживать таблетки';

  @override
  String get settingsPackType => 'Тип упаковки';

  @override
  String settingsPills(int count) {
    return '$count таблеток';
  }

  @override
  String get settingsReminder => 'Напоминание';

  @override
  String get settingsPackSettings => 'Настройки упаковки';

  @override
  String get settingsPlaceboCount => 'Дни плацебо';

  @override
  String get settingsBreakDuration => 'Длительность перерыва';

  @override
  String get dialogPackTitle => 'Выберите тип упаковки';

  @override
  String get dialogPackSubtitle => 'Укажите формат упаковки, который вы используете.';

  @override
  String get pack21Title => '21 Таблетка';

  @override
  String get pack21Subtitle => '21 Активная + 7 Дней перерыва';

  @override
  String get pack28Title => '28 Таблеток';

  @override
  String get pack28Subtitle => '21 Активная + 7 Плацебо';

  @override
  String get pack24Title => '28 Pills (24+4)';

  @override
  String get pack24Subtitle => '24 Active + 4 Placebo';

  @override
  String get packContinuousTitle => 'Continuous / Mini-Pill';

  @override
  String get packContinuousSubtitle => '28 Active (No Break)';

  @override
  String get pack21 => '21 Активная + 7 Перерыв';

  @override
  String get pack28 => '28 Активных (Без перерыва)';

  @override
  String get pack24 => '24 Активные + 4 Пустышки';

  @override
  String get pillTaken => 'Принята';

  @override
  String get pillTake => 'Принять таблетку';

  @override
  String get pillMissed => 'Missed pill?';

  @override
  String get pillTakeNow => 'Take now';

  @override
  String pillScheduled(String time) {
    return 'По расписанию в $time';
  }

  @override
  String pillScheduledFor(String time) {
    return 'It was scheduled for $time';
  }

  @override
  String get blisterMyPack => 'Моя упаковка';

  @override
  String blisterDay(int day, int total) {
    return 'День $day из $total';
  }

  @override
  String blisterOverdue(int day) {
    return 'День $day (Просрочено)';
  }

  @override
  String get blister21 => 'Пачка 21 день';

  @override
  String get blister28 => 'Пачка 28 дней';

  @override
  String get legendTaken => 'Принято';

  @override
  String get legendActive => 'Актив';

  @override
  String get legendPlacebo => 'Плацебо';

  @override
  String get legendBreak => 'Перерыв';

  @override
  String get insightCOCActiveTitle => 'Вы защищены';

  @override
  String get insightCOCActiveBody => 'Фаза активных таблеток. Старайтесь принимать их в одно и то же время.';

  @override
  String get insightCOCBreakTitle => 'Кровотечение отмены';

  @override
  String get insightCOCBreakBody => 'Неделя перерыва. Ожидается кровотечение из-за снижения уровня гормонов.';

  @override
  String get sectionCycle => 'Настройки цикла';

  @override
  String get lblCycleLength => 'Длина цикла';

  @override
  String get lblPeriodLength => 'Длительность месячных';

  @override
  String get lblAverage => 'В среднем';

  @override
  String get lblNormalRange => 'Норма: 21-35 дней';

  @override
  String get emailSubject => 'Отзыв о EviMoon';

  @override
  String get emailBody => 'Здравствуйте, команда EviMoon,\n\nУ меня есть вопрос/предложение:';

  @override
  String msgEmailError(String email) {
    return 'Не удалось открыть почту. Напишите на: $email';
  }

  @override
  String get onboardTitle1 => 'Добро пожаловать';

  @override
  String get onboardBody1 => 'Отслеживайте цикл, понимайте своё тело и живите в гармонии с собой.';

  @override
  String get onboardTitle2 => 'Начало менструации';

  @override
  String get onboardBody2 => 'Выберите первый день последних месячных для точного прогноза.';

  @override
  String get onboardTitle3 => 'Длина цикла';

  @override
  String get onboardBody3 => 'Сколько дней обычно проходит между менструациями? В среднем это 28 дней.';

  @override
  String get onboardModeTitle => 'Какая у вас цель?';

  @override
  String get onboardModeCycle => 'Отслеживать цикл';

  @override
  String get onboardModeCycleDesc => 'Прогноз месячных и фертильности';

  @override
  String get onboardModePill => 'Пить таблетки (КОК)';

  @override
  String get onboardModePillDesc => 'Напоминания и учет пачек';

  @override
  String get onboardDateTitleCycle => 'Когда начались последние месячные?';

  @override
  String get onboardDateTitlePill => 'Когда вы начали эту пачку?';

  @override
  String get onboardLengthTitle => 'Длина цикла';

  @override
  String get onboardPackTitle => 'Тип упаковки';

  @override
  String get onboardPartnerModeCta => 'Partner mode? Enter code here.';

  @override
  String get onboardProcessingSetup => 'Setting up your AI...';

  @override
  String get onboardSetupError => 'Error during setup. Please try again.';

  @override
  String get splashTitle => 'EVIMOON';

  @override
  String get splashSlogan => 'Твой цикл. Твой ритм.';

  @override
  String get splashBrand => 'AYLA';

  @override
  String get splashTagline => 'breathe & bloom';

  @override
  String get premiumInsightLabel => 'PREMIUM INSIGHT';

  @override
  String get calendarForecastTitle => 'КАЛЕНДАРЬ И ПРОГНОЗ';

  @override
  String get aiForecastHigh => 'Прогноз точен';

  @override
  String get aiForecastHighSub => 'На основе стабильной истории';

  @override
  String get aiForecastMedium => 'Средняя точность';

  @override
  String get aiForecastMediumSub => 'Есть колебания цикла';

  @override
  String get aiForecastLow => 'Низкая точность';

  @override
  String get aiForecastLowSub => 'Длина цикла сильно меняется';

  @override
  String get aiLearning => 'ИИ обучается...';

  @override
  String get aiLearningSub => 'Отметьте 3 цикла для прогноза';

  @override
  String get confidenceHighDesc => 'Цикл предсказуем и регулярен.';

  @override
  String get confidenceMedDesc => 'Прогноз на основе средних данных.';

  @override
  String get confidenceLowDesc => 'Прогноз может меняться из-за нерегулярности.';

  @override
  String get confidenceCalcDesc => 'Собираем данные для точности.';

  @override
  String get confidenceNoData => 'Пока недостаточно истории.';

  @override
  String get factorDataNeeded => 'Нужно минимум 3 цикла';

  @override
  String get factorHighVar => 'Высокая нерегулярность';

  @override
  String get factorSlightVar => 'Небольшая нерегулярность';

  @override
  String get factorStable => 'Цикл стабилен';

  @override
  String get factorAnomaly => 'Обнаружена аномалия';

  @override
  String get aiDialogTitle => 'Анализ прогноза AI';

  @override
  String aiDialogScore(int score) {
    return 'Уверенность прогноза цикла: $score%.';
  }

  @override
  String get aiDialogExplanation => 'Оценка рассчитана локально на основе истории вашего цикла.';

  @override
  String get aiDialogFactors => 'Факторы:';

  @override
  String get btnGotIt => 'Понятно';

  @override
  String get aiStatusHigh => 'Высокая точность';

  @override
  String get aiStatusMedium => 'Средняя точность';

  @override
  String get aiStatusLow => 'Низкая точность';

  @override
  String get aiDescHigh => 'Ваш цикл очень регулярный. Прогноз ИИ, скорее всего, точен до ±1 дня.';

  @override
  String get aiDescMedium => 'В последних циклах есть вариативность. Прогноз может отклоняться на ±2-3 дня.';

  @override
  String get aiDescLow => 'История циклов нерегулярна или слишком коротка. ИИ нужно больше данных.';

  @override
  String get aiConfidenceScore => 'Уровень доверия';

  @override
  String get aiLabelHistory => 'Длина истории';

  @override
  String get aiLabelVariation => 'Вариация цикла';

  @override
  String get aiSuffixCycles => 'циклов';

  @override
  String get aiSuffixDays => 'дней';

  @override
  String get modeTTC => 'Планирование беременности';

  @override
  String get modeTTCDesc => 'Фокус на фертильности и овуляции';

  @override
  String get modeTTCActive => 'Режим планирования включен';

  @override
  String get modeCycle => 'Трекер цикла';

  @override
  String get modeTrackCycle => 'Отслеживать цикл';

  @override
  String get modeGetPregnant => 'Хочу забеременеть';

  @override
  String get dialogTTCConflict => 'Отключить контрацепцию?';

  @override
  String get dialogTTCConflictBody => 'Чтобы включить режим планирования, необходимо отключить отслеживание таблеток.';

  @override
  String get btnDisableAndSwitch => 'Отключить и переключить';

  @override
  String get ttcStatusLow => 'Низкий шанс';

  @override
  String get ttcStatusHigh => 'Высокая фертильность';

  @override
  String get ttcStatusPeak => 'Пик фертильности';

  @override
  String get ttcStatusOvulation => 'День Овуляции';

  @override
  String ttcDPO(int days) {
    return '$days ДПО';
  }

  @override
  String get ttcChance => 'Вероятность зачатия';

  @override
  String get ttcChanceHigh => 'Высокий шанс';

  @override
  String get ttcChancePeak => 'Пик фертильности';

  @override
  String get ttcChanceLow => 'Низкий шанс';

  @override
  String get ttcTestWait => 'Рано для теста';

  @override
  String get ttcTestReady => 'Можно делать тест';

  @override
  String lblCycleDay(int day) {
    return 'День цикла $day';
  }

  @override
  String ttcCycleDay(int day) {
    return 'ДЕНЬ ЦИКЛА $day';
  }

  @override
  String get ttcBtnBBT => 'БТ График';

  @override
  String get ttcBtnTest => 'ЛГ Тест';

  @override
  String get ttcBtnSex => 'Близость';

  @override
  String get dashboardActionLogged => 'Logged';

  @override
  String get dashboardPeriodEndingTitle => 'Ending today';

  @override
  String get dashboardPeriodEndingBody => 'Tap if bleeding has stopped';

  @override
  String dashboardPeriodDayTitle(int day) {
    return 'Day $day of period';
  }

  @override
  String get dashboardPeriodDayBody => 'Tap to manage or log symptoms';

  @override
  String get dashboardStartPeriodTitle => 'Start period';

  @override
  String get dashboardStartPeriodBody => 'Log today, yesterday, or choose a date';

  @override
  String get dashboardShortCycleSpottingBody => 'It\'s been less than 21 days since your last cycle started. Is this a new period, or just spotting?';

  @override
  String get dashboardNewPeriodAction => 'New Period';

  @override
  String get dashboardPeriodStartRemoved => 'Period start removed';

  @override
  String get dashboardFutureDateError => 'Cannot log a date in the future';

  @override
  String get dashboardResumePeriodTitle => 'Resume period';

  @override
  String get dashboardResumePeriodBody => 'Still bleeding? Continue current period';

  @override
  String get dashboardMistakeTitle => 'I made a mistake';

  @override
  String get dashboardMistakeBody => 'Remove period start';

  @override
  String get dashboardInsightCycleResetTitle => 'Cycle Reset';

  @override
  String get dashboardInsightCycleResetBody => 'Start fresh. Remember to take your daily folic acid or prenatal vitamins.';

  @override
  String get dashboardInsightPreparingOvulationTitle => 'Preparing for Ovulation';

  @override
  String get dashboardInsightPreparingOvulationBody => 'Your body is getting ready. Keep tracking BBT and watch for cervical mucus changes.';

  @override
  String get dashboardInsightPeakFertilityTitle => 'Peak Fertility!';

  @override
  String get dashboardInsightPeakFertilityBody => 'This is your optimal window for conception. Log your intercourse and LH tests.';

  @override
  String get dashboardInsightTwwTitle => 'Two Week Wait (TWW)';

  @override
  String get dashboardInsightTwwBody => 'Progesterone is rising. Stay relaxed, avoid hot tubs, and keep tracking BBT.';

  @override
  String get dashboardInsightTestDayTitle => 'Test Day! 🤞';

  @override
  String get dashboardInsightTestDayBody => 'Your period is late. It\'s a great time to take a pregnancy test!';

  @override
  String get dashboardInsightRestResetTitle => 'Rest & Reset';

  @override
  String get dashboardInsightRestResetBody => 'Your hormones are at their lowest. Focus on hydration.';

  @override
  String get dashboardInsightEnergyRisingTitle => 'Energy Rising';

  @override
  String get dashboardInsightEnergyRisingBody => 'Estrogen is climbing. Great time for complex tasks.';

  @override
  String get dashboardInsightPeakVitalityTitle => 'Peak Vitality';

  @override
  String get dashboardInsightPeakVitalityBody => 'You are glowing. Best time for high-intensity workouts.';

  @override
  String get dashboardInsightWindDownTitle => 'Wind Down';

  @override
  String get dashboardInsightWindDownBody => 'Progesterone is high. Cravings and mood swings are normal.';

  @override
  String get dashboardInsightCycleDelayedTitle => 'Cycle Delayed';

  @override
  String get dashboardInsightCycleDelayedBody => 'Your period is late. Stress could be a factor.';

  @override
  String get dashboardInsightAnalyzingBadge => '⏳ ANALYZING...';

  @override
  String get dashboardInsightLocalBadge => '⚡ LOCAL INSIGHT';

  @override
  String get dashboardInsightDailyAiBadge => '✨ DAILY AI';

  @override
  String get dashboardInsightThinkingTitle => 'Ayla is thinking...';

  @override
  String get dashboardInsightThinkingBody => 'Analyzing your latest cycle data and symptoms to generate a personalized insight...';

  @override
  String get ttcBtnReset => 'Сбросить';

  @override
  String get ttcLogTitle => 'Отчет за сегодня';

  @override
  String get ttcSectionBBT => 'Базальная температура';

  @override
  String get ttcSectionTest => 'Тест на овуляцию (ЛГ)';

  @override
  String get ttcSectionSex => 'Близость';

  @override
  String get lblNegative => 'Отриц. (-)';

  @override
  String get lblPositive => 'Положит. (+)';

  @override
  String get lblPeak => 'Пик';

  @override
  String get chipNegative => 'Отриц.';

  @override
  String get chipPositive => 'Полож.';

  @override
  String get chipPeak => 'Пик';

  @override
  String get valNegative => 'Отриц.';

  @override
  String get valPositive => 'Полож.';

  @override
  String get valPeak => 'Пик';

  @override
  String get lblSexYes => 'Да, был!';

  @override
  String get lblSexNo => 'Не сегодня';

  @override
  String get labelSexNo => 'Нет';

  @override
  String get labelSexYes => 'Да';

  @override
  String get valSexYes => 'Да';

  @override
  String get ttcTipTitle => 'Совет дня';

  @override
  String get ttcTipDefault => 'Стресс влияет на овуляцию. Попробуйте 5-минутную медитацию.';

  @override
  String get ttcStrategyTitle => 'Стратегия';

  @override
  String get ttcStrategyMinimal => 'Минимум усилий';

  @override
  String get ttcStrategyMaximal => 'Максимум шансов';

  @override
  String get ttcPlanTitle => 'План';

  @override
  String get ttcPlanMinimalBody => 'В фертильное окно: близость через день, ЛГ-тесты 2–3 дня, ББТ по желанию.';

  @override
  String get ttcPlanMaximalBody => 'В фертильное окно: близость каждый день, ЛГ-тест ежедневно, ББТ каждое утро.';

  @override
  String get ttcOvulationBadgeTitle => 'Овуляция';

  @override
  String get ttcOvulationEstimatedCalendar => 'Оценка (календарь)';

  @override
  String get ttcOvulationConfirmedLH => 'Подтверждено по ЛГ';

  @override
  String get ttcOvulationConfirmedBBT => 'Подтверждено по ББТ';

  @override
  String get ttcOvulationConfirmedManual => 'Подтверждено';

  @override
  String get dialogHighTempTitle => 'Высокая температура';

  @override
  String get dialogHighTempBody => 'Температура выше 37.5°C обычно указывает на жар, а не овуляцию.';

  @override
  String get dialogLowTempTitle => 'Низкая температура';

  @override
  String get dialogLowTempBody => 'Температура ниже 35.5°C необычно низкая. Это опечатка?';

  @override
  String get dialogPeriodLHTitle => 'Необычное значение';

  @override
  String get dialogPeriodLHBody => 'Положительный ЛГ-тест во время менструации — редкость. Возможна ошибка.';

  @override
  String get btnLogAnyway => 'Все равно записать';

  @override
  String get insightFertilitySub => 'Как тело сообщает об овуляции';

  @override
  String get insightLibidoHigh => 'Высокое либидо в фертильное окно';

  @override
  String get insightPainOvulation => 'Замечена овуляторная боль';

  @override
  String get insightTempShift => 'Сдвиг температуры после овуляции';

  @override
  String get lblDetected => 'Обнаружено';

  @override
  String get msgLhPeakRecorded => 'LH пик записан! Окно высокой фертильности.';

  @override
  String get transitionTTC => 'Вперед за малышом... ✨';

  @override
  String get transitionCOC => 'Защита активирована 🛡️';

  @override
  String get transitionTrack => 'В гармонии с телом 🌿';

  @override
  String get notifPhaseFollicularTitle => 'Прилив сил ⚡';

  @override
  String get notifPhaseFollicularBody => 'Энергия растет! Отличное время для спорта.';

  @override
  String get notifFollTitle => 'Прилив сил ⚡';

  @override
  String get notifFollBody => 'Энергия растет! Отличное время для спорта.';

  @override
  String get notifPhaseOvulationTitle => 'Ты сияешь 🌸';

  @override
  String get notifPhaseOvulationBody => 'Пик женственности и фертильности сегодня.';

  @override
  String get notifOvulationTitle => 'Ты сияешь 🌸';

  @override
  String get notifOvulationBody => 'Пик женственности и фертильности сегодня.';

  @override
  String get notifPhaseLutealTitle => 'Время заботы 🌙';

  @override
  String get notifPhaseLutealBody => 'Организм просит отдыха, не перегружай себя.';

  @override
  String get notifLutealTitle => 'Время заботы 🌙';

  @override
  String get notifLutealBody => 'Организм просит отдыха, не перегружай себя.';

  @override
  String get notifPhasePeriodTitle => 'Новый цикл начался 🩸';

  @override
  String get notifPhasePeriodBody => 'Не забудь отметить начало менструации в календаре.';

  @override
  String get notifPeriodSoonTitle => 'Скоро цикл 🩸';

  @override
  String get notifPeriodSoonBody => 'Ожидается завтра. Всё готово?';

  @override
  String get notifPeriodTitle => 'Скоро новый цикл';

  @override
  String get notifPeriodBody => 'Месячные могут начаться через 2 дня. Не забудьте подготовиться!';

  @override
  String get notifLatePeriodTitle => 'Задержка?';

  @override
  String get notifLatePeriodBody => 'Цикл длится дольше обычного. Отметь симптомы или сделай тест.';

  @override
  String get notifLateTitle => 'Задержка?';

  @override
  String get notifLateBody => 'Цикл длиннее обычного. Не волнуйся, так бывает.';

  @override
  String get notifLateFiveDaysTitle => 'Period is 5 days late';

  @override
  String get notifLateFiveDaysBody => 'Consider taking a pregnancy test if you\'ve been sexually active.';

  @override
  String get notifLogCheckinTitle => 'Как самочувствие?';

  @override
  String get notifLogCheckinBody => 'Пара секунд на отметку симптомов помогут нам лучше понимать твое тело.';

  @override
  String get notifCheckinTitle => 'Как самочувствие? 📝';

  @override
  String get notifCheckinBody => 'Отметь симптомы в дневнике.';

  @override
  String get notifPillTitle => 'Таблетка 💊';

  @override
  String get notifPillBody => 'Время принять контрацептив.';

  @override
  String get notifNewPackTitle => 'Новая пачка 💊';

  @override
  String get notifNewPackBody => 'Пора начинать новый блистер!';

  @override
  String get notifBreakTitle => 'Перерыв 🩸';

  @override
  String get notifBreakBody => 'Активные таблетки закончились. Неделя перерыва.';

  @override
  String get partnerLinkTitle => 'Enter Invite Code';

  @override
  String get partnerLinkSubtitle => 'Ask your partner to generate a 6-digit code in their Ayla app settings.';

  @override
  String get partnerLinkHint => '000-000';

  @override
  String get partnerLinkButton => 'Connect to Partner';

  @override
  String get partnerLinkInvalidCode => 'Invalid or expired code. Please check and try again.';

  @override
  String get partnerDashboardTitle => 'Ayla for Partners';

  @override
  String get partnerStatusTracking => 'Tracking...';

  @override
  String get partnerPhaseMenstruation => 'Menstruation (Period)';

  @override
  String get partnerPhaseFollicular => 'Follicular Phase';

  @override
  String get partnerPhaseOvulation => 'Ovulation Phase';

  @override
  String get partnerPhaseLuteal => 'Luteal Phase (PMS)';

  @override
  String get partnerPhasePill => 'Pill Cycle';

  @override
  String get partnerPeriodExpectedToday => 'Period expected today';

  @override
  String partnerNextPeriodInDays(int days) {
    return 'Next period in ~$days days';
  }

  @override
  String get partnerCompanionTitle => 'AI Companion';

  @override
  String get partnerCompanionLowMoodTitle => 'Low Mood Detected';

  @override
  String get partnerAdviceDefault => 'Support your partner today!';

  @override
  String get partnerAdviceMenstruation => 'Energy levels might be low today. It\'s a great time to offer a heating pad, order her favorite comfort food, and keep plans low-key.';

  @override
  String get partnerAdviceFollicular => 'Estrogen is rising! She likely has more energy and feels social. Great time for a date night or outdoor activities.';

  @override
  String get partnerAdviceLuteal => 'Progesterone is high, which can cause fatigue or PMS. Be extra patient, offer a massage, and don\'t take mood swings personally.';

  @override
  String get partnerAdviceLowMood => 'She logged a low mood today. Send a sweet message or bring her a small treat to brighten her day! 🍫';

  @override
  String get partnerFertilityTitle => 'Fertility Window';

  @override
  String get partnerFertilityHigh => 'Chance of conception is currently HIGH. 👶';

  @override
  String get partnerFertilityLow => 'Chance of conception is low right now.';

  @override
  String get partnerSendHug => 'Send a Digital Hug 💖';

  @override
  String get partnerHugSent => 'Digital hug sent! 💖';

  @override
  String get partnerDisconnectedTitle => 'Connection Lost';

  @override
  String get partnerDisconnectedBody => 'Your partner has unlinked the connection.';

  @override
  String get partnerGoBack => 'Go Back';

  @override
  String get partnerSyncTitle => 'Partner Sync';

  @override
  String get partnerSyncInviteTitle => 'Invite Your Partner';

  @override
  String get partnerSyncInviteBody => 'Share your cycle phase and mood so your partner knows when you need extra support, chocolate, or space.';

  @override
  String get partnerSyncGenerateCode => 'Generate Invite Code';

  @override
  String get partnerSyncPrivacyFootnote => 'You control what they see.';

  @override
  String get partnerSyncConnectedTitle => 'Partner Connected';

  @override
  String get partnerSyncWaitingTitle => 'Waiting for Partner...';

  @override
  String get partnerSyncConnectedBody => 'Your Ayla app is securely syncing data.';

  @override
  String get partnerSyncWaitingBody => 'Ask your partner to download Ayla and enter this code during setup:';

  @override
  String get partnerSyncCodeCopied => 'Code copied to clipboard!';

  @override
  String get partnerSyncCodeHint => 'Tap to copy • Expires in 24h';

  @override
  String get partnerSyncPrivacySettings => 'Privacy Settings';

  @override
  String get partnerSyncShareMoodTitle => 'Share Mood & Energy';

  @override
  String get partnerSyncShareMoodBody => 'Partner will see if you are tired, anxious, or happy.';

  @override
  String get partnerSyncShareFertilityTitle => 'Share Fertility Window';

  @override
  String get partnerSyncShareFertilityBody => 'Partner will be notified when your conception chance is high.';

  @override
  String get partnerSyncUnlinkTitle => 'Unlink Partner?';

  @override
  String get partnerSyncUnlinkBody => 'Your partner will immediately lose access to your cycle updates.';

  @override
  String get partnerSyncUnlinkAction => 'Unlink';

  @override
  String get partnerSyncUnlinkButton => 'Unlink Partner';

  @override
  String get chatTitle => 'Ayla AI';

  @override
  String get chatStatusOnline => 'Online • Cycle Intelligence Assistant';

  @override
  String get chatEmptyTitle => 'Hi, I\'m Ayla!';

  @override
  String get chatEmptyBody => 'I analyze your cycle, logs, and symptoms in real-time. Ask me anything about your current well-being, hormones, or fertility.';

  @override
  String get chatTyping => 'Ayla is typing...';

  @override
  String get chatInputHint => 'Ask Ayla...';

  @override
  String get chatConnectionIssue => 'I\'m having a little trouble connecting right now. Please check your internet or try again in a moment. 💜';

  @override
  String get aiDailyInsightTitle => 'Daily Insight';

  @override
  String get aiDailyInsightBody => 'Listen to your body today.';

  @override
  String get notifAylaInsightTitle => 'Ayla Insight ✨';

  @override
  String get homeBrandWordmark => 'A Y L A';

  @override
  String homeCocDayOfTotal(int current, int total) {
    return 'Day $current of $total';
  }

  @override
  String get medicationsLoading => 'Loading medications...';

  @override
  String get medicationsTitle => 'Medications & Vitamins';

  @override
  String get medicationsEmptyBody => 'Add your daily medications or supplements to track intake for the day.';

  @override
  String get medicationsAdd => 'Add medication';

  @override
  String get medicationsDailyIntake => 'Daily Intake';

  @override
  String get medicationsManage => 'Manage';

  @override
  String get medicationsProgressNone => 'Nothing marked as taken yet';

  @override
  String get medicationsProgressAll => 'All medications completed for today';

  @override
  String medicationsProgressSome(int taken, int total) {
    return '$taken of $total completed today';
  }

  @override
  String get medicationsTakenBadge => 'Taken';

  @override
  String get medicationsManageTitle => 'Manage Medications';

  @override
  String get medicationsManageBody => 'Add, remove, and organize the medications you want to track each day.';

  @override
  String get medicationsCurrent => 'Current medications';

  @override
  String get medicationsAddNew => 'Add new medication';

  @override
  String get medicationsNameLabel => 'Medication name';

  @override
  String get medicationsNameHint => 'Iron, Vitamin D, Omega-3...';

  @override
  String get medicationsDosageLabel => 'Dosage';

  @override
  String get medicationsDosageHint => '500mg, 1 pill, 2 drops...';

  @override
  String get medicationsAddButton => 'Add Medication';

  @override
  String get paywallTitle => 'EviMoon Premium';

  @override
  String get paywallSubtitle => 'Раскройте полный потенциал своего цикла.';

  @override
  String get featureTimersTitle => 'Премиум дизайны';

  @override
  String get featureTimersDesc => 'Уникальные стили таймера';

  @override
  String get featurePdfTitle => 'Медицинский PDF-отчет';

  @override
  String get featurePdfDesc => 'История симптомов для врача';

  @override
  String get featureAiTitle => 'Точность прогноза (AI)';

  @override
  String get featureAiDesc => 'Оценка уверенности алгоритма';

  @override
  String get featureTtcTitle => 'Режим планирования';

  @override
  String get featureTtcDesc => 'Инструменты для зачатия';

  @override
  String get paywallNoOffers => 'Нет доступных предложений';

  @override
  String get paywallSelectPlan => 'Выберите план';

  @override
  String paywallSubscribeFor(String price) {
    return 'Подписаться за $price';
  }

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallTerms => 'Условия и Политика';

  @override
  String get paywallBestValue => 'ВЫГОДНО';

  @override
  String get msgNoSubscriptions => 'Активные подписки не найдены';

  @override
  String get proStatusTitle => 'Статус подписки';

  @override
  String get proStatusActive => 'Premium Активен';

  @override
  String get proStatusDesc => 'У вас есть полный доступ ко всем функциям.';

  @override
  String get btnManageSub => 'Управление подпиской';

  @override
  String get btnManageSubDesc => 'Сменить план или отменить в настройках iOS';

  @override
  String get msgLinkError => 'Не удалось открыть настройки';

  @override
  String get badgePro => 'PRO';

  @override
  String get badgeGoPro => 'GO PRO';

  @override
  String get badgePremium => 'ПРЕМИУМ';

  @override
  String get debugPremiumOn => 'ОТЛАДКА: Премиум ВКЛ';

  @override
  String get debugPremiumOff => 'ОТЛАДКА: Премиум ВЫКЛ';

  @override
  String get phaseNewMoon => 'Новолуние';

  @override
  String get phaseWaxingCrescent => 'Растущая Луна';

  @override
  String get phaseFirstQuarter => 'Первая четверть';

  @override
  String get phaseFullMoon => 'Полнолуние';

  @override
  String get phaseWaningGibbous => 'Убывающая Луна';

  @override
  String get phaseWaningCrescent => 'Старая Луна';

  @override
  String get lblTest => 'Тест ЛГ';

  @override
  String get lblSex => 'Близость';

  @override
  String get lblMucus => 'Выделения';

  @override
  String valMeasured(double temp) {
    return '$temp°';
  }

  @override
  String get valMucusLogged => 'Отмечено';

  @override
  String get titleInputBBT => 'Ввод температуры';

  @override
  String get titleInputTest => 'Результат теста ЛГ';

  @override
  String get titleInputSex => 'Детали близости';

  @override
  String get titleInputMucus => 'Цервикальная слизь';

  @override
  String get mucusDry => 'Сухо';

  @override
  String get mucusSticky => 'Липкая';

  @override
  String get mucusCreamy => 'Крем';

  @override
  String get mucusWatery => 'Вода';

  @override
  String get mucusEggWhite => 'Белок';

  @override
  String get ttcChartTitle => 'ГРАФИК БТ (14 ДНЕЙ)';

  @override
  String get ttcChartPlaceholder => 'Введите БТ для графика';

  @override
  String get hintTemp => '36.6';

  @override
  String get designSelectorTitle => 'Стиль таймера';

  @override
  String get designClassic => 'Классика';

  @override
  String get designMinimal => 'Минимализм';

  @override
  String get designLunar => 'Луна';

  @override
  String get designBloom => 'Цветение';

  @override
  String get designLiquid => 'Жидкость';

  @override
  String get designOrbit => 'Орбита';

  @override
  String get designZen => 'Дзен';

  @override
  String get ttcHintToday => 'Сегодня';

  @override
  String get ttcTimelineTitle => 'Лента';

  @override
  String ttcTimelineOvulationEquals(int day) {
    return 'Овуляция = $day';
  }

  @override
  String get ttcDockBBT => 'БТТ';

  @override
  String get ttcDockLH => 'ЛГ';

  @override
  String get ttcDockSex => 'Секс';

  @override
  String get ttcDockMucus => 'Слизь';

  @override
  String get ttcShortBBT => 'БТТ';

  @override
  String get ttcShortLH => 'ЛГ';

  @override
  String get ttcShortSex => 'Секс';

  @override
  String get ttcShortMucus => 'Слизь';

  @override
  String get ttcMarkDone => '✓';

  @override
  String get ttcMarkMissing => '?';

  @override
  String get ttcAllDone => 'Всё заполнено ✓';

  @override
  String ttcMissingList(String items) {
    return 'Осталось: $items';
  }

  @override
  String ttcRemainingLeft(String items) {
    return 'Осталось: $items';
  }

  @override
  String ttcCtaTestReadyBody(int dpo, String bbt, String lh) {
    return 'DPO $dpo • БТТ $bbt • ЛГ $lh';
  }

  @override
  String ttcCtaTestWaitBody(int dpo, int days) {
    return 'DPO $dpo • осталось ~$days дн. до надёжного теста';
  }

  @override
  String get ttcCtaPeakBody => 'Сегодня/завтра — максимум. Отметь секс и тест, чтобы улучшить точность.';

  @override
  String ttcCtaHighBody(int days) {
    return 'Окно фертильности открыто • пик через ~$days дн.';
  }

  @override
  String get ttcCtaMenstruationBody => 'Мягкий режим: сон, вода, тепло. Лог необязателен — но БТТ полезна.';

  @override
  String ttcCtaLowBody(String status) {
    return 'День подготовки • $status';
  }

  @override
  String get ttcDash => '—';

  @override
  String get eduTitleBBT => 'Зачем измерять БТ?';

  @override
  String get eduBodyBBT => 'Базальная температура (БТ) немного повышается после овуляции из-за выработки прогестерона. График температуры помогает подтвердить, что овуляция действительно произошла.';

  @override
  String get eduTitleLH => 'Тесты на овуляцию';

  @override
  String get eduBodyLH => 'Уровень лютеинизирующего гормона (ЛГ) резко возрастает за 24–48 часов до овуляции. Положительный тест предсказывает самые благоприятные дни для зачатия перед выходом яйцеклетки.';

  @override
  String get eduTitleSex => 'Отметка близости';

  @override
  String get eduBodySex => 'Сперматозоиды могут жить в организме до 5 дней. Отметки помогают убедиться, что близость совпала с окном фертильности, что значительно повышает шансы на зачатие.';

  @override
  String get eduTitleMucus => 'Цервикальная слизь';

  @override
  String get eduBodyMucus => 'При приближении овуляции эстроген делает выделения прозрачными и тягучими (как яичный белок). Это создает идеальную среду для выживания и передвижения сперматозоидов.';
}
