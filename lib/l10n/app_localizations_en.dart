// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change it later in your profile';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonResume => 'Resume';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get fieldEmail => 'Email address';

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get commonOpenOutsideApp => 'Open outside the app';

  @override
  String get commonShowPassword => 'Show password';

  @override
  String get commonHidePassword => 'Hide password';

  @override
  String commonRatingOutOf(String rating, int count) {
    return '$rating out of $count';
  }

  @override
  String get splashWelcome => 'Welcome to iTeach!';

  @override
  String get onboardingHeadlineLead => 'Learn ';

  @override
  String get onboardingHeadlineHighlight => 'English';

  @override
  String get onboardingHeadlineTail => ' faster than ever before';

  @override
  String get onboardingSubtitle =>
      'Set your level — we\'ll build a study plan that fits you';

  @override
  String get onboardingFreshStart => 'Let\'s Get a Fresh Start';

  @override
  String get onboardingResume => 'Resume Journey';

  @override
  String get welcomeTitle => 'Welcome to iTeach';

  @override
  String get welcomeSubtitle =>
      'Your personalized English\nlearning journey starts here';

  @override
  String get welcomeGetStarted => 'Get Started';

  @override
  String get welcomeSignIn => 'Sign In';

  @override
  String get noConnectionTitle => 'No Connection';

  @override
  String get noConnectionMessage =>
      'Unable to reach the server.\nCheck your connection and try again.';

  @override
  String get noConnectionRetry => 'Try Again';

  @override
  String get surveyReasonTitle => 'Why are you learning English?';

  @override
  String get surveyReasonDescription => 'Choose the one that fits best';

  @override
  String get surveyReasonCareer => 'Career Growth';

  @override
  String get surveyReasonTravel => 'Travel & Adventure';

  @override
  String get surveyReasonAcademic => 'Academic Studies';

  @override
  String get surveyReasonPersonal => 'Personal Interest';

  @override
  String get surveyReasonImmigration => 'Immigration';

  @override
  String get surveyTimeTitle => 'How much time can you spend daily?';

  @override
  String get surveyTimeDescription =>
      'We\'ll build a schedule that fits your lifestyle';

  @override
  String get surveyTime5 => '5 minutes';

  @override
  String get surveyTime15 => '15 minutes';

  @override
  String get surveyTime30 => '30 minutes';

  @override
  String get surveyTime60 => '1+ hour';

  @override
  String get levelCheckTitle => 'Do you already know some English?';

  @override
  String get levelCheckDescription =>
      'If you have studied before, a short test places you at the right level';

  @override
  String get levelCheckYes => 'Yes, I have studied some';

  @override
  String get levelCheckNo => 'No, I am starting from zero';

  @override
  String get navHome => 'Home';

  @override
  String get navCourse => 'Courses';

  @override
  String get navStudy => 'Study';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMission => 'Mission';

  @override
  String get homeGreeting => 'Good day,';

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
      other: '$countString days',
      one: '$countString day',
    );
    return '$_temp0';
  }

  @override
  String get homeDontForgetMe => 'Don\'t forget me!';

  @override
  String get homeStreakStartTitle => 'Start your streak';

  @override
  String get homeStreakStartSubtitle =>
      'Finish your first lesson to light up your streak';

  @override
  String get homeStatsScores => 'Scores';

  @override
  String get homeStatsCoins => 'Coins';

  @override
  String get homeGoTo => 'Go to';

  @override
  String get homeAiPartnerTitle => 'AI partner';

  @override
  String get homeAiPartnerBody => 'A live conversation with AI';

  @override
  String get homeAiPartnerAction => 'Start talking';

  @override
  String get homePartnerTitle => 'Speaking partner';

  @override
  String get homePartnerBody => 'A live conversation with a partner';

  @override
  String get homeResume => 'Resume';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get coursesSearchHint => 'Search...';

  @override
  String get coursesShowLess => 'Show less';

  @override
  String get coursesNoResults => 'No courses found';

  @override
  String get coursesMyCourses => 'Current courses';

  @override
  String get coursesAvailable => 'Available courses';

  @override
  String get coursesNoneAvailable => 'No courses available.';

  @override
  String get courseUnits => 'Modules';

  @override
  String courseLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '$count lesson',
    );
    return '$_temp0';
  }

  @override
  String courseModuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modules',
      one: '$count module',
    );
    return '$_temp0';
  }

  @override
  String courseHourCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '$count hour',
    );
    return '$_temp0';
  }

  @override
  String get courseAbout => 'About the course';

  @override
  String get courseTeacher => 'Teacher';

  @override
  String get courseOtherCourses => 'Other courses';

  @override
  String get courseSeeAll => 'See all';

  @override
  String get courseNotEnrolledTitle => 'You\'re not enrolled in this course';

  @override
  String get courseNotEnrolledMessage => 'Buy a plan to open its lessons.';

  @override
  String get courseChoosePlan => 'Buy a plan';

  @override
  String get unitNoLessonsTitle => 'No lessons yet';

  @override
  String get lessonUnitLessons => 'Lessons';

  @override
  String get lessonGoToTest => 'Go to the test';

  @override
  String get lessonNoContent => 'No content';

  @override
  String get lessonVideoPlay => 'Play';

  @override
  String get lessonVideoPause => 'Pause';

  @override
  String get lessonVideoRewind => 'Back 15 seconds';

  @override
  String get lessonVideoForward => 'Forward 15 seconds';

  @override
  String get lessonVideoMute => 'Mute';

  @override
  String get lessonVideoUnmute => 'Unmute';

  @override
  String get lessonVideoFullscreen => 'Full screen';

  @override
  String get lessonVideoExitFullscreen => 'Exit full screen';

  @override
  String get lessonVideoSpeed => 'Playback speed';

  @override
  String get materialsTitle => 'Materials';

  @override
  String materialsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return '$_temp0';
  }

  @override
  String get materialsOpenFailed => 'This file couldn\'t be opened';

  @override
  String get purchaseSuccessTitle => 'You’re in!';

  @override
  String purchaseSuccessBody(String course) {
    return '$course is now yours. Time to start learning.';
  }

  @override
  String get purchaseSuccessButton => 'Start learning';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String taskProgress(int current, int total) {
    return 'Task $current of $total';
  }

  @override
  String get taskFallbackName => 'Task';

  @override
  String get taskAnswerHint => 'Type your answer…';

  @override
  String get taskSubmit => 'Submit';

  @override
  String get taskNext => 'Next';

  @override
  String get tasksEmptyTitle => 'No Tasks Yet';

  @override
  String get tasksEmptySubtitle => 'Tasks for this lesson will appear here.';

  @override
  String get taskAudioError => 'Audio could not be played';

  @override
  String get taskImageError => 'Image could not be loaded';

  @override
  String get taskResultsTitle => 'Results';

  @override
  String taskResultsSummary(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String taskResultsCoinsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count coins earned',
      one: '+$count coin earned',
    );
    return '$_temp0';
  }

  @override
  String get taskResultsCorrect => 'Correct';

  @override
  String get taskResultsIncorrect => 'Incorrect';

  @override
  String taskResultsYourAnswer(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String get taskResultsNoAnswer => 'No answer';

  @override
  String get taskResultsDone => 'Done';

  @override
  String pdfPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get pdfLoadFailed => 'This PDF couldn\'t be opened';

  @override
  String get pdfLoadFailedHint =>
      'It may be damaged, or the connection dropped.';

  @override
  String get imageLoadFailed => 'This image couldn\'t be loaded';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginSubtitlePhone =>
      'Enter your phone number to sign in to your account';

  @override
  String get loginSubtitleEmail =>
      'Enter your email to sign in to your account';

  @override
  String get loginTabPhone => 'Via phone';

  @override
  String get loginTabEmail => 'Via email';

  @override
  String get loginOr => 'or';

  @override
  String get loginTelegram => 'Sign in via Telegram';

  @override
  String get loginTelegramUnavailable =>
      'Telegram sign-in isn\'t available yet';

  @override
  String get loginLegalLead => 'By continuing you agree to the ';

  @override
  String get loginLegalOffer => 'public offer';

  @override
  String get loginLegalTail => ' terms.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get registerSubmit => 'Sign up';

  @override
  String get registerLegalOpenFailed => 'Couldn\'t open the document';

  @override
  String get forgotTitle => 'Reset password';

  @override
  String get forgotSubtitle => 'Enter your phone number and a new password';

  @override
  String get forgotSubmit => 'Send code';

  @override
  String get fieldPhone => 'Phone number';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get validationPhone => 'Enter a valid phone number';

  @override
  String get validationPassword => 'Password must be at least 8 characters';

  @override
  String get validationPasswordsMatch => 'Passwords do not match';

  @override
  String otpSubtitle(String phone) {
    return 'We sent a 6-digit code to $phone';
  }

  @override
  String otpEmailSubtitle(String email) {
    return 'We emailed a 6-digit code to $email';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpPasswordUpdated => 'Password updated successfully';

  @override
  String get profileCurrentPlan => 'Current plan';

  @override
  String get profilePlanActive => 'Active';

  @override
  String get profilePlanEnds => 'Ends on';

  @override
  String get profileNoPlanTitle => 'No active plan';

  @override
  String get profileNoPlanBody =>
      'Choose a plan for group lessons with a mentor and live lessons';

  @override
  String get profileChoosePlan => 'Choose a plan';

  @override
  String profilePlanExpired(String course) {
    return '$course plan has expired';
  }

  @override
  String profilePlanEndedOn(String date) {
    return 'Ended on: $date';
  }

  @override
  String get profileRenewPlan => 'Renew plan';

  @override
  String get profileStreak => 'Current streak';

  @override
  String get profileTotalXp => 'Total XP';

  @override
  String get profileCoins => 'Coin balance';

  @override
  String get profileRank => 'Leaderboard rank';

  @override
  String profileRankValue(int rank) {
    return '#$rank';
  }

  @override
  String get profileLanguageHint =>
      'The app will be shown in the language you choose';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileAppLanguage => 'App language';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get settingsLogOut => 'Log out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsLogOutConfirm => 'Log out?';

  @override
  String get settingsDeleteConfirm => 'Delete your account?';

  @override
  String get settingsLogOutBody =>
      'To sign back in, you\'ll need your phone number or email and your password.';

  @override
  String get settingsLogOutAction => 'Log out';

  @override
  String get settingsDeleteBody =>
      'Your profile details, progress, streak and coins will be deleted for good. This can\'t be undone.';

  @override
  String get settingsDeleteAction => 'Delete';

  @override
  String get settingsDeleteRequestedTitle => 'Request sent';

  @override
  String get settingsDeleteRequestedBody =>
      'Your account deletion request has been sent. You can keep using the app until it is processed.';

  @override
  String get chatMentor => 'Mentor';

  @override
  String get chatFile => 'File';

  @override
  String get chatHint => 'Type a message…';

  @override
  String get chatEmptyTitle => 'No messages yet';

  @override
  String get chatEmptySubtitle => 'Send a message to start the conversation.';

  @override
  String get studyEmptyTitle => 'Buy a course to choose your lesson times';

  @override
  String get studyEmptyBody =>
      'After buying a course you\'ll choose the days and times that suit you, then we\'ll add you to a group with mentors.';

  @override
  String get studyBrowseCourses => 'Browse courses';

  @override
  String get studyJoinGroup => 'Join the group';

  @override
  String get studyMentors => 'Mentors';

  @override
  String get studyPrimaryMentor => 'Lead mentor';

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
      other: '$countString members',
      one: '$countString member',
    );
    return '$_temp0';
  }

  @override
  String get studyPickTitle => 'You\'ll join a group soon';

  @override
  String studyPickBody(int count) {
    return 'Choose $count weekday times for your lessons';
  }

  @override
  String get studyWeekdays => 'Weekdays';

  @override
  String studyTimeFor(String day) {
    return 'Time — $day';
  }

  @override
  String get studyWeekdayLetters => 'Mo,Tu,We,Th,Fr,Sa,Su';

  @override
  String studyConfirm(int count, int total) {
    return 'Confirm ($count/$total)';
  }

  @override
  String studyTooManySlots(int count) {
    return 'You can choose only $count days — remove one first';
  }

  @override
  String get studyRequestSent =>
      'Request sent — we\'ll add you to a group soon';

  @override
  String get studyMentorPending => 'A mentor hasn\'t been assigned yet';

  @override
  String get studyTaskTimes => 'Task submission times';

  @override
  String get studyLoadFailed => 'Couldn\'t load your group';

  @override
  String get studyPullToRetry => 'Pull down to try again';

  @override
  String get mentorHeader => 'Mentor';

  @override
  String get mentorReviewsTitle => 'Student reviews';

  @override
  String get mentorNoReviews => 'No reviews yet';

  @override
  String get mentorLeaveReview => 'Leave a review';

  @override
  String get mentorReviewHint => 'Share your experience with this mentor...';

  @override
  String get mentorReviewSubmit => 'Submit review';

  @override
  String get mentorReviewSent => 'Thanks for your feedback!';

  @override
  String get mentorReviewRatingRequired => 'Please select a rating';

  @override
  String get purchaseHistoryTitle => 'Purchase history';

  @override
  String get purchaseHistoryPayments => 'Payments';

  @override
  String get purchaseHistoryEnrollments => 'Enrollments';

  @override
  String get purchaseHistoryLoadFailed =>
      'Couldn\'t load your purchase history';

  @override
  String get purchaseHistoryEmptyPayments => 'No payments yet';

  @override
  String get purchaseHistoryEmptyEnrollments => 'No enrollments yet';

  @override
  String get purchaseHistoryStatusCreated => 'Pending';

  @override
  String get purchaseHistoryStatusPaid => 'Paid';

  @override
  String get purchaseHistoryStatusCancelled => 'Cancelled';

  @override
  String get plansTitle => 'Choose a plan';

  @override
  String get plansLoadFailed => 'Couldn\'t load the plans';

  @override
  String get plansEmptyTitle => 'No plans yet';

  @override
  String get plansEmptySubtitle => 'This course is not on sale at the moment';

  @override
  String plansDuration(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
    );
    return '$_temp0';
  }

  @override
  String plansPrice(String amount) {
    return '$amount so\'m';
  }

  @override
  String get paymentTitle => 'Payment method';

  @override
  String get paymentLoadFailed => 'Couldn\'t start the payment';

  @override
  String get paymentEmptyTitle => 'No payment methods';

  @override
  String get paymentEmptySubtitle => 'None are set up yet';

  @override
  String paymentNoLink(String type) {
    return '$type has no checkout link yet';
  }

  @override
  String paymentOpenFailed(String type) {
    return 'Couldn\'t open $type';
  }

  @override
  String get aiTitle => 'AI partner';

  @override
  String get aiIntroTitle => 'Live conversation with AI';

  @override
  String get aiIntroBody =>
      'Tap the button and talk freely in English — the conversation runs in real time, just like a call.';

  @override
  String get aiFeatureEndAnytime => 'You can end it whenever you like';

  @override
  String get aiFeatureLiveVoice => 'A live voice conversation, in real time';

  @override
  String get aiFeatureNoScore => 'No grades or points — just talk';

  @override
  String get aiMicNote => 'The conversation needs access to your microphone.';

  @override
  String get aiEnd => 'End conversation';

  @override
  String get aiConnecting => 'Connecting…';

  @override
  String get aiInCall => 'Conversation in progress';

  @override
  String get aiYou => 'You';

  @override
  String get aiYourTurn => 'Your turn';

  @override
  String get aiMicOff => 'Mic off';

  @override
  String get aiStatusListening => 'Listening';

  @override
  String get aiStatusThinking => 'Thinking';

  @override
  String get aiStatusSpeaking => 'Speaking';

  @override
  String get aiMute => 'Mute';

  @override
  String get aiUnmute => 'Unmute';

  @override
  String get aiSoundOff => 'Mute the AI\'s voice';

  @override
  String get aiSoundOn => 'Unmute the AI\'s voice';

  @override
  String aiAutoEndNote(int minutes) {
    return 'The conversation ends automatically after $minutes minutes';
  }

  @override
  String get aiTimeUp => 'Time\'s up — the conversation has ended';

  @override
  String get aiMicDenied => 'Microphone permission denied';

  @override
  String get aiRecordFailed => 'Recording failed';

  @override
  String get aiUploadFailed => 'Upload failed. Tap to try again.';

  @override
  String get aiUploading => 'Uploading…';

  @override
  String get aiPlayingFeedback => 'Playing feedback…';

  @override
  String get aiTapToStop => 'Tap to stop';

  @override
  String get aiTapToSpeak => 'Tap to speak';

  @override
  String get aiResultsTitle => 'Skill Results';

  @override
  String get aiSkillGrammar => 'Grammar';

  @override
  String get aiSkillVocabulary => 'Vocabulary';

  @override
  String get aiSkillFluency => 'Fluency';

  @override
  String get aiSkillPronunciation => 'Pronunciation';

  @override
  String get aiSkillBreakdown => 'Skill Breakdown';

  @override
  String get aiSummary =>
      'You show strong B2-level grammar and professional vocabulary. Focus on fluency and pronunciation to reach C1.';

  @override
  String get aiStartLearning => 'Start Personalized Learning';

  @override
  String get aiYourLevel => 'Your English Level';

  @override
  String aiBasedOnResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Based on $count conversation responses',
      one: 'Based on $count conversation response',
    );
    return '$_temp0';
  }

  @override
  String aiImprovedFrom(String level) {
    return '↑ Improved from $level';
  }

  @override
  String get p2pTitle => 'Speaking Partner';

  @override
  String get p2pFinding => 'Finding your match…';

  @override
  String get p2pLookingSubtitle => 'Looking for someone at your level';

  @override
  String get p2pConnecting => 'Connecting…';

  @override
  String get p2pMatched => 'Matched';

  @override
  String get p2pConnected => 'Connected';

  @override
  String get p2pMute => 'Mute';

  @override
  String get p2pUnmute => 'Unmute';

  @override
  String get p2pEnd => 'End';

  @override
  String get p2pEndedCall => 'Call ended';

  @override
  String get p2pPeerLeft => 'Your partner left the call';

  @override
  String get p2pPeerDisconnected => 'Your partner disconnected';

  @override
  String get p2pCancelled => 'Call cancelled';

  @override
  String get p2pReplaced => 'Session replaced by another connection';

  @override
  String get p2pError => 'Call error';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptySubtitle => 'You\'re all caught up!';

  @override
  String get roadmapStart => 'Start';

  @override
  String roadmapLevelNumber(int number) {
    return 'Lv.$number';
  }

  @override
  String get roadmapLevelA1 => 'Beginner';

  @override
  String get roadmapLevelA2 => 'Elementary';

  @override
  String get roadmapLevelB1 => 'Intermediate';

  @override
  String get roadmapLevelB2 => 'Upper-Intermediate';

  @override
  String get roadmapLevelC1 => 'Advanced';

  @override
  String get roadmapLevelC2 => 'Proficiency';

  @override
  String get roadmapTopicGreetings => 'Greetings';

  @override
  String get roadmapTopicNumbersDates => 'Numbers & Dates';

  @override
  String get roadmapTopicColorsObjects => 'Colors & Objects';

  @override
  String get roadmapTopicFamily => 'Family';

  @override
  String get roadmapTopicFoodDrinks => 'Food & Drinks';

  @override
  String get roadmapTopicDailyRoutines => 'Daily Routines';

  @override
  String get roadmapTopicShopping => 'Shopping';

  @override
  String get roadmapTopicTravelTransport => 'Travel & Transport';

  @override
  String get roadmapTopicWeatherSeasons => 'Weather & Seasons';

  @override
  String get roadmapTopicHomeFurniture => 'Home & Furniture';

  @override
  String get roadmapTopicHobbies => 'Hobbies & Interests';

  @override
  String get roadmapTopicHealthBody => 'Health & Body';

  @override
  String get roadmapTopicWorkCareers => 'Work & Careers';

  @override
  String get roadmapTopicCurrentEvents => 'Current Events';

  @override
  String get roadmapTopicFuturePlans => 'Future Plans';

  @override
  String get roadmapTopicPastExperiences => 'Past Experiences';

  @override
  String get roadmapTopicOpinionsFeelings => 'Opinions & Feelings';

  @override
  String get roadmapTopicTourismCulture => 'Tourism & Culture';

  @override
  String get roadmapTopicDebates => 'Debates & Arguments';

  @override
  String get roadmapTopicSocialIssues => 'Social Issues';

  @override
  String get roadmapTopicBusinessEnglish => 'Business English';

  @override
  String get roadmapTopicMedia => 'Media & Entertainment';

  @override
  String get roadmapTopicEnvironment => 'Environment';

  @override
  String get roadmapTopicAcademicWriting => 'Academic Writing';

  @override
  String get roadmapTopicAcademicDiscourse => 'Academic Discourse';

  @override
  String get roadmapTopicProfessionalComms => 'Professional Comms';

  @override
  String get roadmapTopicIdioms => 'Idioms & Phrases';

  @override
  String get roadmapTopicLiterature => 'Literature & Arts';

  @override
  String get roadmapTopicCriticalAnalysis => 'Critical Analysis';

  @override
  String get roadmapTopicNegotiations => 'Complex Negotiations';

  @override
  String get roadmapTopicNativeFluency => 'Native-like Fluency';

  @override
  String get roadmapTopicSpecializedVocab => 'Specialized Vocabulary';

  @override
  String get roadmapTopicCulturalReferences => 'Cultural References';

  @override
  String get roadmapTopicRhetoric => 'Advanced Rhetoric';

  @override
  String get roadmapTopicCreativeWriting => 'Creative Writing';

  @override
  String get roadmapTopicPresentations => 'Expert Presentations';

  @override
  String get updateTitle => 'A new version is available';

  @override
  String get updateBody =>
      'A new version of the app is ready. Update now to enjoy the latest features.';

  @override
  String get updateAction => 'Update';

  @override
  String get otpEnterCode => 'Enter the code';

  @override
  String get registerPersonalInfo => 'Personal details';

  @override
  String get registerChangePhoto => 'Change photo';

  @override
  String get registerFirstName => 'First name';

  @override
  String get registerFirstNameHint => 'Enter your first name';

  @override
  String get registerLastName => 'Last name';

  @override
  String get registerLastNameHint => 'Enter your last name';

  @override
  String get registerPasswordHint => 'At least 8 characters';

  @override
  String get registerGender => 'Your gender';
}
