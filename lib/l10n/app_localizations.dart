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

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

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
  /// **' faster than ever before'**
  String get onboardingHeadlineTail;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your level — we\'ll build a study plan that fits you'**
  String get onboardingSubtitle;

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
  /// **'Courses'**
  String get navCourse;

  /// No description provided for @navStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get navStudy;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get navMission;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good day,'**
  String get homeGreeting;

  /// No description provided for @homeGreetingName.
  ///
  /// In en, this message translates to:
  /// **'{name}!'**
  String homeGreetingName(String name);

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

  /// No description provided for @homeStreakStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your streak'**
  String get homeStreakStartTitle;

  /// No description provided for @homeStreakStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your first lesson to light up your streak'**
  String get homeStreakStartSubtitle;

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

  /// No description provided for @homeGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get homeGoTo;

  /// No description provided for @homeAiPartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'AI partner'**
  String get homeAiPartnerTitle;

  /// No description provided for @homeAiPartnerBody.
  ///
  /// In en, this message translates to:
  /// **'A live conversation with AI'**
  String get homeAiPartnerBody;

  /// No description provided for @homeAiPartnerAction.
  ///
  /// In en, this message translates to:
  /// **'Start talking'**
  String get homeAiPartnerAction;

  /// No description provided for @homePartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Speaking partner'**
  String get homePartnerTitle;

  /// No description provided for @homePartnerBody.
  ///
  /// In en, this message translates to:
  /// **'A live conversation with a partner'**
  String get homePartnerBody;

  /// No description provided for @homeResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get homeResume;

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// No description provided for @coursesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get coursesSearchHint;

  /// No description provided for @coursesShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get coursesShowLess;

  /// No description provided for @coursesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No courses found'**
  String get coursesNoResults;

  /// No description provided for @coursesMyCourses.
  ///
  /// In en, this message translates to:
  /// **'Current courses'**
  String get coursesMyCourses;

  /// No description provided for @coursesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available courses'**
  String get coursesAvailable;

  /// No description provided for @coursesNoneAvailable.
  ///
  /// In en, this message translates to:
  /// **'No courses available.'**
  String get coursesNoneAvailable;

  /// No description provided for @courseUnits.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get courseUnits;

  /// No description provided for @courseLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} lesson} other{{count} lessons}}'**
  String courseLessonCount(int count);

  /// No description provided for @courseModuleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} module} other{{count} modules}}'**
  String courseModuleCount(int count);

  /// No description provided for @courseHourCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} hour} other{{count} hours}}'**
  String courseHourCount(int count);

  /// No description provided for @courseAbout.
  ///
  /// In en, this message translates to:
  /// **'About the course'**
  String get courseAbout;

  /// No description provided for @courseTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get courseTeacher;

  /// No description provided for @courseOtherCourses.
  ///
  /// In en, this message translates to:
  /// **'Other courses'**
  String get courseOtherCourses;

  /// No description provided for @courseSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get courseSeeAll;

  /// No description provided for @courseNotEnrolledTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re not enrolled in this course'**
  String get courseNotEnrolledTitle;

  /// No description provided for @courseNotEnrolledMessage.
  ///
  /// In en, this message translates to:
  /// **'Buy a plan to open its lessons.'**
  String get courseNotEnrolledMessage;

  /// No description provided for @courseChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Buy a plan'**
  String get courseChoosePlan;

  /// No description provided for @unitNoLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'No lessons yet'**
  String get unitNoLessonsTitle;

  /// No description provided for @lessonUnitLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessonUnitLessons;

  /// No description provided for @lessonGoToTest.
  ///
  /// In en, this message translates to:
  /// **'Go to the test'**
  String get lessonGoToTest;

  /// No description provided for @lessonNoContent.
  ///
  /// In en, this message translates to:
  /// **'No content'**
  String get lessonNoContent;

  /// No description provided for @lessonVideoPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get lessonVideoPlay;

  /// No description provided for @lessonVideoPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get lessonVideoPause;

  /// No description provided for @lessonVideoRewind.
  ///
  /// In en, this message translates to:
  /// **'Back 15 seconds'**
  String get lessonVideoRewind;

  /// No description provided for @lessonVideoForward.
  ///
  /// In en, this message translates to:
  /// **'Forward 15 seconds'**
  String get lessonVideoForward;

  /// No description provided for @lessonVideoMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get lessonVideoMute;

  /// No description provided for @lessonVideoUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get lessonVideoUnmute;

  /// No description provided for @lessonVideoFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get lessonVideoFullscreen;

  /// No description provided for @lessonVideoExitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get lessonVideoExitFullscreen;

  /// No description provided for @lessonVideoSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get lessonVideoSpeed;

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

  /// No description provided for @taskResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get taskResultsTitle;

  /// No description provided for @taskResultsSummary.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String taskResultsSummary(int correct, int total);

  /// No description provided for @taskResultsCoinsEarned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{+{count} coin earned} other{+{count} coins earned}}'**
  String taskResultsCoinsEarned(int count);

  /// No description provided for @taskResultsCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get taskResultsCorrect;

  /// No description provided for @taskResultsIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get taskResultsIncorrect;

  /// No description provided for @taskResultsYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String taskResultsYourAnswer(String answer);

  /// No description provided for @taskResultsNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get taskResultsNoAnswer;

  /// No description provided for @taskResultsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskResultsDone;

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
  /// **'Log in'**
  String get loginTitle;

  /// No description provided for @loginSubtitlePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to sign in to your account'**
  String get loginSubtitlePhone;

  /// No description provided for @loginSubtitleEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to sign in to your account'**
  String get loginSubtitleEmail;

  /// No description provided for @loginTabPhone.
  ///
  /// In en, this message translates to:
  /// **'Via phone'**
  String get loginTabPhone;

  /// No description provided for @loginTabEmail.
  ///
  /// In en, this message translates to:
  /// **'Via email'**
  String get loginTabEmail;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOr;

  /// No description provided for @loginTelegram.
  ///
  /// In en, this message translates to:
  /// **'Sign in via Telegram'**
  String get loginTelegram;

  /// No description provided for @loginTelegramUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Telegram sign-in isn\'t available yet'**
  String get loginTelegramUnavailable;

  /// No description provided for @loginLegalLead.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the '**
  String get loginLegalLead;

  /// No description provided for @loginLegalOffer.
  ///
  /// In en, this message translates to:
  /// **'public offer'**
  String get loginLegalOffer;

  /// No description provided for @loginLegalTail.
  ///
  /// In en, this message translates to:
  /// **' terms.'**
  String get loginLegalTail;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmit;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerSubmit;

  /// No description provided for @registerLegalOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the document'**
  String get registerLegalOpenFailed;

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

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

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

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We emailed a 6-digit code to {email}'**
  String otpEmailSubtitle(String email);

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

  /// No description provided for @profileCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get profileCurrentPlan;

  /// No description provided for @profilePlanActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profilePlanActive;

  /// No description provided for @profilePlanEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get profilePlanEnds;

  /// No description provided for @profileNoPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get profileNoPlanTitle;

  /// No description provided for @profileNoPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan for group lessons with a mentor and live lessons'**
  String get profileNoPlanBody;

  /// No description provided for @profileChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get profileChoosePlan;

  /// No description provided for @profilePlanExpired.
  ///
  /// In en, this message translates to:
  /// **'{course} plan has expired'**
  String profilePlanExpired(String course);

  /// No description provided for @profilePlanEndedOn.
  ///
  /// In en, this message translates to:
  /// **'Ended on: {date}'**
  String profilePlanEndedOn(String date);

  /// No description provided for @profileRenewPlan.
  ///
  /// In en, this message translates to:
  /// **'Renew plan'**
  String get profileRenewPlan;

  /// No description provided for @profileStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get profileStreak;

  /// No description provided for @profileTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get profileTotalXp;

  /// No description provided for @profileCoins.
  ///
  /// In en, this message translates to:
  /// **'Coin balance'**
  String get profileCoins;

  /// No description provided for @profileRank.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard rank'**
  String get profileRank;

  /// No description provided for @profileRankValue.
  ///
  /// In en, this message translates to:
  /// **'#{rank}'**
  String profileRankValue(int rank);

  /// No description provided for @profileLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'The app will be shown in the language you choose'**
  String get profileLanguageHint;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileAppLanguage;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

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
  /// **'Log out?'**
  String get settingsLogOutConfirm;

  /// No description provided for @settingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteConfirm;

  /// No description provided for @settingsLogOutBody.
  ///
  /// In en, this message translates to:
  /// **'To sign back in, you\'ll need your phone number or email and your password.'**
  String get settingsLogOutBody;

  /// No description provided for @settingsLogOutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogOutAction;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile details, progress, streak and coins will be deleted for good. This can\'t be undone.'**
  String get settingsDeleteBody;

  /// No description provided for @settingsDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAction;

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

  /// No description provided for @studyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy a course to choose your lesson times'**
  String get studyEmptyTitle;

  /// No description provided for @studyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'After buying a course you\'ll choose the days and times that suit you, then we\'ll add you to a group with mentors.'**
  String get studyEmptyBody;

  /// No description provided for @studyBrowseCourses.
  ///
  /// In en, this message translates to:
  /// **'Browse courses'**
  String get studyBrowseCourses;

  /// No description provided for @studyJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join the group'**
  String get studyJoinGroup;

  /// No description provided for @studyMentors.
  ///
  /// In en, this message translates to:
  /// **'Mentors'**
  String get studyMentors;

  /// No description provided for @studyPrimaryMentor.
  ///
  /// In en, this message translates to:
  /// **'Lead mentor'**
  String get studyPrimaryMentor;

  /// No description provided for @studySupportMentor.
  ///
  /// In en, this message translates to:
  /// **'Support mentor'**
  String get studySupportMentor;

  /// No description provided for @studyMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} member} other{{count} members}}'**
  String studyMembers(int count);

  /// No description provided for @studyPickTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll join a group soon'**
  String get studyPickTitle;

  /// No description provided for @studyPickBody.
  ///
  /// In en, this message translates to:
  /// **'Choose {count} weekday times for your lessons'**
  String studyPickBody(int count);

  /// No description provided for @studyWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get studyWeekdays;

  /// No description provided for @studyTimeFor.
  ///
  /// In en, this message translates to:
  /// **'Time — {day}'**
  String studyTimeFor(String day);

  /// No description provided for @studyWeekdayLetters.
  ///
  /// In en, this message translates to:
  /// **'Mo,Tu,We,Th,Fr,Sa,Su'**
  String get studyWeekdayLetters;

  /// No description provided for @studyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm ({count}/{total})'**
  String studyConfirm(int count, int total);

  /// No description provided for @studyTooManySlots.
  ///
  /// In en, this message translates to:
  /// **'You can choose only {count} days — remove one first'**
  String studyTooManySlots(int count);

  /// No description provided for @studyRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent — we\'ll add you to a group soon'**
  String get studyRequestSent;

  /// No description provided for @studyMentorPending.
  ///
  /// In en, this message translates to:
  /// **'A mentor hasn\'t been assigned yet'**
  String get studyMentorPending;

  /// No description provided for @studyTaskTimes.
  ///
  /// In en, this message translates to:
  /// **'Task submission times'**
  String get studyTaskTimes;

  /// No description provided for @studyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your group'**
  String get studyLoadFailed;

  /// No description provided for @studyPullToRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again'**
  String get studyPullToRetry;

  /// No description provided for @mentorHeader.
  ///
  /// In en, this message translates to:
  /// **'Mentor'**
  String get mentorHeader;

  /// No description provided for @mentorReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student reviews'**
  String get mentorReviewsTitle;

  /// No description provided for @mentorNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get mentorNoReviews;

  /// No description provided for @mentorLeaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get mentorLeaveReview;

  /// No description provided for @mentorReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this mentor...'**
  String get mentorReviewHint;

  /// No description provided for @mentorReviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get mentorReviewSubmit;

  /// No description provided for @mentorReviewSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get mentorReviewSent;

  /// No description provided for @mentorReviewRatingRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get mentorReviewRatingRequired;

  /// No description provided for @purchaseHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase history'**
  String get purchaseHistoryTitle;

  /// No description provided for @purchaseHistoryPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get purchaseHistoryPayments;

  /// No description provided for @purchaseHistoryEnrollments.
  ///
  /// In en, this message translates to:
  /// **'Enrollments'**
  String get purchaseHistoryEnrollments;

  /// No description provided for @purchaseHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your purchase history'**
  String get purchaseHistoryLoadFailed;

  /// No description provided for @purchaseHistoryEmptyPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get purchaseHistoryEmptyPayments;

  /// No description provided for @purchaseHistoryEmptyEnrollments.
  ///
  /// In en, this message translates to:
  /// **'No enrollments yet'**
  String get purchaseHistoryEmptyEnrollments;

  /// No description provided for @purchaseHistoryStatusCreated.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get purchaseHistoryStatusCreated;

  /// No description provided for @purchaseHistoryStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get purchaseHistoryStatusPaid;

  /// No description provided for @purchaseHistoryStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get purchaseHistoryStatusCancelled;

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
  /// **'AI partner'**
  String get aiTitle;

  /// No description provided for @aiIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Live conversation with AI'**
  String get aiIntroTitle;

  /// No description provided for @aiIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the button and talk freely in English — the conversation runs in real time, just like a call.'**
  String get aiIntroBody;

  /// No description provided for @aiFeatureEndAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can end it whenever you like'**
  String get aiFeatureEndAnytime;

  /// No description provided for @aiFeatureLiveVoice.
  ///
  /// In en, this message translates to:
  /// **'A live voice conversation, in real time'**
  String get aiFeatureLiveVoice;

  /// No description provided for @aiFeatureNoScore.
  ///
  /// In en, this message translates to:
  /// **'No grades or points — just talk'**
  String get aiFeatureNoScore;

  /// No description provided for @aiMicNote.
  ///
  /// In en, this message translates to:
  /// **'The conversation needs access to your microphone.'**
  String get aiMicNote;

  /// No description provided for @aiEnd.
  ///
  /// In en, this message translates to:
  /// **'End conversation'**
  String get aiEnd;

  /// No description provided for @aiConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get aiConnecting;

  /// No description provided for @aiInCall.
  ///
  /// In en, this message translates to:
  /// **'Conversation in progress'**
  String get aiInCall;

  /// No description provided for @aiYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get aiYou;

  /// No description provided for @aiYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get aiYourTurn;

  /// No description provided for @aiMicOff.
  ///
  /// In en, this message translates to:
  /// **'Mic off'**
  String get aiMicOff;

  /// No description provided for @aiStatusListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get aiStatusListening;

  /// No description provided for @aiStatusThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get aiStatusThinking;

  /// No description provided for @aiStatusSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get aiStatusSpeaking;

  /// No description provided for @aiMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get aiMute;

  /// No description provided for @aiUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get aiUnmute;

  /// No description provided for @aiSoundOff.
  ///
  /// In en, this message translates to:
  /// **'Mute the AI\'s voice'**
  String get aiSoundOff;

  /// No description provided for @aiSoundOn.
  ///
  /// In en, this message translates to:
  /// **'Unmute the AI\'s voice'**
  String get aiSoundOn;

  /// No description provided for @aiAutoEndNote.
  ///
  /// In en, this message translates to:
  /// **'The conversation ends automatically after {minutes} minutes'**
  String aiAutoEndNote(int minutes);

  /// No description provided for @aiTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up — the conversation has ended'**
  String get aiTimeUp;

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

  /// No description provided for @roadmapStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get roadmapStart;

  /// No description provided for @roadmapLevelNumber.
  ///
  /// In en, this message translates to:
  /// **'Lv.{number}'**
  String roadmapLevelNumber(int number);

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

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is ready. Update now to enjoy the latest features.'**
  String get updateBody;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpEnterCode;

  /// No description provided for @registerPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get registerPersonalInfo;

  /// No description provided for @registerChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get registerChangePhoto;

  /// No description provided for @registerFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registerFirstName;

  /// No description provided for @registerFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get registerFirstNameHint;

  /// No description provided for @registerLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get registerLastName;

  /// No description provided for @registerLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get registerLastNameHint;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registerPasswordHint;

  /// No description provided for @registerGender.
  ///
  /// In en, this message translates to:
  /// **'Your gender'**
  String get registerGender;
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
