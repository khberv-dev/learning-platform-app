// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get languageTitle => 'Tilni tanlang';

  @override
  String get languageSubtitle =>
      'Keyinroq profilingizdan o\'zgartirishingiz mumkin';

  @override
  String get languageContinue => 'Davom etish';

  @override
  String get languageSettingsTitle => 'Til';

  @override
  String get commonContinue => 'Davom etish';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonResume => 'Davom etish';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonYes => 'Ha';

  @override
  String get commonNo => 'Yo\'q';

  @override
  String get commonOk => 'OK';

  @override
  String get commonJoin => 'Qo\'shilish';

  @override
  String get commonLoading => 'Yuklanmoqda…';

  @override
  String get commonSomethingWentWrong =>
      'Nimadir xato ketdi. Qayta urinib ko\'ring.';

  @override
  String get authUsePhone => 'Telefon';

  @override
  String get authUseEmail => 'Email';

  @override
  String get fieldEmail => 'Email manzil';

  @override
  String get validationEmail => 'To\'g\'ri email manzilini kiriting';

  @override
  String get commonOpenOutsideApp => 'Ilovadan tashqarida ochish';

  @override
  String get commonShowPassword => 'Parolni ko\'rsatish';

  @override
  String get commonHidePassword => 'Parolni yashirish';

  @override
  String commonRatingOutOf(String rating, int count) {
    return '$count tadan $rating';
  }

  @override
  String get splashWelcome => 'iTeach\'ga xush kelibsiz!';

  @override
  String get onboardingHeadlineLead => '';

  @override
  String get onboardingHeadlineHighlight => 'Ingliz tilini';

  @override
  String get onboardingHeadlineTail => '\nhar qachongidan tez o\'rganing';

  @override
  String get onboardingFreshStart => 'Noldan boshlaymiz';

  @override
  String get onboardingResume => 'Davom ettirish';

  @override
  String get welcomeTitle => 'iTeach\'ga xush kelibsiz';

  @override
  String get welcomeSubtitle =>
      'Ingliz tilini o\'rganish yo\'lingiz\nshu yerdan boshlanadi';

  @override
  String get welcomeGetStarted => 'Boshlash';

  @override
  String get welcomeSignIn => 'Kirish';

  @override
  String get noConnectionTitle => 'Aloqa yo\'q';

  @override
  String get noConnectionMessage =>
      'Serverga ulanib bo\'lmadi.\nInternetni tekshirib, qayta urining.';

  @override
  String get noConnectionRetry => 'Qayta urinish';

  @override
  String get surveyReasonTitle => 'Ingliz tilini nima uchun o\'rganyapsiz?';

  @override
  String get surveyReasonDescription => 'O\'zingizga eng mosini tanlang';

  @override
  String get surveyReasonCareer => 'Karyera';

  @override
  String get surveyReasonTravel => 'Sayohat';

  @override
  String get surveyReasonAcademic => 'O\'qish';

  @override
  String get surveyReasonPersonal => 'O\'zim uchun';

  @override
  String get surveyReasonImmigration => 'Chet elga ketish';

  @override
  String get surveyTimeTitle => 'Kuniga qancha vaqt ajrata olasiz?';

  @override
  String get surveyTimeDescription => 'Kun tartibingizga mos jadval tuzamiz';

  @override
  String get surveyTime5 => '5 daqiqa';

  @override
  String get surveyTime15 => '15 daqiqa';

  @override
  String get surveyTime30 => '30 daqiqa';

  @override
  String get surveyTime60 => '1+ soat';

  @override
  String get levelCheckTitle => 'Ingliz tilini biroz bilasizmi?';

  @override
  String get levelCheckDescription =>
      'Avval o\'qigan bo\'lsangiz, qisqa test darajangizni aniqlaydi';

  @override
  String get levelCheckYes => 'Ha, avval o\'rganganman';

  @override
  String get levelCheckNo => 'Yo\'q, noldan boshlayapman';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navCourse => 'Kurslar';

  @override
  String get navChat => 'Chat';

  @override
  String get navMentor => 'Mentor';

  @override
  String get navProfile => 'Profil';

  @override
  String get levelBeginner => 'Boshlang\'ich';

  @override
  String get levelIntermediate => 'O\'rta';

  @override
  String get levelAdvanced => 'Yuqori';

  @override
  String get homeOnFire => 'Zo\'r ketyapsiz';

  @override
  String homeStreakDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString kun',
      one: '$countString kun',
    );
    return '$_temp0';
  }

  @override
  String get homeDontForgetMe => 'Meni unutmang!';

  @override
  String get homeStatsScores => 'Ballar';

  @override
  String get homeStatsCoins => 'Tangalar';

  @override
  String get homeStatsRanking => 'Umumiy reyting';

  @override
  String get homeLibrary => 'Kutubxona';

  @override
  String get homeNoCoursesTitle => 'Faol kurslar yo\'q';

  @override
  String get homeNoCoursesSubtitle => 'Kurs tanlab, bugunoq boshlang';

  @override
  String get homeNoCoursesButton => 'Mashqni boshlash';

  @override
  String get homeProgress => 'Jarayon';

  @override
  String get homeResume => 'Davom etish';

  @override
  String get homeLiveLessons => 'Jonli darslar';

  @override
  String get homeLiveNow => 'HOZIR EFIRDA';

  @override
  String get homeUpcoming => 'TEZ ORADA';

  @override
  String get homeJoinLesson => 'Darsga qo\'shilish';

  @override
  String get homeMoreUpcoming => 'Boshqa yaqin darslar';

  @override
  String get homeNoUpcomingLessons => 'Yaqin darslar yo\'q';

  @override
  String get homeAiTestTitle => 'Bilimingizni AI bilan sinang';

  @override
  String get homeAiTestBody =>
      'Erkin gapiring, AI darajangizni baholaydi — bir necha daqiqada to\'liq hisobot';

  @override
  String get homeAiTestButton => 'Testni boshlash';

  @override
  String get homeSpeakingTitle => 'Suhbatdosh toping';

  @override
  String get homeSpeakingBody =>
      'Sizning darajangizdagi odam bilan bog\'laymiz. Jonli suhbatda mashq qiling';

  @override
  String get homeSpeakingButton => 'Suhbatdosh topish';

  @override
  String get coursesTitle => 'Kurslar';

  @override
  String get coursesTabCourses => 'Kurslar';

  @override
  String get coursesTabLive => 'Jonli darslar';

  @override
  String get coursesRoadmap => 'Yo\'l xaritasi';

  @override
  String get coursesMyCourses => 'Mening kurslarim';

  @override
  String get coursesAvailable => 'Sotib olish mumkin';

  @override
  String get coursesNoneAvailable => 'Hozircha kurslar yo\'q.';

  @override
  String get coursesCurrentUpcoming => 'Joriy va yaqin';

  @override
  String get coursesPastSessions => 'O\'tgan darslar';

  @override
  String coursesRecordedCount(int count) {
    return '$count ta yozuv';
  }

  @override
  String get coursesNoRecordedTitle => 'Yozuvlar yo\'q';

  @override
  String get coursesNoRecordedSubtitle =>
      'Jonli darslar yozuvlari tayyor bo\'lgach\nshu yerda ko\'rinadi';

  @override
  String get courseUnits => 'Bo\'limlar';

  @override
  String courseLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta dars',
      one: '$count ta dars',
    );
    return '$_temp0';
  }

  @override
  String get courseChoosePlan => 'Tarifni tanlash';

  @override
  String get courseExpired => 'Muddati tugagan';

  @override
  String get courseProgress => 'Jarayon';

  @override
  String get courseLearnMore => 'Batafsil';

  @override
  String get courseRecordedSession => 'DARS YOZUVI';

  @override
  String get courseRecorded => 'YOZUV';

  @override
  String unitNumber(String number) {
    return '$number-bo\'lim';
  }

  @override
  String get unitNoLessonsTitle => 'Hozircha darslar yo\'q';

  @override
  String get unitNoLessonsSubtitle =>
      'Bu bo\'lim darslari shu yerda paydo bo\'ladi.';

  @override
  String get unitNotFound => 'Bo\'lim topilmadi';

  @override
  String lessonUnitLesson(String unit, String lesson) {
    return '$unit-bo\'lim · $lesson-dars';
  }

  @override
  String lessonUnitLessonOf(String unit, String lesson, int total) {
    return '$unit-bo\'lim · $total tadan $lesson-dars';
  }

  @override
  String get lessonViewTasks => 'Topshiriqlar';

  @override
  String get lessonTasksCompleted => 'Topshiriqlar bajarildi';

  @override
  String get lessonTasksInProgress => 'Topshiriqlar jarayonda';

  @override
  String lessonScore(int correct, int total, int percent) {
    return '$total tadan $correct ta to\'g\'ri · $percent%';
  }

  @override
  String get lessonRetake => 'Qayta ishlash';

  @override
  String get lessonInThisUnit => 'Shu bo\'limda';

  @override
  String get lessonNoContent => 'Kontent yo\'q';

  @override
  String get materialsTitle => 'Materiallar';

  @override
  String materialsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta fayl',
      one: '$count ta fayl',
    );
    return '$_temp0';
  }

  @override
  String get materialsLoadFailed => 'Materiallarni yuklab bo\'lmadi';

  @override
  String get materialsOpenFailed => 'Faylni ochib bo\'lmadi';

  @override
  String get purchaseSuccessTitle => 'Tayyor!';

  @override
  String purchaseSuccessBody(String course) {
    return '«$course» endi sizniki. O\'rganishni boshlang.';
  }

  @override
  String get purchaseSuccessButton => 'O\'rganishni boshlash';

  @override
  String get tasksTitle => 'Topshiriqlar';

  @override
  String taskProgress(int current, int total) {
    return '$total tadan $current-topshiriq';
  }

  @override
  String get taskFallbackName => 'Topshiriq';

  @override
  String get taskAnswerHint => 'Javobingizni yozing…';

  @override
  String get taskSubmit => 'Yuborish';

  @override
  String get taskNext => 'Keyingi';

  @override
  String get tasksEmptyTitle => 'Topshiriqlar yo\'q';

  @override
  String get tasksEmptySubtitle =>
      'Bu darsning topshiriqlari shu yerda paydo bo\'ladi.';

  @override
  String get taskAudioError => 'Audioni ijro etib bo\'lmadi';

  @override
  String get taskImageError => 'Rasmni yuklab bo\'lmadi';

  @override
  String pdfPageOf(int current, int total) {
    return '$total tadan $current-sahifa';
  }

  @override
  String get pdfLoadFailed => 'PDF faylni ochib bo\'lmadi';

  @override
  String get pdfLoadFailedHint => 'Fayl shikastlangan yoki aloqa uzilgan.';

  @override
  String get imageLoadFailed => 'Rasmni yuklab bo\'lmadi';

  @override
  String get loginTitle => 'Xush kelibsiz';

  @override
  String get loginForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get loginSubmit => 'Kirish';

  @override
  String get registerTitle => 'Hisob yaratish';

  @override
  String get registerSubmit => 'Hisob yaratish';

  @override
  String get registerLegalLead => 'Hisob yaratish orqali siz\n';

  @override
  String get registerLegalTerms => 'Foydalanish shartlari';

  @override
  String get registerLegalAnd => ' va ';

  @override
  String get registerLegalPrivacy => 'Maxfiylik siyosatiga rozilik bildirasiz';

  @override
  String get forgotTitle => 'Parolni tiklash';

  @override
  String get forgotSubtitle => 'Telefon raqamingiz va yangi parolni kiriting';

  @override
  String get forgotSubmit => 'Kod yuborish';

  @override
  String get fieldPhone => 'Telefon raqami';

  @override
  String get fieldPassword => 'Parol';

  @override
  String get fieldNewPassword => 'Yangi parol';

  @override
  String get fieldConfirmPassword => 'Parolni tasdiqlang';

  @override
  String get fieldFullName => 'Ism va familiya';

  @override
  String get validationPhone => 'To\'g\'ri telefon raqamini kiriting';

  @override
  String get validationPassword => 'Parol kamida 8 ta belgidan iborat bo\'lsin';

  @override
  String get validationPasswordsMatch => 'Parollar mos kelmadi';

  @override
  String get validationFullName => 'Ism va familiyangizni kiriting';

  @override
  String get otpTitle => 'Telefon raqamingizni\ntasdiqlang';

  @override
  String otpSubtitle(String phone) {
    return '$phone raqamiga 6 xonali kod yubordik';
  }

  @override
  String get otpEmailTitle => 'Email manzilingizni\ntasdiqlang';

  @override
  String otpEmailSubtitle(String email) {
    return '$email email manziliga 6 xonali kod yubordik';
  }

  @override
  String otpResendIn(int seconds) {
    return 'Kodni qayta yuborish: $seconds s';
  }

  @override
  String get otpResend => 'Kodni qayta yuborish';

  @override
  String get otpPasswordUpdated => 'Parol muvaffaqiyatli yangilandi';

  @override
  String get profilePhone => 'Telefon raqami';

  @override
  String get profileEmail => 'Email manzil';

  @override
  String get profilePassword => 'Parol';

  @override
  String get profileUpdatePassword => 'Parolni yangilash';

  @override
  String get settingsPrivacyPolicy => 'Maxfiylik siyosati';

  @override
  String get settingsAppVersion => 'Ilova versiyasi';

  @override
  String get settingsLogOut => 'Chiqish';

  @override
  String get settingsDeleteAccount => 'Hisobni o\'chirish';

  @override
  String get settingsLogOutConfirm => 'Hisobdan chiqmoqchimisiz?';

  @override
  String get settingsDeleteConfirm =>
      'Hisobingizni o\'chirmoqchimisiz? Kurslaringiz va natijalaringiz butunlay yo\'qoladi.';

  @override
  String get settingsDeleteRequestedTitle => 'So\'rov yuborildi';

  @override
  String get settingsDeleteRequestedBody =>
      'Hisobni o\'chirish so\'rovi yuborildi. U ko\'rib chiqilguncha ilovadan foydalanishingiz mumkin.';

  @override
  String get chatMentor => 'Mentor';

  @override
  String get chatFile => 'Fayl';

  @override
  String get chatHint => 'Xabar yozing…';

  @override
  String get chatEmptyTitle => 'Hozircha xabarlar yo\'q';

  @override
  String get chatEmptySubtitle => 'Suhbatni boshlash uchun xabar yuboring.';

  @override
  String get tutorsTitle => 'O\'qituvchi topish';

  @override
  String get tutorsLoadFailed => 'O\'qituvchilarni yuklab bo\'lmadi';

  @override
  String get tutorsPullToRetry => 'Qayta urinish uchun pastga torting';

  @override
  String get tutorsEmptyTitle => 'O\'qituvchilar yo\'q';

  @override
  String get tutorsEmptySubtitle => 'Ular qo\'shilgach shu yerda ko\'rinadi';

  @override
  String get tutorsAvailable => 'Mavjud o\'qituvchilar';

  @override
  String get tutorHeader => 'O\'qituvchi';

  @override
  String get tutorReviewsTitle => 'Talabalar fikri';

  @override
  String get tutorNoReviews => 'Hozircha fikrlar yo\'q';

  @override
  String get tutorBook => 'Band qilish';

  @override
  String get tutorBookingSent => 'So\'rov yuborildi';

  @override
  String tutorRatingReviews(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta fikr',
      one: '$count ta fikr',
    );
    return '$rating  ·  $_temp0';
  }

  @override
  String get bookTitle => 'Jadvalni tanlang';

  @override
  String bookSubtitle(String name) {
    return '$name bilan haftasiga 3 tagacha vaqt tanlang';
  }

  @override
  String get bookLoadFailed => 'Jadvalni yuklab bo\'lmadi';

  @override
  String get bookNoAvailability =>
      'O\'qituvchi hali bo\'sh vaqtini kiritmagan.\nShunda ham so\'rov yuborishingiz mumkin.';

  @override
  String bookSlotsSelected(int count) {
    return '3 tadan $count tasi tanlandi';
  }

  @override
  String get bookConfirm => 'Bandlovni tasdiqlash';

  @override
  String get weekdayMonday => 'Dushanba';

  @override
  String get weekdayTuesday => 'Seshanba';

  @override
  String get weekdayWednesday => 'Chorshanba';

  @override
  String get weekdayThursday => 'Payshanba';

  @override
  String get weekdayFriday => 'Juma';

  @override
  String get weekdaySaturday => 'Shanba';

  @override
  String get weekdaySunday => 'Yakshanba';

  @override
  String get plansTitle => 'Tarifni tanlang';

  @override
  String get plansLoadFailed => 'Tariflarni yuklab bo\'lmadi';

  @override
  String get plansEmptyTitle => 'Tariflar yo\'q';

  @override
  String get plansEmptySubtitle => 'Bu kurs hozir sotuvda emas';

  @override
  String plansDuration(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oy',
      one: '$count oy',
    );
    return '$_temp0';
  }

  @override
  String plansPrice(String amount) {
    return '$amount so\'m';
  }

  @override
  String get plansWithMentor => 'Mentor bilan';

  @override
  String get paymentTitle => 'To\'lov usuli';

  @override
  String get paymentLoadFailed => 'To\'lovni boshlab bo\'lmadi';

  @override
  String get paymentEmptyTitle => 'To\'lov usullari yo\'q';

  @override
  String get paymentEmptySubtitle => 'Hozircha hech biri sozlanmagan';

  @override
  String paymentNoLink(String type) {
    return '«$type» uchun to\'lov havolasi hali yo\'q';
  }

  @override
  String paymentOpenFailed(String type) {
    return '«$type» ochilmadi';
  }

  @override
  String get aiTitle => 'AI baholash';

  @override
  String get aiInitialPrompt => 'Xohlagan narsangizni gapirib ko\'ring!';

  @override
  String get aiMicDenied => 'Mikrofonga ruxsat berilmadi';

  @override
  String get aiRecordFailed => 'Yozib bo\'lmadi';

  @override
  String get aiUploadFailed => 'Yuborilmadi. Qayta urinish uchun bosing.';

  @override
  String get aiUploading => 'Yuborilmoqda…';

  @override
  String get aiPlayingFeedback => 'Izoh ijro etilmoqda…';

  @override
  String get aiTapToStop => 'To\'xtatish uchun bosing';

  @override
  String get aiTapToSpeak => 'Gapirish uchun bosing';

  @override
  String get aiListening => 'Tinglanmoqda…';

  @override
  String get aiResultsTitle => 'Natijalar';

  @override
  String get aiSkillGrammar => 'Grammatika';

  @override
  String get aiSkillVocabulary => 'So\'z boyligi';

  @override
  String get aiSkillFluency => 'Ravonlik';

  @override
  String get aiSkillPronunciation => 'Talaffuz';

  @override
  String get aiSkillBreakdown => 'Ko\'nikmalar tahlili';

  @override
  String get aiSummary =>
      'Grammatikangiz B2 darajasida kuchli, lug\'atingiz professional. C1 ga chiqish uchun ravonlik va talaffuz ustida ishlang.';

  @override
  String get aiStartLearning => 'Shaxsiy dasturni boshlash';

  @override
  String get aiYourLevel => 'Ingliz tili darajangiz';

  @override
  String aiBasedOnResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Suhbatdagi $count ta javob asosida',
      one: 'Suhbatdagi $count ta javob asosida',
    );
    return '$_temp0';
  }

  @override
  String aiImprovedFrom(String level) {
    return '↑ $level darajasidan o\'sdi';
  }

  @override
  String get p2pTitle => 'Suhbatdosh';

  @override
  String get p2pFinding => 'Suhbatdosh qidirilmoqda…';

  @override
  String get p2pLookingSubtitle => 'Darajangizga mos odam tanlanmoqda';

  @override
  String get p2pConnecting => 'Ulanmoqda…';

  @override
  String get p2pMatched => 'Topildi';

  @override
  String get p2pConnected => 'Ulandi';

  @override
  String get p2pMute => 'Mikrofonni o\'chirish';

  @override
  String get p2pUnmute => 'Mikrofonni yoqish';

  @override
  String get p2pEnd => 'Tugatish';

  @override
  String get p2pEndedCall => 'Qo\'ng\'iroq tugadi';

  @override
  String get p2pPeerLeft => 'Suhbatdoshingiz qo\'ng\'iroqni tark etdi';

  @override
  String get p2pPeerDisconnected => 'Suhbatdoshingiz uzildi';

  @override
  String get p2pCancelled => 'Qo\'ng\'iroq bekor qilindi';

  @override
  String get p2pReplaced => 'Sessiya boshqa ulanish bilan almashtirildi';

  @override
  String get p2pError => 'Qo\'ng\'iroqda xatolik';

  @override
  String get notificationsTitle => 'Bildirishnomalar';

  @override
  String get notificationsEmptyTitle => 'Bildirishnomalar yo\'q';

  @override
  String get notificationsEmptySubtitle => 'Hammasi ko\'rib chiqilgan!';

  @override
  String get roadmapLevelA1 => 'Boshlang\'ich';

  @override
  String get roadmapLevelA2 => 'Elementar';

  @override
  String get roadmapLevelB1 => 'O\'rta';

  @override
  String get roadmapLevelB2 => 'O\'rtadan yuqori';

  @override
  String get roadmapLevelC1 => 'Yuqori';

  @override
  String get roadmapLevelC2 => 'Mukammal';

  @override
  String get roadmapTopicGreetings => 'Salomlashish';

  @override
  String get roadmapTopicNumbersDates => 'Sonlar va sanalar';

  @override
  String get roadmapTopicColorsObjects => 'Ranglar va buyumlar';

  @override
  String get roadmapTopicFamily => 'Oila';

  @override
  String get roadmapTopicFoodDrinks => 'Ovqat va ichimliklar';

  @override
  String get roadmapTopicDailyRoutines => 'Kun tartibi';

  @override
  String get roadmapTopicShopping => 'Xarid';

  @override
  String get roadmapTopicTravelTransport => 'Sayohat va transport';

  @override
  String get roadmapTopicWeatherSeasons => 'Ob-havo va fasllar';

  @override
  String get roadmapTopicHomeFurniture => 'Uy va mebel';

  @override
  String get roadmapTopicHobbies => 'Qiziqishlar';

  @override
  String get roadmapTopicHealthBody => 'Salomatlik va tana';

  @override
  String get roadmapTopicWorkCareers => 'Ish va karyera';

  @override
  String get roadmapTopicCurrentEvents => 'Kunlik yangiliklar';

  @override
  String get roadmapTopicFuturePlans => 'Kelajak rejalari';

  @override
  String get roadmapTopicPastExperiences => 'O\'tmish tajribasi';

  @override
  String get roadmapTopicOpinionsFeelings => 'Fikr va his-tuyg\'ular';

  @override
  String get roadmapTopicTourismCulture => 'Turizm va madaniyat';

  @override
  String get roadmapTopicDebates => 'Bahs va dalillar';

  @override
  String get roadmapTopicSocialIssues => 'Ijtimoiy masalalar';

  @override
  String get roadmapTopicBusinessEnglish => 'Biznes ingliz tili';

  @override
  String get roadmapTopicMedia => 'OAV va ko\'ngilochar';

  @override
  String get roadmapTopicEnvironment => 'Atrof-muhit';

  @override
  String get roadmapTopicAcademicWriting => 'Akademik yozuv';

  @override
  String get roadmapTopicAcademicDiscourse => 'Akademik nutq';

  @override
  String get roadmapTopicProfessionalComms => 'Kasbiy muloqot';

  @override
  String get roadmapTopicIdioms => 'Idiomalar va iboralar';

  @override
  String get roadmapTopicLiterature => 'Adabiyot va san\'at';

  @override
  String get roadmapTopicCriticalAnalysis => 'Tanqidiy tahlil';

  @override
  String get roadmapTopicNegotiations => 'Murakkab muzokaralar';

  @override
  String get roadmapTopicNativeFluency => 'Ona tilidek ravonlik';

  @override
  String get roadmapTopicSpecializedVocab => 'Maxsus lug\'at';

  @override
  String get roadmapTopicCulturalReferences => 'Madaniy iqtiboslar';

  @override
  String get roadmapTopicRhetoric => 'Yuqori ritorika';

  @override
  String get roadmapTopicCreativeWriting => 'Ijodiy yozuv';

  @override
  String get roadmapTopicPresentations => 'Ekspert taqdimotlari';
}
