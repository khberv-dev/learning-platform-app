// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get languageTitle => 'Выберите язык';

  @override
  String get languageSubtitle => 'Позже его можно изменить в профиле';

  @override
  String get languageContinue => 'Продолжить';

  @override
  String get languageSettingsTitle => 'Язык';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonResume => 'Далее';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonOk => 'ОК';

  @override
  String get commonJoin => 'Войти';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get commonSomethingWentWrong =>
      'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get authUsePhone => 'Телефон';

  @override
  String get authUseEmail => 'Email';

  @override
  String get fieldEmail => 'Электронная почта';

  @override
  String get validationEmail => 'Введите корректный email';

  @override
  String get commonOpenOutsideApp => 'Открыть вне приложения';

  @override
  String get commonShowPassword => 'Показать пароль';

  @override
  String get commonHidePassword => 'Скрыть пароль';

  @override
  String commonRatingOutOf(String rating, int count) {
    return '$rating из $count';
  }

  @override
  String get splashWelcome => 'Добро пожаловать в iTeach!';

  @override
  String get onboardingHeadlineLead => 'Учите ';

  @override
  String get onboardingHeadlineHighlight => 'английский';

  @override
  String get onboardingHeadlineTail => '\nбыстрее, чем когда-либо';

  @override
  String get onboardingFreshStart => 'Начать с нуля';

  @override
  String get onboardingResume => 'Продолжить путь';

  @override
  String get welcomeTitle => 'Добро пожаловать в iTeach';

  @override
  String get welcomeSubtitle =>
      'Ваш персональный путь\nк английскому начинается здесь';

  @override
  String get welcomeGetStarted => 'Начать';

  @override
  String get welcomeSignIn => 'Войти';

  @override
  String get noConnectionTitle => 'Нет соединения';

  @override
  String get noConnectionMessage =>
      'Не удалось связаться с сервером.\nПроверьте подключение и попробуйте снова.';

  @override
  String get noConnectionRetry => 'Повторить';

  @override
  String get surveyReasonTitle => 'Зачем вы учите английский?';

  @override
  String get surveyReasonDescription =>
      'Выберите то, что подходит больше всего';

  @override
  String get surveyReasonCareer => 'Карьера';

  @override
  String get surveyReasonTravel => 'Путешествия';

  @override
  String get surveyReasonAcademic => 'Учёба';

  @override
  String get surveyReasonPersonal => 'Для себя';

  @override
  String get surveyReasonImmigration => 'Переезд';

  @override
  String get surveyTimeTitle => 'Сколько времени готовы уделять в день?';

  @override
  String get surveyTimeDescription => 'Мы составим график под ваш ритм жизни';

  @override
  String get surveyTime5 => '5 минут';

  @override
  String get surveyTime15 => '15 минут';

  @override
  String get surveyTime30 => '30 минут';

  @override
  String get surveyTime60 => '1+ час';

  @override
  String get levelCheckTitle => 'Вы уже немного знаете английский?';

  @override
  String get levelCheckDescription =>
      'Если вы учили раньше, короткий тест определит ваш уровень';

  @override
  String get levelCheckYes => 'Да, я уже учил английский';

  @override
  String get levelCheckNo => 'Нет, я начинаю с нуля';

  @override
  String get navHome => 'Главная';

  @override
  String get navCourse => 'Курсы';

  @override
  String get navChat => 'Чат';

  @override
  String get navMentor => 'Ментор';

  @override
  String get navProfile => 'Профиль';

  @override
  String get levelBeginner => 'Начальный';

  @override
  String get levelIntermediate => 'Средний';

  @override
  String get levelAdvanced => 'Продвинутый';

  @override
  String get homeOnFire => 'Вы в ударе';

  @override
  String homeStreakDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString дня',
      many: '$countString дней',
      few: '$countString дня',
      one: '$countString день',
    );
    return '$_temp0';
  }

  @override
  String get homeDontForgetMe => 'Не забывайте про меня!';

  @override
  String get homeStatsScores => 'Баллы';

  @override
  String get homeStatsCoins => 'Монеты';

  @override
  String get homeStatsRanking => 'Место в рейтинге';

  @override
  String get homeLibrary => 'Библиотека';

  @override
  String get homeNoCoursesTitle => 'Пока нет активных курсов';

  @override
  String get homeNoCoursesSubtitle => 'Выберите курс и начните учиться';

  @override
  String get homeNoCoursesButton => 'Начать практику';

  @override
  String get homeProgress => 'Прогресс';

  @override
  String get homeResume => 'Продолжить';

  @override
  String get homeLiveLessons => 'Живые уроки';

  @override
  String get homeLiveNow => 'СЕЙЧАС В ЭФИРЕ';

  @override
  String get homeUpcoming => 'СКОРО';

  @override
  String get homeJoinLesson => 'Присоединиться';

  @override
  String get homeMoreUpcoming => 'Другие ближайшие уроки';

  @override
  String get homeNoUpcomingLessons => 'Нет ближайших уроков';

  @override
  String get homeAiTestTitle => 'Проверьте себя с ИИ';

  @override
  String get homeAiTestBody =>
      'Говорите свободно, а ИИ оценит ваш уровень — полный отчёт за считаные минуты';

  @override
  String get homeAiTestButton => 'Начать тест';

  @override
  String get homeSpeakingTitle => 'Найдите собеседника';

  @override
  String get homeSpeakingBody =>
      'Мы подберём человека вашего уровня. Практикуйте живое общение';

  @override
  String get homeSpeakingButton => 'Найти собеседника';

  @override
  String get coursesTitle => 'Курсы';

  @override
  String get coursesTabCourses => 'Курсы';

  @override
  String get coursesTabLive => 'Живые уроки';

  @override
  String get coursesRoadmap => 'Маршрут';

  @override
  String get coursesMyCourses => 'Мои курсы';

  @override
  String get coursesAvailable => 'Доступны для покупки';

  @override
  String get coursesNoneAvailable => 'Курсов пока нет.';

  @override
  String get coursesCurrentUpcoming => 'Текущие и ближайшие';

  @override
  String get coursesPastSessions => 'Прошедшие уроки';

  @override
  String coursesRecordedCount(int count) {
    return '$count в записи';
  }

  @override
  String get coursesNoRecordedTitle => 'Нет записей';

  @override
  String get coursesNoRecordedSubtitle =>
      'Записи живых уроков появятся\nздесь, когда будут готовы';

  @override
  String get courseUnits => 'Разделы';

  @override
  String courseLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count урока',
      many: '$count уроков',
      few: '$count урока',
      one: '$count урок',
    );
    return '$_temp0';
  }

  @override
  String get courseChoosePlan => 'Выбрать тариф';

  @override
  String get courseExpired => 'Истёк';

  @override
  String get courseProgress => 'Прогресс';

  @override
  String get courseLearnMore => 'Подробнее';

  @override
  String get courseRecordedSession => 'ЗАПИСЬ УРОКА';

  @override
  String get courseRecorded => 'ЗАПИСЬ';

  @override
  String unitNumber(String number) {
    return 'Раздел $number';
  }

  @override
  String get unitNoLessonsTitle => 'Пока нет уроков';

  @override
  String get unitNoLessonsSubtitle => 'Уроки этого раздела появятся здесь.';

  @override
  String get unitNotFound => 'Раздел не найден';

  @override
  String lessonUnitLesson(String unit, String lesson) {
    return 'Раздел $unit · Урок $lesson';
  }

  @override
  String lessonUnitLessonOf(String unit, String lesson, int total) {
    return 'Раздел $unit · Урок $lesson из $total';
  }

  @override
  String get lessonViewTasks => 'К заданиям';

  @override
  String get lessonTasksCompleted => 'Задания выполнены';

  @override
  String get lessonTasksInProgress => 'Задания в процессе';

  @override
  String lessonScore(int correct, int total, int percent) {
    return '$correct из $total верно · $percent%';
  }

  @override
  String get lessonRetake => 'Пройти заново';

  @override
  String get lessonInThisUnit => 'В этом разделе';

  @override
  String get lessonNoContent => 'Нет контента';

  @override
  String get materialsTitle => 'Материалы';

  @override
  String materialsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String get materialsLoadFailed => 'Не удалось загрузить материалы';

  @override
  String get materialsOpenFailed => 'Не удалось открыть файл';

  @override
  String get purchaseSuccessTitle => 'Готово!';

  @override
  String purchaseSuccessBody(String course) {
    return 'Курс «$course» теперь ваш. Пора учиться.';
  }

  @override
  String get purchaseSuccessButton => 'Начать учиться';

  @override
  String get tasksTitle => 'Задания';

  @override
  String taskProgress(int current, int total) {
    return 'Задание $current из $total';
  }

  @override
  String get taskFallbackName => 'Задание';

  @override
  String get taskAnswerHint => 'Введите ответ…';

  @override
  String get taskSubmit => 'Отправить';

  @override
  String get taskNext => 'Далее';

  @override
  String get tasksEmptyTitle => 'Пока нет заданий';

  @override
  String get tasksEmptySubtitle => 'Задания к этому уроку появятся здесь.';

  @override
  String get taskAudioError => 'Не удалось воспроизвести аудио';

  @override
  String get taskImageError => 'Не удалось загрузить изображение';

  @override
  String pdfPageOf(int current, int total) {
    return 'Страница $current из $total';
  }

  @override
  String get pdfLoadFailed => 'Не удалось открыть PDF';

  @override
  String get pdfLoadFailedHint => 'Файл повреждён или связь прервалась.';

  @override
  String get imageLoadFailed => 'Не удалось загрузить изображение';

  @override
  String get loginTitle => 'С возвращением';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginSubmit => 'Войти';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get registerSubmit => 'Создать аккаунт';

  @override
  String get registerLegalLead => 'Создавая аккаунт, вы принимаете\n';

  @override
  String get registerLegalTerms => 'Условия использования';

  @override
  String get registerLegalAnd => ' и ';

  @override
  String get registerLegalPrivacy => 'Политику конфиденциальности';

  @override
  String get forgotTitle => 'Сброс пароля';

  @override
  String get forgotSubtitle => 'Введите номер телефона и новый пароль';

  @override
  String get forgotSubmit => 'Отправить код';

  @override
  String get fieldPhone => 'Номер телефона';

  @override
  String get fieldPassword => 'Пароль';

  @override
  String get fieldNewPassword => 'Новый пароль';

  @override
  String get fieldConfirmPassword => 'Повторите пароль';

  @override
  String get fieldFullName => 'Имя и фамилия';

  @override
  String get validationPhone => 'Введите корректный номер телефона';

  @override
  String get validationPassword => 'Пароль должен быть не короче 8 символов';

  @override
  String get validationPasswordsMatch => 'Пароли не совпадают';

  @override
  String get validationFullName => 'Введите имя и фамилию';

  @override
  String get otpTitle => 'Подтвердите\nномер телефона';

  @override
  String otpSubtitle(String phone) {
    return 'Мы отправили 6-значный код на $phone';
  }

  @override
  String get otpEmailTitle => 'Подтвердите адрес\nэлектронной почты';

  @override
  String otpEmailSubtitle(String email) {
    return 'Мы отправили 6-значный код на email $email';
  }

  @override
  String otpResendIn(int seconds) {
    return 'Отправить код повторно через $seconds с';
  }

  @override
  String get otpResend => 'Отправить код ещё раз';

  @override
  String get otpPasswordUpdated => 'Пароль успешно обновлён';

  @override
  String get profilePhone => 'Номер телефона';

  @override
  String get profileEmail => 'Электронная почта';

  @override
  String get profilePassword => 'Пароль';

  @override
  String get profileUpdatePassword => 'Изменить пароль';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsAppVersion => 'Версия приложения';

  @override
  String get settingsLogOut => 'Выйти';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsLogOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get settingsDeleteConfirm =>
      'Удалить аккаунт? Ваши курсы и прогресс будут стёрты без возможности восстановления.';

  @override
  String get settingsDeleteRequestedTitle => 'Запрос отправлен';

  @override
  String get settingsDeleteRequestedBody =>
      'Запрос на удаление аккаунта отправлен. Вы можете пользоваться приложением, пока он обрабатывается.';

  @override
  String get chatMentor => 'Ментор';

  @override
  String get chatFile => 'Файл';

  @override
  String get chatHint => 'Введите сообщение…';

  @override
  String get chatEmptyTitle => 'Сообщений пока нет';

  @override
  String get chatEmptySubtitle => 'Напишите первым, чтобы начать разговор.';

  @override
  String get tutorsTitle => 'Найти репетитора';

  @override
  String get tutorsLoadFailed => 'Не удалось загрузить репетиторов';

  @override
  String get tutorsPullToRetry => 'Потяните вниз, чтобы повторить';

  @override
  String get tutorsEmptyTitle => 'Репетиторов пока нет';

  @override
  String get tutorsEmptySubtitle =>
      'Они появятся здесь, как только присоединятся';

  @override
  String get tutorsAvailable => 'Доступные репетиторы';

  @override
  String get tutorHeader => 'Репетитор';

  @override
  String get tutorReviewsTitle => 'Отзывы студентов';

  @override
  String get tutorNoReviews => 'Отзывов пока нет';

  @override
  String get tutorBook => 'Записаться';

  @override
  String get tutorBookingSent => 'Заявка отправлена';

  @override
  String tutorRatingReviews(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзыва',
      many: '$count отзывов',
      few: '$count отзыва',
      one: '$count отзыв',
    );
    return '$rating  ·  $_temp0';
  }

  @override
  String get bookTitle => 'Выберите расписание';

  @override
  String bookSubtitle(String name) {
    return 'Выберите до 3 занятий в неделю с $name';
  }

  @override
  String get bookLoadFailed => 'Не удалось загрузить расписание';

  @override
  String get bookNoAvailability =>
      'Репетитор ещё не указал свободное время.\nВы всё равно можете отправить заявку.';

  @override
  String bookSlotsSelected(int count) {
    return 'Выбрано $count/3';
  }

  @override
  String get bookConfirm => 'Подтвердить запись';

  @override
  String get weekdayMonday => 'Понедельник';

  @override
  String get weekdayTuesday => 'Вторник';

  @override
  String get weekdayWednesday => 'Среда';

  @override
  String get weekdayThursday => 'Четверг';

  @override
  String get weekdayFriday => 'Пятница';

  @override
  String get weekdaySaturday => 'Суббота';

  @override
  String get weekdaySunday => 'Воскресенье';

  @override
  String get plansTitle => 'Выберите тариф';

  @override
  String get plansLoadFailed => 'Не удалось загрузить тарифы';

  @override
  String get plansEmptyTitle => 'Тарифов пока нет';

  @override
  String get plansEmptySubtitle => 'Этот курс сейчас не продаётся';

  @override
  String plansDuration(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцев',
      few: '$count месяца',
      one: '$count месяц',
    );
    return '$_temp0';
  }

  @override
  String plansPrice(String amount) {
    return '$amount сум';
  }

  @override
  String get plansWithMentor => 'С ментором';

  @override
  String get paymentTitle => 'Способ оплаты';

  @override
  String get paymentLoadFailed => 'Не удалось начать оплату';

  @override
  String get paymentEmptyTitle => 'Нет способов оплаты';

  @override
  String get paymentEmptySubtitle => 'Пока ни один не настроен';

  @override
  String paymentNoLink(String type) {
    return 'У «$type» пока нет ссылки на оплату';
  }

  @override
  String paymentOpenFailed(String type) {
    return 'Не удалось открыть «$type»';
  }

  @override
  String get aiTitle => 'ИИ-оценка';

  @override
  String get aiInitialPrompt => 'Скажите что угодно — просто начните говорить!';

  @override
  String get aiMicDenied => 'Нет доступа к микрофону';

  @override
  String get aiRecordFailed => 'Не удалось записать';

  @override
  String get aiUploadFailed =>
      'Не удалось отправить. Нажмите, чтобы повторить.';

  @override
  String get aiUploading => 'Отправка…';

  @override
  String get aiPlayingFeedback => 'Воспроизведение отзыва…';

  @override
  String get aiTapToStop => 'Нажмите, чтобы остановить';

  @override
  String get aiTapToSpeak => 'Нажмите и говорите';

  @override
  String get aiListening => 'Слушаю…';

  @override
  String get aiResultsTitle => 'Результаты';

  @override
  String get aiSkillGrammar => 'Грамматика';

  @override
  String get aiSkillVocabulary => 'Словарный запас';

  @override
  String get aiSkillFluency => 'Беглость';

  @override
  String get aiSkillPronunciation => 'Произношение';

  @override
  String get aiSkillBreakdown => 'Разбор по навыкам';

  @override
  String get aiSummary =>
      'У вас уверенная грамматика уровня B2 и профессиональная лексика. Поработайте над беглостью и произношением, чтобы дойти до C1.';

  @override
  String get aiStartLearning => 'Начать персональное обучение';

  @override
  String get aiYourLevel => 'Ваш уровень английского';

  @override
  String aiBasedOnResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'На основе $count ответов в диалоге',
      many: 'На основе $count ответов в диалоге',
      few: 'На основе $count ответов в диалоге',
      one: 'На основе $count ответа в диалоге',
    );
    return '$_temp0';
  }

  @override
  String aiImprovedFrom(String level) {
    return '↑ Рост с уровня $level';
  }

  @override
  String get p2pTitle => 'Собеседник';

  @override
  String get p2pFinding => 'Ищем собеседника…';

  @override
  String get p2pLookingSubtitle => 'Подбираем человека вашего уровня';

  @override
  String get p2pConnecting => 'Соединение…';

  @override
  String get p2pMatched => 'Найден';

  @override
  String get p2pConnected => 'На связи';

  @override
  String get p2pMute => 'Выключить микрофон';

  @override
  String get p2pUnmute => 'Включить микрофон';

  @override
  String get p2pEnd => 'Завершить';

  @override
  String get p2pEndedCall => 'Звонок завершён';

  @override
  String get p2pPeerLeft => 'Собеседник вышел из звонка';

  @override
  String get p2pPeerDisconnected => 'Собеседник отключился';

  @override
  String get p2pCancelled => 'Звонок отменён';

  @override
  String get p2pReplaced => 'Сессия заменена другим подключением';

  @override
  String get p2pError => 'Ошибка звонка';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmptyTitle => 'Уведомлений пока нет';

  @override
  String get notificationsEmptySubtitle => 'Вы всё просмотрели!';

  @override
  String get roadmapLevelA1 => 'Начальный';

  @override
  String get roadmapLevelA2 => 'Элементарный';

  @override
  String get roadmapLevelB1 => 'Средний';

  @override
  String get roadmapLevelB2 => 'Выше среднего';

  @override
  String get roadmapLevelC1 => 'Продвинутый';

  @override
  String get roadmapLevelC2 => 'Владение в совершенстве';

  @override
  String get roadmapTopicGreetings => 'Приветствия';

  @override
  String get roadmapTopicNumbersDates => 'Числа и даты';

  @override
  String get roadmapTopicColorsObjects => 'Цвета и предметы';

  @override
  String get roadmapTopicFamily => 'Семья';

  @override
  String get roadmapTopicFoodDrinks => 'Еда и напитки';

  @override
  String get roadmapTopicDailyRoutines => 'Распорядок дня';

  @override
  String get roadmapTopicShopping => 'Покупки';

  @override
  String get roadmapTopicTravelTransport => 'Путешествия и транспорт';

  @override
  String get roadmapTopicWeatherSeasons => 'Погода и времена года';

  @override
  String get roadmapTopicHomeFurniture => 'Дом и мебель';

  @override
  String get roadmapTopicHobbies => 'Хобби и интересы';

  @override
  String get roadmapTopicHealthBody => 'Здоровье и тело';

  @override
  String get roadmapTopicWorkCareers => 'Работа и карьера';

  @override
  String get roadmapTopicCurrentEvents => 'Новости и события';

  @override
  String get roadmapTopicFuturePlans => 'Планы на будущее';

  @override
  String get roadmapTopicPastExperiences => 'Прошлый опыт';

  @override
  String get roadmapTopicOpinionsFeelings => 'Мнения и чувства';

  @override
  String get roadmapTopicTourismCulture => 'Туризм и культура';

  @override
  String get roadmapTopicDebates => 'Споры и аргументы';

  @override
  String get roadmapTopicSocialIssues => 'Социальные вопросы';

  @override
  String get roadmapTopicBusinessEnglish => 'Деловой английский';

  @override
  String get roadmapTopicMedia => 'СМИ и развлечения';

  @override
  String get roadmapTopicEnvironment => 'Экология';

  @override
  String get roadmapTopicAcademicWriting => 'Академическое письмо';

  @override
  String get roadmapTopicAcademicDiscourse => 'Академическая речь';

  @override
  String get roadmapTopicProfessionalComms => 'Деловое общение';

  @override
  String get roadmapTopicIdioms => 'Идиомы и выражения';

  @override
  String get roadmapTopicLiterature => 'Литература и искусство';

  @override
  String get roadmapTopicCriticalAnalysis => 'Критический анализ';

  @override
  String get roadmapTopicNegotiations => 'Сложные переговоры';

  @override
  String get roadmapTopicNativeFluency => 'Речь как у носителя';

  @override
  String get roadmapTopicSpecializedVocab => 'Специальная лексика';

  @override
  String get roadmapTopicCulturalReferences => 'Культурные отсылки';

  @override
  String get roadmapTopicRhetoric => 'Продвинутая риторика';

  @override
  String get roadmapTopicCreativeWriting => 'Творческое письмо';

  @override
  String get roadmapTopicPresentations => 'Экспертные презентации';
}
