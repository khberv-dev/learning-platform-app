import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/startup/language_screen.dart';
import 'package:student/ui/startup/no_connection_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const path = '/';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoAnimationController, titleAnimationController;
  late Animation<double> logoRotateAnimation,
      logoScaleAnimation,
      titleTranslateAnimation,
      titleOpacityAnimation;

  @override
  void initState() {
    super.initState();

    const logoAnimationDuration = Duration(seconds: 2);

    logoAnimationController = AnimationController(
      vsync: this,
      duration: logoAnimationDuration,
    );

    titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    );

    logoRotateAnimation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: logoAnimationController, curve: Curves.easeInOut),
    );

    logoScaleAnimation = Tween(begin: 8.0, end: 1.0).animate(
      CurvedAnimation(parent: logoAnimationController, curve: Curves.easeInOut),
    );

    titleTranslateAnimation = Tween(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: titleAnimationController, curve: Curves.easeOut),
    );

    titleOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: titleAnimationController, curve: Curves.easeOut),
    );

    logoAnimationController.forward();

    Future.delayed(logoAnimationDuration, () {
      titleAnimationController.forward();
    });

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Let the full splash animation play before navigating.
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final destination = await _destination();
    if (!mounted || destination == null) return;

    // A student who has never chosen a language picks one first; the picker
    // carries the destination on, so the detour costs them nothing.
    final hasLanguage = ref.read(localeControllerProvider) != null;
    context.go(hasLanguage ? destination : languageRouteFor(destination));
  }

  /// Where the student belongs, or null when the outcome is one the splash
  /// screen deliberately sits still on.
  Future<String?> _destination() async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (!mounted) return null;

    if (token == null) return OnboardingScreen.path;

    try {
      final user = await ref.read(useGetMeProvider).call();
      if (!mounted) return null;
      ref.read(currentUserProvider.notifier).state = user;
      return AppScreen.path;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final isServerError = status != null && status >= 500;
      final isNetworkError =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      return isServerError || isNetworkError ? NoConnectionScreen.path : null;
    } catch (_) {
      return LoginScreen.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: logoAnimationController,
              builder: (context, _) => Transform(
                alignment: AlignmentGeometry.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(logoRotateAnimation.value)
                  ..multiply(
                    Matrix4.diagonal3Values(
                      logoScaleAnimation.value,
                      logoScaleAnimation.value,
                      1,
                    ),
                  ),
                child: Image.asset('assets/images/brand.png', width: 150),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: titleAnimationController,
              builder: (context, _) => Opacity(
                opacity: titleOpacityAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, titleTranslateAnimation.value),
                  child: Text(
                    AppLocalizations.of(context).splashWelcome,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    logoAnimationController.dispose();
    titleAnimationController.dispose();
    super.dispose();
  }
}
