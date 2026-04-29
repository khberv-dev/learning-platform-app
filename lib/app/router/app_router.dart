import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/auth/otp_screen.dart';
import 'package:student/ui/auth/register_screen.dart';
import 'package:student/ui/courses/course_detail_screen.dart';
import 'package:student/ui/courses/lesson_screen.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/startup/no_connection_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';
import 'package:student/ui/startup/skill_level_quiz_screen.dart';
import 'package:student/ui/startup/splash_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';
import 'package:student/ui/startup/welcome_screen.dart';
import 'package:student/ui/tutors/tutor_profile_screen.dart';

final appRouterProvider = Provider((ref) => _appRouter);

final _appRouter = GoRouter(
  // initialLocation: AppScreen.path,
  routes: [
    GoRoute(path: SplashScreen.path, builder: (_, _) => SplashScreen()),
    GoRoute(
      path: NoConnectionScreen.path,
      builder: (_, _) => NoConnectionScreen(),
    ),
    GoRoute(path: OnboardingScreen.path, builder: (_, _) => OnboardingScreen()),
    GoRoute(path: WelcomeScreen.path, builder: (_, _) => WelcomeScreen()),
    GoRoute(path: SurveyScreen.path, builder: (_, _) => SurveyScreen()),
    GoRoute(
      path: SkillLevelQuizScreen.path,
      builder: (_, _) => SkillLevelQuizScreen(),
    ),
    GoRoute(path: RegisterScreen.path, builder: (_, _) => RegisterScreen()),
    GoRoute(path: OtpScreen.path, builder: (_, _) => OtpScreen()),
    GoRoute(path: LoginScreen.path, builder: (_, _) => LoginScreen()),
    GoRoute(path: AppScreen.path, builder: (_, _) => AppScreen()),
    GoRoute(
      path: CourseDetailScreen.path,
      builder: (_, state) => CourseDetailScreen(
        courseId: state.pathParameters['id']!,
        isOwned: state.uri.queryParameters['owned'] == 'true',
      ),
    ),
    GoRoute(
      path: TutorProfileScreen.path,
      builder: (_, state) =>
          TutorProfileScreen(tutorId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: LessonScreen.path,
      builder: (_, state) => LessonScreen(
        courseId: state.uri.queryParameters['courseId']!,
        unitIndex:
            int.tryParse(state.uri.queryParameters['unitIndex'] ?? '0') ?? 0,
        initialLessonIndex:
            int.tryParse(state.uri.queryParameters['lessonIndex'] ?? '0') ?? 0,
      ),
    ),
  ],
);
