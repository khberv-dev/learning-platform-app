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
  String get commonContinue => 'Davom etish';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonResume => 'Davom etish';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonLoading => 'Yuklanmoqda…';

  @override
  String get commonSomethingWentWrong =>
      'Nimadir xato ketdi. Qayta urinib ko\'ring.';

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
  String get onboardingHeadlineTail => ' har qachongidan ham tez o\'rganing';

  @override
  String get onboardingSubtitle =>
      'Darajangizni belgilang — biz sizga mos o\'quv rejasini tuzamiz';

  @override
  String get onboardingFreshStart => 'Noldan boshlaymiz';

  @override
  String get onboardingResume => 'Davom etish';

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
  String get navHome => 'Asosiy';

  @override
  String get navCourse => 'Kurslar';

  @override
  String get navStudy => 'Ta\'lim';

  @override
  String get navProfile => 'Profil';

  @override
  String get navMission => 'Missiya';

  @override
  String get homeGreeting => 'Hayrli kun,';

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
      other: '$countString kun',
      one: '$countString kun',
    );
    return '$_temp0';
  }

  @override
  String get homeDontForgetMe => 'Meni unutmang!';

  @override
  String get homeStreakStartTitle => 'Seriyani boshlang';

  @override
  String get homeStreakStartSubtitle =>
      'Birinchi darsni tugatib, seriyangizni yoqing';

  @override
  String get homeStatsScores => 'Ballar';

  @override
  String get homeStatsCoins => 'Tangalar';

  @override
  String get homeAiPartnerTitle => 'AI suhbatdosh';

  @override
  String get homeAiPartnerBody => 'AI bilan jonli suhbat';

  @override
  String get homeAiPartnerAction => 'Suhbatni boshlash';

  @override
  String get homePartnerTitle => 'Suhbatdosh';

  @override
  String get homePartnerBody => 'Suhbatdosh bilan jonli suhbat';

  @override
  String get homePartnerAction => 'Suhbatdosh qidirish';

  @override
  String get homeResume => 'Davom etish';

  @override
  String get coursesTitle => 'Kurslar';

  @override
  String get coursesSearchHint => 'Qidirish...';

  @override
  String get coursesShowLess => 'Kamroq';

  @override
  String get coursesNoResults => 'Kurslar topilmadi';

  @override
  String get coursesMyCourses => 'Joriy kurslar';

  @override
  String get coursesAvailable => 'Mavjud kurslar';

  @override
  String get coursesNoneAvailable => 'Hozircha kurslar yo\'q.';

  @override
  String get courseUnits => 'Modullar';

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
  String courseModuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modul',
      one: '$count modul',
    );
    return '$_temp0';
  }

  @override
  String courseHourCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count soat',
      one: '$count soat',
    );
    return '$_temp0';
  }

  @override
  String get courseAbout => 'Kurs haqida';

  @override
  String get courseTeacher => 'O\'qituvchi';

  @override
  String get courseOtherCourses => 'Boshqa kurslar';

  @override
  String get courseSeeAll => 'Barchasi';

  @override
  String get courseNotEnrolledTitle => 'Siz bu kursga yozilmagansiz';

  @override
  String get courseNotEnrolledMessage =>
      'Darslarni ochish uchun tarif sotib oling.';

  @override
  String get courseChoosePlan => 'Tarif sotib olish';

  @override
  String get unitNoLessonsTitle => 'Hozircha darslar yo\'q';

  @override
  String get lessonUnitLessons => 'Bo\'limlar';

  @override
  String get lessonGoToTest => 'Testga o\'tish';

  @override
  String get lessonNoContent => 'Kontent yo\'q';

  @override
  String get lessonVideoPlay => 'Ijro etish';

  @override
  String get lessonVideoPause => 'Pauza';

  @override
  String get lessonVideoRewind => '15 soniya orqaga';

  @override
  String get lessonVideoForward => '15 soniya oldinga';

  @override
  String get lessonVideoMute => 'Ovozni o\'chirish';

  @override
  String get lessonVideoUnmute => 'Ovozni yoqish';

  @override
  String get lessonVideoFullscreen => 'To\'liq ekran';

  @override
  String get lessonVideoExitFullscreen => 'To\'liq ekrandan chiqish';

  @override
  String get lessonVideoSpeed => 'Ijro tezligi';

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
  String get taskResultsTitle => 'Natijalar';

  @override
  String taskResultsSummary(int correct, int total) {
    return '$total tadan $correct tasi to\'g\'ri';
  }

  @override
  String taskResultsCoinsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count tanga',
      one: '+$count tanga',
    );
    return '$_temp0';
  }

  @override
  String get taskResultsCorrect => 'To\'g\'ri';

  @override
  String get taskResultsIncorrect => 'Noto\'g\'ri';

  @override
  String taskResultsYourAnswer(String answer) {
    return 'Sizning javobingiz: $answer';
  }

  @override
  String get taskResultsNoAnswer => 'Javob yo\'q';

  @override
  String get taskResultsDone => 'Tayyor';

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
  String get loginTitle => 'Kirish';

  @override
  String get loginSubtitlePhone =>
      'Hisobingizga kirish uchun telefon raqamingizni kiriting';

  @override
  String get loginSubtitleEmail =>
      'Hisobingizga kirish uchun elektron pochtangizni kiriting';

  @override
  String get loginTabPhone => 'Telefon orqali';

  @override
  String get loginTabEmail => 'Email orqali';

  @override
  String get loginOr => 'yoki';

  @override
  String get loginTelegram => 'Telegram orqali kirish';

  @override
  String get loginTelegramUnavailable =>
      'Telegram orqali kirish hali mavjud emas';

  @override
  String get loginLegalLead => 'Davom etish orqali siz ';

  @override
  String get loginLegalOffer => 'ommaviy oferta';

  @override
  String get loginLegalTail =>
      ' shartlari bilan rozi ekanligingizni tasdiqlaysiz.';

  @override
  String get loginForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get loginPasswordHint => 'Parolingizni kiriting';

  @override
  String get loginSubmit => 'Kirish';

  @override
  String get registerSubmit => 'Ro\'yxatdan o\'tish';

  @override
  String get registerLegalOpenFailed => 'Hujjatni ochib bo\'lmadi';

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
  String get genderMale => 'Erkak';

  @override
  String get genderFemale => 'Ayol';

  @override
  String get validationPhone => 'To\'g\'ri telefon raqamini kiriting';

  @override
  String get validationPassword => 'Parol kamida 8 ta belgidan iborat bo\'lsin';

  @override
  String get validationPasswordsMatch => 'Parollar mos kelmadi';

  @override
  String otpSubtitle(String phone) {
    return '$phone raqamiga 6 xonali kod yubordik';
  }

  @override
  String otpEmailSubtitle(String email) {
    return '$email email manziliga 6 xonali kod yubordik';
  }

  @override
  String get otpResend => 'Qayta yuborish';

  @override
  String get otpPasswordUpdated => 'Parol muvaffaqiyatli yangilandi';

  @override
  String get profileCurrentPlan => 'Joriy tarif';

  @override
  String get profilePlanActive => 'Faol';

  @override
  String get profilePlanEnds => 'Tugash sanasi';

  @override
  String get profileNoPlanTitle => 'Faol tarif yo\'q';

  @override
  String get profileNoPlanBody =>
      'Mentor bilan guruh darslari va jonli darslar uchun tarif tanlang';

  @override
  String get profileChoosePlan => 'Tarif tanlash';

  @override
  String profilePlanExpired(String course) {
    return '$course tarifi muddati tugadi';
  }

  @override
  String profilePlanEndedOn(String date) {
    return 'Tugagan sana: $date';
  }

  @override
  String get profileRenewPlan => 'Tarifni yangilash';

  @override
  String get profileStreak => 'Joriy seriya';

  @override
  String get profileTotalXp => 'Jami XP';

  @override
  String get profileCoins => 'Coin balansi';

  @override
  String get profileRank => 'Reytingdagi o\'rin';

  @override
  String profileRankValue(int rank) {
    return '$rank-o\'rin';
  }

  @override
  String get profileLanguageHint =>
      'Ilova interfeysi tanlangan tilda ko\'rsatiladi';

  @override
  String get profileSettings => 'Sozlamalar';

  @override
  String get profileAccount => 'Hisob';

  @override
  String get profileAppLanguage => 'Ilova tili';

  @override
  String get profileChangePassword => 'Parolni o\'zgartirish';

  @override
  String get settingsLogOut => 'Hisobdan chiqish';

  @override
  String get settingsDeleteAccount => 'Hisobni o\'chirish';

  @override
  String get settingsLogOutConfirm => 'Hisobdan chiqasizmi?';

  @override
  String get settingsDeleteConfirm => 'Hisobni o\'chirasizmi?';

  @override
  String get settingsLogOutBody =>
      'Qayta kirish uchun telefon raqam yoki email va parolingizni kiritishingiz kerak bo\'ladi.';

  @override
  String get settingsLogOutAction => 'Chiqish';

  @override
  String get settingsDeleteBody =>
      'Profil ma\'lumotlari, progress, seriya va coinlaringiz butunlay o\'chiriladi. Bu amalni ortga qaytarib bo\'lmaydi.';

  @override
  String get settingsDeleteAction => 'O\'chirish';

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
  String get studyEmptyTitle =>
      'Dars vaqtlarini tanlash uchun kurs sotib oling';

  @override
  String get studyEmptyBody =>
      'Kurs sotib olganingizdan so\'ng o\'zingizga qulay kun va vaqtlarni tanlaysiz, keyin sizni guruhga va mentorlarga biriktiramiz.';

  @override
  String get studyBrowseCourses => 'Kurslarni ko\'rish';

  @override
  String get studyWaitingTitle => 'Tez orada sizni guruhga qo\'shamiz';

  @override
  String get studyWaitingBody =>
      'Kursingiz faol. Guruh va mentorlaringizni tayyorlayapmiz.';

  @override
  String get studyJoinGroup => 'Guruhga qo\'shilish';

  @override
  String get studyMentors => 'Mentorlar';

  @override
  String get studyPrimaryMentor => 'Asosiy mentor';

  @override
  String get studySupportMentor => 'Support mentor';

  @override
  String studyMembers(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString a\'zo',
      one: '$countString a\'zo',
    );
    return '$_temp0';
  }

  @override
  String get studyLoadFailed => 'Guruh ma\'lumotlarini yuklab bo\'lmadi';

  @override
  String get studyPullToRetry => 'Qayta urinish uchun pastga torting';

  @override
  String get mentorHeader => 'Mentor';

  @override
  String get mentorReviewsTitle => 'Talabalar fikri';

  @override
  String get mentorNoReviews => 'Hozircha fikrlar yo\'q';

  @override
  String get mentorLeaveReview => 'Fikr qoldirish';

  @override
  String get mentorReviewHint => 'Ushbu mentor haqidagi fikringizni yozing...';

  @override
  String get mentorReviewSubmit => 'Fikrni yuborish';

  @override
  String get mentorReviewSent => 'Fikringiz uchun rahmat!';

  @override
  String get mentorReviewRatingRequired => 'Iltimos, baho tanlang';

  @override
  String get purchaseHistoryTitle => 'Xaridlar tarixi';

  @override
  String get purchaseHistoryPayments => 'To\'lovlar';

  @override
  String get purchaseHistoryEnrollments => 'Yozilishlar';

  @override
  String get purchaseHistoryLoadFailed => 'Xaridlar tarixini yuklab bo\'lmadi';

  @override
  String get purchaseHistoryEmptyPayments => 'Hozircha to\'lovlar yo\'q';

  @override
  String get purchaseHistoryEmptyEnrollments => 'Hozircha yozilishlar yo\'q';

  @override
  String get purchaseHistoryStatusCreated => 'Kutilmoqda';

  @override
  String get purchaseHistoryStatusPaid => 'To\'landi';

  @override
  String get purchaseHistoryStatusCancelled => 'Bekor qilindi';

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
  String get aiTitle => 'AI suhbatdosh';

  @override
  String get aiIntroTitle => 'AI bilan jonli suhbat';

  @override
  String get aiIntroBody =>
      'Tugmani bosing va ingliz tilida erkin gaplashing — suhbat real vaqtda, xuddi qo\'ng\'iroq kabi bo\'ladi.';

  @override
  String get aiFeatureEndAnytime => 'Xohlagan payt tugatishingiz mumkin';

  @override
  String get aiFeatureLiveVoice => 'Jonli ovozli suhbat, real vaqtda';

  @override
  String get aiFeatureNoScore => 'Baholash va ball yo\'q — shunchaki gapiring';

  @override
  String get aiMicNote => 'Suhbat uchun mikrofonga ruxsat kerak bo\'ladi.';

  @override
  String get aiEnd => 'Suhbatni tugatish';

  @override
  String get aiConnecting => 'Ulanmoqda…';

  @override
  String get aiInCall => 'Suhbat davom etmoqda';

  @override
  String get aiYou => 'Siz';

  @override
  String get aiYourTurn => 'Sizning navbatingiz';

  @override
  String get aiMicOff => 'Mikrofon o\'chiq';

  @override
  String get aiStatusListening => 'Tinglamoqda';

  @override
  String get aiStatusThinking => 'O\'ylamoqda';

  @override
  String get aiStatusSpeaking => 'Gapirmoqda';

  @override
  String get aiMute => 'Mikrofonni o\'chirish';

  @override
  String get aiUnmute => 'Mikrofonni yoqish';

  @override
  String get aiSoundOff => 'AI ovozini o\'chirish';

  @override
  String get aiSoundOn => 'AI ovozini yoqish';

  @override
  String aiAutoEndNote(int minutes) {
    return 'Suhbat $minutes daqiqadan so\'ng avtomatik yakunlanadi';
  }

  @override
  String get aiTimeUp => 'Vaqt tugadi — suhbat yakunlandi';

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
  String get roadmapStart => 'Boshlash';

  @override
  String roadmapLevelNumber(int number) {
    return 'Lv.$number';
  }

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

  @override
  String get updateTitle => 'Yangi versiya mavjud';

  @override
  String get updateBody =>
      'Ilovaning yangi versiyasi tayyor. Hozir yangilang va yangi imkoniyatlardan foydalaning.';

  @override
  String get updateAction => 'Yangilash';

  @override
  String get otpEnterCode => 'Kodni kiriting';

  @override
  String get registerPersonalInfo => 'Shaxsiy ma\'lumotlar';

  @override
  String get registerChangePhoto => 'Rasmni o\'zgartirish';

  @override
  String get registerFirstName => 'Ism';

  @override
  String get registerFirstNameHint => 'Ismingizni kiriting';

  @override
  String get registerLastName => 'Familiya';

  @override
  String get registerLastNameHint => 'Familiyangizni kiriting';

  @override
  String get registerPasswordHint => 'Kamida 8 ta belgi';

  @override
  String get registerGender => 'Jinsingiz';
}
