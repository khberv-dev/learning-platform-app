import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ru'),
    Locale('uz'),
  ];

  /// Title of the language picker shown after the splash screen
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in your profile'**
  String get languageSubtitle;

  /// No description provided for @languageContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get languageContinue;

  /// No description provided for @languageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingsTitle;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get commonResume;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get commonJoin;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @authUsePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authUsePhone;

  /// No description provided for @authUseEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authUseEmail;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get fieldEmail;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// No description provided for @commonOpenOutsideApp.
  ///
  /// In en, this message translates to:
  /// **'Open outside the app'**
  String get commonOpenOutsideApp;

  /// No description provided for @commonShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get commonShowPassword;

  /// No description provided for @commonHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get commonHidePassword;

  /// Screen-reader label for a star rating
  ///
  /// In en, this message translates to:
  /// **'{rating} out of {count}'**
  String commonRatingOutOf(String rating, int count);

  /// No description provided for @splashWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to iTeach!'**
  String get splashWelcome;

  /// No description provided for @onboardingHeadlineLead.
  ///
  /// In en, this message translates to:
  /// **'Learn '**
  String get onboardingHeadlineLead;

  /// No description provided for @onboardingHeadlineHighlight.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get onboardingHeadlineHighlight;

  /// No description provided for @onboardingHeadlineTail.
  ///
  /// In en, this message translates to:
  /// **'\nFaster than ever'**
  String get onboardingHeadlineTail;

  /// No description provided for @onboardingFreshStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get a Fresh Start'**
  String get onboardingFreshStart;

  /// No description provided for @onboardingResume.
  ///
  /// In en, this message translates to:
  /// **'Resume Journey'**
  String get onboardingResume;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to iTeach'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personalized English\nlearning journey starts here'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get welcomeSignIn;

  /// No description provided for @noConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnectionTitle;

  /// No description provided for @noConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server.\nCheck your connection and try again.'**
  String get noConnectionMessage;

  /// No description provided for @noConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get noConnectionRetry;

  /// No description provided for @surveyReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you learning English?'**
  String get surveyReasonTitle;

  /// No description provided for @surveyReasonDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the one that fits best'**
  String get surveyReasonDescription;

  /// No description provided for @surveyReasonCareer.
  ///
  /// In en, this message translates to:
  /// **'Career Growth'**
  String get surveyReasonCareer;

  /// No description provided for @surveyReasonTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel & Adventure'**
  String get surveyReasonTravel;

  /// No description provided for @surveyReasonAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic Studies'**
  String get surveyReasonAcademic;

  /// No description provided for @surveyReasonPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Interest'**
  String get surveyReasonPersonal;

  /// No description provided for @surveyReasonImmigration.
  ///
  /// In en, this message translates to:
  /// **'Immigration'**
  String get surveyReasonImmigration;

  /// No description provided for @surveyTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time can you spend daily?'**
  String get surveyTimeTitle;

  /// No description provided for @surveyTimeDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll build a schedule that fits your lifestyle'**
  String get surveyTimeDescription;

  /// No description provided for @surveyTime5.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get surveyTime5;

  /// No description provided for @surveyTime15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get surveyTime15;

  /// No description provided for @surveyTime30.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get surveyTime30;

  /// No description provided for @surveyTime60.
  ///
  /// In en, this message translates to:
  /// **'1+ hour'**
  String get surveyTime60;

  /// No description provided for @levelCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you already know some English?'**
  String get levelCheckTitle;

  /// No description provided for @levelCheckDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have studied before, a short test places you at the right level'**
  String get levelCheckDescription;

  /// No description provided for @levelCheckYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I have studied some'**
  String get levelCheckYes;

  /// No description provided for @levelCheckNo.
  ///
  /// In en, this message translates to:
  /// **'No, I am starting from zero'**
  String get levelCheckNo;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get navCourse;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navMentor.
  ///
  /// In en, this message translates to:
  /// **'Mentor'**
  String get navMentor;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// No description provided for @homeOnFire.
  ///
  /// In en, this message translates to:
  /// **'You\'re on fire'**
  String get homeOnFire;

  /// Streaks run into the thousands, so the count is grouped
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String homeStreakDays(int count);

  /// No description provided for @homeDontForgetMe.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget me!'**
  String get homeDontForgetMe;

  /// No description provided for @homeStatsScores.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get homeStatsScores;

  /// No description provided for @homeStatsCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get homeStatsCoins;

  /// No description provided for @homeStatsRanking.
  ///
  /// In en, this message translates to:
  /// **'Global ranking'**
  String get homeStatsRanking;

  /// No description provided for @homeLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get homeLibrary;

  /// No description provided for @homeNoCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'No active courses yet'**
  String get homeNoCoursesTitle;

  /// No description provided for @homeNoCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse and start learning today'**
  String get homeNoCoursesSubtitle;

  /// No description provided for @homeNoCoursesButton.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get homeNoCoursesButton;

  /// No description provided for @homeProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeProgress;

  /// No description provided for @homeResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get homeResume;

  /// No description provided for @homeLiveLessons.
  ///
  /// In en, this message translates to:
  /// **'Live lessons'**
  String get homeLiveLessons;

  /// No description provided for @homeLiveNow.
  ///
  /// In en, this message translates to:
  /// **'LIVE NOW'**
  String get homeLiveNow;

  /// No description provided for @homeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get homeUpcoming;

  /// No description provided for @homeJoinLesson.
  ///
  /// In en, this message translates to:
  /// **'Join Lesson'**
  String get homeJoinLesson;

  /// No description provided for @homeMoreUpcoming.
  ///
  /// In en, this message translates to:
  /// **'More upcoming lessons'**
  String get homeMoreUpcoming;

  /// No description provided for @homeNoUpcomingLessons.
  ///
  /// In en, this message translates to:
  /// **'No upcoming lessons'**
  String get homeNoUpcomingLessons;

  /// No description provided for @homeAiTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test your skills with AI'**
  String get homeAiTestTitle;

  /// No description provided for @homeAiTestBody.
  ///
  /// In en, this message translates to:
  /// **'Speak naturally and let AI evaluate your level — get a full skill report in minutes'**
  String get homeAiTestBody;

  /// No description provided for @homeAiTestButton.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get homeAiTestButton;

  /// No description provided for @homeSpeakingTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a speaking partner'**
  String get homeSpeakingTitle;

  /// No description provided for @homeSpeakingBody.
  ///
  /// In en, this message translates to:
  /// **'Get matched with a real person at your level. Practice conversations that matter'**
  String get homeSpeakingBody;

  /// No description provided for @homeSpeakingButton.
  ///
  /// In en, this message translates to:
  /// **'Find partner'**
  String get homeSpeakingButton;

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// No description provided for @coursesTabCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTabCourses;

  /// No description provided for @coursesTabLive.
  ///
  /// In en, this message translates to:
  /// **'Live sessions'**
  String get coursesTabLive;

  /// No description provided for @coursesRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Roadmap'**
  String get coursesRoadmap;

  /// No description provided for @coursesMyCourses.
  ///
  /// In en, this message translates to:
  /// **'My courses'**
  String get coursesMyCourses;

  /// No description provided for @coursesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available to purchase'**
  String get coursesAvailable;

  /// No description provided for @coursesNoneAvailable.
  ///
  /// In en, this message translates to:
  /// **'No courses available.'**
  String get coursesNoneAvailable;

  /// No description provided for @coursesCurrentUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Current & Upcoming'**
  String get coursesCurrentUpcoming;

  /// No description provided for @coursesPastSessions.
  ///
  /// In en, this message translates to:
  /// **'Past sessions'**
  String get coursesPastSessions;

  /// No description provided for @coursesRecordedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recorded'**
  String coursesRecordedCount(int count);

  /// No description provided for @coursesNoRecordedTitle.
  ///
  /// In en, this message translates to:
  /// **'No recorded sessions'**
  String get coursesNoRecordedTitle;

  /// No description provided for @coursesNoRecordedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded live sessions will appear\nhere once available'**
  String get coursesNoRecordedSubtitle;

  /// No description provided for @courseUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get courseUnits;

  /// No description provided for @courseLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} lesson} other{{count} lessons}}'**
  String courseLessonCount(int count);

  /// No description provided for @courseChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get courseChoosePlan;

  /// No description provided for @courseExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get courseExpired;

  /// No description provided for @courseProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get courseProgress;

  /// No description provided for @courseLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get courseLearnMore;

  /// No description provided for @courseRecordedSession.
  ///
  /// In en, this message translates to:
  /// **'RECORDED SESSION'**
  String get courseRecordedSession;

  /// No description provided for @courseRecorded.
  ///
  /// In en, this message translates to:
  /// **'RECORDED'**
  String get courseRecorded;

  /// No description provided for @unitNumber.
  ///
  /// In en, this message translates to:
  /// **'Unit {number}'**
  String unitNumber(String number);

  /// No description provided for @unitNoLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'No lessons yet'**
  String get unitNoLessonsTitle;

  /// No description provided for @unitNoLessonsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons for this unit will appear here.'**
  String get unitNoLessonsSubtitle;

  /// No description provided for @unitNotFound.
  ///
  /// In en, this message translates to:
  /// **'Unit not found'**
  String get unitNotFound;

  /// The numbers are zero-padded strings, e.g. 01
  ///
  /// In en, this message translates to:
  /// **'Unit {unit} · Lesson {lesson}'**
  String lessonUnitLesson(String unit, String lesson);

  /// No description provided for @lessonUnitLessonOf.
  ///
  /// In en, this message translates to:
  /// **'Unit {unit} · Lesson {lesson} of {total}'**
  String lessonUnitLessonOf(String unit, String lesson, int total);

  /// No description provided for @lessonViewTasks.
  ///
  /// In en, this message translates to:
  /// **'View Tasks'**
  String get lessonViewTasks;

  /// No description provided for @lessonTasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get lessonTasksCompleted;

  /// No description provided for @lessonTasksInProgress.
  ///
  /// In en, this message translates to:
  /// **'Tasks In Progress'**
  String get lessonTasksInProgress;

  /// No description provided for @lessonScore.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct · {percent}%'**
  String lessonScore(int correct, int total, int percent);

  /// No description provided for @lessonRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get lessonRetake;

  /// No description provided for @lessonInThisUnit.
  ///
  /// In en, this message translates to:
  /// **'In this unit'**
  String get lessonInThisUnit;

  /// No description provided for @materialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materialsTitle;

  /// No description provided for @materialsFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} file} other{{count} files}}'**
  String materialsFileCount(int count);

  /// No description provided for @materialsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Materials couldn\'t be loaded'**
  String get materialsLoadFailed;

  /// No description provided for @materialsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'This file couldn\'t be opened'**
  String get materialsOpenFailed;

  /// No description provided for @purchaseSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re in!'**
  String get purchaseSuccessTitle;

  /// No description provided for @purchaseSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{course} is now yours. Time to start learning.'**
  String purchaseSuccessBody(String course);

  /// No description provided for @purchaseSuccessButton.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get purchaseSuccessButton;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @taskProgress.
  ///
  /// In en, this message translates to:
  /// **'Task {current} of {total}'**
  String taskProgress(int current, int total);

  /// No description provided for @taskFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskFallbackName;

  /// No description provided for @taskAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer…'**
  String get taskAnswerHint;

  /// No description provided for @taskSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get taskSubmit;

  /// No description provided for @taskNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get taskNext;

  /// No description provided for @tasksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Tasks Yet'**
  String get tasksEmptyTitle;

  /// No description provided for @tasksEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks for this lesson will appear here.'**
  String get tasksEmptySubtitle;

  /// No description provided for @taskAudioError.
  ///
  /// In en, this message translates to:
  /// **'Audio could not be played'**
  String get taskAudioError;

  /// No description provided for @taskImageError.
  ///
  /// In en, this message translates to:
  /// **'Image could not be loaded'**
  String get taskImageError;

  /// No description provided for @pdfPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pdfPageOf(int current, int total);

  /// No description provided for @pdfLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This PDF couldn\'t be opened'**
  String get pdfLoadFailed;

  /// No description provided for @pdfLoadFailedHint.
  ///
  /// In en, this message translates to:
  /// **'It may be damaged, or the connection dropped.'**
  String get pdfLoadFailedHint;

  /// No description provided for @imageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This image couldn\'t be loaded'**
  String get imageLoadFailed;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmit;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerSubmit;

  /// No description provided for @registerLegalLead.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to our\n'**
  String get registerLegalLead;

  /// No description provided for @registerLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get registerLegalTerms;

  /// No description provided for @registerLegalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get registerLegalAnd;

  /// No description provided for @registerLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get registerLegalPrivacy;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number and a new password'**
  String get forgotSubtitle;

  /// No description provided for @forgotSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotSubmit;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get fieldPhone;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get fieldNewPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldConfirmPassword;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validationPhone;

  /// No description provided for @validationPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPassword;

  /// No description provided for @validationPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsMatch;

  /// No description provided for @validationFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get validationFullName;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your\nPhone Number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your\nEmail Address'**
  String get otpEmailTitle;

  /// No description provided for @otpEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We emailed a 6-digit code to {email}'**
  String otpEmailSubtitle(String email);

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// No description provided for @otpPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get otpPasswordUpdated;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhone;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get profileEmail;

  /// No description provided for @profilePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get profilePassword;

  /// No description provided for @profileUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get profileUpdatePassword;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogOut;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settingsLogOutConfirm;

  /// No description provided for @settingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This removes your courses and progress, and cannot be undone.'**
  String get settingsDeleteConfirm;

  /// No description provided for @settingsDeleteRequestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get settingsDeleteRequestedTitle;

  /// No description provided for @settingsDeleteRequestedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account deletion request has been sent. You can keep using the app until it is processed.'**
  String get settingsDeleteRequestedBody;

  /// No description provided for @chatMentor.
  ///
  /// In en, this message translates to:
  /// **'Mentor'**
  String get chatMentor;

  /// No description provided for @chatFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get chatFile;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatHint;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the conversation.'**
  String get chatEmptySubtitle;

  /// No description provided for @tutorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a tutor'**
  String get tutorsTitle;

  /// No description provided for @tutorsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load tutors'**
  String get tutorsLoadFailed;

  /// No description provided for @tutorsPullToRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again'**
  String get tutorsPullToRetry;

  /// No description provided for @tutorsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tutors yet'**
  String get tutorsEmptyTitle;

  /// No description provided for @tutorsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tutors will appear here once they join'**
  String get tutorsEmptySubtitle;

  /// No description provided for @tutorsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available tutors'**
  String get tutorsAvailable;

  /// No description provided for @tutorHeader.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get tutorHeader;

  /// No description provided for @tutorReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student reviews'**
  String get tutorReviewsTitle;

  /// No description provided for @tutorNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get tutorNoReviews;

  /// No description provided for @tutorBook.
  ///
  /// In en, this message translates to:
  /// **'Book tutor'**
  String get tutorBook;

  /// No description provided for @tutorBookingSent.
  ///
  /// In en, this message translates to:
  /// **'Booking request sent'**
  String get tutorBookingSent;

  /// No description provided for @tutorRatingReviews.
  ///
  /// In en, this message translates to:
  /// **'{rating}  ·  {count, plural, one{{count} review} other{{count} reviews}}'**
  String tutorRatingReviews(String rating, int count);

  /// No description provided for @bookTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Schedule'**
  String get bookTitle;

  /// No description provided for @bookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 3 weekly slots with {name}'**
  String bookSubtitle(String name);

  /// No description provided for @bookLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load schedule'**
  String get bookLoadFailed;

  /// No description provided for @bookNoAvailability.
  ///
  /// In en, this message translates to:
  /// **'This tutor hasn\'t set availability yet.\nYou can still send a booking request.'**
  String get bookNoAvailability;

  /// No description provided for @bookSlotsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count}/3 slots selected'**
  String bookSlotsSelected(int count);

  /// No description provided for @bookConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get bookConfirm;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get plansTitle;

  /// No description provided for @plansLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the plans'**
  String get plansLoadFailed;

  /// No description provided for @plansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No plans yet'**
  String get plansEmptyTitle;

  /// No description provided for @plansEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This course is not on sale at the moment'**
  String get plansEmptySubtitle;

  /// No description provided for @plansDuration.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} month} other{{count} months}}'**
  String plansDuration(int count);

  /// No description provided for @plansPrice.
  ///
  /// In en, this message translates to:
  /// **'{amount} so\'m'**
  String plansPrice(String amount);

  /// No description provided for @plansWithMentor.
  ///
  /// In en, this message translates to:
  /// **'With mentor'**
  String get plansWithMentor;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentTitle;

  /// No description provided for @paymentLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the payment'**
  String get paymentLoadFailed;

  /// No description provided for @paymentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payment methods'**
  String get paymentEmptyTitle;

  /// No description provided for @paymentEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'None are set up yet'**
  String get paymentEmptySubtitle;

  /// No description provided for @paymentNoLink.
  ///
  /// In en, this message translates to:
  /// **'{type} has no checkout link yet'**
  String paymentNoLink(String type);

  /// No description provided for @paymentOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open {type}'**
  String paymentOpenFailed(String type);

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assessment'**
  String get aiTitle;

  /// No description provided for @aiInitialPrompt.
  ///
  /// In en, this message translates to:
  /// **'Try to speak anything you want!'**
  String get aiInitialPrompt;

  /// No description provided for @aiMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get aiMicDenied;

  /// No description provided for @aiRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Recording failed'**
  String get aiRecordFailed;

  /// No description provided for @aiUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Tap to try again.'**
  String get aiUploadFailed;

  /// No description provided for @aiUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get aiUploading;

  /// No description provided for @aiPlayingFeedback.
  ///
  /// In en, this message translates to:
  /// **'Playing feedback…'**
  String get aiPlayingFeedback;

  /// No description provided for @aiTapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get aiTapToStop;

  /// No description provided for @aiTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get aiTapToSpeak;

  /// No description provided for @aiListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get aiListening;

  /// No description provided for @aiResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skill Results'**
  String get aiResultsTitle;

  /// No description provided for @aiSkillGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get aiSkillGrammar;

  /// No description provided for @aiSkillVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get aiSkillVocabulary;

  /// No description provided for @aiSkillFluency.
  ///
  /// In en, this message translates to:
  /// **'Fluency'**
  String get aiSkillFluency;

  /// No description provided for @aiSkillPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get aiSkillPronunciation;

  /// No description provided for @aiSkillBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Skill Breakdown'**
  String get aiSkillBreakdown;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'You show strong B2-level grammar and professional vocabulary. Focus on fluency and pronunciation to reach C1.'**
  String get aiSummary;

  /// No description provided for @aiStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Personalized Learning'**
  String get aiStartLearning;

  /// No description provided for @aiYourLevel.
  ///
  /// In en, this message translates to:
  /// **'Your English Level'**
  String get aiYourLevel;

  /// No description provided for @aiBasedOnResponses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Based on {count} conversation response} other{Based on {count} conversation responses}}'**
  String aiBasedOnResponses(int count);

  /// No description provided for @aiImprovedFrom.
  ///
  /// In en, this message translates to:
  /// **'↑ Improved from {level}'**
  String aiImprovedFrom(String level);

  /// No description provided for @p2pTitle.
  ///
  /// In en, this message translates to:
  /// **'Speaking Partner'**
  String get p2pTitle;

  /// No description provided for @p2pFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding your match…'**
  String get p2pFinding;

  /// No description provided for @p2pLookingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for someone at your level'**
  String get p2pLookingSubtitle;

  /// No description provided for @p2pConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get p2pConnecting;

  /// No description provided for @p2pMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get p2pMatched;

  /// No description provided for @p2pConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get p2pConnected;

  /// No description provided for @p2pMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get p2pMute;

  /// No description provided for @p2pUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get p2pUnmute;

  /// No description provided for @p2pEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get p2pEnd;

  /// No description provided for @p2pEndedCall.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get p2pEndedCall;

  /// No description provided for @p2pPeerLeft.
  ///
  /// In en, this message translates to:
  /// **'Your partner left the call'**
  String get p2pPeerLeft;

  /// No description provided for @p2pPeerDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Your partner disconnected'**
  String get p2pPeerDisconnected;

  /// No description provided for @p2pCancelled.
  ///
  /// In en, this message translates to:
  /// **'Call cancelled'**
  String get p2pCancelled;

  /// No description provided for @p2pReplaced.
  ///
  /// In en, this message translates to:
  /// **'Session replaced by another connection'**
  String get p2pReplaced;

  /// No description provided for @p2pError.
  ///
  /// In en, this message translates to:
  /// **'Call error'**
  String get p2pError;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get notificationsEmptySubtitle;

  /// No description provided for @roadmapLevelA1.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get roadmapLevelA1;

  /// No description provided for @roadmapLevelA2.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get roadmapLevelA2;

  /// No description provided for @roadmapLevelB1.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get roadmapLevelB1;

  /// No description provided for @roadmapLevelB2.
  ///
  /// In en, this message translates to:
  /// **'Upper-Intermediate'**
  String get roadmapLevelB2;

  /// No description provided for @roadmapLevelC1.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get roadmapLevelC1;

  /// No description provided for @roadmapLevelC2.
  ///
  /// In en, this message translates to:
  /// **'Proficiency'**
  String get roadmapLevelC2;

  /// No description provided for @roadmapTopicGreetings.
  ///
  /// In en, this message translates to:
  /// **'Greetings'**
  String get roadmapTopicGreetings;

  /// No description provided for @roadmapTopicNumbersDates.
  ///
  /// In en, this message translates to:
  /// **'Numbers & Dates'**
  String get roadmapTopicNumbersDates;

  /// No description provided for @roadmapTopicColorsObjects.
  ///
  /// In en, this message translates to:
  /// **'Colors & Objects'**
  String get roadmapTopicColorsObjects;

  /// No description provided for @roadmapTopicFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get roadmapTopicFamily;

  /// No description provided for @roadmapTopicFoodDrinks.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get roadmapTopicFoodDrinks;

  /// No description provided for @roadmapTopicDailyRoutines.
  ///
  /// In en, this message translates to:
  /// **'Daily Routines'**
  String get roadmapTopicDailyRoutines;

  /// No description provided for @roadmapTopicShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get roadmapTopicShopping;

  /// No description provided for @roadmapTopicTravelTransport.
  ///
  /// In en, this message translates to:
  /// **'Travel & Transport'**
  String get roadmapTopicTravelTransport;

  /// No description provided for @roadmapTopicWeatherSeasons.
  ///
  /// In en, this message translates to:
  /// **'Weather & Seasons'**
  String get roadmapTopicWeatherSeasons;

  /// No description provided for @roadmapTopicHomeFurniture.
  ///
  /// In en, this message translates to:
  /// **'Home & Furniture'**
  String get roadmapTopicHomeFurniture;

  /// No description provided for @roadmapTopicHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies & Interests'**
  String get roadmapTopicHobbies;

  /// No description provided for @roadmapTopicHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Health & Body'**
  String get roadmapTopicHealthBody;

  /// No description provided for @roadmapTopicWorkCareers.
  ///
  /// In en, this message translates to:
  /// **'Work & Careers'**
  String get roadmapTopicWorkCareers;

  /// No description provided for @roadmapTopicCurrentEvents.
  ///
  /// In en, this message translates to:
  /// **'Current Events'**
  String get roadmapTopicCurrentEvents;

  /// No description provided for @roadmapTopicFuturePlans.
  ///
  /// In en, this message translates to:
  /// **'Future Plans'**
  String get roadmapTopicFuturePlans;

  /// No description provided for @roadmapTopicPastExperiences.
  ///
  /// In en, this message translates to:
  /// **'Past Experiences'**
  String get roadmapTopicPastExperiences;

  /// No description provided for @roadmapTopicOpinionsFeelings.
  ///
  /// In en, this message translates to:
  /// **'Opinions & Feelings'**
  String get roadmapTopicOpinionsFeelings;

  /// No description provided for @roadmapTopicTourismCulture.
  ///
  /// In en, this message translates to:
  /// **'Tourism & Culture'**
  String get roadmapTopicTourismCulture;

  /// No description provided for @roadmapTopicDebates.
  ///
  /// In en, this message translates to:
  /// **'Debates & Arguments'**
  String get roadmapTopicDebates;

  /// No description provided for @roadmapTopicSocialIssues.
  ///
  /// In en, this message translates to:
  /// **'Social Issues'**
  String get roadmapTopicSocialIssues;

  /// No description provided for @roadmapTopicBusinessEnglish.
  ///
  /// In en, this message translates to:
  /// **'Business English'**
  String get roadmapTopicBusinessEnglish;

  /// No description provided for @roadmapTopicMedia.
  ///
  /// In en, this message translates to:
  /// **'Media & Entertainment'**
  String get roadmapTopicMedia;

  /// No description provided for @roadmapTopicEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get roadmapTopicEnvironment;

  /// No description provided for @roadmapTopicAcademicWriting.
  ///
  /// In en, this message translates to:
  /// **'Academic Writing'**
  String get roadmapTopicAcademicWriting;

  /// No description provided for @roadmapTopicAcademicDiscourse.
  ///
  /// In en, this message translates to:
  /// **'Academic Discourse'**
  String get roadmapTopicAcademicDiscourse;

  /// No description provided for @roadmapTopicProfessionalComms.
  ///
  /// In en, this message translates to:
  /// **'Professional Comms'**
  String get roadmapTopicProfessionalComms;

  /// No description provided for @roadmapTopicIdioms.
  ///
  /// In en, this message translates to:
  /// **'Idioms & Phrases'**
  String get roadmapTopicIdioms;

  /// No description provided for @roadmapTopicLiterature.
  ///
  /// In en, this message translates to:
  /// **'Literature & Arts'**
  String get roadmapTopicLiterature;

  /// No description provided for @roadmapTopicCriticalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Critical Analysis'**
  String get roadmapTopicCriticalAnalysis;

  /// No description provided for @roadmapTopicNegotiations.
  ///
  /// In en, this message translates to:
  /// **'Complex Negotiations'**
  String get roadmapTopicNegotiations;

  /// No description provided for @roadmapTopicNativeFluency.
  ///
  /// In en, this message translates to:
  /// **'Native-like Fluency'**
  String get roadmapTopicNativeFluency;

  /// No description provided for @roadmapTopicSpecializedVocab.
  ///
  /// In en, this message translates to:
  /// **'Specialized Vocabulary'**
  String get roadmapTopicSpecializedVocab;

  /// No description provided for @roadmapTopicCulturalReferences.
  ///
  /// In en, this message translates to:
  /// **'Cultural References'**
  String get roadmapTopicCulturalReferences;

  /// No description provided for @roadmapTopicRhetoric.
  ///
  /// In en, this message translates to:
  /// **'Advanced Rhetoric'**
  String get roadmapTopicRhetoric;

  /// No description provided for @roadmapTopicCreativeWriting.
  ///
  /// In en, this message translates to:
  /// **'Creative Writing'**
  String get roadmapTopicCreativeWriting;

  /// No description provided for @roadmapTopicPresentations.
  ///
  /// In en, this message translates to:
  /// **'Expert Presentations'**
  String get roadmapTopicPresentations;
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
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
