import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/main/app_screen.dart';

class NoConnectionScreen extends ConsumerStatefulWidget {
  static const path = '/no-connection';

  const NoConnectionScreen({super.key});

  @override
  ConsumerState<NoConnectionScreen> createState() => _NoConnectionScreenState();
}

class _NoConnectionScreenState extends ConsumerState<NoConnectionScreen> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    try {
      final user = await ref.read(useGetMeProvider).call();
      if (!mounted) return;
      ref.read(currentUserProvider.notifier).state = user;
      context.go(AppScreen.path);
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      if (status != null && status < 500) {
        context.go(LoginScreen.path);
      } else {
        setState(() => _isRetrying = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 40,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Connection',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unable to reach the server.\nCheck your connection and try again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isRetrying ? null : _retry,
                    child: _isRetrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Try Again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
