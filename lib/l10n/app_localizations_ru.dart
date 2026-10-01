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
  String get commonContinue => 'Продолжить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonResume => 'Далее';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get commonSomethingWentWrong =>
      'Что-то пошло не так. Попробуйте ещё раз.';

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
  String get onboardingHeadlineTail => ' быстрее, чем когда-либо';

  @override
  String get onboardingSubtitle =>
      'Определите свой уровень — мы составим подходящий план обучения';

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
  String get navStudy => 'Обучение';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navMission => 'Миссия';

  @override
  String get homeGreeting => 'Добрый день,';

  @override
  String homeGreetingName(String name) {
    return '$name!';
  }

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
  String get homeStreakStartTitle => 'Начните серию';

  @override
  String get homeStreakStartSubtitle =>
      'Пройдите первый урок, чтобы зажечь серию';

  @override
  String get homeStatsScores => 'Баллы';

  @override
  String get homeStatsCoins => 'Монеты';

  @override
  String get homeAiPartnerTitle => 'ИИ-собеседник';

  @override
  String get homeAiPartnerBody => 'Живой разговор с ИИ';

  @override
  String get homeAiPartnerAction => 'Начать разговор';

  @override
  String get homePartnerTitle => 'Собеседник';

  @override
  String get homePartnerBody => 'Живой разговор с собеседником';

  @override
  String get homePartnerAction => 'Найти собеседника';

  @override
  String get homeResume => 'Продолжить';

  @override
  String get coursesTitle => 'Курсы';

  @override
  String get coursesSearchHint => 'Поиск...';

  @override
  String get coursesShowLess => 'Свернуть';

  @override
  String get coursesNoResults => 'Курсы не найдены';

  @override
  String get coursesMyCourses => 'Текущие курсы';

  @override
  String get coursesAvailable => 'Доступные курсы';

  @override
  String get coursesNoneAvailable => 'Курсов пока нет.';

  @override
  String get courseUnits => 'Модули';

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
  String courseModuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count модуля',
      many: '$count модулей',
      few: '$count модуля',
      one: '$count модуль',
    );
    return '$_temp0';
  }

  @override
  String courseHourCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа',
      many: '$count часов',
      few: '$count часа',
      one: '$count час',
    );
    return '$_temp0';
  }

  @override
  String get courseAbout => 'О курсе';

  @override
  String get courseTeacher => 'Преподаватель';

  @override
  String get courseOtherCourses => 'Другие курсы';

  @override
  String get courseSeeAll => 'Все';

  @override
  String get courseNotEnrolledTitle => 'Вы не записаны на этот курс';

  @override
  String get courseNotEnrolledMessage =>
      'Купите тариф, чтобы открыть его уроки.';

  @override
  String get courseChoosePlan => 'Купить тариф';

  @override
  String get unitNoLessonsTitle => 'Пока нет уроков';

  @override
  String get lessonUnitLessons => 'Уроки';

  @override
  String get lessonGoToTest => 'Перейти к тесту';

  @override
  String get lessonNoContent => 'Нет контента';

  @override
  String get lessonVideoPlay => 'Воспроизвести';

  @override
  String get lessonVideoPause => 'Пауза';

  @override
  String get lessonVideoRewind => 'Назад на 15 секунд';

  @override
  String get lessonVideoForward => 'Вперёд на 15 секунд';

  @override
  String get lessonVideoMute => 'Выключить звук';

  @override
  String get lessonVideoUnmute => 'Включить звук';

  @override
  String get lessonVideoFullscreen => 'Полноэкранный режим';

  @override
  String get lessonVideoExitFullscreen => 'Выйти из полноэкранного режима';

  @override
  String get lessonVideoSpeed => 'Скорость воспроизведения';

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
  String get taskResultsTitle => 'Результаты';

  @override
  String taskResultsSummary(int correct, int total) {
    return '$correct из $total правильно';
  }

  @override
  String taskResultsCoinsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count монеты',
      many: '+$count монет',
      few: '+$count монеты',
      one: '+$count монета',
    );
    return '$_temp0';
  }

  @override
  String get taskResultsCorrect => 'Верно';

  @override
  String get taskResultsIncorrect => 'Неверно';

  @override
  String taskResultsYourAnswer(String answer) {
    return 'Ваш ответ: $answer';
  }

  @override
  String get taskResultsNoAnswer => 'Нет ответа';

  @override
  String get taskResultsDone => 'Готово';

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
  String get loginTitle => 'Вход';

  @override
  String get loginSubtitlePhone =>
      'Введите номер телефона, чтобы войти в аккаунт';

  @override
  String get loginSubtitleEmail => 'Введите email, чтобы войти в аккаунт';

  @override
  String get loginTabPhone => 'По телефону';

  @override
  String get loginTabEmail => 'По email';

  @override
  String get loginOr => 'или';

  @override
  String get loginTelegram => 'Войти через Telegram';

  @override
  String get loginTelegramUnavailable => 'Вход через Telegram пока недоступен';

  @override
  String get loginLegalLead => 'Продолжая, вы соглашаетесь с условиями ';

  @override
  String get loginLegalOffer => 'публичной оферты';

  @override
  String get loginLegalTail => '.';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginPasswordHint => 'Введите пароль';

  @override
  String get loginSubmit => 'Войти';

  @override
  String get registerSubmit => 'Зарегистрироваться';

  @override
  String get registerLegalOpenFailed => 'Не удалось открыть документ';

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
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get validationPhone => 'Введите корректный номер телефона';

  @override
  String get validationPassword => 'Пароль должен быть не короче 8 символов';

  @override
  String get validationPasswordsMatch => 'Пароли не совпадают';

  @override
  String otpSubtitle(String phone) {
    return 'Мы отправили 6-значный код на $phone';
  }

  @override
  String otpEmailSubtitle(String email) {
    return 'Мы отправили 6-значный код на email $email';
  }

  @override
  String get otpResend => 'Отправить код ещё раз';

  @override
  String get otpPasswordUpdated => 'Пароль успешно обновлён';

  @override
  String get profileCurrentPlan => 'Текущий тариф';

  @override
  String get profilePlanActive => 'Активен';

  @override
  String get profilePlanEnds => 'Дата окончания';

  @override
  String get profileNoPlanTitle => 'Нет активного тарифа';

  @override
  String get profileNoPlanBody =>
      'Выберите тариф для групповых занятий с ментором и живых уроков';

  @override
  String get profileChoosePlan => 'Выбрать тариф';

  @override
  String profilePlanExpired(String course) {
    return 'Тариф «$course» истёк';
  }

  @override
  String profilePlanEndedOn(String date) {
    return 'Дата окончания: $date';
  }

  @override
  String get profileRenewPlan => 'Продлить тариф';

  @override
  String get profileStreak => 'Текущая серия';

  @override
  String get profileTotalXp => 'Всего XP';

  @override
  String get profileCoins => 'Баланс монет';

  @override
  String get profileRank => 'Место в рейтинге';

  @override
  String profileRankValue(int rank) {
    return '$rank-е место';
  }

  @override
  String get profileLanguageHint =>
      'Интерфейс приложения будет на выбранном языке';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get profileAppLanguage => 'Язык приложения';

  @override
  String get profileChangePassword => 'Сменить пароль';

  @override
  String get settingsLogOut => 'Выйти';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsLogOutConfirm => 'Выйти из аккаунта?';

  @override
  String get settingsDeleteConfirm => 'Удалить аккаунт?';

  @override
  String get settingsLogOutBody =>
      'Чтобы снова войти, понадобятся номер телефона или email и пароль.';

  @override
  String get settingsLogOutAction => 'Выйти';

  @override
  String get settingsDeleteBody =>
      'Данные профиля, прогресс, серия и монеты будут удалены навсегда. Это действие нельзя отменить.';

  @override
  String get settingsDeleteAction => 'Удалить';

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
  String get studyEmptyTitle => 'Купите курс, чтобы выбрать время занятий';

  @override
  String get studyEmptyBody =>
      'После покупки курса вы выберете удобные дни и время, а затем мы добавим вас в группу с менторами.';

  @override
  String get studyBrowseCourses => 'Смотреть курсы';

  @override
  String get studyWaitingTitle => 'Скоро мы добавим вас в группу';

  @override
  String get studyWaitingBody =>
      'Ваш курс активен. Мы подбираем вам группу и менторов.';

  @override
  String get studyJoinGroup => 'Перейти в группу';

  @override
  String get studyMentors => 'Менторы';

  @override
  String get studyPrimaryMentor => 'Основной ментор';

  @override
  String get studySupportMentor => 'Ментор поддержки';

  @override
  String studyMembers(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString участника',
      many: '$countString участников',
      few: '$countString участника',
      one: '$countString участник',
    );
    return '$_temp0';
  }

  @override
  String get studyLoadFailed => 'Не удалось загрузить данные группы';

  @override
  String get studyPullToRetry => 'Потяните вниз, чтобы повторить';

  @override
  String get mentorHeader => 'Ментор';

  @override
  String get mentorReviewsTitle => 'Отзывы студентов';

  @override
  String get mentorNoReviews => 'Отзывов пока нет';

  @override
  String get mentorLeaveReview => 'Оставить отзыв';

  @override
  String get mentorReviewHint => 'Поделитесь впечатлением об этом менторе...';

  @override
  String get mentorReviewSubmit => 'Отправить отзыв';

  @override
  String get mentorReviewSent => 'Спасибо за отзыв!';

  @override
  String get mentorReviewRatingRequired => 'Пожалуйста, выберите оценку';

  @override
  String get purchaseHistoryTitle => 'История покупок';

  @override
  String get purchaseHistoryPayments => 'Платежи';

  @override
  String get purchaseHistoryEnrollments => 'Записи на курсы';

  @override
  String get purchaseHistoryLoadFailed =>
      'Не удалось загрузить историю покупок';

  @override
  String get purchaseHistoryEmptyPayments => 'Платежей пока нет';

  @override
  String get purchaseHistoryEmptyEnrollments => 'Записей пока нет';

  @override
  String get purchaseHistoryStatusCreated => 'Ожидает оплаты';

  @override
  String get purchaseHistoryStatusPaid => 'Оплачено';

  @override
  String get purchaseHistoryStatusCancelled => 'Отменено';

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
  String get aiTitle => 'ИИ-собеседник';

  @override
  String get aiIntroTitle => 'Живой разговор с ИИ';

  @override
  String get aiIntroBody =>
      'Нажмите кнопку и свободно говорите по-английски — разговор идёт в реальном времени, как звонок.';

  @override
  String get aiFeatureEndAnytime => 'Можно закончить в любой момент';

  @override
  String get aiFeatureLiveVoice =>
      'Живой голосовой разговор в реальном времени';

  @override
  String get aiFeatureNoScore => 'Без оценок и баллов — просто говорите';

  @override
  String get aiMicNote => 'Для разговора нужен доступ к микрофону.';

  @override
  String get aiEnd => 'Завершить разговор';

  @override
  String get aiConnecting => 'Подключение…';

  @override
  String get aiInCall => 'Идёт разговор';

  @override
  String get aiYou => 'Вы';

  @override
  String get aiYourTurn => 'Ваша очередь';

  @override
  String get aiMicOff => 'Микрофон выключен';

  @override
  String get aiStatusListening => 'Слушает';

  @override
  String get aiStatusThinking => 'Думает';

  @override
  String get aiStatusSpeaking => 'Говорит';

  @override
  String get aiMute => 'Выключить микрофон';

  @override
  String get aiUnmute => 'Включить микрофон';

  @override
  String get aiSoundOff => 'Выключить голос ИИ';

  @override
  String get aiSoundOn => 'Включить голос ИИ';

  @override
  String aiAutoEndNote(int minutes) {
    return 'Разговор завершится автоматически через $minutes мин.';
  }

  @override
  String get aiTimeUp => 'Время вышло — разговор завершён';

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
  String get roadmapStart => 'Начать';

  @override
  String roadmapLevelNumber(int number) {
    return 'Ур.$number';
  }

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

  @override
  String get updateTitle => 'Доступна новая версия';

  @override
  String get updateBody =>
      'Новая версия приложения готова. Обновитесь сейчас и пользуйтесь новыми возможностями.';

  @override
  String get updateAction => 'Обновить';

  @override
  String get otpEnterCode => 'Введите код';

  @override
  String get registerPersonalInfo => 'Личные данные';

  @override
  String get registerChangePhoto => 'Изменить фото';

  @override
  String get registerFirstName => 'Имя';

  @override
  String get registerFirstNameHint => 'Введите имя';

  @override
  String get registerLastName => 'Фамилия';

  @override
  String get registerLastNameHint => 'Введите фамилию';

  @override
  String get registerPasswordHint => 'Не менее 8 символов';

  @override
  String get registerGender => 'Ваш пол';
}
