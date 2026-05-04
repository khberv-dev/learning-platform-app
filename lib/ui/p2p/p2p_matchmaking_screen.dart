import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/p2p/domain/entity/p2p_state.dart';
import 'package:student/core/p2p/presentation/p2p_controller.dart';
import 'package:student/ui/p2p/p2p_call_screen.dart';
import 'package:student/ui/p2p/widget/radar_pulse.dart';

class P2pMatchmakingScreen extends ConsumerStatefulWidget {
  static const path = '/p2p-matchmaking';

  const P2pMatchmakingScreen({super.key});

  @override
  ConsumerState<P2pMatchmakingScreen> createState() =>
      _P2pMatchmakingScreenState();
}

class _P2pMatchmakingScreenState extends ConsumerState<P2pMatchmakingScreen> {
  bool _navigatedToCall = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(p2pControllerProvider.notifier).findPartner();
    });
  }

  void _onCancel() {
    ref.read(p2pControllerProvider.notifier).cancel();
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<P2pState>(p2pControllerProvider, (prev, next) {
      if (!_navigatedToCall && next is P2pMatched) {
        _navigatedToCall = true;
        context.replace(P2pCallScreen.path);
      } else if (next is P2pError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
        if (context.canPop()) context.pop();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: _onCancel),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        RadarPulse(initials: '?'),
                        SizedBox(height: 24),
                        Text(
                          'Finding your match...',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Looking for someone at your level',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: _CancelButton(onTap: _onCancel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Speaking Partner',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
