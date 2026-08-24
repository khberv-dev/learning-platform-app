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
  String get languageContinue => 'Continue';

  @override
  String get languageSettingsTitle => 'Language';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonResume => 'Resume';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOk => 'OK';

  @override
  String get commonJoin => 'Join';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get authUsePhone => 'Phone';

  @override
  String get authUseEmail => 'Email';

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
  String get onboardingHeadlineTail => '\nFaster than ever';

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
  String get navCourse => 'Course';

  @override
  String get navChat => 'Chat';

  @override
  String get navMentor => 'Mentor';

  @override
  String get navProfile => 'Profile';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get homeOnFire => 'You\'re on fire';

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
  String get homeStatsScores => 'Scores';

  @override
  String get homeStatsCoins => 'Coins';

  @override
  String get homeStatsRanking => 'Global ranking';

  @override
  String get homeLibrary => 'Library';

  @override
  String get homeNoCoursesTitle => 'No active courses yet';

  @override
  String get homeNoCoursesSubtitle => 'Browse and start learning today';

  @override
  String get homeNoCoursesButton => 'Start practice';

  @override
  String get homeProgress => 'Progress';

  @override
  String get homeResume => 'Resume';

  @override
  String get homeLiveLessons => 'Live lessons';

  @override
  String get homeLiveNow => 'LIVE NOW';

  @override
  String get homeUpcoming => 'UPCOMING';

  @override
  String get homeJoinLesson => 'Join Lesson';

  @override
  String get homeMoreUpcoming => 'More upcoming lessons';

  @override
  String get homeNoUpcomingLessons => 'No upcoming lessons';

  @override
  String get homeAiTestTitle => 'Test your skills with AI';

  @override
  String get homeAiTestBody =>
      'Speak naturally and let AI evaluate your level — get a full skill report in minutes';

  @override
  String get homeAiTestButton => 'Start test';

  @override
  String get homeSpeakingTitle => 'Find a speaking partner';

  @override
  String get homeSpeakingBody =>
      'Get matched with a real person at your level. Practice conversations that matter';

  @override
  String get homeSpeakingButton => 'Find partner';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get coursesTabCourses => 'Courses';

  @override
  String get coursesTabLive => 'Live sessions';

  @override
  String get coursesRoadmap => 'Roadmap';

  @override
  String get coursesMyCourses => 'My courses';

  @override
  String get coursesAvailable => 'Available to purchase';

  @override
  String get coursesNoneAvailable => 'No courses available.';

  @override
  String get coursesCurrentUpcoming => 'Current & Upcoming';

  @override
  String get coursesPastSessions => 'Past sessions';

  @override
  String coursesRecordedCount(int count) {
    return '$count recorded';
  }

  @override
  String get coursesNoRecordedTitle => 'No recorded sessions';

  @override
  String get coursesNoRecordedSubtitle =>
      'Recorded live sessions will appear\nhere once available';

  @override
  String get courseUnits => 'Units';

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
  String get courseChoosePlan => 'Choose a plan';

  @override
  String get courseExpired => 'Expired';

  @override
  String get courseProgress => 'Progress';

  @override
  String get courseLearnMore => 'Learn more';

  @override
  String get courseRecordedSession => 'RECORDED SESSION';

  @override
  String get courseRecorded => 'RECORDED';

  @override
  String unitNumber(String number) {
    return 'Unit $number';
  }

  @override
  String get unitNoLessonsTitle => 'No lessons yet';

  @override
  String get unitNoLessonsSubtitle => 'Lessons for this unit will appear here.';

  @override
  String get unitNotFound => 'Unit not found';

  @override
  String lessonUnitLesson(String unit, String lesson) {
    return 'Unit $unit · Lesson $lesson';
  }

  @override
  String lessonUnitLessonOf(String unit, String lesson, int total) {
    return 'Unit $unit · Lesson $lesson of $total';
  }

  @override
  String get lessonViewTasks => 'View Tasks';

  @override
  String get lessonTasksCompleted => 'Tasks Completed';

  @override
  String get lessonTasksInProgress => 'Tasks In Progress';

  @override
  String lessonScore(int correct, int total, int percent) {
    return '$correct of $total correct · $percent%';
  }

  @override
  String get lessonRetake => 'Retake';

  @override
  String get lessonInThisUnit => 'In this unit';

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
  String get materialsLoadFailed => 'Materials couldn\'t be loaded';

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
  String get loginTitle => 'Welcome back';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get registerLegalLead => 'By creating an account you agree to our\n';

  @override
  String get registerLegalTerms => 'Terms of Use';

  @override
  String get registerLegalAnd => ' and ';

  @override
  String get registerLegalPrivacy => 'Privacy Policy';

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
  String get fieldFullName => 'Full name';

  @override
  String get validationPhone => 'Enter a valid phone number';

  @override
  String get validationPassword => 'Password must be at least 8 characters';

  @override
  String get validationPasswordsMatch => 'Passwords do not match';

  @override
  String get validationFullName => 'Enter your full name';

  @override
  String get otpTitle => 'Verify Your\nPhone Number';

  @override
  String otpSubtitle(String phone) {
    return 'We sent a 6-digit code to $phone';
  }

  @override
  String get otpEmailTitle => 'Verify Your\nEmail Address';

  @override
  String otpEmailSubtitle(String email) {
    return 'We emailed a 6-digit code to $email';
  }

  @override
  String otpResendIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpPasswordUpdated => 'Password updated successfully';

  @override
  String get profilePhone => 'Phone number';

  @override
  String get profileEmail => 'Email address';

  @override
  String get profilePassword => 'Password';

  @override
  String get profileUpdatePassword => 'Update password';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsLogOut => 'Log out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsLogOutConfirm => 'Are you sure you want to log out?';

  @override
  String get settingsDeleteConfirm =>
      'Are you sure you want to delete your account? This removes your courses and progress, and cannot be undone.';

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
  String get tutorsTitle => 'Find a tutor';

  @override
  String get tutorsLoadFailed => 'Couldn\'t load tutors';

  @override
  String get tutorsPullToRetry => 'Pull down to try again';

  @override
  String get tutorsEmptyTitle => 'No tutors yet';

  @override
  String get tutorsEmptySubtitle => 'Tutors will appear here once they join';

  @override
  String get tutorsAvailable => 'Available tutors';

  @override
  String get tutorHeader => 'Tutor';

  @override
  String get tutorReviewsTitle => 'Student reviews';

  @override
  String get tutorNoReviews => 'No reviews yet';

  @override
  String get tutorBook => 'Book tutor';

  @override
  String get tutorBookingSent => 'Booking request sent';

  @override
  String tutorRatingReviews(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '$count review',
    );
    return '$rating  ·  $_temp0';
  }

  @override
  String get bookTitle => 'Select Schedule';

  @override
  String bookSubtitle(String name) {
    return 'Choose up to 3 weekly slots with $name';
  }

  @override
  String get bookLoadFailed => 'Could not load schedule';

  @override
  String get bookNoAvailability =>
      'This tutor hasn\'t set availability yet.\nYou can still send a booking request.';

  @override
  String bookSlotsSelected(int count) {
    return '$count/3 slots selected';
  }

  @override
  String get bookConfirm => 'Confirm Booking';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

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
  String get plansWithMentor => 'With mentor';

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
  String get aiTitle => 'AI Assessment';

  @override
  String get aiInitialPrompt => 'Try to speak anything you want!';

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
  String get aiListening => 'Listening…';

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
}
