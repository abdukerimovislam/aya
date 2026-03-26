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
  String get tabLearn => 'Обучение';

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
  String get phaseStatusMenstruation => 'Время для отдыха';

  @override
  String get phaseStatusFollicular => 'Энергия растет';

  @override
  String get phaseStatusOvulation => 'Вы сияете сегодня';

  @override
  String get phaseStatusLuteal => 'Будьте бережны к себе';

  @override
  String dayOfCycle(int day) {
    return 'День $day';
  }

  @override
  String get editPeriod => 'Изменить месячные';

  @override
  String get logSymptoms => 'Отметить симптомы';

  @override
  String get logSymptomsTitle => 'Симптомы за день';

  @override
  String predictionText(int days) {
    return 'Месячные через $days дн.';
  }

  @override
  String get chanceOfPregnancy => 'Высокий шанс';

  @override
  String get lowChance => 'Низкий шанс';

  @override
  String get wellnessHeader => 'Самочувствие';

  @override
  String get lblFlowAndLove => 'Выделения и Близость';

  @override
  String get lblBodyMind => 'Тело и Разум';

  @override
  String get btnCheckIn => 'Отметиться';

  @override
  String get symptomHeader => 'Как вы себя чувствуете?';

  @override
  String get symptomSubHeader => 'Отмечайте симптомы для точной аналитики.';

  @override
  String get msgSaved => 'Сохранено!';

  @override
  String get msgSavedNoPop => 'Симптомы успешно обновлены';

  @override
  String get catFlow => 'Выделения';

  @override
  String get logFlow => 'Интенсивность';

  @override
  String get flowLight => 'Скудные';

  @override
  String get flowMedium => 'Умеренные';

  @override
  String get flowHeavy => 'Обильные';

  @override
  String get flowNone => 'Нет';

  @override
  String get catPain => 'Боль';

  @override
  String get logPain => 'Боль';

  @override
  String get painNone => 'Нет боли';

  @override
  String get painCramps => 'Спазмы';

  @override
  String get painHeadache => 'Головная боль';

  @override
  String get painBack => 'Боль в спине';

  @override
  String get catMood => 'Настроение';

  @override
  String get logMood => 'Настроение';

  @override
  String get moodHappy => 'Счастливое';

  @override
  String get moodSad => 'Грустное';

  @override
  String get moodAnxious => 'Тревожное';

  @override
  String get moodEnergetic => 'Энергичное';

  @override
  String get moodIrritated => 'Раздраженное';

  @override
  String get catSleep => 'Сон';

  @override
  String get logSleep => 'Качество сна';

  @override
  String get logNotes => 'Заметки';

  @override
  String get hintNotes => 'Добавить заметку...';

  @override
  String get logVitals => 'Показатели';

  @override
  String get lblTemp => 'Температура';

  @override
  String get lblWeight => 'Вес';

  @override
  String get logSkin => 'Кожа';

  @override
  String get symptomAcne => 'Акне';

  @override
  String get symptomNausea => 'Тошнота';

  @override
  String get symptomBloating => 'Вздутие';

  @override
  String get symCramps => 'Спазмы';

  @override
  String get symHeadache => 'Головная боль';

  @override
  String get symBloating => 'Вздутие';

  @override
  String get symAcne => 'Акне';

  @override
  String get symTenderBreasts => 'Чувствит. груди';

  @override
  String get symBackache => 'Боль в спине';

  @override
  String get symNausea => 'Тошнота';

  @override
  String get symFatigue => 'Усталость';

  @override
  String get symAnxious => 'Тревога';

  @override
  String get symIrritable => 'Раздражение';

  @override
  String get symCryingSpells => 'Слезливость';

  @override
  String get symBrainFog => 'Туман в голове';

  @override
  String get symHappy => 'Радость';

  @override
  String get symFocused => 'Фокус';

  @override
  String get symCalm => 'Спокойствие';

  @override
  String get symSpotting => 'Мазня';

  @override
  String get symAlcohol => 'Алкоголь';

  @override
  String get symTravel => 'Поездка';

  @override
  String get symHighStress => 'Сильный стресс';

  @override
  String get symSick => 'Болезнь';

  @override
  String get symExercise => 'Тренировка';

  @override
  String get symPoorDiet => 'Плохое питание';

  @override
  String get symDryMucus => 'Сухая слизь';

  @override
  String get symStickyMucus => 'Липкая слизь';

  @override
  String get symCreamyMucus => 'Кремовая слизь';

  @override
  String get symEggWhiteMucus => 'Яичный белок';

  @override
  String get symLhNegative => 'ЛГ: Отрицат.';

  @override
  String get symLhHigh => 'ЛГ: Высокий';

  @override
  String get symLhPeak => 'ЛГ: Пик';

  @override
  String get symIntimacy => 'Близость';

  @override
  String get symHighLibido => 'Высокое либидо';

  @override
  String get symProtectedSex => 'Защищенный секс';

  @override
  String get symUnprotectedSex => 'Незащищенный секс';

  @override
  String get logLibido => 'Либидо';

  @override
  String get lblIntimacy => 'Близость';

  @override
  String get hadSex => 'Был секс';

  @override
  String get protectedSex => 'Защищенный';

  @override
  String get lblLifestyle => 'Образ жизни';

  @override
  String get lblLifestyleHeader => 'Факторы образа жизни';

  @override
  String get factorStress => 'Стресс';

  @override
  String get factorAlcohol => 'Алкоголь';

  @override
  String get factorTravel => 'Поездка';

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
  String get btnStartToday => 'Начать сегодня';

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
  String get legendFertile => 'Фертильные дни';

  @override
  String get legendOvulation => 'Овуляция';

  @override
  String get legendFollicular => 'Фолликулярная';

  @override
  String get legendLuteal => 'Лютеиновая';

  @override
  String get legendPredictedPeriod => 'Ожидается';

  @override
  String get calendarHeader => 'Ваша история';

  @override
  String get calendarViewMonth => 'Месяц';

  @override
  String get calendarIntimacyQuickLog => 'Быстрая отметка близости';

  @override
  String get calendarLogUnprotectedSex => 'Незащищенный секс';

  @override
  String get calendarLogProtectedSex => 'Защищенный секс';

  @override
  String get calendarOpenFullLogger => 'Открыть дневник полностью';

  @override
  String calendarIntimacyLogged(String date) {
    return 'Близость отмечена за $date';
  }

  @override
  String calendarIntimacyRemoved(String date) {
    return 'Близость удалена за $date';
  }

  @override
  String get calendarBasedOnRecentLogs => 'На основе недавних записей';

  @override
  String get calendarLoggedBreak => 'Отмечен перерыв';

  @override
  String get calendarLoggedPeriod => 'Отмечены месячные';

  @override
  String get calendarPredictedPeriod => 'Прогноз месячных';

  @override
  String get calendarFertileWindow => 'Окно фертильности';

  @override
  String get calendarHasLog => 'Есть запись';

  @override
  String calendarPillDay(int day) {
    return 'Таблетка: День $day';
  }

  @override
  String get calendarTwoWeekWaitTtc => 'Двухнедельное ожидание (TWW)';

  @override
  String calendarDaysToBreak(int days) {
    return '~$days дн. до перерыва';
  }

  @override
  String calendarDaysToPeriod(int days) {
    return '~$days дн. до месячных';
  }

  @override
  String calendarDaysToFertileWindow(int days) {
    return '~$days дн. до окна фертильности';
  }

  @override
  String calendarDaysToTestDay(int days) {
    return '~$days дн. до дня теста';
  }

  @override
  String get calendarWelcomeTitle => 'Добро пожаловать в Ayla';

  @override
  String get calendarTrackingPaused => 'Отслеживание приостановлено';

  @override
  String get calendarAddFirstPeriodBody => 'Добавьте первый день вашей менструации, чтобы начать.';

  @override
  String get calendarNeedMoreTimelineData => 'Недостаточно данных для таймлайна. Пожалуйста, отметьте прошлые месячные.';

  @override
  String get calendarCurrentCycleTimeline => 'Таймлайн текущего цикла';

  @override
  String get calendarNormalPhase => 'Норма';

  @override
  String calendarTimelineDay(int day) {
    return 'Д$day';
  }

  @override
  String get calendarYourAverages => 'Ваши средние показатели';

  @override
  String get calendarRecentCycles => 'Недавние циклы';

  @override
  String get calendarPeakOvulation => 'Пик овуляции';

  @override
  String get calendarTwoWeekWait => 'Двухнедельное ожидание';

  @override
  String get calendarTestDay => 'День теста';

  @override
  String get calendarLoggedBleeding => 'Кровотечение';

  @override
  String calendarBbtLogged(String temp) {
    return 'БТТ: $temp';
  }

  @override
  String get calendarOpkLogged => 'Тест на овуляцию (ЛГ)';

  @override
  String get calendarSymptomsLogged => 'Симптомы';

  @override
  String get calendarPrediction => 'Прогноз';

  @override
  String get calendarAvgShort => 'Ср.';

  @override
  String get lblPreviousCycle => 'Предыдущий цикл';

  @override
  String get lblNoData => 'Нет данных';

  @override
  String get lblNoSymptoms => 'Симптомы не отмечены.';

  @override
  String get insightsTitle => 'Тренды и Инсайты';

  @override
  String get insightsOverview => 'Обзор';

  @override
  String get insightsHealth => 'Здоровье';

  @override
  String get insightsPatterns => 'Паттерны';

  @override
  String get chartCycleLength => 'Длина цикла';

  @override
  String get chartSubtitle => 'За последние 6 месяцев';

  @override
  String get topSymptoms => 'Частые симптомы';

  @override
  String get patternDetected => 'Обнаружен паттерн';

  @override
  String get patternBody => 'Вы часто отмечаете головную боль перед месячными. Попробуйте пить больше воды.';

  @override
  String get insightPhasesTitle => 'Фазы цикла';

  @override
  String get insightPhasesSubtitle => 'Типичная продолжительность';

  @override
  String get insightMoodTitle => 'Настроение по фазам';

  @override
  String get insightMoodSubtitle => 'Средняя интенсивность настроения';

  @override
  String get insightVitals => 'Показатели';

  @override
  String get insightVitalsSub => 'Изменения температуры и веса';

  @override
  String get insightBodyBalance => 'Баланс организма';

  @override
  String get insightBodyBalanceSub => 'Фолликулярная (Фиолет) vs Лютеиновая (Оранж)';

  @override
  String get insightMoodFlow => 'Поток настроения';

  @override
  String get insightMoodFlowSub => 'Тренд за последние 30 дней';

  @override
  String get insightCorrelationTitle => 'Умные паттерны';

  @override
  String get insightCorrelationSub => 'Как образ жизни влияет на ваше тело';

  @override
  String insightPatternText(String factor, String symptom, int percent) {
    return 'Когда вы отмечаете $factor, вы испытываете $symptom в $percent% случаев.';
  }

  @override
  String get insightCycleDNA => 'ДНК Вашего цикла';

  @override
  String get insightDNASub => 'Фолликулярная vs Лютеиновая фаза';

  @override
  String get insightGeneratedOffline => 'Сгенерировано локально на основе недавних симптомов.';

  @override
  String get insightLocalAnalysis => 'Локальный анализ';

  @override
  String get insightTodayAnalytics => 'Аналитика за сегодня';

  @override
  String get insightAvgCycle => 'Ср. цикл';

  @override
  String get insightAvgPeriod => 'Ср. месячные';

  @override
  String get unitDaysShort => 'д.';

  @override
  String get daysUnit => 'дней';

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
  String get predSubtitle => 'Основано на вашем цикле и сне';

  @override
  String get recHighEnergy => 'Отличный день для сложных задач или тренировок!';

  @override
  String get recLowEnergy => 'Не спешите. Сегодня важен отдых.';

  @override
  String get recNormalEnergy => 'Поддерживайте стабильный темп.';

  @override
  String msgFeedback(String metric, String status) {
    return 'Ваш параметр ($metric) действительно $status сегодня?';
  }

  @override
  String get statusLow => 'Низкий';

  @override
  String get statusHigh => 'Высокий';

  @override
  String get statusNormal => 'В норме';

  @override
  String get stateLow => 'Низкий';

  @override
  String get stateMedium => 'Средний';

  @override
  String get stateHigh => 'Высокий';

  @override
  String get feedbackTitle => 'Обратная связь';

  @override
  String feedbackQuestion(String metric, String status) {
    return 'Ваш параметр ($metric) действительно $status сегодня?';
  }

  @override
  String get btnYesCorrect => 'Да, верно';

  @override
  String get btnNoWrong => 'Нет, это ошибка';

  @override
  String get btnWrong => 'Ошибка';

  @override
  String get btnAdjust => 'Изменить';

  @override
  String get predMismatchTitle => 'Чувствуете себя иначе?';

  @override
  String get predMismatchBody => 'Нажмите на иконку, чтобы скорректировать прогноз.';

  @override
  String predInsightHormones(String hormone) {
    return 'Гормоны: уровень ($hormone) растет.';
  }

  @override
  String get hormoneEstrogen => 'Эстроген';

  @override
  String get hormoneProgesterone => 'Прогестерон';

  @override
  String get hormoneReset => 'Сброс гормонов';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileGoalSectionTitle => 'Моя цель';

  @override
  String get profileGoalTrackBody => 'Стандартное отслеживание цикла и овуляции';

  @override
  String get profileGoalPreventTitle => 'Предотвратить беременность';

  @override
  String get profileGoalPreventBody => 'Отслеживание приема противозачаточных (КОК)';

  @override
  String get profileGoalPreventPillTitle => 'Контрацепция (Таблетки)';

  @override
  String get profileGoalConceiveTitle => 'Планирование беременности';

  @override
  String get profileGoalConceiveBody => 'Точные прогнозы фертильности и базальной температуры';

  @override
  String get profileGoalConceiveFromPillBody => 'Поздравляем с этим замечательным решением!\n\nПереход от контрацепции к планированию беременности означает перезапуск ваших естественных гормонов. Мы очистим историю приема таблеток и начнем совершенно новый цикл. Вы готовы?';

  @override
  String get profileGoalConceiveConfirmBody => 'Поздравляем с этим замечательным решением!\n\nМы настроим AI-алгоритмы на максимально точное определение окна фертильности и включим расширенные функции (например, БТТ). Вы готовы?';

  @override
  String get profileGoalConceiveDialogTitle => 'Захватывающее путешествие! 🎉';

  @override
  String get profileGoalReadyAction => 'Да, я готова';

  @override
  String get profileGoalCurrentModeBody => 'Текущий режим отслеживания';

  @override
  String get profileChangeAction => 'Изменить';

  @override
  String get profilePackFormatBody => 'Формат упаковки таблеток';

  @override
  String get profileReminderTimeBody => 'Ежедневное напоминание о таблетке';

  @override
  String get profileAverageCycleBody => 'Средняя длина цикла';

  @override
  String get profileAverageBleedingBody => 'Средняя длительность месячных';

  @override
  String get profileLanguageBody => 'Язык приложения';

  @override
  String get profileNotificationsBody => 'Уведомления о цикле';

  @override
  String get profileDailyReminderBody => 'Вечернее напоминание о симптомах';

  @override
  String get profileFaceIdPinTitle => 'Face ID / ПИН-код';

  @override
  String get profileFaceIdPinBody => 'Защитите ваши личные данные';

  @override
  String get profileSupportBody => 'Написать в поддержку';

  @override
  String get profilePartnerSyncBody => 'Поделиться циклом безопасно';

  @override
  String get profileHealthSyncAppleTitle => 'Синхронизация Apple Health';

  @override
  String get profileHealthSyncGoogleTitle => 'Синхронизация Google Health Connect';

  @override
  String get profileHealthSyncBody => 'Синхронизация цикла и температуры (БТТ)';

  @override
  String get profileHealthSyncEnabled => 'Синхронизация успешно включена! 🎉';

  @override
  String get profileHealthSyncDenied => 'Доступ к синхронизации отклонен.';

  @override
  String get profilePdfExportBody => 'Выгрузить медицинский отчет (PDF)';

  @override
  String get profileBackupCreateBody => 'Создать локальную резервную копию';

  @override
  String get profileBackupRestoreBody => 'Восстановить данные из копии';

  @override
  String get profileResetFailed => 'Сброс не удался. Ваши данные в безопасности.';

  @override
  String get profileEditTitle => 'Редактировать профиль';

  @override
  String get profileNameLabel => 'Ваше имя';

  @override
  String get profileDoneAction => 'Готово';

  @override
  String get profileHeroPremiumMember => 'Премиум участник';

  @override
  String get profileHeroSubtitle => 'Ваше личное пространство здоровья';

  @override
  String get profileHeroPrivateChip => 'Приватно';

  @override
  String get lblUser => 'Пользователь';

  @override
  String get sectionGeneral => 'Общее';

  @override
  String get settingsGeneral => 'Общее';

  @override
  String get sectionSecurity => 'Безопасность';

  @override
  String get sectionData => 'Управление данными';

  @override
  String get settingsData => 'Управление данными';

  @override
  String get sectionBackup => 'Резервное копирование';

  @override
  String get sectionAbout => 'О приложении';

  @override
  String get lblLanguage => 'Язык';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get lblNotifications => 'Уведомления';

  @override
  String get settingsNotifs => 'Уведомления';

  @override
  String get lblBiometrics => 'Биометрия';

  @override
  String get settingsBiometrics => 'FaceID / TouchID';

  @override
  String get lblExport => 'Экспорт в PDF';

  @override
  String get settingsExport => 'Скачать PDF Отчет';

  @override
  String get lblDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsReset => 'Сбросить все данные';

  @override
  String get settingsTheme => 'Тема приложения';

  @override
  String get settingsDailyLog => 'Ежедневная отметка (20:00)';

  @override
  String get settingsSupport => 'Поддержка и отзывы';

  @override
  String get btnExportPdf => 'Скачать PDF Отчет';

  @override
  String get btnBackup => 'Сохранить резервную копию';

  @override
  String get btnSaveBackup => 'Сохранить';

  @override
  String get btnRestoreBackup => 'Восстановить из файла';

  @override
  String get btnContactSupport => 'Написать в поддержку';

  @override
  String get btnRateApp => 'Оценить EviMoon';

  @override
  String get themeOceanic => 'Океан';

  @override
  String get themeNature => 'Природа';

  @override
  String get themeVelvet => 'Вельвет';

  @override
  String get themeDigital => 'Диджитал';

  @override
  String get themeActive => 'Актив';

  @override
  String get selectThemeTitle => 'Выбор темы';

  @override
  String get prefNotifications => 'Уведомления';

  @override
  String get prefBiometrics => 'FaceID / TouchID';

  @override
  String get prefCOC => 'Режим контрацепции (КОК)';

  @override
  String get descDelete => 'Это навсегда удалит все ваши данные с этого устройства.';

  @override
  String get alertDeleteTitle => 'Вы уверены?';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get dialogResetTitle => 'Сбросить всё?';

  @override
  String get dialogResetBody => 'Это навсегда удалит все ваши данные. Это действие нельзя отменить.';

  @override
  String get dialogResetConfirm => 'Сбросить';

  @override
  String get languageSelectionTitle => 'Выберите язык';

  @override
  String get languageSelectionSubtitle => 'Язык интерфейса приложения';

  @override
  String get languageNameEnglish => 'Английский';

  @override
  String get languageNameKyrgyz => 'Кыргызский';

  @override
  String get languageNameRussian => 'Русский';

  @override
  String get languageNameSpanish => 'Испанский';

  @override
  String get languageNameGerman => 'Немецкий';

  @override
  String get languageNamePortugueseBrazil => 'Португальский (Бразилия)';

  @override
  String get languageNameTurkish => 'Турецкий';

  @override
  String get languageNamePolish => 'Польский';

  @override
  String get dialogRestoreTitle => 'Восстановить данные?';

  @override
  String get dialogRestoreBody => 'Это действие перезапишет ваши текущие данные файлом резервной копии. Вы уверены?';

  @override
  String get btnRestore => 'Восстановить';

  @override
  String get msgRestoreSuccess => 'Данные успешно восстановлены!';

  @override
  String get subscriptionRestoreSuccess => 'Покупки успешно восстановлены!';

  @override
  String get backupSubject => 'Резервная копия EviMoon';

  @override
  String backupBody(String date) {
    return 'Резервная копия приложения EviMoon от $date';
  }

  @override
  String get backupExportTitle => 'Экспорт копии';

  @override
  String get backupExportBody => 'Файл резервной копии содержит приватные данные. Мы зашифруем его паролем.';

  @override
  String get backupRestoreTitle => 'Восстановление копии';

  @override
  String get backupRestoreBody => 'Это полностью заменит ваши текущие данные информацией из резервной копии.';

  @override
  String get backupSetPasswordTitle => 'Установите пароль';

  @override
  String get backupEnterPasswordTitle => 'Введите пароль копии';

  @override
  String get backupPasswordHint => 'Пароль';

  @override
  String get backupConfirmPasswordHint => 'Повторите пароль';

  @override
  String get backupShowPassword => 'Показать пароль';

  @override
  String get backupPasswordLostWarning => 'Важно: если вы забудете этот пароль, восстановить копию будет невозможно.';

  @override
  String get backupPasswordTooShort => 'Пароль слишком короткий (мин 6)';

  @override
  String get backupPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get backupContinueAction => 'Продолжить';

  @override
  String get backupAuthFailed => 'Ошибка аутентификации';

  @override
  String get backupPathEmpty => 'Путь к файлу пуст';

  @override
  String get backupWrongPassword => 'Неверный пароль или поврежденный файл';

  @override
  String get backupInvalidFileFormat => 'Неверный формат файла резервной копии';

  @override
  String get backupRestoreFailed => 'Ошибка восстановления: файл поврежден';

  @override
  String backupEncryptedCreated(String date) {
    return 'Зашифрованная копия создана $date';
  }

  @override
  String backupFailed(String error) {
    return 'Ошибка резервного копирования: $error';
  }

  @override
  String backupEncryptedBoxMustBeOpen(String name) {
    return 'Зашифрованная база \'$name\' должна быть открыта перед созданием копии.';
  }

  @override
  String storageEncryptedBoxClosed(String name) {
    return 'Зашифрованная база $name закрыта.';
  }

  @override
  String get greetMorning => 'Доброе утро';

  @override
  String get greetAfternoon => 'Добрый день';

  @override
  String get greetEvening => 'Добрый вечер';

  @override
  String get authLockedTitle => 'Ayla Заблокирована';

  @override
  String get authUnlockBtn => 'Разблокировать';

  @override
  String get authReason => 'Пройдите авторизацию для входа в Ayla';

  @override
  String get authUnlockShortReason => 'Отсканируйте для входа в Ayla';

  @override
  String get authNotAvailable => 'Биометрия недоступна на устройстве';

  @override
  String get authBiometricsReason => 'Подтвердите для включения биометрии';

  @override
  String get msgBiometricsError => 'Биометрия недоступна';

  @override
  String get pdfReportTitle => 'Медицинский отчет EviMoon';

  @override
  String get pdfReportSubtitle => 'Гинекология и история циклов';

  @override
  String get pdfCycleHistory => 'История циклов';

  @override
  String get pdfHeaderStart => 'Начало';

  @override
  String get pdfHeaderEnd => 'Конец';

  @override
  String get pdfHeaderLength => 'Длина';

  @override
  String get pdfCurrent => 'Текущий';

  @override
  String get pdfGenerated => 'Дата';

  @override
  String get pdfPage => 'Стр.';

  @override
  String get pdfPatient => 'Пациент';

  @override
  String get pdfClinicalSummary => 'Клиническое резюме';

  @override
  String get pdfDetailedLogs => 'Детальный журнал';

  @override
  String get pdfMedicationRegistry => 'Активные препараты и витамины';

  @override
  String get pdfAvgCycle => 'Средняя длина цикла';

  @override
  String get pdfAvgPeriod => 'Средние месячные';

  @override
  String get pdfPainReported => 'Симптомы боли';

  @override
  String get pdfTableDate => 'Дата';

  @override
  String get pdfTableCD => 'ДЦ';

  @override
  String get pdfTableSymptoms => 'Симптомы';

  @override
  String get pdfTableBBT => 'БТТ';

  @override
  String get pdfTableNotes => 'Заметки';

  @override
  String get pdfClinicalSymptoms => 'Клинические симптомы';

  @override
  String get pdfMedicationShort => 'Лекарства';

  @override
  String get pdfDefaultPatient => 'Пациент';

  @override
  String get pdfModeCoc => 'КОК';

  @override
  String get pdfModeTtc => 'ПЛАН';

  @override
  String pdfPeriodRange(String start, String end) {
    return 'Период: $start - $end';
  }

  @override
  String get pdfFlowShort => 'Выдел.';

  @override
  String get pdfFlowMedium => 'Сред.';

  @override
  String get pdfLhNegativeShort => 'Отриц.';

  @override
  String get pdfLhPositiveShort => 'Полож.';

  @override
  String get pdfLhPeakShort => 'Пик';

  @override
  String get pdfSymptomSexProtected => 'Секс (Защ)';

  @override
  String get pdfSymptomSexUnprotected => 'Секс (Незащ)';

  @override
  String get unitDays => 'дней';

  @override
  String get pdfDisclaimer => 'ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: Этот отчет сгенерирован Ayla на основе введенных пользователем данных и не является медицинским диагнозом.';

  @override
  String get msgExportError => 'Не удалось создать PDF';

  @override
  String get msgExportEmpty => 'Нет данных для экспорта.';

  @override
  String get dialogDataInsufficientTitle => 'Недостаточно данных';

  @override
  String get dialogDataInsufficientBody => 'Для генерации медицинского отчета необходимо как минимум 2 дня записей.';

  @override
  String get dayTitle => 'День';

  @override
  String get insightTipTitle => 'Совет дня';

  @override
  String get insightTipBody => 'Уровень энергии падает во время лютеиновой фазы. Отличное время для йоги.';

  @override
  String get insightMenstruationTitle => 'Отдых и забота';

  @override
  String get insightMenstruationSubtitle => 'Держитесь в тепле, пейте чай, отложите тяжелые тренировки.';

  @override
  String get insightFollicularTitle => 'Творческая искра';

  @override
  String get insightFollicularSubtitle => 'Энергия растет! Мозг работает на пике.';

  @override
  String get insightOvulationTitle => 'Суперсила';

  @override
  String get insightOvulationSubtitle => 'Магнетическая энергия. Высокое либидо и уверенность.';

  @override
  String get insightLutealTitle => 'Внутренний фокус';

  @override
  String get insightLutealSubtitle => 'Спокойствие или раздражительность. Загляните внутрь себя.';

  @override
  String get insightLateTitle => 'Сохраняйте спокойствие';

  @override
  String get insightLateSubtitle => 'Снизьте стресс и поддерживайте здоровое питание.';

  @override
  String get insightProstaglandinsTitle => 'Простагландины в действии';

  @override
  String get insightProstaglandinsBody => 'Сокращения матки помогают отторгнуть слизистую. Обычно помогают тепло и магний.';

  @override
  String get insightWinterPhaseTitle => 'Отдых и восстановление';

  @override
  String get insightWinterPhaseBody => 'Гормоны на самом низком уровне. Замедлиться и отдохнуть — это нормально.';

  @override
  String get insightEstrogenTitle => 'Эстроген растет';

  @override
  String get insightEstrogenBody => 'Эстроген повышает уровень серотонина. Отличное время для творчества и планирования!';

  @override
  String get insightMittelschmerzTitle => 'Миттельшмерц (Овуляторная боль)';

  @override
  String get insightMittelschmerzBody => 'Возможно, вы чувствуете точный момент овуляции. Обычно это быстро проходит.';

  @override
  String get insightFertilityTitle => 'Пик фертильности';

  @override
  String get insightFertilityBody => 'Природа стимулирует социальные связи прямо сейчас. Вы магнетически привлекательны!';

  @override
  String get insightWaterTitle => 'Задержка жидкости';

  @override
  String get insightWaterBody => 'Тело удерживает воду, готовясь к возможной беременности. Это скоро пройдет.';

  @override
  String get insightProgesteroneTitle => 'Падение прогестерона';

  @override
  String get insightProgesteroneBody => 'Уровень химических веществ в мозге падает перед менструацией. Будьте бережны к себе.';

  @override
  String get insightSkinTitle => 'Гормональная кожа';

  @override
  String get insightSkinBody => 'Прогестерон стимулирует работу сальных желез. Выбирайте простой уход за кожей.';

  @override
  String get insightMetabolismTitle => 'Потребность в энергии';

  @override
  String get insightMetabolismBody => 'Метаболизм ускоряется. Выбирайте сложные углеводы вместо сладкого.';

  @override
  String get insightSpottingTitle => 'Обнаружена мазня';

  @override
  String get insightSpottingBody => 'Легкие выделения могут случаться в период овуляции или из-за стресса.';

  @override
  String get symptomInsightPeakFertilityDetectedTitle => 'Пик фертильности! 🎯';

  @override
  String get symptomInsightPeakFertilityDetectedBody => 'Пик ЛГ означает, что овуляция, скорее всего, произойдет в ближайшие 24-36 часов. Сегодня и завтра — лучшие дни для зачатия.';

  @override
  String get symptomInsightFertileWindowOpeningTitle => 'Окно фертильности открыто';

  @override
  String get symptomInsightFertileWindowOpeningBody => 'Уровень ЛГ повышается. Начните планировать близость каждые 1-2 дня, чтобы увеличить шансы.';

  @override
  String get symptomInsightHighlyFertileMucusTitle => 'Супер фертильная слизь';

  @override
  String get symptomInsightHighlyFertileMucusBody => 'Цервикальная слизь типа \'яичный белок\' создает идеальную среду для выживания и продвижения сперматозоидов.';

  @override
  String get symptomInsightBuildingUpFertilityTitle => 'Подготовка к фертильности';

  @override
  String get symptomInsightBuildingUpFertilityBody => 'Ваша цервикальная слизь меняется. Ближе к овуляции она станет прозрачной и тягучей.';

  @override
  String get symptomInsightPerfectTimingTitle => 'Идеальный момент! ✨';

  @override
  String get symptomInsightPerfectTimingBody => 'Вы отметили незащищенный секс в фазу овуляции. Вы максимизировали свои шансы в этом цикле. Впереди Двухнедельное ожидание (TWW).';

  @override
  String get symptomInsightTwoWeekWaitTitle => 'Двухнедельное ожидание (TWW)';

  @override
  String get symptomInsightTwoWeekWaitBody => 'Яйцеклетка живет только 24 часа после овуляции. Близость в лютеиновой фазе не ведет к зачатию, но отлично укрепляет связь!';

  @override
  String get symptomInsightMedicalAlertPainSpottingTitle => 'Внимание врача: Боль и Мазня';

  @override
  String get symptomInsightMedicalAlertPainSpottingBody => 'Мазня, сопровождаемая болью вне менструации, может указывать на кисты, полипы или гормональные нарушения. Рекомендуется консультация врача.';

  @override
  String get symptomInsightDysmenorrheaPatternTitle => 'Паттерн дисменореи';

  @override
  String get symptomInsightDysmenorrheaPatternBody => 'Высокий уровень простагландинов вызывает сильные спазмы и тошноту. Тепло и НПВП (например, ибупрофен) помогут блокировать этот процесс.';

  @override
  String get symptomInsightSeverePmsPmddTitle => 'Признак тяжелого ПМС / ПМДР';

  @override
  String get symptomInsightSeverePmsPmddBody => 'Резкое падение серотонина на фоне прогестерона вызывает эмоциональные перепады. Требуется бережный уход за собой.';

  @override
  String get symptomInsightBiologicalPeakTitle => 'Биологический пик';

  @override
  String get symptomInsightBiologicalPeakBody => 'Эстроген и тестостерон достигают максимума. Ваше тело биологически готово к общению, близости и активным задачам.';

  @override
  String get symptomLogCycleWarningTitle => 'Влияние на цикл';

  @override
  String get symptomLogOvulationSpottingWarningBody => 'Легкие кровотечения бывают во время овуляции. Если вы отметите это как Новые месячные, весь ваш цикл будет пересчитан. Хотите начать новый цикл или отметить как \'Мазня\'?';

  @override
  String get symptomLogResetStartCycleAction => 'Сбросить и начать новый цикл';

  @override
  String get symptomLogJustSpottingAction => 'Только мазня';

  @override
  String get symptomLogShortCycleWarningBody => 'С ваших последних месячных прошло менее 21 дня. Запись новых месячных сильно изменит вашу статистику и прогнозы. Вы уверены?';

  @override
  String get symptomLogNewPeriodWarningBody => 'Эта запись завершит ваш текущий цикл и создаст новый прогноз. Вы уверены, что хотите отметить начало месячных сегодня?';

  @override
  String get symptomLogStartNewCycleAction => 'Да, начать новый цикл';

  @override
  String get symptomLogRemoveBleedingWarningBody => 'Удаление записи о кровотечении приведет к пересчету всей истории вашего цикла и будущих прогнозов. Вы уверены?';

  @override
  String get symptomLogRemoveAction => 'Удалить';

  @override
  String get symptomLogLhPeakAddedWarningBody => 'Отметка пика ЛГ немедленно сдвинет день предполагаемой овуляции и окно фертильности. Продолжить?';

  @override
  String get symptomLogConfirmShiftAction => 'Подтвердить сдвиг';

  @override
  String get symptomLogLhPeakRemovedWarningBody => 'Удаление пика ЛГ вернет прогнозы овуляции к стандартным алгоритмам ИИ. Вы уверены?';

  @override
  String get symptomLogFuturePredictionTitle => 'Прогноз в будущее';

  @override
  String get symptomLogFutureTitle => 'Будущее светло';

  @override
  String get symptomLogFutureBody => 'Вы не можете отмечать симптомы для будущих дат. Выберите прошедшую дату.';

  @override
  String get symptomLogTtcAiTitle => 'Интеллект планирования беременности';

  @override
  String get symptomLogTtcAiBody => 'Отмечайте базальную температуру (БТТ) и тесты ЛГ ниже, чтобы улучшить точность определения окна фертильности.';

  @override
  String get symptomLogSectionBleedingTitle => 'Месячные и выделения';

  @override
  String get symptomLogSectionBleedingBody => 'Выберите интенсивность на сегодня';

  @override
  String get symptomLogSectionBbtTitle => 'Базальная температура (БТТ)';

  @override
  String get symptomLogSectionBbtBody => 'Скорректируйте утреннюю БТТ';

  @override
  String get symptomLogSectionOpkTitle => 'Тесты на овуляцию (ЛГ)';

  @override
  String get symptomLogSectionOpkBody => 'Активен может быть только один статус ЛГ';

  @override
  String get symptomLogSectionMucusTitle => 'Цервикальная слизь';

  @override
  String get symptomLogSectionMucusBody => 'Отметьте самый актуальный тип';

  @override
  String get symptomLogSectionIntimacyTitle => 'Близость и либидо';

  @override
  String get symptomLogSectionIntimacyTtcBody => 'Помогает анализировать фертильность';

  @override
  String get symptomLogSectionIntimacyBody => 'Отмечайте интимную жизнь и желание';

  @override
  String get symptomLogSectionVitalsTitle => 'Показатели';

  @override
  String get symptomLogSectionVitalsBody => 'Быстрая проверка состояния на сегодня';

  @override
  String get symptomLogSectionPhysicalTitle => 'Физические симптомы';

  @override
  String get symptomLogSectionPhysicalBody => 'Дискомфорт и сигналы тела';

  @override
  String get symptomLogSectionMentalTitle => 'Эмоции и разум';

  @override
  String get symptomLogSectionMentalBody => 'Настроение, фокус и психологическое состояние';

  @override
  String get symptomLogSectionOtherTitle => 'Другие факторы';

  @override
  String get symptomLogSectionOtherBody => 'Ситуации, которые могут повлиять на цикл';

  @override
  String get symptomLogMenstruationConflictRemoved => 'Отмечена менструация. Несовместимые симптомы (Пик ЛГ / Слизь) удалены.';

  @override
  String get symptomLogBbtMeasuredLabel => 'Измеренная базальная температура';

  @override
  String get symptomLogBbtSuggestedLabel => 'Предложено по прошлым записям';

  @override
  String get symptomLogBleedingRemovedOvulationConflict => 'Кровотечение удалено. Менструация и овуляция не могут происходить одновременно.';

  @override
  String get symptomLogBleedingRemovedMucusConflict => 'Кровотечение удалено. Слизь не отслеживается во время менструации.';

  @override
  String get healthFlagPcosTitle => 'Паттерн нерегулярного цикла';

  @override
  String get healthFlagPcosBody => 'Ваши циклы сильно различаются по длине или стабильно превышают 35 дней.';

  @override
  String get healthFlagPcosRecommendation => 'Такой паттерн иногда связан с СПКЯ или проблемами со щитовидной железой. Рассмотрите возможность консультации с врачом.';

  @override
  String get healthFlagEndometriosisTitle => 'Высокий профиль боли';

  @override
  String get healthFlagEndometriosisBody => 'Вы часто отмечаете сильную тазовую боль и обильные кровотечения.';

  @override
  String get healthFlagEndometriosisRecommendation => 'Сильная боль при месячных, мешающая нормальной жизни, не является нормой. Это может указывать на эндометриоз или миомы.';

  @override
  String get healthFlagLutealDefectTitle => 'Короткая лютеиновая фаза';

  @override
  String get healthFlagLutealDefectBody => 'Время между овуляцией и началом следующих месячных стабильно короткое (< 10 дней).';

  @override
  String get healthFlagLutealDefectRecommendation => 'Короткая лютеиновая фаза часто связана с низким уровнем прогестерона, что может осложнить зачатие.';

  @override
  String get healthFlagMenorrhagiaTitle => 'Продолжительные кровотечения';

  @override
  String get healthFlagMenorrhagiaBody => 'Ваши менструации стабильно длятся 8 дней или более.';

  @override
  String get healthFlagMenorrhagiaRecommendation => 'Затяжные кровотечения (меноррагия) могут привести к дефициту железа и хронической усталости.';

  @override
  String get healthFlagPolymenorrheaTitle => 'Слишком короткие циклы';

  @override
  String get healthFlagPolymenorrheaBody => 'Ваши циклы стабильно короче 21 дня.';

  @override
  String get healthFlagPolymenorrheaRecommendation => 'Частые менструации могут вызвать анемию и свидетельствовать о проблемах с овуляцией. Рекомендуется обсудить с врачом.';

  @override
  String get healthFlagPmddTitle => 'Сильные спады настроения (ПМС)';

  @override
  String get healthFlagPmddBody => 'Вы стабильно отмечаете депрессию, тревогу или очень плохое настроение в неделю перед месячными.';

  @override
  String get healthFlagPmddRecommendation => 'Такой циклический спад может быть признаком ПМДР. Вы не должны страдать в одиночку — существуют методы лечения.';

  @override
  String get healthFlagAmenorrheaTitle => 'Продолжительная задержка';

  @override
  String get healthFlagAmenorrheaBody => 'Ваш текущий цикл длится уже более 90 дней.';

  @override
  String get healthFlagAmenorrheaRecommendation => 'Это называется вторичной аменореей. Если беременность исключена, причиной может быть стресс, изменение веса или гормональный сбой.';

  @override
  String get insightsLoadingHistoryPatterns => 'Анализ истории и паттернов...';

  @override
  String get insightsFertilityStatusTitle => 'Статус фертильности';

  @override
  String get insightsCycleAnalysisTitle => 'Анализ цикла';

  @override
  String get insightsKeySignalsSubtitle => 'Ключевые сигналы вашего тела';

  @override
  String get insightsHormonalRhythmTitle => 'Гормональный ритм';

  @override
  String get insightsHormonalRhythmBody => 'Симптомы в соотношении с предполагаемым уровнем гормонов';

  @override
  String get insightsHormonalRhythmInspectHint => 'Коснитесь графика для деталей';

  @override
  String insightsHormonalRhythmScrubbingDay(int day) {
    return 'Просмотр дня $day';
  }

  @override
  String insightsHormonalRhythmMore(int count) {
    return 'и еще +$count';
  }

  @override
  String get insightsHormonalContextTitle => 'Гормональный контекст';

  @override
  String get insightsHormonalContextBody => 'Почему вы можете так себя чувствовать сегодня';

  @override
  String get insightsMedicalInsightsTitle => 'Медицинские инсайты';

  @override
  String get insightsMedicalInsightsBody => 'Паттерны, обнаруженные в вашей истории';

  @override
  String get insightsThermalShiftTitle => 'Температурный сдвиг';

  @override
  String get insightsThermalShiftBody => 'График вашей температуры в этом цикле';

  @override
  String get insightsFrequentSymptomsTitle => 'Частые симптомы';

  @override
  String get insightsFrequentSymptomsBody => 'Самые частые симптомы из недавних записей';

  @override
  String get insightsEmptySymptomsBody => 'Отмечайте симптомы каждый день, чтобы увидеть уникальные паттерны вашего тела.';

  @override
  String get insightsTopBarFertilityHubTitle => 'Центр Фертильности';

  @override
  String get insightsTopBarFertilityHubSubtitle => 'Ваша персональная аналитика фертильности';

  @override
  String get insightsTopBarDefaultSubtitle => 'Интеллект вашего тела';

  @override
  String get insightsHeroContraceptiveModeTitle => 'Режим контрацепции (КОК)';

  @override
  String get insightsHeroContraceptiveModeBody => 'Отслеживание адаптировано для цикла с таблетками';

  @override
  String get insightsHeroOvulationConfirmedTitle => 'Овуляция подтверждена';

  @override
  String get insightsHeroOvulationConfirmedBody => 'Сейчас идет фаза двухнедельного ожидания';

  @override
  String get insightsHeroFertileWindowActiveTitle => 'Окно фертильности открыто';

  @override
  String get insightsHeroFertileWindowActiveBody => 'Вероятность зачатия повышена';

  @override
  String get insightsHeroTrackingFertilityTitle => 'Отслеживание фертильности';

  @override
  String get insightsHeroTrackingFertilityBody => 'Отмечайте БТТ и симптомы для высокой точности';

  @override
  String get insightsHeroCycleIntelligenceTitle => 'Интеллект Цикла';

  @override
  String get insightsHeroCycleIntelligenceEmptyBody => 'Начните вести дневник для анализа';

  @override
  String get insightsHeroCycleIntelligenceReadyBody => 'Тренды обновлены на основе недавних записей';

  @override
  String get insightsHeroStatusLabel => 'Статус';

  @override
  String get insightsHeroPhaseLabel => 'Фаза';

  @override
  String get insightsHeroLogsLabel => 'Записей';

  @override
  String get insightsHeroCycleLabel => 'Цикл';

  @override
  String get insightsHeroPeriodLabel => 'Месячные';

  @override
  String get insightsAylaEngineTitle => 'ИИ Ayla';

  @override
  String get insightsAylaReadyBody => 'Ваш гормональный анализ на сегодня готов. Вы также можете пообщаться с Ayla для получения персональных советов.';

  @override
  String get insightsAylaPromptBody => 'Интересно, почему вы так себя чувствуете сегодня? Поговорите с Ayla или сгенерируйте дневной отчет по гормонам.';

  @override
  String get insightsChatWithAylaAction => 'Чат с Ayla';

  @override
  String get insightsViewTodaysReportAction => 'Открыть отчет за сегодня';

  @override
  String get insightsGenerateDailyReportAction => 'Сгенерировать дневной отчет';

  @override
  String get insightsAnalysisDataInsufficientTitle => 'Недостаточно данных';

  @override
  String get insightsAnalysisDataInsufficientBody => 'Добавьте больше циклов, чтобы открыть аналитику.';

  @override
  String get insightsAnalysisOvulationConfirmedTitle => 'Овуляция подтверждена';

  @override
  String get insightsAnalysisOvulationConfirmedBody => 'Идет двухнедельное ожидание. Поддерживайте рутину.';

  @override
  String get insightsAnalysisFertileWindowOpenTitle => 'Окно фертильности';

  @override
  String get insightsAnalysisFertileWindowOpenBody => 'Шансы на зачатие высоки. Отмечайте БТТ каждый день.';

  @override
  String get insightsAnalysisTrackingPhaseTitle => 'Фаза отслеживания';

  @override
  String get insightsAnalysisTrackingPhaseBody => 'Анализируем ваши данные для прогноза овуляции.';

  @override
  String get insightsAnalysisContraceptiveModeTitle => 'Режим КОК';

  @override
  String get insightsAnalysisContraceptiveModeBody => 'Цикл управляется таблетками. Не забывайте их принимать.';

  @override
  String get insightsAnalysisDelayedCycleTitle => 'Задержка цикла';

  @override
  String get insightsAnalysisDelayedCycleBody => 'Задержка более 60 дней. Подумайте о консультации врача.';

  @override
  String get insightsAnalysisIrregularBleedingTitle => 'Нерегулярное кровотечение';

  @override
  String get insightsAnalysisIrregularBleedingBody => 'Недавние месячные длились дольше обычного.';

  @override
  String get insightsAnalysisStableRhythmTitle => 'Стабильный ритм';

  @override
  String get insightsAnalysisStableRhythmBody => 'Ваши недавние циклы выглядят очень регулярными.';

  @override
  String get insightsAnalysisLearningRhythmTitle => 'Изучаем ваш ритм';

  @override
  String get insightsAnalysisLearningRhythmBody => 'AI строит вашу модель. Продолжайте вести дневник.';

  @override
  String get insightsMetricCycleLength => 'Длина цикла';

  @override
  String get insightsMetricPeriod => 'Месячные';

  @override
  String get insightsMetricFertility => 'Фертильность';

  @override
  String get insightsMetricOvulation => 'Овуляция';

  @override
  String get insightsMetricYes => 'Да';

  @override
  String get insightsMetricPending => 'Ожидание';

  @override
  String get insightsBbtEmptyBody => 'Отметьте утреннюю температуру, чтобы увидеть график сдвига.';

  @override
  String get aylaConsultationTitle => 'Советы от Ayla';

  @override
  String get aylaConsultationAction => 'Понятно, Ayla';

  @override
  String get timerPeriod => 'МЕСЯЧНЫЕ';

  @override
  String get timerFertileIn => 'ФЕРТИЛЬНОСТЬ ЧЕРЕЗ';

  @override
  String get timerFertileWindow => 'ОКНО ФЕРТИЛЬНОСТИ';

  @override
  String get timerOvulation => 'ОВУЛЯЦИЯ';

  @override
  String get timerPastOvulation => 'ПОСЛЕ ОВУЛЯЦИИ';

  @override
  String get timerCycleDelay => 'ЗАДЕРЖКА ЦИКЛА';

  @override
  String timerDayValue(int day) {
    return 'ДЕНЬ $day';
  }

  @override
  String timerDaysValue(int days) {
    return '$days ДН.';
  }

  @override
  String timerDpoValue(int days) {
    return '$days ДПО';
  }

  @override
  String get timerDaysLate => 'ДН. ЗАДЕРЖКИ';

  @override
  String get timerPreparing => 'ПОДГОТОВКА';

  @override
  String get timerTwwDpo => 'ОЖИДАНИЕ (TWW) / ДПО';

  @override
  String get tipPeriod => 'Отдыхайте и ешьте продукты, богатые железом.';

  @override
  String get tipOvulation => 'Пик фертильности! Идеальное время для зачатия.';

  @override
  String get tipLutealEarly => 'Прогестерон растет. Пейте больше воды.';

  @override
  String get tipLutealLate => 'Окно имплантации. Избегайте сильного стресса.';

  @override
  String get tipFollicular => 'Энергия растет. Отличное время для тренировок.';

  @override
  String get tipLowEnergy => 'Отдых сегодня необходим. Попробуйте легкую йогу.';

  @override
  String get tipHighEnergy => 'Отличное время для кардио и сложных задач!';

  @override
  String get tipLowMood => 'Будьте бережны к себе. Шоколад помогает.';

  @override
  String get tipHighMood => 'Делитесь позитивом! Отличное время для общения.';

  @override
  String get tipLowFocus => 'Избегайте многозадачности. Выберите одну простую цель.';

  @override
  String get tipHighFocus => 'Режим глубокой работы. Беритесь за сложный проект.';

  @override
  String get dialogStartTitle => 'Начать новый цикл?';

  @override
  String get dialogStartBody => 'Сегодня будет отмечено как День 1 вашей менструации.';

  @override
  String get dialogEndTitle => 'Завершить месячные?';

  @override
  String get dialogEndBody => 'Ваша фаза цикла изменится на фолликулярную.';

  @override
  String get btnPeriodStart => 'НАЧАЛОСЬ';

  @override
  String get btnPeriodEnd => 'ЗАКОНЧИЛОСЬ';

  @override
  String get dialogPeriodStartTitle => 'Месячные начались?';

  @override
  String get dialogPeriodStartBody => 'Месячные начались сегодня, или вы просто забыли отметить их раньше?';

  @override
  String get btnToday => 'Today';

  @override
  String get btnYesterday => 'Yesterday';

  @override
  String get btnPickDate => 'Select Date';

  @override
  String get btnAnotherDay => 'Select Date';

  @override
  String get cocActivePhase => 'Прием активных таблеток';

  @override
  String get cocBreakPhase => 'Неделя перерыва';

  @override
  String cocPredictionActive(int days) {
    return 'Осталось $days активных таблеток';
  }

  @override
  String cocPredictionBreak(int days) {
    return 'Новая упаковка через $days дн.';
  }

  @override
  String get btnStartNewPack => 'Начать новую упаковку';

  @override
  String get btnRestartPack => 'Перезапустить упаковку';

  @override
  String get dialogStartPackTitle => 'Начать новую упаковку?';

  @override
  String get dialogStartPackBody => 'Это сбросит цикл на День 1. Используйте при открытии новой пачки таблеток.';

  @override
  String get dialogCOCStartTitle => 'Отслеживать контрацепцию?';

  @override
  String get dialogCOCStartSubtitle => 'Выберите, как вы хотите начать отслеживание приема таблеток.';

  @override
  String get optionFreshPack => 'Новая упаковка';

  @override
  String get optionFreshPackSub => 'Сегодня День 1';

  @override
  String get optionContinuePack => 'Продолжить текущую';

  @override
  String get optionContinuePackSub => 'Я уже в середине упаковки';

  @override
  String get labelOr => 'ИЛИ';

  @override
  String cocDayInfo(int day) {
    return 'День $day из 28';
  }

  @override
  String get settingsContraception => 'Контрацепция';

  @override
  String get settingsTrackPill => 'Отслеживать противозачаточные';

  @override
  String get settingsPackType => 'Тип упаковки';

  @override
  String settingsPills(int count) {
    return '$count Таблеток';
  }

  @override
  String get settingsReminder => 'Напоминание';

  @override
  String get settingsPackSettings => 'Настройки упаковки';

  @override
  String get settingsPlaceboCount => 'Дней плацебо';

  @override
  String get settingsBreakDuration => 'Длительность перерыва';

  @override
  String get dialogPackTitle => 'Выберите тип упаковки';

  @override
  String get dialogPackSubtitle => 'Укажите формат вашей упаковки.';

  @override
  String get pack21Title => '21 Таблетка';

  @override
  String get pack21Subtitle => '21 Активная + 7 дней перерыв';

  @override
  String get pack28Title => '28 Таблеток';

  @override
  String get pack28Subtitle => '21 Активная + 7 Плацебо';

  @override
  String get pack24Title => '28 Таблеток (24+4)';

  @override
  String get pack24Subtitle => '24 Активная + 4 Плацебо';

  @override
  String get packContinuousTitle => 'Непрерывный (Мини-пили)';

  @override
  String get packContinuousSubtitle => '28 Активных (без перерыва)';

  @override
  String get pack21 => '21 Активная + 7 Перерыв';

  @override
  String get pack28 => '28 Активных (Без перерыва)';

  @override
  String get pack24 => '24 Активная + 4 Пустышки';

  @override
  String get pillTaken => 'Таблетка выпита';

  @override
  String get pillTake => 'Выпить таблетку';

  @override
  String get pillMissed => 'Пропущена таблетка?';

  @override
  String get pillTakeNow => 'Выпить сейчас';

  @override
  String pillScheduled(String time) {
    return 'Назначено на $time';
  }

  @override
  String pillScheduledFor(String time) {
    return 'Было назначено на $time';
  }

  @override
  String get blisterMyPack => 'Моя упаковка';

  @override
  String blisterDay(int day, int total) {
    return 'День $day / $total';
  }

  @override
  String blisterOverdue(int day) {
    return 'День $day (Пропущено)';
  }

  @override
  String get blister21 => '21-дневная упаковка';

  @override
  String get blister28 => '28-дневная упаковка';

  @override
  String get legendTaken => 'Выпито';

  @override
  String get legendActive => 'Активная';

  @override
  String get legendPlacebo => 'Плацебо';

  @override
  String get legendBreak => 'Перерыв';

  @override
  String get insightCOCActiveTitle => 'Защита активна';

  @override
  String get insightCOCActiveBody => 'Фаза активных таблеток. Старайтесь принимать таблетку в одно и то же время.';

  @override
  String get insightCOCBreakTitle => 'Кровотечение отмены';

  @override
  String get insightCOCBreakBody => 'Это неделя перерыва. Ожидается кровотечение из-за падения гормонов.';

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
  String get emailSubject => 'Отзыв о приложении EviMoon';

  @override
  String get emailBody => 'Здравствуйте, команда EviMoon,\n\nУ меня есть вопрос или предложение по приложению:';

  @override
  String msgEmailError(String email) {
    return 'Не удалось открыть почтовый клиент. Напишите нам: $email';
  }

  @override
  String get onboardTitle1 => 'Добро пожаловать в EviMoon';

  @override
  String get onboardBody1 => 'Отслеживайте свой цикл, понимайте свое тело и живите в гармонии с собственным ритмом.';

  @override
  String get onboardTitle2 => 'Начало последних месячных';

  @override
  String get onboardBody2 => 'Пожалуйста, выберите первый день вашей последней менструации.';

  @override
  String get onboardTitle3 => 'Длина цикла';

  @override
  String get onboardBody3 => 'Сколько дней обычно проходит между месячными? В среднем это 28 дней.';

  @override
  String get onboardModeTitle => 'Какая у вас цель?';

  @override
  String get onboardModeCycle => 'Отслеживать цикл';

  @override
  String get onboardModeCycleDesc => 'Прогноз месячных и фертильности';

  @override
  String get onboardModePill => 'Прием таблеток (КОК)';

  @override
  String get onboardModePillDesc => 'Напоминания и учет упаковки';

  @override
  String get onboardDateTitleCycle => 'Когда начались ваши последние месячные?';

  @override
  String get onboardDateTitlePill => 'Когда вы начали текущую упаковку таблеток?';

  @override
  String get onboardLengthTitle => 'Длина цикла';

  @override
  String get onboardPackTitle => 'Тип упаковки';

  @override
  String get onboardPartnerModeCta => 'Режим партнера? Введите код здесь.';

  @override
  String get onboardProcessingSetup => 'Настройка вашего ИИ...';

  @override
  String get onboardSetupError => 'Ошибка при настройке. Пожалуйста, попробуйте еще раз.';

  @override
  String get splashTitle => 'EVIMOON';

  @override
  String get splashSlogan => 'Слушай свой ритм';

  @override
  String get splashBrand => 'AYLA';

  @override
  String get splashTagline => 'breathe & bloom';

  @override
  String get premiumInsightLabel => 'ПРЕМИУМ ИНСАЙТ';

  @override
  String get calendarForecastTitle => 'КАЛЕНДАРЬ И ПРОГНОЗ';

  @override
  String get aiForecastHigh => 'Высокая точность прогноза';

  @override
  String get aiForecastHighSub => 'На основе стабильной истории';

  @override
  String get aiForecastMedium => 'Средняя точность';

  @override
  String get aiForecastMediumSub => 'Замечены вариации в циклах';

  @override
  String get aiForecastLow => 'Низкая точность';

  @override
  String get aiForecastLowSub => 'Длина цикла сильно меняется';

  @override
  String get aiLearning => 'ИИ обучается...';

  @override
  String get aiLearningSub => 'Отметьте 3 цикла для работы прогноза';

  @override
  String get confidenceHighDesc => 'Ваш цикл предсказуем и регулярен.';

  @override
  String get confidenceMedDesc => 'Прогноз основан на средних данных.';

  @override
  String get confidenceLowDesc => 'Прогнозы могут колебаться из-за нерегулярной истории.';

  @override
  String get confidenceCalcDesc => 'Сбор дополнительных данных для повышения точности.';

  @override
  String get confidenceNoData => 'Пока недостаточно данных.';

  @override
  String get factorDataNeeded => 'Нужно как минимум 3 цикла';

  @override
  String get factorHighVar => 'Замечена высокая нерегулярность';

  @override
  String get factorSlightVar => 'Легкая нерегулярность';

  @override
  String get factorStable => 'Цикл стабилен';

  @override
  String get factorAnomaly => 'Обнаружена недавняя аномалия';

  @override
  String get aiDialogTitle => 'Анализ точности прогноза';

  @override
  String aiDialogScore(int score) {
    return 'Точность вашего прогноза составляет $score%.';
  }

  @override
  String get aiDialogExplanation => 'Этот показатель рассчитывается локально на основе дисперсии вашей истории циклов.';

  @override
  String get aiDialogFactors => 'Факторы:';

  @override
  String get btnGotIt => 'Понятно';

  @override
  String get aiStatusHigh => 'Высокая точность';

  @override
  String get aiStatusMedium => 'Умеренная точность';

  @override
  String get aiStatusLow => 'Низкая точность';

  @override
  String get aiDescHigh => 'Ваши циклы очень регулярны. AI-прогноз, скорее всего, точен до ±1 дня.';

  @override
  String get aiDescMedium => 'В недавних циклах есть колебания. Прогноз может варьироваться на ±2-3 дня.';

  @override
  String get aiDescLow => 'История ваших циклов нерегулярна или слишком коротка. ИИ нужно больше данных.';

  @override
  String get aiConfidenceScore => 'Уверенность';

  @override
  String get aiLabelHistory => 'Длина истории';

  @override
  String get aiLabelVariation => 'Колебания цикла';

  @override
  String get aiSuffixCycles => 'циклов';

  @override
  String get aiSuffixDays => 'дн.';

  @override
  String get modeTTC => 'Планирование беременности';

  @override
  String get modeTTCDesc => 'Фокус на фертильности и отслеживании овуляции';

  @override
  String get modeTTCActive => 'Режим планирования активирован';

  @override
  String get modeCycle => 'Отслеживание цикла';

  @override
  String get modeTrackCycle => 'Отслеживать цикл';

  @override
  String get modeGetPregnant => 'Забеременеть';

  @override
  String get dialogTTCConflict => 'Отключить контрацепцию?';

  @override
  String get dialogTTCConflictBody => 'Чтобы включить режим Планирования беременности, отслеживание контрацептивов должно быть отключено.';

  @override
  String get btnDisableAndSwitch => 'Отключить и перейти';

  @override
  String get ttcStatusLow => 'Низкий шанс';

  @override
  String get ttcStatusHigh => 'Высокая фертильность';

  @override
  String get ttcStatusPeak => 'Пик фертильности';

  @override
  String get ttcStatusOvulation => 'День овуляции';

  @override
  String ttcDPO(int days) {
    return '$days ДПО';
  }

  @override
  String get ttcChance => 'Шанс на зачатие';

  @override
  String get ttcChanceHigh => 'Высокий шанс';

  @override
  String get ttcChancePeak => 'Пик фертильности';

  @override
  String get ttcChanceLow => 'Низкий шанс';

  @override
  String get ttcTestWait => 'Пока рано делать тест';

  @override
  String get ttcTestReady => 'Вы можете сделать тест сегодня';

  @override
  String lblCycleDay(int day) {
    return 'День цикла: $day';
  }

  @override
  String ttcCycleDay(int day) {
    return 'ДЕНЬ ЦИКЛА $day';
  }

  @override
  String get ttcBtnBBT => 'Отметить БТТ';

  @override
  String get ttcBtnTest => 'Тест на ЛГ';

  @override
  String get ttcBtnSex => 'Близость';

  @override
  String get dashboardActionLogged => 'Отмечено';

  @override
  String get dashboardActionGenericError => 'Ошибка. Пожалуйста, попробуйте еще раз.';

  @override
  String get dashboardPeriodEndingTitle => 'Заканчиваются сегодня';

  @override
  String get dashboardPeriodEndingBody => 'Нажмите, если кровотечение прекратилось';

  @override
  String dashboardPeriodDayTitle(int day) {
    return 'День $day месячных';
  }

  @override
  String get dashboardPeriodDayBody => 'Нажмите, чтобы отметить симптомы';

  @override
  String get dashboardStartPeriodTitle => 'Начать месячные';

  @override
  String get dashboardStartPeriodBody => 'Отметьте сегодня, вчера или выберите дату';

  @override
  String get dashboardShortCycleSpottingBody => 'Прошло менее 21 дня с начала вашего последнего цикла. Это новые месячные или мазня?';

  @override
  String get dashboardNewPeriodAction => 'Новые месячные';

  @override
  String get dashboardPeriodStartRemoved => 'Начало месячных удалено';

  @override
  String get dashboardFutureDateError => 'Нельзя отмечать будущие даты';

  @override
  String get dashboardResumePeriodTitle => 'Продолжить месячные';

  @override
  String get dashboardResumePeriodBody => 'Всё еще есть кровотечение? Продлить месячные';

  @override
  String get dashboardMistakeTitle => 'Я ошиблась';

  @override
  String get dashboardMistakeBody => 'Удалить начало месячных';

  @override
  String get dashboardInsightCycleResetTitle => 'Сброс цикла';

  @override
  String get dashboardInsightCycleResetBody => 'Начинаем заново. Не забудьте принять ежедневную фолиевую кислоту или витамины.';

  @override
  String get dashboardInsightPreparingOvulationTitle => 'Подготовка к овуляции';

  @override
  String get dashboardInsightPreparingOvulationBody => 'Тело готовится. Продолжайте отмечать БТТ и следить за цервикальной слизью.';

  @override
  String get dashboardInsightPeakFertilityTitle => 'Пик фертильности!';

  @override
  String get dashboardInsightPeakFertilityBody => 'Это оптимальное окно для зачатия. Отмечайте близость и тесты на ЛГ.';

  @override
  String get dashboardInsightTwwTitle => 'Двухнедельное ожидание (TWW)';

  @override
  String get dashboardInsightTwwBody => 'Прогестерон растет. Оставайтесь спокойной, избегайте горячих ванн и следите за БТТ.';

  @override
  String get dashboardInsightTestDayTitle => 'День теста! 🤞';

  @override
  String get dashboardInsightTestDayBody => 'У вас задержка. Отличное время, чтобы сделать тест на беременность!';

  @override
  String get dashboardInsightRestResetTitle => 'Отдых и восстановление';

  @override
  String get dashboardInsightRestResetBody => 'Уровень гормонов низкий. Сфокусируйтесь на питье воды.';

  @override
  String get dashboardInsightEnergyRisingTitle => 'Энергия растет';

  @override
  String get dashboardInsightEnergyRisingBody => 'Эстроген повышается. Идеально для решения сложных задач.';

  @override
  String get dashboardInsightPeakVitalityTitle => 'Пик активности';

  @override
  String get dashboardInsightPeakVitalityBody => 'Вы сияете. Лучшее время для интенсивных тренировок.';

  @override
  String get dashboardInsightWindDownTitle => 'Замедляемся';

  @override
  String get dashboardInsightWindDownBody => 'Прогестерон высокий. Тяга к сладкому и перепады настроения — это нормально.';

  @override
  String get dashboardInsightCycleDelayedTitle => 'Задержка цикла';

  @override
  String get dashboardInsightCycleDelayedBody => 'Месячные задерживаются. Стресс мог сыграть свою роль.';

  @override
  String get dashboardInsightAnalyzingBadge => '⏳ АНАЛИЗ...';

  @override
  String get dashboardInsightLocalBadge => '⚡ ЛОКАЛЬНЫЙ ИНСАЙТ';

  @override
  String get dashboardInsightDailyAiBadge => '✨ DAILY AI';

  @override
  String get dashboardInsightThinkingTitle => 'Ayla думает...';

  @override
  String get dashboardInsightThinkingBody => 'Анализируем последние данные вашего цикла и симптомы, чтобы сгенерировать персональный инсайт...';

  @override
  String get ttcBtnReset => 'Сброс';

  @override
  String get ttcLogTitle => 'Журнал за сегодня';

  @override
  String get ttcSectionBBT => 'Базальная температура тела';

  @override
  String get ttcSectionTest => 'Тест на овуляцию (ЛГ)';

  @override
  String get ttcSectionSex => 'Близость';

  @override
  String get lblNegative => 'Отрицательный (-)';

  @override
  String get lblPositive => 'Положительный (+)';

  @override
  String get lblPeak => 'Пик';

  @override
  String get chipNegative => 'Отрицат.';

  @override
  String get chipPositive => 'Положит.';

  @override
  String get chipPeak => 'Пик';

  @override
  String get valNegative => 'Отрицат.';

  @override
  String get valPositive => 'Положит.';

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
  String get valSexYes => 'Отмечено';

  @override
  String get ttcTipTitle => 'Совет на день';

  @override
  String get ttcTipDefault => 'Стресс влияет на овуляцию. Попробуйте 5-минутную медитацию сегодня.';

  @override
  String get ttcStrategyTitle => 'Стратегия';

  @override
  String get ttcStrategyMinimal => 'Минимум усилий';

  @override
  String get ttcStrategyMaximal => 'Максимум шансов';

  @override
  String get ttcPlanTitle => 'Ваш план';

  @override
  String get ttcPlanMinimalBody => 'В период окна фертильности: близость через день, тесты на ЛГ 2–3 дня, БТТ по желанию.';

  @override
  String get ttcPlanMaximalBody => 'В период окна фертильности: близость каждый день, тесты на ЛГ каждый день, БТТ каждое утро.';

  @override
  String get ttcOvulationBadgeTitle => 'Овуляция';

  @override
  String get ttcOvulationEstimatedCalendar => 'Ожидаемая (календарь)';

  @override
  String get ttcOvulationConfirmedLH => 'Подтверждена ЛГ';

  @override
  String get ttcOvulationConfirmedBBT => 'Подтверждена БТТ';

  @override
  String get ttcOvulationConfirmedManual => 'Подтверждена';

  @override
  String get dialogHighTempTitle => 'Высокая температура';

  @override
  String get dialogHighTempBody => 'Температура выше 37.5°C обычно указывает на жар/простуду, а не на овуляцию.';

  @override
  String get dialogLowTempTitle => 'Низкая температура';

  @override
  String get dialogLowTempBody => 'Температура ниже 35.5°C необычно низкая. Это не опечатка?';

  @override
  String get dialogPeriodLHTitle => 'Нетипичные показатели';

  @override
  String get dialogPeriodLHBody => 'Положительный тест ЛГ во время менструации бывает редко. Возможно, это ошибка.';

  @override
  String get btnLogAnyway => 'Всё равно сохранить';

  @override
  String get insightFertilitySub => 'Как тело сигнализирует об овуляции';

  @override
  String get insightLibidoHigh => 'Высокое либидо в окно фертильности';

  @override
  String get insightPainOvulation => 'Овуляторная боль (Mittelschmerz) обнаружена';

  @override
  String get insightTempShift => 'Замечен температурный скачок после овуляции';

  @override
  String get lblDetected => 'Обнаружено';

  @override
  String get msgLhPeakRecorded => 'Записан пик ЛГ! Активировано высокое окно фертильности.';

  @override
  String get transitionTTC => 'Путешествие начинается... ✨';

  @override
  String get transitionCOC => 'Защита активирована 🛡️';

  @override
  String get transitionTrack => 'Прислушиваемся к вашему телу 🌿';

  @override
  String get notifPhaseFollicularTitle => 'Энергия растет ⚡';

  @override
  String get notifPhaseFollicularBody => 'Отличное время для тренировок! Ваша энергия на подъеме.';

  @override
  String get notifFollTitle => 'Энергия растет ⚡';

  @override
  String get notifFollBody => 'Отличное время для тренировок! Ваша энергия на подъеме.';

  @override
  String get notifPhaseOvulationTitle => 'Вы сияете 🌸';

  @override
  String get notifPhaseOvulationBody => 'Пик уверенности в себе и фертильности сегодня.';

  @override
  String get notifOvulationTitle => 'Вы сияете 🌸';

  @override
  String get notifOvulationBody => 'Пик уверенности в себе и фертильности сегодня.';

  @override
  String get notifPhaseLutealTitle => 'Будьте бережны 🌙';

  @override
  String get notifPhaseLutealBody => 'Замедлите темп сегодня, прислушайтесь к телу.';

  @override
  String get notifLutealTitle => 'Будьте бережны 🌙';

  @override
  String get notifLutealBody => 'Замедлите темп сегодня, прислушайтесь к телу.';

  @override
  String get notifPhasePeriodTitle => 'Новый цикл 🩸';

  @override
  String get notifPhasePeriodBody => 'Не забудьте отметить начало менструации.';

  @override
  String get notifPeriodSoonTitle => 'Скоро месячные 🩸';

  @override
  String get notifPeriodSoonBody => 'Ожидаются месячные завтра. Подготовили всё необходимое?';

  @override
  String get notifPeriodTitle => 'Обновление цикла';

  @override
  String get notifPeriodBody => 'Ваши месячные, вероятно, начнутся через 2 дня. Приготовьтесь!';

  @override
  String get notifLatePeriodTitle => 'Задержка?';

  @override
  String get notifLatePeriodBody => 'Цикл дольше обычного. Отметьте симптомы или сделайте тест.';

  @override
  String get notifLateTitle => 'Задержка?';

  @override
  String get notifLateBody => 'Цикл дольше обычного. Не волнуйтесь, такое бывает.';

  @override
  String get notifLateFiveDaysTitle => 'Задержка уже 5 дней';

  @override
  String get notifLateFiveDaysBody => 'Подумайте о том, чтобы сделать тест на беременность.';

  @override
  String get notifLogCheckinTitle => 'Как вы себя чувствуете?';

  @override
  String get notifLogCheckinBody => 'Уделите секунду, чтобы отметить симптомы для точных прогнозов.';

  @override
  String get notifCheckinTitle => 'Журнал дня 📝';

  @override
  String get notifCheckinBody => 'Как самочувствие сегодня? Отметьте ваши симптомы.';

  @override
  String get notifPillTitle => 'Напоминание о таблетке 💊';

  @override
  String get notifPillBody => 'Пора принять вашу противозачаточную таблетку.';

  @override
  String get notifNewPackTitle => 'Новая упаковка 💊';

  @override
  String get notifNewPackBody => 'Пора начать новую упаковку таблеток!';

  @override
  String get notifBreakTitle => 'Неделя перерыва 🩸';

  @override
  String get notifBreakBody => 'Активные таблетки закончились. Приятного перерыва.';

  @override
  String get partnerLinkTitle => 'Введите код приглашения';

  @override
  String get partnerLinkSubtitle => 'Попросите вашего партнера сгенерировать 6-значный код в настройках приложения Ayla.';

  @override
  String get partnerLinkHint => '000-000';

  @override
  String get partnerLinkButton => 'Подключиться к Партнеру';

  @override
  String get partnerLinkInvalidCode => 'Неверный или истекший код. Пожалуйста, проверьте и попробуйте снова.';

  @override
  String get partnerDashboardTitle => 'Ayla для Партнеров';

  @override
  String get partnerStatusTracking => 'Отслеживание...';

  @override
  String get partnerPhaseMenstruation => 'Менструация';

  @override
  String get partnerPhaseFollicular => 'Фолликулярная фаза';

  @override
  String get partnerPhaseOvulation => 'Фаза Овуляции';

  @override
  String get partnerPhaseLuteal => 'Лютеиновая фаза (ПМС)';

  @override
  String get partnerPhasePill => 'Прием таблеток';

  @override
  String get partnerPeriodExpectedToday => 'Ожидаются месячные сегодня';

  @override
  String partnerNextPeriodInDays(int days) {
    return 'Следующие месячные через ~$days дн.';
  }

  @override
  String get partnerCompanionTitle => 'AI Компаньон';

  @override
  String get partnerCompanionLowMoodTitle => 'Замечено плохое настроение';

  @override
  String get partnerAdviceDefault => 'Поддержите своего партнера сегодня!';

  @override
  String get partnerAdviceMenstruation => 'Уровень энергии может быть низким. Отличное время предложить грелку, заказать ее любимую еду и провести вечер спокойно.';

  @override
  String get partnerAdviceFollicular => 'Уровень эстрогена растет! Вероятно, у нее больше энергии и она настроена на общение. Отличное время для свидания или активного отдыха на природе.';

  @override
  String get partnerAdviceLuteal => 'Прогестерон высокий, что может вызывать усталость или ПМС. Будьте особенно терпеливы, предложите массаж и не принимайте перепады настроения на свой счет.';

  @override
  String get partnerAdviceLowMood => 'Она отметила сегодня плохое настроение. Отправьте милое сообщение или принесите небольшое угощение, чтобы поднять ей настроение! 🍫';

  @override
  String get partnerFertilityTitle => 'Окно Фертильности';

  @override
  String get partnerFertilityHigh => 'Шанс на зачатие сейчас ВЫСОКИЙ. 👶';

  @override
  String get partnerFertilityLow => 'Шанс на зачатие сейчас низкий.';

  @override
  String get partnerSendHug => 'Отправить виртуальное объятие 💖';

  @override
  String get partnerHugSent => 'Объятие отправлено! 💖';

  @override
  String get partnerDisconnectedTitle => 'Соединение разорвано';

  @override
  String get partnerDisconnectedBody => 'Ваш партнер отменил привязку.';

  @override
  String get partnerGoBack => 'Назад';

  @override
  String get partnerSyncTitle => 'Синхронизация партнера';

  @override
  String get partnerSyncInviteTitle => 'Пригласите вашего партнера';

  @override
  String get partnerSyncInviteBody => 'Поделитесь фазой вашего цикла и настроением, чтобы ваш партнер знал, когда вам нужна дополнительная поддержка, шоколад или личное пространство.';

  @override
  String get partnerSyncGenerateCode => 'Сгенерировать код';

  @override
  String get partnerSyncPrivacyFootnote => 'Вы контролируете то, что он видит.';

  @override
  String get partnerSyncConnectedTitle => 'Партнер подключен';

  @override
  String get partnerSyncWaitingTitle => 'Ожидание партнера...';

  @override
  String get partnerSyncConnectedBody => 'Ваше приложение Ayla безопасно синхронизирует данные.';

  @override
  String get partnerSyncWaitingBody => 'Попросите вашего партнера скачать Ayla и ввести этот код при настройке:';

  @override
  String get partnerSyncCodeCopied => 'Код скопирован в буфер обмена!';

  @override
  String get partnerSyncCodeHint => 'Нажмите, чтобы скопировать • Действует 24ч';

  @override
  String get partnerSyncPrivacySettings => 'Настройки приватности';

  @override
  String get partnerSyncShareMoodTitle => 'Делиться настроением и энергией';

  @override
  String get partnerSyncShareMoodBody => 'Партнер будет видеть, устали вы, тревожитесь или счастливы.';

  @override
  String get partnerSyncShareFertilityTitle => 'Делиться окном фертильности';

  @override
  String get partnerSyncShareFertilityBody => 'Партнер получит уведомление, когда шанс зачатия высок.';

  @override
  String get partnerSyncUnlinkTitle => 'Отключить партнера?';

  @override
  String get partnerSyncUnlinkBody => 'Ваш партнер немедленно потеряет доступ к данным вашего цикла.';

  @override
  String get partnerSyncUnlinkAction => 'Отключить';

  @override
  String get partnerSyncUnlinkButton => 'Отключить Партнера';

  @override
  String get partnerSyncAnonymousAuthFailed => 'Не удалось войти анонимно.';

  @override
  String get partnerSyncGenerateCodeFailed => 'Не удалось сгенерировать уникальный код.';

  @override
  String get partnerSyncInviteNoLongerValid => 'Код приглашения больше не действителен.';

  @override
  String get partnerSyncOwnInviteCode => 'Вы не можете подключиться к собственному коду.';

  @override
  String get partnerSyncInviteAlreadyUsed => 'Этот код приглашения уже использован.';

  @override
  String get partnerSyncNotLinked => 'Не привязано ни к одной паре.';

  @override
  String get chatTitle => 'Ayla AI';

  @override
  String get chatStatusOnline => 'В сети • Ваш Интеллект Цикла';

  @override
  String get chatEmptyTitle => 'Привет, я Ayla!';

  @override
  String get chatEmptyBody => 'Я анализирую ваш цикл, записи и симптомы в реальном времени. Спросите меня о вашем самочувствии, гормонах или фертильности.';

  @override
  String get chatTyping => 'Ayla печатает...';

  @override
  String get chatInputHint => 'Спросить Ayla...';

  @override
  String get chatConnectionIssue => 'Возникли проблемы с соединением. Пожалуйста, проверьте интернет или попробуйте позже. 💜';

  @override
  String get aiSecurityTokenMissing => 'Отсутствует токен безопасности в конфигурации облака.';

  @override
  String get aiTokenLoadFailed => 'Не удалось загрузить безопасный токен из облака.';

  @override
  String get aiNoSymptomsLoggedToday => 'Сегодня не отмечено физических симптомов.';

  @override
  String aiDailyAdvicePrompt(String phase, String isCoc, String symptoms) {
    return 'You are Ayla, an empathetic and highly professional Cycle Intelligence Assistant and women\'s wellness guide.\nAnalyze the user\'s current state and explain why they might be feeling this way based on their cycle.\nAlways remind the user to consult a healthcare provider for any medical concerns.\n\nContext:\n- Current cycle phase: $phase\n- Contraceptive pill user: $isCoc\n- Today\'s symptoms and moods: $symptoms\n\nTask:\nProvide a short, comforting, and scientifically accurate explanation (2 to 4 sentences max) of how their current hormonal profile is likely causing these specific symptoms.\n\nCritical instruction:\nRespond in raw plain text only.\nDo not use JSON.\nDo not wrap the response in braces.\nDo not use Markdown.\nJust write the sentences directly.';
  }

  @override
  String aiProxyHttpError(int statusCode) {
    return 'Ошибка прокси: HTTP $statusCode';
  }

  @override
  String get aiNoCandidatesReturned => 'Кандидаты не получены.';

  @override
  String get aiNoTextPartsReturned => 'Текстовые блоки не получены.';

  @override
  String get aiGeneratedTextEmpty => 'Сгенерированный текст пуст.';

  @override
  String get aiRefreshRateLimit => 'Пожалуйста, подождите минуту перед обновлением.';

  @override
  String aiDailyInsightContext(int totalCycles, int totalLogs, String date) {
    return 'Ayla app user.\nRecorded cycles: $totalCycles.\nRecorded symptom days: $totalLogs.\nCurrent date: $date.';
  }

  @override
  String aiDailyInsightPrompt(String context, String titleKey, String bodyKey, String typeKey, String neutralType, String positiveType, String warningType) {
    return 'You are the women\'s health AI assistant (Cycle Intelligence Assistant) in the Ayla app.\nAnalyze the user context and provide one short insight or advice for today.\nIf there is little data available (for example, 0 cycles), greet the user and suggest starting the journal.\n\nContext: $context\n\nReturn the answer strictly as valid JSON with three keys:\n\"$titleKey\": A short title (up to 3 or 4 words in English, for example \"Rest & Reset\").\n\"$bodyKey\": One or two sentences with advice or analysis (in English).\n\"$typeKey\": One of these exact values only ($neutralType, $positiveType, $warningType).';
  }

  @override
  String get aiRequestTimeout => 'Время ожидания истекло.';

  @override
  String get aiProxyInvalidJson => 'Прокси вернул неверный JSON.';

  @override
  String get aiGeneratedNoTextParts => 'ИИ не сгенерировал текстовых блоков.';

  @override
  String get aiGeneratedTextCompletelyEmpty => 'Сгенерированный текст полностью пуст.';

  @override
  String get aiInvalidJsonObject => 'ИИ не вернул валидный JSON-объект.';

  @override
  String aiJsonFormatError(String error) {
    return 'Ошибка формата JSON от ИИ: $error';
  }

  @override
  String aiMoodLabel(String mood) {
    return 'Настроение: $mood';
  }

  @override
  String aiChatContext(String phase, int day, String isCoc) {
    return 'User context: Phase: $phase, Day: $day, COC user: $isCoc.';
  }

  @override
  String aiChatSymptomsToday(String symptoms) {
    return 'Symptoms today: $symptoms.';
  }

  @override
  String aiChatSystemPrompt(String context) {
    return 'You are Ayla, an empathetic, highly professional Cycle Intelligence Assistant and women\'s wellness guide.\nYou are chatting directly with the user. Keep responses warm, concise, and scientifically accurate.\nYou are not a doctor. Do not give dangerous medical diagnoses. Always remind the user to consult a healthcare provider for any serious or concerning medical symptoms.\n$context';
  }

  @override
  String get aiChatRoleUser => 'User';

  @override
  String get aiChatRoleAyla => 'Ayla';

  @override
  String aiChatHttpError(int statusCode) {
    return 'Ошибка чата: HTTP $statusCode';
  }

  @override
  String get aiChatNoCandidates => 'Кандидаты отсутствуют.';

  @override
  String get aiChatNoTextParts => 'Текстовые блоки отсутствуют.';

  @override
  String get aiDailyInsightTitle => 'Ежедневный инсайт';

  @override
  String get aiDailyInsightBody => 'Слушайте свое тело сегодня.';

  @override
  String get notifAylaInsightTitle => 'Инсайт от Ayla ✨';

  @override
  String get homeBrandWordmark => 'A Y L A';

  @override
  String homeCocDayOfTotal(int current, int total) {
    return 'День $current из $total';
  }

  @override
  String get medicationsLoading => 'Загрузка препаратов...';

  @override
  String get medicationsTitle => 'Лекарства и Витамины';

  @override
  String get medicationsEmptyBody => 'Добавьте ежедневные препараты или витамины для отслеживания их приема.';

  @override
  String get medicationsAdd => 'Добавить лекарство';

  @override
  String get medicationsDailyIntake => 'Прием за сегодня';

  @override
  String get medicationsManage => 'Управление';

  @override
  String get medicationsProgressNone => 'Ничего не отмечено';

  @override
  String get medicationsProgressAll => 'Все препараты приняты на сегодня';

  @override
  String medicationsProgressSome(int taken, int total) {
    return '$taken из $total принято сегодня';
  }

  @override
  String get medicationsTakenBadge => 'Выпито';

  @override
  String get medicationsManageTitle => 'Управление лекарствами';

  @override
  String get medicationsManageBody => 'Добавляйте, удаляйте и настраивайте лекарства, которые хотите отслеживать каждый день.';

  @override
  String get medicationsCurrent => 'Текущие лекарства';

  @override
  String get medicationsAddNew => 'Добавить новое лекарство';

  @override
  String get medicationsNameLabel => 'Название препарата';

  @override
  String get medicationsNameHint => 'Железо, Витамин D, Омега-3...';

  @override
  String get medicationsDosageLabel => 'Дозировка';

  @override
  String get medicationsDosageHint => '500мг, 1 таб, 2 капли...';

  @override
  String get medicationsAddButton => 'Добавить Лекарство';

  @override
  String get paywallTitle => 'EviMoon Premium';

  @override
  String get paywallSubtitle => 'Раскройте весь потенциал вашего цикла.';

  @override
  String get featureTimersTitle => 'Премиум дизайн таймеров';

  @override
  String get featureTimersDesc => 'Уникальные стили для главного экрана';

  @override
  String get featurePdfTitle => 'Медицинский PDF отчет';

  @override
  String get featurePdfDesc => 'Поделитесь историей симптомов с врачом';

  @override
  String get featureAiTitle => 'Точность ИИ прогнозов';

  @override
  String get featureAiDesc => 'Узнайте, насколько точен ваш прогноз';

  @override
  String get featureTtcTitle => 'Режим планирования беременности';

  @override
  String get featureTtcDesc => 'Специальные инструменты для зачатия';

  @override
  String get paywallNoOffers => 'Нет доступных предложений';

  @override
  String get paywallSelectPlan => 'Выберите тариф';

  @override
  String paywallSubscribeFor(String price) {
    return 'Оформить подписку за $price';
  }

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallTerms => 'Условия и Конфиденциальность';

  @override
  String get paywallBestValue => 'ЛУЧШАЯ ЦЕНА';

  @override
  String get msgNoSubscriptions => 'Активные подписки не найдены';

  @override
  String get proStatusTitle => 'Статус подписки';

  @override
  String get proStatusActive => 'Премиум Активен';

  @override
  String get proStatusDesc => 'У вас есть полный доступ ко всем функциям.';

  @override
  String get btnManageSub => 'Управление подпиской';

  @override
  String get btnManageSubDesc => 'Сменить тариф или отменить в настройках iOS';

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
  String get phaseWaxingCrescent => 'Растущий месяц';

  @override
  String get phaseFirstQuarter => 'Первая четверть';

  @override
  String get phaseFullMoon => 'Полнолуние';

  @override
  String get phaseWaningGibbous => 'Убывающая луна';

  @override
  String get phaseWaningCrescent => 'Убывающий месяц';

  @override
  String get lblTest => 'Тест ЛГ';

  @override
  String get lblSex => 'Близость';

  @override
  String get lblMucus => 'Слизь';

  @override
  String valMeasured(double temp) {
    return '$temp°';
  }

  @override
  String get valMucusLogged => 'Отмечено';

  @override
  String get titleInputBBT => 'Температура (БТТ)';

  @override
  String get titleInputTest => 'Результат теста на ЛГ';

  @override
  String get titleInputSex => 'Детали близости';

  @override
  String get titleInputMucus => 'Цервикальная слизь';

  @override
  String get mucusDry => 'Сухая';

  @override
  String get mucusSticky => 'Липкая';

  @override
  String get mucusCreamy => 'Кремовая';

  @override
  String get mucusWatery => 'Водянистая';

  @override
  String get mucusEggWhite => 'Яичный белок';

  @override
  String get ttcChartTitle => 'ГРАФИК БТТ (14 ДНЕЙ)';

  @override
  String get ttcChartPlaceholder => 'Отмечайте температуру для графика';

  @override
  String get hintTemp => '36.6';

  @override
  String get designSelectorTitle => 'Стиль таймера';

  @override
  String get designClassic => 'Классика';

  @override
  String get designMinimal => 'Минимализм';

  @override
  String get designLunar => 'Лунный';

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
  String get ttcTimelineTitle => 'Таймлайн';

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
  String get ttcAllDone => 'Всё выполнено ✓';

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
    return 'ДПО $dpo • БТТ $bbt • ЛГ $lh';
  }

  @override
  String ttcCtaTestWaitBody(int dpo, int days) {
    return 'ДПО $dpo • ~$days дн. до надежного теста';
  }

  @override
  String get ttcCtaPeakBody => 'Сегодня/завтра будет пик. Отмечайте близость и ЛГ для точности.';

  @override
  String ttcCtaHighBody(int days) {
    return 'Окно фертильности открыто • пик через ~$days дн.';
  }

  @override
  String get ttcCtaMenstruationBody => 'Бережный режим: сон, вода, тепло. Ведение журнала по желанию — но БТТ поможет.';

  @override
  String ttcCtaLowBody(String status) {
    return 'День подготовки • $status';
  }

  @override
  String get ttcDash => '—';

  @override
  String get eduTitleBBT => 'Зачем измерять БТТ?';

  @override
  String get eduBodyBBT => 'Базальная температура тела (БТТ) немного повышается после овуляции из-за выработки прогестерона. Ее отслеживание подтверждает, что овуляция действительно произошла.';

  @override
  String get eduTitleLH => 'Зачем тесты на овуляцию?';

  @override
  String get eduBodyLH => 'Лютеинизирующий гормон (ЛГ) резко возрастает за 24-48 часов до овуляции. Положительный тест предсказывает ваши самые фертильные дни до выхода яйцеклетки.';

  @override
  String get eduTiteSex => 'Logging Intimacy';

  @override
  String get eduBodySex => 'Сперматозоиды могут выживать в теле до 5 дней. Отслеживание помогает убедиться, что близость попадает в окно фертильности для максимального шанса зачатия.';

  @override
  String get eduTitleMucus => 'Цервикальная слизь';

  @override
  String get eduBodyMucus => 'По мере приближения овуляции эстроген делает выделения тягучими и прозрачными (как яичный белок). Это идеальная среда для выживания сперматозоидов.';
}
